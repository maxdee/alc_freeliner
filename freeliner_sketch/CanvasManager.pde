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
  public boolean layerCreator(String[] _args){ return false; }

  public int setTrails(int _t, int _max){ return 0; }

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
  // MergeLayer mergeLayer;
  PGraphics mergeCanvas;

  public LayeredCanvasManager(){
    layers = new ArrayList();
    renderLayers = new ArrayList();
    // mergeLayer = new MergeLayer();
    mergeCanvas = createGraphics(width, height, P2D);

    // define the stack
    layerCreator("layer tracerOne tracerLayer");
    layerCreator("layer firstShader shaderLayer");
    layerCreator("layer mergeA mergeLayer");
    layerCreator("layer untraced renderLayer");
    layerCreator("layer secondShader shaderLayer");
    layerCreator("layer mergeB mergeLayer");
    layerCreator("layer mergeOutput mergeOutput");
    layerCreator("layer screen outputLayer");
    // very beta
    // layerCreator("layer firstShader vertexShaderLayer");

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
    if(_lr == null) return null;
    layers.add(_lr);
    if(_lr instanceof RenderLayer || _lr instanceof VertexShaderLayer)
      renderLayers.add((RenderLayer)_lr);
    return _lr;
  }


  public boolean layerCreator(String _s){
    return layerCreator(split(_s, ' '));
  }

  // takes a cmd : layer newID type : layer myTracer tracerLayer
  public boolean layerCreator(String[] _args){
    if(_args.length < 3) return false;
    // first check if there is a layer with the same Name or other subclass
    Layer _existingLayer = null;
    for(Layer _l : layers){
      if(_l.getID().equals(_args[1])){
        _existingLayer = _l;
        _args[2] = "containerLayer";
        _args[1] = getNewCloneName(_args[1]);
      }
    }

    Layer _lyr = null;

    switch(_args[2]){
      case "renderLayer":
        _lyr = new RenderLayer();
        break;
      case "tracerLayer":
        _lyr = new TracerLayer();
        break;
      case "mergeLayer":
        _lyr = new MergeLayer();
        _lyr.setCanvas(mergeCanvas);
        break;
      case "mergeOutput":
        _lyr = new MergeOutput();
        _lyr.setCanvas(mergeCanvas);
        break;
      case "outputLayer":
        _lyr = new OutputLayer();
        break;
      case "maskLayer":
        _lyr = new MaskLayer();
        break;
      case "shaderLayer":
        _lyr = new ShaderLayer();
        break;
      case "vertexShaderLayer":
        _lyr = new VertexShaderLayer();
        break;
      case "imageLayer":
        _lyr = new ImageLayer();
        break;
      case "containerLayer":
        if(_existingLayer != null){
          _lyr = new ContainerLayer();
          _lyr.setLayer(_existingLayer);
        }
        break;
    }
    if(_lyr != null){
      _lyr.setID(_args[1]);
      addLayer(_lyr);
      return true;
    }
    return false;
  }

  /**
   * makes a different name for a same layer so the layer can be tapped at different places.
   */
  private String getNewCloneName(String _s){
    for(Layer _l : layers){
      if(_l.getID().equals(_s))
        return getNewCloneName(_s+"I");
    }
    return _s;
  }

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

    mergeCanvas.beginDraw();
    mergeCanvas.clear();

    // and this is where the magic happens
    PGraphics _prev = null;
    for(Layer _lr : layers) _prev = _lr.apply(_prev);

    for(Layer _lr : layers){
      if(_lr instanceof MaskLayer){
        if(((MaskLayer)_lr).checkMakeMask()) ((MaskLayer)_lr).makeMask(mergeCanvas);
      }
    }
	}

  public final PGraphics getCanvas(){
    return mergeCanvas;// mergeLayer.getCanvas();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void updateOptions(){
    println();
    String[] _files = split(freeliner.getFileNames(), ' ');
    ArrayList<String> _images = new ArrayList();
    ArrayList<String> _shaders = new ArrayList();
    String[] _tmp;
    for(String _s : _files){
      _tmp = split(_s, '.');
      if(_tmp.length > 1){
        if(_tmp[1].equals("png")) _images.add(_s);
        else if(_tmp[1].equals("glsl")) _shaders.add(_s);
      }
    }
    String[] _glsl = _shaders.toArray(new String[_shaders.size()]);
    String[] _png = _images.toArray(new String[_images.size()]);

    for(Layer _lyr : layers){
      if(_lyr instanceof ImageLayer) _lyr.setOptions(_png);
      else if(_lyr instanceof ShaderLayer) _lyr.setOptions(_glsl);
    }
  }


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
    updateOptions();
    String _out = "";
    for(Layer _lyr : layers){
      _out += _lyr.getID()+"-";
      _out += _lyr.getName()+"-";
      if(_lyr.useLayer()) _out += str(1)+"-";
      else _out += str(0)+"-";
      _out += _lyr.getSelectedOption()+"-";
      for(String _s : _lyr.getOptions()) _out += _s+"-";
      // _out += _lyr.getType()+"-";
      _out += " ";
    }
    return _out;
  }

  public void printLayer(Layer _lyr){
    println(".............."+_lyr.getID()+"..............");
    println(_lyr.getDescription());
    for(String _cmd : _lyr.getCMDList() ) println(_cmd);
    println("enable "+_lyr.useLayer());
    println("............................................");
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
    else if(_args[2].equals("delete") ) {
      return deleteLayer(getLayer(_args[1]));
    }

    Layer _lyr = getLayer(_args[1]);
    if(_lyr == null) return layerCreator(_args);
    else if(_lyr.parseCMD(_args)) return true;
    else return layerCreator(_args);
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
          return;
        }
      }
    }
  }

  public boolean deleteLayer(Layer _lyr){
    if(_lyr != null) layers.remove(_lyr);
    else return false;
    return true;
  }

  public void addLayer(String _id){
    addLayer(new Layer()).setID(_id);
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
