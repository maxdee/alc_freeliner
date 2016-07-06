/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */


 // ADD TRANSLATION LAYER
// add layer opacity!!

/**
* Something that acts on a PGraphics.
* Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
*/
class Layer implements FreelinerConfig{
  String type;
  String name;

  String description;
  String filename;
  boolean enabled;
  PGraphics canvas;
  ArrayList<String> commandList;

  public Layer(){
    type = "basicLayer";
    name = type;
    description = "a basic layer that does not do anything";
    commandList = new ArrayList<String>();
    commandList.add("enable (-3|0|1)");
    commandList.add("setName layerName");
    enabled = true;
    canvas = null;
    filename = "none";
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
   * Since each layer are quite specific and require various inputs,
   * layers are just going to have to parse the CMDs themselve.
   * overiding this should include super
   * @param String[] arguments
   * @return boolean weather or not the CMD was parsed.
   */
  public boolean parseCMD(String[] _args){
    if(_args.length > 3){
      if(_args[2].equals("loadFile")) loadFile(_args[3]);
      else if(_args[2].equals("enable")) setEnable(stringInt(_args[3]));
      else if(_args[2].equals("setName")) setName(_args[3]);
      else return false;
      return true;
    }
    else return false;
  }

  /**
   * Load a file, used with shaders masks images...
   * @param String filename
   */
  public Layer loadFile(String _file){
    filename = _file;
    return this;
  }

  /**
   * Get the canvas
   * @return PGraphics
   */
  public PGraphics getCanvas(){
   return canvas;
  }

  public String getFilename(){
    return filename;
  }

  public String getType(){
    return type;
  }

  /**
   * Set or toggle the enabled boolean
   * @param String name
   */
  public void setEnable(int _v){
   if(_v == -3) enabled = !enabled;
   else if(_v == 0) enabled = false;
   else if(_v == 1) enabled = true;
  }

  /**
   * Set the name of the layer, like "shader fx.glsl"
   * @param String name
   */
  public Layer setName(String _n){
   name = _n;
   return this;
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

  /**
   * Get layer description.
   * @return String description
   */
  public String getDescription(){
   return description;
  }

  public ArrayList<String> getCMDList(){
   return commandList;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    subaclasses
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * Simple layer twith a real PGraphics
 */
class CanvasLayer extends Layer{
  /**
   * Actualy make a PGraphics.
   */
  public CanvasLayer(){
    canvas = createGraphics(width,height,P2D);
    canvas.beginDraw();
    canvas.background(0);
    canvas.endDraw();
    enabled = true;
    type = "CanvasLayer";
    name = type;
    description = "a layer with a buffer";
  }

  /**
   * This layer's PG gets applied onto the incoming PG
   */
  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(_pg == null) return canvas;
    _pg.beginDraw();
    _pg.clear();
    _pg.image(canvas,0,0);
    _pg.endDraw();
    return _pg;
   }
 }

/**
 * Simple layer that can be drawn on by the rendering system.
 */
class RenderLayer extends CanvasLayer{
  public RenderLayer(){
    super();
    enabled = true;
    type = "RenderLayer";
    name = type;
    description = "a layer that freeliner renders onto, set a template's layer with [p]";
  }
 }

/**
 * Tracer layer
 */
class TracerLayer extends RenderLayer{
  int trailmix = 30;
  public TracerLayer(){
    super();
    commandList.add("layer name setTracers 30");
    type = "tracerLayer";
    name = type;
    description = "renderLayer with tracers, set a template's layer with [p]";
  }

  /**
   * Override parent's
   */
  public boolean parseCMD(String[] _args){
    boolean _parsed = super.parseCMD(_args);
    if(_parsed) return true;
    else if(_args.length > 3) {
      if(_args[2].equals("setTracers")) setTrails(stringInt(_args[3]), 255);
      else return false;
    }
    else return false;
    return true;
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
    if(_v == -42) _v = trailmix;
    trailmix = numTweaker(_v, trailmix);
    if(trailmix >= _max) trailmix = _max - 1;
    return trailmix;
  }

}

/**
 * Layer to merge graphics down. should only be one of these
 */
class MergeLayer extends CanvasLayer{
  public MergeLayer(){
    super();
    type = "MergeLayer";
    name = type;
    description = "used to merge layers together";
  }

  // set canvas method ?
  // setBlend ?

  public PGraphics apply(PGraphics _pg){
    if(_pg == null) return null;
    canvas.blendMode(LIGHTEST);
    canvas.image(_pg,0,0);
    return null;
  }
}

/**
 * For fragment shaders!
 */
class ShaderLayer extends CanvasLayer{
  PShader shader;
  String fileName;
  PVector center;// implements this
  // uniforms to control shader params
  float[] uniforms;

  public ShaderLayer(){
    super();
    commandList.add("layer name uniforms 0 0.5");
    commandList.add("layer name loadFile fragShader.glsl");
    enabled = true;
    type = "ShaderLayer";
    name = type;
    description = "a layer with a fragment shader";

    shader = null;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5};
  }


  public void beginDrawing(){

  }

  /**
   * Override parent's
   */
  public boolean parseCMD(String[] _args){
    boolean _parsed = super.parseCMD(_args);
    if(_parsed) return true;
    else if(_args.length > 4) {
      if(_args[2].equals("uniforms")){
        setUniforms(stringInt(_args[3]), stringFloat(_args[4]));
      }
    }
    else return false;
    return true;
  }

  public PGraphics apply(PGraphics _pg){
    if(shader == null) return _pg;
    if(!enabled) return _pg;
    if(_pg == null) return null;

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

  public Layer loadFile(String _file){
    fileName = _file;
    reloadShader();
    return this;
  }

  public void reloadShader(){
    try{
      shader = loadShader(sketchPath()+"/data/shaders/"+fileName);
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
    uniforms[_i % 8] = _val;
  }

  public void passUniforms(){
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
    shader.set("u5", uniforms[4]);
    shader.set("u6", uniforms[5]);
    shader.set("u7", uniforms[6]);
    shader.set("u8", uniforms[7]);
  }
}


/**
 * Just draw a image, like a background Image to draw.
 *
 */
class ImageLayer extends Layer{

  PImage imageToDraw;

  public ImageLayer(){
    super();
    commandList.add("layer name loadFile .jpg .png .???");
    // try to load a mask if one is provided
    loadFile(sketchPath()+"/data/userdata/layer_image.png");
    type = "ImageLayer";
    name = type;
    description = "put an image as a layer";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(imageToDraw == null) return _pg;
    if(_pg == null) return null; // maybe cast image to a PG???
    _pg.beginDraw();
    _pg.image(imageToDraw,0,0);
    _pg.endDraw();
    return _pg;
  }

  public Layer loadFile(String _file){
    filename = _file;
    try { imageToDraw = loadImage(_file);}
    catch(Exception _e) {imageToDraw = null;}
    return this;
  }
}

/**
 * Take a image and make a mask where all the pixels with green go transparent, everything else black;
 * Needs to be fixed for INVERTED_COLOR...
 */
class MaskLayer extends ImageLayer{
  boolean maskFlag = false;
  public MaskLayer(){
    super();
    commandList.add("layer name loadFile mask.png");
    commandList.add("layer name makeMask");
    // try to load a mask if one is provided
    //loadFile("userdata/mask_image.png");
    type = "MaskLayer";
    name = type;
    description = "a configurable mask layer";
  }

  /**
   * Override parent's
   */
  public boolean parseCMD(String[] _args){
    boolean _parsed = super.parseCMD(_args);
    if(_parsed) return true;
    else if(_args.length > 2) {
      if(_args[2].equals("makeMask")) maskFlag = true;
      else return false;
    }
    else return false;
    return true;
  }

  // pg.endDraw() -> then this ?
  public void makeMask(PGraphics _source){
    imageToDraw = _source.get();
    imageToDraw.loadPixels();
    int _grn = 0;
    for(int i = 0; i< width * height; i++){
      // check the green pixels.
      _grn = ((imageToDraw.pixels[i] >> 8) & 0xFF);
      if(_grn > 3) imageToDraw.pixels[i] = color(0, 255-_grn);
      else imageToDraw.pixels[i] = color(0,255);
    }
    imageToDraw.updatePixels();
    saveFile(sketchPath()+"/data/userdata/mask_image.png"); // auto save mask
  }

  public void saveFile(String _file){
    imageToDraw.save(_file);
  }

  public boolean checkMakeMask(){
    if(maskFlag) {
      maskFlag = false;
      return true;
    }
    else return false;
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
//     type = "FrameSaver";
//     name = type;
      // enabled = false;
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
