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

  // subclass with different ones?

class CanvasManager implements FreelinerConfig{

  ArrayList<Layer> layers;
  ArrayList<Layer> layerStack;
  ArrayList<RenderLayer> renderLayers;
  ArrayList<ShaderLayer> shaderLayers;

  // RenderLayer guiLayer;
  Layer maskLayer;
  Layer tracerLayer;
  Layer captureLayer;
  Layer mergeLayer;

  //graphics buffers
  PGraphics canvas;
  PGraphics mergeCanvas;

  boolean makeMaskFlag = false;



  public CanvasManager(){
    // init canvases
    canvas = createGraphics(width, height, P2D);
    canvas.smooth(0);
    // layer lists
    layers = new ArrayList();
    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();

    // merging layer
    mergeLayer = addLayer(new MergeLayer());
    // tracer layer
    tracerLayer = addLayer(new TracerLayer());
    // Regular Layer
    addLayer(new RenderLayer(), "REG_ONE");
    addLayer(new RenderLayer(), "REG_TWO");
    // shaders
    addNewShader("shaders/fragZero.glsl");
    addNewShader("shaders/fragOne.glsl");
    addNewShader("shaders/fragTwo.glsl");
    addNewShader("shaders/fragThree.glsl");
    // mask
    maskLayer = addLayer(new MaskLayer());
    // capture
    captureLayer = addLayer(new CaptureLayer());

    //////////////////////////////////////////////////
    layerStack = new ArrayList();
    layerStack.add(renderLayers.get(1));
    layerStack.add(mergeLayer);
    layerStack.add(renderLayers.get(2));
    layerStack.add(mergeLayer);

    // layerStack.add(renderLayers.get(1));
    // layerStack.add(mergeLayer);
    // layerStack.add(renderLayers.get(2));
    // layerStack.add(mergeLayer);

    // reset
    // layers.add(new ResetShaderLayer());
    // addNewShader("shaders/fragOne.glsl");

    // for(Layer _lyr : layers)
    //   if(_lyr instanceof RenderLayer) renderLayers.add((RenderLayer)_lyr);

    printLayerStacks();
  }


  /**
   * Begin redering process. Make sure to end it with endRender();
   */
  public void beginRender(){
    canvas.beginDraw();
    canvas.clear();
    canvas.resetShader();
    for(RenderLayer _lyr : renderLayers) _lyr.beginDraw();
	}

  /**
   * End redering process.
   */
  public void endRender(){
    for(RenderLayer _lyr : renderLayers)
      if(_lyr != mergeLayer) _lyr.endDraw();

    for(Layer _lyr : layerStack) _lyr.apply(canvas);

    ((MergeLayer)mergeLayer).endDraw();
    canvas.endDraw();
    if(makeMaskFlag) ((MaskLayer)maskLayer).makeMask(canvas);
    makeMaskFlag = false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // add a new layer
  public Layer addLayer(Layer _lyr){
    layers.add(_lyr);
    if(_lyr instanceof RenderLayer) renderLayers.add((RenderLayer)_lyr);
    else if(_lyr instanceof ShaderLayer) shaderLayers.add((ShaderLayer)_lyr);
    return _lyr;
  }
  // add a newLayer with a custom name
  public Layer addLayer(Layer _lyr, String _name){
    _lyr.setName(_name);
    return addLayer(_lyr);
  }

  public void addNewShader(String _file){
    ShaderLayer _shader = new ShaderLayer();
    _shader.loadFile(_file);
    if(_shader.isNull()) {
      println("Failed to load "+_file+" as a shader");
      return;
    }
    // layers.add(_shader);
    // shaderLayers.add((ShaderLayer)_shader);
    addLayer(_shader);
  }


  public void printLayerStacks(){
    println("-----Layers-----");
    for(Layer _lyr : layers) println(_lyr.getName());
    println("-----Render-----");
    for(Layer _lyr : renderLayers) println(_lyr.getName());
    println("-----Shader-----");
    for(Layer _lyr : shaderLayers) println(_lyr.getName());
    println("-----Stack-----");
    for(Layer _lyr : layerStack) println(_lyr.getName());
    println("-----END-----");
  }


  public void screenShot(){
    // save screenshot to capture/screenshots/datetime.png
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

  /**
   * Set a flag to generate mask next render.
   */
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
    ((MaskLayer) maskLayer).loadFile(_file);
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void oscSetTrails(int _t){
    ((TracerLayer)tracerLayer).setTrails(_t);
  }

  public int setTrails(int _t){
    return ((TracerLayer)tracerLayer).setTrails(_t);
  }


  /**
   * Toggle the use of background with alpha value
   * @return boolean value given
   */
  public boolean toggleTrails(){
    tracerLayer.toggleLayer();
    return tracerLayer.useLayer();
  }

  /**
   * Toggle the use of shaders
   * @return boolean value given
   */
  public boolean toggleShader(){
    // useShader = !useShader;
    // getSelectedShader().reloadShader();
    // getSelectedShader().passUniforms();
    return false;//useShader;
  }

  /**
   * Shader to use of whatever
   * @param int tweaking value
   * @return int value given
   */
  public int setShader(int v){
    // shaderIndex = numTweaker(v, shaderIndex);
    // getSelectedShader().reloadShader();
    // getSelectedShader().passUniforms();

    return 0;//shaderIndex;
  }

  /**
   * Turn on and off frame capture
   * @return boolean value given
   */
  public boolean toggleRecording(){
    return captureLayer.toggleLayer();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public PGraphics getRenderLayer(int _ind){
    _ind %= renderLayers.size();
    return renderLayers.get(_ind).getCanvas();
  }

  /**
   * Access the drawingCanvas
   * @return PGraphics
   */
	public final PGraphics getCanvas(){
    return canvas;

    // return ((RenderLayer)mergeLayer).getCanvas();
  }

}
