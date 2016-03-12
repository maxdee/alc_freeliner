/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */



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
  public void apply(PGraphics _pg){
    // do something
  }

  public void setName(String _name){
    name = _name;
  }

  public boolean toggleLayer(){
    enable = !enable;
    return enable;
  }

  public void setEnable(boolean _b){
    enable = _b;
  }

//////////////////////

  public String getName(){
    return name;
  }

  public boolean useLayer(){
    return enable;
  }
}


/**
 * A buffer to render some stuff to.
 * Needs to be fixed for INVERTED_COLOR...
 */
class RenderLayer extends Layer{

  PGraphics canvas;

  public RenderLayer(){
    canvas = createGraphics(width, height, P2D);
    name = "DrawingLayer";
  }

  public void apply(PGraphics _pg){
    canvas.endDraw();
    if(!useLayer) return;
    _pg.image(canvas);
  }

  public PGraphics getCanvas(){
    canvas.beginDraw();
    canvas.clear();
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

  public PGraphics getCanvas(){
    canvas.beginDraw();
    canvas.fill(0, trailmix);
    canvas.noStroke();
    canvas.rect(0,0,width,height);
  }

  public int setTrails(int v){
    trailmix = numTweaker(v, trailmix);
    if(v == 255) trails = false;
    else trails = true;
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
    try { imageToDraw = loadImage("userdata/layer_image.png");}
    catch(Exception _e) {imageToDraw = null;}
  }

  public void apply(PGraphics _pg){
    if(maskImage == null) return;
    if(!useLayer) return;
    else _pg.image(maskImage, 0, 0);
  }

  // pg.endDraw() -> then this ?
  void makeMask(PImage _source){
    maskImage = _source.get();
    maskImage.loadPixels();
    for(int i = 0; i< width * height; i++){
      // check the green pixels.
      if(((maskImage.pixels[i] >> 8) & 0xFF) > 100) maskImage.pixels[i] = color(100, 0);
      else maskImage.pixels[i] = color(0,255);
    }
    maskImage.updatePixels();
    saveMask("userdata/mask_image.png"); // auto save mask
  }
}

/**
 * Take a image and make a mask where all the pixels with green go transparent, everything else black;
 * Needs to be fixed for INVERTED_COLOR...
 */
class MaskLayer extends Layer{

  PImage maskImage;

  public MaskLayer(){
    // try to load a mask if one is provided
    try { maskImage = loadImage("userdata/mask_image.png");}
    catch(Exception _e) {maskImage = null;}
  }

  public void apply(PGraphics _pg){
    if(maskImage == null) return;
    if(!useLayer) return;
    else _pg.image(maskImage, 0, 0);
  }

  // pg.endDraw() -> then this ?
  void makeMask(PImage _source){
    maskImage = _source.get();
    maskImage.loadPixels();
    for(int i = 0; i< width * height; i++){
      // check the green pixels.
      if(((maskImage.pixels[i] >> 8) & 0xFF) > 100) maskImage.pixels[i] = color(100, 0);
      else maskImage.pixels[i] = color(0,255);
    }
    maskImage.updatePixels();
    saveMask("userdata/mask_image.png"); // auto save mask
  }
}


/**
 * Saves frames to userdata/capture
 *
 */
class CaptureLayer extends Layer{
  int clipCount;
  int frameCount;

  public CaptureLayer(){
    name = "FrameSaver";
    enable = false;
  }

  public void apply(PGraphics _pg){
    String fn = String.format("%06d", frameCount);
    _pg.save("userdata/capture/clip_"+clipCount+"/frame-"+fn+".tif");
    frameCount++;
  }
}


/**
 * For fragment shaders!
 *
 */
class ShaderLayer extends Layer{
  PShader shader;
  String fileName;

  float[] uniforms;

  public FLShader(){
    shader = null;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5};
  }

  public void apply(PGraphics _pg){
    if(shader == null) return;
    passUniforms();
    try{_pg.shader(shader);}
    catch(RuntimeException _e){
      println("shader no good");
      _pg.resetShader();
    }
  }

  public void loadFile(String _file){
    fileName = _file;
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

  public void setUniforms(int _i, float _val){
    uniforms[_i % 4] = _val;
    valuesUpdated = true;
  }

  public void passUniforms(){
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
  }
}

class ResetShaderLayer extends Layer{
  public ResetShaderLayer(){}
  public apply(PGraphics _pg){
    _pg.resetShader();
  }
}
