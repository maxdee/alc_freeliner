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
  boolean makeMaskFlag = false;


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
  // multiple shaders?
  ArrayList<ShaderLayer> shaderLayers;

  MergeLayer mergeLayer;
  MaskLayer maskLayer;
  TracerLayer tracerLayer;
  ShaderLayer shaderLayer;

  String[] shaderFiles = {"fragZero.glsl", "fragOne.glsl", "fragTwo.glsl", "fragThree.glsl",};

  public LayeredCanvasManager(){
    layers = new ArrayList();
    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();
    mergeLayer = new MergeLayer();
    //mergeLayer.getCanvas().blendMode(LIGHTEST);


    // begin stack
    tracerLayer = (TracerLayer)addLayer(new TracerLayer());
    shaderLayer = (ShaderLayer)addLayer(new ShaderLayer());
    shaderLayer.loadFile(shaderFiles[0]);
    addLayer(mergeLayer);
    addLayer(new RenderLayer()).setName("Untraced");
    maskLayer = (MaskLayer)addLayer(new MaskLayer());
    addLayer(mergeLayer);

    //addLayer(new ImageLayer()).loadFile(sketchPath()+"/data/userdata/grey.png");
    //addLayer(new RenderLayer()).setName("First");
    //
    //addLayer(mergeLayer);

    printLayers();
  }

  public int setTrails(int _t, int _max){
    return tracerLayer.setTrails(_t, _max);
  }

  public Layer addLayer(Layer _lr){
    layers.add(_lr);
    if(_lr instanceof ShaderLayer) shaderLayers.add((ShaderLayer)_lr);
    else if(_lr instanceof RenderLayer && ! (_lr instanceof MergeLayer)) renderLayers.add((RenderLayer)_lr);
    return _lr;
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
    mergeLayer.beginDrawing();
    mergeLayer.getCanvas().background(100);
    PGraphics _prev = null;
    for(Layer _lr : layers) _prev = _lr.apply(_prev);
    mergeLayer.endDrawing();
    //blendMode(BLEND);
    image(mergeLayer.getCanvas(),0,0);
    if(makeMaskFlag){
      maskLayer.makeMask(mergeLayer.getCanvas());
      makeMaskFlag = false;
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
    println("+--------Render--------+");
    for(Layer _lr : renderLayers) println(_lr.getName());
    println("+--------END-----------+");
  }

  public void screenShot(){
    // save screenshot to capture/screenshots/datetime.png
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Toggle the use of background with alpha value
   * @return boolean value given
   */
  public boolean toggleTrails(){
    //tracerLayer.toggleLayer();
    return false;//tracerLayer.useLayer();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Masking
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  /**
   * Parse a image to make a mask.
   * @param PImage to make into mask
   */

  // Set a flag to generate mask next render.
  public void generateMask(){
    makeMaskFlag = true;
  }
  public boolean toggleMask(){
    return false;
  }

  /**
   * Load a image as the mask (transparent png for now...)
   * @param String mask png file
   */
  public void loadMask(String _file){
    //((MaskLayer) maskLayer).loadFile(_file);
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // set uniform values for shader
  public void setUniforms(int _i, float _v){
    if(shaderLayer != null) shaderLayer.setUniforms(_i, _v);
  }
  // reload the shader file
  public void reloadShader(){
    shaderLayer.reloadShader();
  }

  // load a different shader from the list
  public void loadShader(int _n){
    if(shaderLayer == null) return;
    if(_n < shaderFiles.length) {
      shaderLayer.loadFile(sketchPath()+"/data/shaders/"+shaderFiles[_n]);
    }
    else println("out of shaders");
  }
}
