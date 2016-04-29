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
  boolean enabled;
  PGraphics canvas;

  public Layer(){
   name = "basicLayer";
   enabled = true;
   canvas = null;
  }

 /**
  * The apply method takes and resturns a PGraphics.
  * @param PGraphics source
  * @return PGraphics output
  */
  public PGraphics apply(PGraphics _pg){
   return _pg;
  }

  /**
   * Default operation for beginDrawing
   */
  public void beginDrawing(){
    if(canvas != null){
      canvas.beginDraw();
      canvas.clear();
    }
  }

  /**
   * Default operation for endDrawing
   */
  public void endDrawing(){
   if(canvas != null) canvas.endDraw();
  }

  /**
   * Load a file, used with shaders masks images...
   * @param String filename
   */
  public void loadFile(String _file){}

  /**
   * Get the canvas
   * @return PGraphics
   */
  public PGraphics getCanvas(){
   return canvas;
  }

  /**
   * Set the name of the layer, like "shader fx.glsl"
   * @param String name
   */
  public void setName(String _n){
   name = _n;
  }

  /**
   * Whether of not the layer is used.
   * @return Boolean
   */
  public boolean useLayer(){
   return enabled;
  }

  /**
   * Get layer name.
   * @return String name
   */
  public String getName(){
   return name;
  }
}

/**
 * Simple layer that can be drawn on by the rendering system.
 */
class RenderLayer extends Layer{
  /**
   * Actualy make a PGraphics.
   */
  public RenderLayer(){
    canvas = createGraphics(width,height,P2D);
    canvas.beginDraw();
    canvas.background(0);
    canvas.endDraw();
    enabled = true;
    name = "RenderLayer";
  }

  /**
   * This layer's PG gets applied onto the incoming PG
   */
  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(_pg == null) return canvas;
    _pg.beginDraw();
    _pg.image(canvas,0,0);
    _pg.endDraw();
    return _pg;
   }
 }

/**
 * Tracer layer
 */
class TracerLayer extends RenderLayer{
  int trailmix = 30;
  public TracerLayer(){
    super();
  }
  /**
   * Override parent's beginDrawing to draw a transparent background.
   */
  public void beginDrawing(){
    if(canvas != null){
      canvas.beginDraw();
      canvas.fill(BACKGROUND_COLOR, trailmix);
      canvas.stroke(BACKGROUND_COLOR, trailmix);
      canvas.stroke(10);
      canvas.noStroke();
      canvas.rect(0,0,width,height);
    }
  }
  public int setTrails(int _v, int _max){
    trailmix = numTweaker(_v, trailmix);
    if(trailmix >= _max) trailmix = _max - 1;
    return trailmix;
  }
}

/**
 * Layer to merge graphics down. should only be one of these
 */
class MergeLayer extends RenderLayer{
  public MergeLayer(){
    super();
    name = "MergeLayer";
  }

  public PGraphics apply(PGraphics _pg){
    // canvas.blendMode(LIGHTEST);
    if(_pg == null) return null;
    canvas.image(_pg,0,0);
    return null;
  }

  public void beginDrawing(){
   if(canvas != null){
     canvas.beginDraw();
     canvas.background(BACKGROUND_COLOR);
   }
  }
}

/**
 * For fragment shaders!
 */
class ShaderLayer extends RenderLayer{
  PShader shader;
  String fileName;

  // uniforms to control shader params
  float[] uniforms;

  public ShaderLayer(){
    enabled = true;
    name = "ShaderLayer";
    shader = null;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5};
  }

  public PGraphics apply(PGraphics _pg){
    if(shader == null) return _pg;
    if(!enabled) return _pg;
    try {
      canvas.shader(shader);
    }
    catch(RuntimeException _e){
      println("shader no good");
      canvas.resetShader();
      return _pg;
    }
    passUniforms();
    canvas.beginDraw();
    canvas.image(_pg,0,0);
    canvas.endDraw();
    canvas.resetShader();
    return canvas;
  }

  public void loadFile(String _file){
    fileName = _file;
    name = _file;//_splt[_splt.length];
    reloadShader();
  }

  public void reloadShader(){
    try{
      shader = loadShader(fileName);
      println("Loaded shader "+fileName);
    }
    catch(Exception _e){
      println("Could not load shader... "+fileName);
      println(_e);
      shader = null;
    }
  }

  public boolean isNull(){
    return (shader == null);
  }

  public void setUniforms(int _i, float _val){
    if(_i < 0) return;
    uniforms[_i % 4] = _val;
  }

  public void passUniforms(){
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
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

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(imageToDraw == null) return _pg;
    if(_pg == null) return null;
    _pg.beginDraw();
    _pg.image(imageToDraw,0,0);
    _pg.endDraw();
    return _pg;
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
    //loadFile("userdata/mask_image.png");
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
      else imageToDraw.pixels[i] = color(0,255);
    }
    imageToDraw.updatePixels();
    saveFile("userdata/mask_image.png"); // auto save mask
  }

  public void saveFile(String _file){
    imageToDraw.save(_file);
  }
}

// /**
//  * Saves frames to userdata/capture
//  *
//  */
// class CaptureLayer extends Layer{
//   int clipCount = 0;
//   int frameCount = 0;
//
//   public CaptureLayer(){
//     name = "FrameSaver";
//     enabled = false;
//   }
//
//   public Layer apply(Layer _lr){
//     if(!enabled) return _lr;
//     String fn = String.format("%06d", frameCount);
//     // might need to endDraw first?
//     _lr.getCanvas().save("userdata/capture/clip_"+clipCount+"/frame-"+fn+".tif");
//     frameCount++;
//     return _lr;
//   }
//
//   public void setEnable(boolean _b){
//     enabled = _b;
//     if(enabled) {
//       clipCount++;
//       frameCount = 0;
//     }
//   }
// }
