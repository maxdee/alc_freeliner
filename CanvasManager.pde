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

  // layers that need access
  Layer maskLayer;
  Layer tracerLayer;
  Layer captureLayer;

  Layer second;
  Layer third;
  // graphics buffers
  PGraphics outputCanvas;

  // misc
  boolean makeMaskFlag = false;

  public CanvasManager(){
    outputCanvas = null;
    // layer lists
    layers = new ArrayList();
    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();

    // tracer layer
    tracerLayer = addLayer(new TracerLayer());
    // mask
    maskLayer = addLayer(new MaskLayer());
    // capture
    captureLayer = addLayer(new CaptureLayer());
    // Regular Layer
    second = addLayer(new RenderLayer(), "REG_ONE");
    third = addLayer(new RenderLayer(), "REG_TWO");
    // shaders
    addNewShader("shaders/fragZero.glsl");
    addNewShader("shaders/fragOne.glsl");
    // addNewShader("shaders/fragTwo.glsl");
    // addNewShader("shaders/fragThree.glsl");


    //////////////////////////////////////////////////
    layerStack = new ArrayList();
    //layerStack.add(renderLayers.get(0));
    layerStack.add(second);

    // layerStack.add(renderLayers.get(1));
    // layerStack.add(mergeLayer);
    // layerStack.add(renderLayers.get(2));
    // layerStack.add(mergeLayer);

    // reset
    // layers.add(new ResetShaderLayer());
    // addNewShader("shaders/fragOne.glsl");

    // for(Layer _lr : layers)
    //   if(_lr instanceof RenderLayer) renderLayers.add((RenderLayer)_lr);

    printLayerStacks();
  }


  /**
   * Begin redering process. Make sure to end it with endRender();
   */
  public void beginRender(){
    for(Layer _lr : layers) _lr.beginDrawing();
	}

  /**
   * End redering process.
   */
  public void endRender(){
    Layer _prev = null;

    // for(Layer _lr : layerStack) _prev = _lr.apply(_prev);
    outputCanvas = second.getImage();//_prev.getImage();
    for(Layer _lr : layers) _lr.endDrawing();

    if(makeMaskFlag) ((MaskLayer)maskLayer).makeMask(outputCanvas);
    makeMaskFlag = false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // add a new layer
  public Layer addLayer(Layer _lr){
    layers.add(_lr);
    if(_lr instanceof ShaderLayer) shaderLayers.add((ShaderLayer)_lr);
    else if(_lr instanceof RenderLayer) renderLayers.add((RenderLayer)_lr);
    return _lr;
  }
  // add a newLayer with a custom name
  public Layer addLayer(Layer _lr, String _name){
    _lr.setName(_name);
    return addLayer(_lr);
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
    for(Layer _lr : layers) println(_lr.getName());
    println("-----Render-----");
    for(Layer _lr : renderLayers) println(_lr.getName());
    println("-----Shader-----");
    for(Layer _lr : shaderLayers) println(_lr.getName());
    println("-----Stack-----");
    for(Layer _lr : layerStack) println(_lr.getName());
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
    println(renderLayers.get(_ind).getName());
    return renderLayers.get(_ind).getCanvas();
  }

  /**
   * Access the drawingCanvas
   * @return PGraphics
   */
	public final PGraphics getCanvas(){
    return outputCanvas;
  }

}
