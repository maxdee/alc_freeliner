/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-01-22
 */
import java.util.Collections;

 /**
  * Manage the drawing buffer.
  * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
  */
abstract class CanvasManager implements FreelinerConfig{
  // Template renderer needed to do the rendering
  TemplateRenderer templateRenderer;
  // boolean makeMaskFlag = false;


  //  abstract methods
  abstract void render(ArrayList<RenderableTemplate> _toRender);
  abstract PGraphics getCanvas();
  // concrete methods?
  public void setUniforms(int _i, float _v){}
  public void reloadShader(){}
  public void loadShader(int _n){}
  public void loadMask(String _file){}
  public void generateMask(){}


  public int setTrails(int _t, int _max){ return 0;}

  // implemented methods
  public void inject(TemplateRenderer _tr){
    templateRenderer = _tr;
  }
  // no commands available
  public boolean parseCMD(String[] _args){ return false; }
  public String getLayerInfo(){return "none";}
}

/**
 * Simple CanvasManager subclass.
 * Lightest possible for faster performance on older hardware
 * AKA classic mode.
 */
class ClassicCanvasManager extends CanvasManager{
  TracerLayer tracerLayer;
  public ClassicCanvasManager(){
    tracerLayer = new TracerLayer();
  }

  public void render(ArrayList<RenderableTemplate> _toRender){
    tracerLayer.beginDrawing();
    for(RenderableTemplate _rt : _toRender)
      templateRenderer.render(_rt, tracerLayer.getCanvas());

    tracerLayer.endDrawing();
    image(tracerLayer.getCanvas(),0,0);
  }

  // unfortunatly for LEDs wont get the shader effects...
  public PGraphics getCanvas(){
    return tracerLayer.getCanvas();
  }

  public int setTrails(int _t, int _max){
    return tracerLayer.setTrails(_t, _max);
  }
}

/**
 * Customizable rendering layer system
 * AKA custom deluxe
 */
class LayeredCanvasManager extends CanvasManager{
  // all of the layers?
  ArrayList<Layer> layers;
  // layers that can be drawn on
  ArrayList<RenderLayer> renderLayers;

  MergeLayer mergeLayer;
  // MaskLayer maskLayer;
  // TracerLayer tracerLayer;
  // ShaderLayer shaderLayer;
  // ShaderLayer shaderTwo;


  String[] shaderFiles = {"fragZero.glsl", "fragOne.glsl", "fragTwo.glsl", "fragThree.glsl",};

  public LayeredCanvasManager(){
    layers = new ArrayList();
    renderLayers = new ArrayList();
    mergeLayer = new MergeLayer();

    addLayer(new TracerLayer()).setID("tracerOne");
    addLayer(new ShaderLayer()).setID("firstShader").loadFile("fragZero.glsl");
    // addLayer(new ShaderLayer()).setID("secondShader").loadFile("fragTwo.glsl");
    addLayer(mergeLayer);

    addLayer(new RenderLayer()).setID("untraced");
    addLayer(new ShaderLayer()).setID("thirdShader").loadFile("fragTwo.glsl");
    addLayer(new ShaderLayer()).setID("fourthShader").loadFile("fragTwo.glsl");

    // addLayer(new MaskLayer());
    addLayer(mergeLayer);

    addLayer(new RenderLayer()).setID("untraced2");
    addLayer(mergeLayer);
    // loadShader(0);

    printLayers();
  }

  public int setTrails(int _t, int _max){
    int _ret = 0;
    for(Layer _lyr : layers)
      if(_lyr instanceof TracerLayer)
        _ret = ((TracerLayer)_lyr).setTrails(_t, _max);
    return _ret;
  }

  public Layer addLayer(Layer _lr){
    layers.add(_lr);
    if(_lr instanceof RenderLayer)
      renderLayers.add((RenderLayer)_lr);
    return _lr;
  }
  int rtest = 0;
  /**
   * Begin redering process. Make sure to end it with endRender();
   */
  public void render(ArrayList<RenderableTemplate> _toRender){
    int _index = 0;
    for(Layer _rl : renderLayers){
      _rl.beginDrawing();
      for(RenderableTemplate _rt : _toRender){
        if(_rt.getRenderLayer() == _index) templateRenderer.render(_rt, _rl.getCanvas());
      }
      _rl.endDrawing();
      _index++;
    }

    mergeLayer.beginDrawing();

    PGraphics _prev = null;
    for(Layer _lr : layers) _prev = _lr.apply(_prev);
    mergeLayer.endDrawing();
    image(mergeLayer.getCanvas(),0,0);

    for(Layer _lr : layers){
      if(_lr instanceof MaskLayer){
        if(((MaskLayer)_lr).checkMakeMask()) ((MaskLayer)_lr).makeMask(mergeLayer.getCanvas());
      }
    }
	}

  public final PGraphics getCanvas(){
    return mergeLayer.getCanvas();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void printLayers(){
    println("+--------Layers--------+");
    for(Layer _lr : layers) println(_lr.getID());
    println("+--------details--------+");
    for(Layer _lr : layers) printLayer(_lr);
    println("+--------END-----------+");
  }

  // type-layerName
  // the rest can be figured out in JS
  public String getLayerInfo(){
    String _out = "";
    for(Layer _lyr : layers){
      _out += _lyr.getID()+"-";
      _out += _lyr.getName()+"-";
      _out += _lyr.getFilename()+"-";
      if(_lyr.useLayer()) _out += str(1);
      else _out += str(0);

      // _out += _lyr.getType()+"-";
      _out += " ";
    }
    return _out;
  }

  public void printLayer(Layer _lyr){
    println("_________"+_lyr.getID()+"_________");
    println(_lyr.getDescription());
    for(String _cmd : _lyr.getCMDList() ) println(_cmd);
    println("enable "+_lyr.useLayer());
    println("||||||||||||||||||||||||||||||||||||||||||||");
  }

  public void screenShot(){
    // save screenshot to capture/screenshots/datetime.png
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean parseCMD(String[] _args){
    if(_args.length < 3) return false;
    else if(_args[2].equals("swap") ) {
      swapOrder(_args[1], stringInt(_args[3]));
      return true;
    }

    Layer _lyr = getLayer(_args[1]);
    if(_lyr == null) return false;
    else return _lyr.parseCMD(_args);
  }

  public Layer getLayer(String _id){
    for(Layer _lyr : layers)
      if(_lyr.getID().equals(_id)) return _lyr;
    return null;
  }

  // seem to work!
  public void swapOrder(String _id, int _dir){
    for(int i = 0; i < layers.size(); i++){
      if(layers.get(i).getID().equals(_id)){
        if(i + _dir >= 0 && i + _dir < layers.size()){
          Collections.swap(layers, i, i + _dir);
        }
      }
    }
  }

  public void deleteLayer(Layer _lyr){
    layers.remove(_lyr);
  }

  public void addLayer(String _id){
    addLayer(new Layer()).setID(_id);
  }

  public void castLayer(String _id, String _type){
    Layer _lyr = getLayer(_id);
    if(_lyr == null) _lyr = addLayer(new Layer()).setID(_id);
    switch(_type){
      case "merge":
        _lyr = mergeLayer;
      case "render":
        _lyr = new RenderLayer().setID(_lyr.getID());
      case "tracer":
        _lyr = new TracerLayer().setID(_lyr.getID());
      case "mask":
        _lyr = new MaskLayer().setID(_lyr.getID());
      case "shader":
        _lyr = new ShaderLayer().setID(_lyr.getID());
    }
  }

  /**
   * Toggle the use of background with alpha value
   * @return boolean value given
   */
  public boolean toggleTrails(){
    //tracerLayer.toggleLayer();
    return false;//tracerLayer.useLayer();
  }

  // ////////////////////////////////////////////////////////////////////////////////////
  // ///////
  // ///////     Masking
  // ///////
  // ////////////////////////////////////////////////////////////////////////////////////
  // /**
  //  * Parse a image to make a mask.
  //  * @param PImage to make into mask
  //  */
  //
  // // Set a flag to generate mask next render.
  // //DPREACET
  // public void generateMask(){
  //   //makeMaskFlag = true;
  // }
  // //DPREACET
  // public boolean toggleMask(){
  //   return false;
  // }
  //
  // /**
  //  * Load a image as the mask (transparent png for now...)
  //  * @param String mask png file
  //  */
  // public void loadMask(String _file){
  //   //((MaskLayer) maskLayer).loadFile(_file);
  // }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // set uniform values for shader
  // public void setUniforms(int _i, float _v){
  //   //
  //   // if(_i < 8 && shaderLayer != null)
  //   //   shaderLayer.setUniforms(_i, _v);
  //   // else if(shaderTwo != null)
  //   //   shaderTwo.setUniforms(_i-8, _v);
  // }
  // reload the shader file
  // public void reloadShader(){
  //   // shaderLayer.reloadShader();
  // }

  // load a different shader from the list
  // public void loadShader(int _n){
  //   if(shaderLayer == null) return;
  //   if(_n < shaderFiles.length) {
  //     shaderLayer.loadFile(sketchPath()+"/data/shaders/"+shaderFiles[_n]);
  //   }
  //   else println("out of shaders");
  // }
}
