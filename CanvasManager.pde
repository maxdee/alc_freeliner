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

  MergeLayer mergeLayer;
  TracerLayer tracerLayer;
  ShaderLayer shaderLayer;
  MaskLayer maskLayer;

  boolean makeMaskFlag = false;

  TemplateRenderer templateRenderer;

  String[] shaderFiles = {"shaders/mainFrag.glsl", "shaders/fragThree.glsl", "shaders/blurShader.glsl"};

  public CanvasManager(){
    layers = new ArrayList();
    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();

    mergeLayer = new MergeLayer();

    // begin stack
    tracerLayer =  (TracerLayer)addLayer(new TracerLayer());

    shaderLayer = (ShaderLayer)addLayer(new ShaderLayer());
    shaderLayer.loadFile("shaders/mainFrag.glsl");

    // shaderLayer = (ShaderLayer)addLayer(new ShaderLayer());
    // shaderLayer.loadFile("shaders/fragThree.glsl");

    //addLayer(new ImageLayer()).loadFile("userdata/grey.png");
    //addLayer(new RenderLayer()).setName("First");
    //maskLayer = (MaskLayer)addLayer(new MaskLayer());
    addLayer(mergeLayer);

    addLayer(new RenderLayer()).setName("Untraced");
    addLayer(mergeLayer);

    printLayers();
  }

  public void inject(TemplateRenderer _tr){
    templateRenderer = _tr;
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
    for(Layer _lr : renderLayers){
      _lr.beginDrawing();
      for(RenderableTemplate _rt : _toRender){
        if(_rt.getRenderLayer() == _index) templateRenderer.render(_rt, _lr.getCanvas());
      }
      _lr.endDrawing();
      _index++;
    }
    mergeLayer.beginDrawing();
    mergeLayer.getCanvas().background(100);
    PGraphics _prev = null;
    for(Layer _lr : layers) _prev = _lr.apply(_prev);
    mergeLayer.endDrawing();
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

  public void oscSetTrails(int _t){
    if(tracerLayer == null) return;
    tracerLayer.setTrails(_t);
  }

  public int setTrails(int _t){
    if(tracerLayer == null) return 0;
    return tracerLayer.setTrails(_t);
  }

  public void setUniforms(int _i, float _v){
    shaderLayer.setUniforms(_i, _v);
  }

  public void reloadShader(){
    shaderLayer.reloadShader();
  }

  public void loadShader(int _n){

    if(_n < shaderFiles.length) {
      shaderLayer.loadFile(shaderFiles[_n]);
    }
    else println("out of shaders");
  }

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

}
