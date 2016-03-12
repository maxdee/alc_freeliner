/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */


 // ADD TRANSLATION LAYER

/**
 * Something that acts on a PGraphics.
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */

class Layer implements FreelinerConfig{
  String name;
  boolean enabled = true;

  public Layer(){
    name = "LayerName";
  }

  // override
  public Layer apply(Layer _in){
    // _in.getCanvas(); and do something
    return _in;
  }

  // Basic layer has no PGraphics
  public PGraphics getCanvas(){
    return null;
  }
  // in subclasses getImage() will endDraw
  public PGraphics getImage(){
    return null;
  }
  public void beginDrawing(){}
  public void endDrawing(){}


  public void setName(String _name){
    name = _name;
  }

  public boolean toggleLayer(){
    setEnable(!enabled);
    return enabled;
  }

  public void setEnable(boolean _b){
    enabled = _b;
  }

  public String getName(){
    return name;
  }

  public boolean useLayer(){
    return enabled;
  }
}


/**
 * A buffer to render some stuff to.
 * Needs to be fixed for INVERTED_COLOR...
 */
class RenderLayer extends Layer{

  PGraphics canvas;
  boolean ended = true;

  public RenderLayer(){
    canvas = createGraphics(width, height, P2D);
    name = "DrawingLayer";
  }

  public void beginDrawing(){
    canvas.beginDraw();
    canvas.clear();
    ended = false;
    canvas.fill(200);
    canvas.stroke(200);
    canvas.text(this.name,100,(int)name.charAt(0));
  }

  public void endDrawing(){
    if(!ended) {
      canvas.endDraw();
      ended = true;
    }
  }

  public Layer apply(Layer _lr){
    if(!useLayer()) return _lr;
    if(_lr == null) {
      return this;
    }
    _lr.getCanvas().image(this.getImage(), 0, 0);
    return _lr;
  }

  public PGraphics getCanvas(){
    return canvas;
  }
  public PGraphics getImage(){
    endDrawing();
    return canvas;
  }
}

/**
 * Draws a big black square of various opacity.
 * Needs to be fixed for INVERTED_COLOR...
 */
class TracerLayer extends RenderLayer{

  int trailmix;

  public TracerLayer(){
    super();
    name = "TracerLayer";
    trailmix = 30;
  }

  public void beginDraw(){
    canvas.beginDraw();
    canvas.fill(BACKGROUND_COLOR, trailmix);
    canvas.stroke(BACKGROUND_COLOR, trailmix);
    canvas.strokeWeight(1);
    canvas.rect(0, 0, width, height);
    canvas.stroke(100);
    canvas.rect(200, 200, 100, 100);
  }

  public int setTrails(int v){
    trailmix = numTweaker(v, trailmix);
    if(v >= 253) enabled = false;
    else enabled = true;
    return trailmix;
  }
}

/**
 * Just draw a image, like a background Image to draw.
 *
 */
class ImageLayer extends Layer{

  PImage imageToDraw;

  public ImageLayer(){
    // try to load a mask if one is provided
    loadFile("userdata/layer_image.png");
    name = "ImageLayer";
  }

  public Layer apply(Layer _lr){
    if(imageToDraw == null) return _lr;
    if(!useLayer()) return _lr;
    _lr.getCanvas().image(imageToDraw, 0, 0);
    return _lr;
  }

  public void loadFile(String _file){
    try { imageToDraw = loadImage(_file);}
    catch(Exception _e) {imageToDraw = null;}
  }
}

/**
 * Take a image and make a mask where all the pixels with green go transparent, everything else black;
 * Needs to be fixed for INVERTED_COLOR...
 */
class MaskLayer extends ImageLayer{

  public MaskLayer(){
    // try to load a mask if one is provided
    loadFile("userdata/mask_image.png");
    name = "MaskLayer";
  }

  // pg.endDraw() -> then this ?
  public void makeMask(PGraphics _source){
    imageToDraw = _source.get();
    imageToDraw.loadPixels();
    int _grn = 0;
    for(int i = 0; i< width * height; i++){
      // check the green pixels.
      _grn = ((imageToDraw.pixels[i] >> 8) & 0xFF);
      if(_grn > 3) imageToDraw.pixels[i] = color(0, _grn);
      else imageToDraw.pixels[i] = color(100,255);
    }
    imageToDraw.updatePixels();
    saveFile("userdata/mask_image.png"); // auto save mask
  }

  public void saveFile(String _file){
    imageToDraw.save(_file);
  }
}

/**
 * Saves frames to userdata/capture
 *
 */
class CaptureLayer extends Layer{
  int clipCount = 0;
  int frameCount = 0;

  public CaptureLayer(){
    name = "FrameSaver";
    enabled = false;
  }

  public Layer apply(Layer _lr){
    if(!enabled) return _lr;
    String fn = String.format("%06d", frameCount);
    // might need to endDraw first?
    _lr.getCanvas().save("userdata/capture/clip_"+clipCount+"/frame-"+fn+".tif");
    frameCount++;
    return _lr;
  }

  public void setEnable(boolean _b){
    enabled = _b;
    if(enabled) {
      clipCount++;
      frameCount = 0;
    }
  }
}


/**
 * For fragment shaders!
 *
 */
class ShaderLayer extends RenderLayer{
  PShader shader;
  String fileName;

  // uniforms to control shader params
  float[] uniforms;

  public ShaderLayer(){
    super();
    enabled = true;
    name = "ShaderLayer";
    shader = null;
    uniforms = new float[]{0.8, 0.5, 0.5, 0.5};
  }


  public Layer apply(Layer _lr){
    if(shader == null) return _lr;
    if(!enabled) return _lr;
    try {
      canvas.shader(shader);
      passUniforms();
    }
    catch(RuntimeException _e){
      println("shader no good");
      return _lr;
    }
    canvas.image(_lr.getImage(),0,0);
    canvas.resetShader();
    return this;
  }

  public void loadFile(String _file){
    fileName = _file;
    //String[] _splt = split(fileName, '/');
    name = _file;//_splt[_splt.length];
    reloadShader();
  }

  public void reloadShader(){
    try{
      shader = loadShader(fileName);
    }
    catch(Exception _e){
      println("Could not load shader... ");
      println(_e);
      shader = null;
    }
  }

  public boolean isNull(){
    return (shader == null);
  }

  public void setUniforms(int _i, float _val){
    uniforms[_i % 4] = _val;
  }

  public void passUniforms(){
    if(shader == null) return;
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
  }
}
