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

  ArrayList<RenderLayer> renderLayers;
  ArrayList<ShaderLayer> shaderLayers;

  RenderLayer guiLayer;
  MaskLayer maskLayer;
  TracerLayer tracerLayer;
  CaptureLayer captureLayer;

  //graphics buffers
  PGraphics canvas;

  boolean makeMaskFlag = false;

  public CanvasManager(){
    // init canvases
    canvas = createGraphics(width, height, P2D);
    canvas.smooth(0);

    layers = new ArrayList();

    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();

    //////////////////////////////////////////////////////

    // tracers
    tracerLayer = new TracerLayer();
    layers.add(tracerLayer);
    renderLayers.add((RenderLayer)tracerLayer);

    // regular render
    RenderLayer _reg = new RenderLayer();
    _reg.setName("RegularRender");
    layers.add(_reg);
    renderLayers.add((RenderLayer)_reg);

    // mask
    maskLayer = new MaskLayer();
    layers.add(maskLayer);

    // shaders
    addNewShader("shaders/fragZero.glsl");
    addNewShader("shaders/fragOne.glsl");
    addNewShader("shaders/fragTwo.glsl");
    addNewShader("shaders/fragThree.glsl");

    // regular render
    RenderLayer _rag = new RenderLayer();
    _rag.setName("PostShaderRander");
    layers.add(_rag);
    renderLayers.add((RenderLayer)_rag);

    // layer for the gui
    guiLayer = new RenderLayer();
    guiLayer.setName("GUI");
    // layers.add(guiLayer);

    // captureLayer
    captureLayer = new CaptureLayer();
    layers.add(captureLayer);

    printLayerStack();
  }


  public void addNewShader(String _file){
    ShaderLayer _shader = new ShaderLayer();
    _shader.loadFile(_file);
    if(_shader.isNull()) {
      println("Failed to load "+_file+" as a shader");
      return;
    }
    layers.add(_shader);
    shaderLayers.add((ShaderLayer)_shader);
  }


  public void printLayerStack(){
    println("-----Layer_Stack-----");
    for(Layer _lyr : layers) println(_lyr.getName());
  }

  /**
   * Begin redering process. Make sure to end it with endRender();
   */
  public void beginRender(){
    canvas.beginDraw();
    canvas.clear();
    for(RenderLayer _lyr : renderLayers) _lyr.beginDraw();
	}

  /**
   * End redering process.
   */
  public void endRender(){
    for(RenderLayer _lyr : renderLayers) _lyr.endDraw();
    for(Layer _lyr : layers) _lyr.apply(canvas);
    canvas.endDraw();
    if(makeMaskFlag) maskLayer.makeMask(canvas);
    makeMaskFlag = false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

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
  //   if(useMask){
  //     useMask = false;
  //     return useMask;
  //   }
  //   else {
  //     generateMask();
  //     return true;
  //   }
    return false;
  }

  /**
   * Load a image as the mask (transparent png for now...)
   * @param String mask png file
   */
  public void loadMask(String _file){
    maskLayer.loadFile(_file);
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void oscSetTrails(int _t){
    tracerLayer.setTrails(_t);
  }

  public int setTrails(int _t){
    return tracerLayer.setTrails(_t);
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
  }

  public final PGraphics getGuiLayer(){
    return guiLayer.getCanvas();
  }
}




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////   Shader object
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
