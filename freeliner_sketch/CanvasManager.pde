/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-01-22
 */


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

    addLayer(new TracerLayer()).setName("tracerOne");
    // addLayer(new ShaderLayer()).setName("firstShader").loadFile("fragZero.glsl");
    // addLayer(new ShaderLayer()).setName("secondShader").loadFile("fragTwo.glsl");
    addLayer(mergeLayer);
    //
    // addLayer(new RenderLayer()).setName("untraced");
    // addLayer(new ShaderLayer()).setName("thirdShader").loadFile("fragTwo.glsl");
    // addLayer(new ShaderLayer()).setName("fourthShader").loadFile("fragTwo.glsl");
    //
    // // addLayer(new MaskLayer());
    // addLayer(mergeLayer);

    // addLayer(new RenderLayer()).setName("untraced2");
    // addLayer(mergeLayer);
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
    for(Layer _lr : layers) println(_lr.getName());
    println("+--------details--------+");
    for(Layer _lr : layers) printLayer(_lr);
    println("+--------END-----------+");
  }

  // type-layerName
  // the rest can be figured out in JS
  public String getLayerInfo(){
    String _out = "";
    for(Layer _lyr : layers){
      _out += _lyr.getType()+"-";
      _out += _lyr.getName()+"-";
      _out += _lyr.getFilename()+"-";
      _out += str(_lyr.useLayer())+"-";
      // _out += _lyr.getType()+"-";
      _out += " ";
    }
    return _out;
  }

  public void printLayer(Layer _lyr){
    println("_________"+_lyr.getName()+"_________");
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

  // add cmd : layer layerName order (-2|-1|n)
  public boolean parseCMD(String[] _args){
    if(_args.length < 2) return false;
    Layer _lyr = getLayer(_args[1]);
    if(_lyr == null) return false;
    else return _lyr.parseCMD(_args);
  }

  public Layer getLayer(String _name){
    for(Layer _lyr : layers)
      if(_lyr.getName().equals(_name)) return _lyr;
    return null;
  }

  public void swapOrder(Layer _lyr, int _dir){
    // swap(layers, i, j);
  }

  public void deleteLayer(Layer _lyr){

  }

  public void addLayer(String _type, String _name){

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
