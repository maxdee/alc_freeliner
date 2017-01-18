/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */

import processing.video.*;
import java.util.Date;
 // ADD TRANSLATION LAYER
// add layer opacity!!

/**
* Something that acts on a PGraphics.
* Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
*/
class Layer extends Mode{
  String id;
  String filename;
  boolean enabled;
  PGraphics canvas;
  ArrayList<String> commandList;
  String[] options = {"none"};
  String selectedOption = "none";
  String command = "none"; // allows to execute commands :)
  boolean cmdFlag;

  public Layer(){
    name = "basicLayer";
    id = name;
    description = "a basic layer that does not do anything";
    commandList = new ArrayList<String>();
    commandList.add("enable (-3|0|1)");
    commandList.add("setName layerName");
    enabled = true;
    canvas = null;
    filename = "none";
    selectedOption = "none";
  }

  /**
   * implement how the options should be used in a layer.
   */
  public void selectOption(String _opt){
    selectedOption = _opt;
  }

  public String[] getOptions(){
    return options;
  }

  public void setOptions(String[] _opt){
    options = _opt;
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
      if(_args[2].equals("load")) loadFile(_args[3]);
      else if(_args[2].equals("enable")) setEnable(stringInt(_args[3]));
      else if(_args[2].equals("name")) setName(_args[3]);
      else if(_args[2].equals("option")) selectOption(_args[3]);
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

  public String getSelectedOption(){
    return selectedOption;
  }

  public Layer setCanvas(PGraphics _pg){
    canvas = _pg;
    return this;
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
  public Layer setID(String _id){
    id = _id;
    return this;
  }

  public void setLayer(Layer _lyr){
  }

  /**
   * Whether of not the layer is used.
   * @return Boolean
   */
  public boolean useLayer(){
   return enabled;
  }

  public String getID(){
    return id;
  }

  public String getCMD(){
    return command;
  }

  public boolean hasCMD(){
    if(cmdFlag){
      cmdFlag = false;
      return true;
    }
    return false;
  }

  public void runCMD(String _s){
    command = _s;
    cmdFlag = true;
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
class ContainerLayer extends Layer{
  Layer containedLayer = null;
  public ContainerLayer(){
    name = "containerLayer";
    description = "a layer that contains an other";
  }

  public void setLayer(Layer _lyr){
    containedLayer = _lyr;
  }

  public Layer setID(String _id){
    this.id = _id;
    return this;
  }

  public String getID(){
    return this.id;
  }

  /////////// the rest is from the containedLayer
  public void selectOption(String _opt){
    if (containedLayer != null) containedLayer.selectOption(_opt);
  }

  public String[] getOptions(){
    if (containedLayer != null) return containedLayer.getOptions();
    else return null;
  }

  public PGraphics apply(PGraphics _pg){
    if (containedLayer != null) return containedLayer.apply(_pg);
    else return null;
  }

  public void beginDrawing(){
    if (containedLayer != null) containedLayer.beginDrawing();
  }

  public void endDrawing(){
    if (containedLayer != null) containedLayer.endDrawing();
  }

  public boolean parseCMD(String[] _args){
   if (containedLayer != null) return containedLayer.parseCMD(_args);
   else return false;
  }

  public Layer loadFile(String _file){
   if (containedLayer != null) return containedLayer.loadFile(_file);
   else return this;
  }

  public PGraphics getCanvas(){
   if (containedLayer != null) return containedLayer.getCanvas();
   else return null;
  }

  public String getFilename(){
   if (containedLayer != null) return containedLayer.getFilename();
   else return "none";
  }

  public String getSelectedOption(){
   if (containedLayer != null) return containedLayer.getSelectedOption();
   else return "none";
  }

  public Layer setCanvas(PGraphics _pg){
   if (containedLayer != null) return containedLayer.setCanvas(_pg);
   else return this;
  }

  public void setEnable(int _v){
   if (containedLayer != null) containedLayer.setEnable(_v);
  }

  public boolean useLayer(){
   if (containedLayer != null) return containedLayer.useLayer();
   else return false;
  }

  public ArrayList<String> getCMDList(){
    if (containedLayer != null) return containedLayer.getCMDList();
    else return null;
  }
}



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
    name = "CanvasLayer";
    id = name;
    description = "a layer with a buffer";
  }

  /**
   * This layer's PG gets applied onto the incoming PG
   */
  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    else if(_pg == null) return canvas;
    else if(canvas == null) return _pg;
    _pg.beginDraw();
    _pg.image(canvas,0,0);
    _pg.endDraw();
    return _pg;
  }
}



/**
 * Simple layer twith a real PGraphics
 */
class GuiLayer extends Layer{
  /**
   * onlyconstructor is overiden
   */
  public GuiLayer(PGraphics _pg){
    canvas = _pg;
    enabled = true;
    name = "GuiLayer";
    id = name;
    description = "A layer for the graphical user interface";
  }
  /**
   * This layer's PG gets applied onto the incoming PG
   */
  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    else if(_pg == null) return canvas;
    else if(canvas == null) return _pg;
    _pg.beginDraw();
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
    name = "renderLayer";
    id = name;
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
    name = "tracerLayer";
    id = name;
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
 * Layer that should reference the mergeCanvas.
 */
class MergeLayer extends Layer{
  int blendMode = LIGHTEST;
  public MergeLayer(){
    super();
    name = "mergeLayer";
    id = name;
    description = "used to merge layers together";
    String[] _opt = {"blend","add","subtract","darkest","lightest","difference","exclusion","multiply","screen","replace"};
    options = _opt;
  }

  public PGraphics apply(PGraphics _pg){
    if(_pg == null) return null;
    if(!useLayer()) return _pg;
    canvas.blendMode(blendMode);
    canvas.image(_pg,0,0);
    return null;
  }

  public void selectOption(String _opt){
    selectedOption = _opt;
    switch(_opt){
      case "blend":
        blendMode = BLEND;
        break;
      case "add":
        blendMode = ADD;
        break;
      case "subtract":
        blendMode = SUBTRACT;
        break;
      case "darkest":
        blendMode = DARKEST;
        break;
      case "lightest":
        blendMode = LIGHTEST;
        break;
      case "difference":
        blendMode = DIFFERENCE;
        break;
      case "exclusion":
        blendMode = EXCLUSION;
        break;
      case "multiply":
        blendMode = MULTIPLY;
        break;
      case "screen":
        blendMode = SCREEN;
        break;
      case "replace":
        blendMode = REPLACE;
        break;
      default:
        blendMode = BLEND;
        break;
    }
  }
}

/**
 * Layer that outputs the rendering. maybe cannot be deleted...
 */
class MergeOutput extends Layer{
  public MergeOutput(){
    super();
    name = "mergeOutput";
    id = name;
    description = "outputs the merged stuff";
  }

  public PGraphics apply(PGraphics _pg){
    if(!useLayer()) return _pg;
    canvas.endDraw();
    canvas.blendMode(ADD);
    return canvas;
  }
}

/**
 * Layer that outputs the rendering. maybe cannot be deleted...
 */
class OutputLayer extends Layer{
  public OutputLayer(){
    super();
    name = "outputLayer";
    id = name;
    description = "output layer that goes to screen";
  }

  public PGraphics apply(PGraphics _pg){
    // if(!useLayer()) return _pg;
    if(_pg != null){
      image(_pg, 0, 0);
    }
    return null;
  }
}



/**
 * For fragment shaders!
 */
class ShaderLayer extends RenderLayer{//CanvasLayer{
  PShader shader;
  String fileName;
  PVector center;// implements this (connect to some sort of geometry thingy)
  // uniforms to control shader params
  float[] uniforms;
  Synchroniser sync;

  public ShaderLayer(Synchroniser _s){
    super();
    sync = _s;
    commandList.add("layer name uniforms 0 0.5");
    commandList.add("layer name loadFile fragShader.glsl");
    enabled = true;
    name = "ShaderLayer";
    id = name;
    description = "a layer with a fragment shader";

    shader = null;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5};
  }

  // Overrirde
  public void setEnable(int _v){
    super.setEnable(_v);
    reloadShader();
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

  public void selectOption(String _opt){
    selectedOption = _opt;
    loadFile(_opt);
  }

  public Layer loadFile(String _file){
    fileName = _file;
    reloadShader();
    return this;
  }

  public void reloadShader(){
    try{
      shader = loadShader("userdata/"+fileName);
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
    shader.set("time", sync.getUnit());
    shader.set("res", float(width), float(height));
  }
}

// only going to work with P3D :/
// class VertexShaderLayer extends ShaderLayer{
//   public VertexShaderLayer(){
//     super();
//     name = "VertexShaderLayer";
//     id = name;
//     description = "a layer which can be rendered to and has a vertex shader";
//     loadFile("aVertexShader.glsl");
//   }
//
//   public void beginDrawing(){
//     if(canvas != null){
//       canvas.beginDraw();
//       canvas.clear();
//       try {
//         canvas.shader(shader);
//       }
//       catch(RuntimeException _e){
//         println("vertex shader no good");
//         canvas.resetShader();
//       }
//     }
//   }
//
//   public PGraphics apply(PGraphics _pg){
//     if(!enabled) return _pg;
//     if(_pg == null) return canvas;
//     _pg.beginDraw();
//     _pg.clear();
//     _pg.image(canvas,0,0);
//     _pg.endDraw();
//     return _pg;
//   }
//
//   public void reloadShader(){
//     try{
//       shader = loadShader( sketchPath()+"/data/userdata/defaultFrag.glsl", sketchPath()+"/data/userdata/"+fileName);
//       println("Loaded vertex shader "+fileName);
//     }
//     catch(Exception _e){
//       println("Could not load vertex shader... "+fileName);
//       println(_e);
//       shader = null;
//     }
//   }
// }


/**
 * Just draw a image, like a background Image to draw.
 *
 */
class ImageLayer extends CanvasLayer{

  PImage imageToDraw;

  public ImageLayer(){
    super();
    commandList.add("layer name loadFile .jpg .png .???");
    name = "ImageLayer";
    id = name;
    description = "put an image as a layer";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(imageToDraw == null) return _pg;
    if(_pg == null) return canvas; // maybe cast image to a PG???
    _pg.beginDraw();
    _pg.image(imageToDraw,0,0);
    _pg.endDraw();
    return _pg;
  }

  public void selectOption(String _opt){
    selectedOption = _opt;
    loadFile(_opt);
    if(imageToDraw != null){
      canvas.beginDraw();
      canvas.image(imageToDraw,0,0);
      canvas.endDraw();
    }
  }

  public Layer loadFile(String _file){
    filename = _file;
    try { imageToDraw = loadImage("userdata/"+_file);}
    catch(Exception _e) {imageToDraw = null;}
    return this;
  }
}

/**
 * Display video from devices like a webcam or capture card
 */
class CaptureLayer extends CanvasLayer{
  Capture cam;
  PApplet applet;

  public CaptureLayer(PApplet _ap){
    super();
    commandList.add("layer name loadFile .jpg .png .???");
    name = "CaptureLayer";
    id = name;
    description = "webcams and capture cards";
    applet = _ap;
    options = Capture.list();
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(cam == null) return _pg;
    if(cam.available()) cam.read();
    if(_pg == null) {
      canvas.beginDraw();
      canvas.image(cam,0,0,width,height);
      canvas.endDraw();
      return canvas;
    }
    else {
      _pg.beginDraw();
      _pg.image(cam,0,0,width,height);
      _pg.endDraw();
      return _pg;
    }
  }

  public void selectOption(String _opt){
    selectedOption = _opt;
    if(cam != null) cam.stop();
    cam = new Capture(applet, _opt);
    cam.start();
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
    name = "MaskLayer";
    id = name;
    description = "a configurable mask layer";
  }

  public void selectOption(String _opt){
    if(_opt.equals("MAKE")) maskFlag = true;
    else {
      selectedOption = _opt;
      loadFile(_opt);
    }
  }

  public void setOptions(String[] _opts){
    options = new String[_opts.length+1];
    for(int i = 0; i < _opts.length; i++){
      options[i] = _opts[i];
    }
    options[_opts.length] = "MAKE";
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


/**
 * Saves frames to userdata/capture
 *
 */
class ScreenshotLayer extends Layer{
  int clipCount;
  int frameCount;
  Date date;

  public ScreenshotLayer(){
    name = "ScreenshotLayer";
    description = "save screenshots, in singleImage mode enabling the layer will take a single screenshot, in imageSequence enabling the layer will begin and end the sequence";
    id = name;
    enabled = false;
    String[] _op = {"singleImage", "imageSequence"};
    setOptions(_op);
    selectedOption = "singleImage";
    date = new Date();
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    if(selectedOption.equals("singleImage")){
      _pg.save( sketchPath()+"/data/userdata/screenshots/freeliner_"+date.getTime()+".png");
      enabled = false;
    }
    else {
      String fn = String.format("%06d", frameCount);
      _pg.save( sketchPath()+"/data/userdata/capture/clip_"+clipCount+"/frame-"+fn+".tif");
      frameCount++;
    }
    return _pg;
  }

  /**
   * Set or toggle the enabled boolean
   * @param String name
   */
  public void setEnable(int _v){
    if(_v == -3) enabled = !enabled;
    else if(_v == 0) enabled = false;
    else if(_v == 1) enabled = true;
    if(enabled && selectedOption.equals("imageSequence")) {
      clipCount++;
      frameCount = 0;
      runCMD("seq steady 1");
    }
    else if(!enabled) runCMD("seq steady 0");
  }
}



// Layer that manages a DMX or stuff.

class FixtureLayer extends Layer{

  FancyFixtures fixtures;

  public FixtureLayer(PApplet _pa){
    super();
    commandList.add("layer name loadFile .xml");
    commandList.add("setchan 0 3 255");
    name = "FixtureLayer";
    id = name;
    description = "A layer that control DMX and whatnot.";
    fixtures = new FancyFixtures(_pa);
  }

  public PGraphics apply(PGraphics _pg){
    if(_pg == null) return null; //
    fixtures.update(_pg); //
    if(enabled){
      _pg.beginDraw();
      fixtures.drawMap(_pg);
      _pg.endDraw();
    }
    return _pg;
  }

  public void selectOption(String _opt){
    selectedOption = _opt;
    loadFile(_opt);
  }

  public Layer loadFile(String _file){
    filename = _file;
    fixtures.loadFile(_file);
    return this;
  }

  /**
   * Override parent's
   */
  public boolean parseCMD(String[] _args){
    boolean _parsed = super.parseCMD(_args);
    if(_parsed) return true;
    else if(_args.length > 2) {
      if(_args[2].equals("setchan")) setChanCMD(_args);
      else return false;
    }
    else return false;
    return true;
  }

  public void setChanCMD(String[] _args){
    if(_args.length < 5) return;
    else {
    //   int _ind = stringInt(_args[3]);
      int _chan = stringInt(_args[3]);
      int _val = stringInt(_args[4]);
      fixtures.setChannel(_chan, _val);
    //   Fixture _fix = fixtures.getFixture(_ind);
    //   if(_fix != null) _fix.setChannel(_chan, _val);
    }
  }
}
