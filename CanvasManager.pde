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



  TemplateRenderer templateRenderer;

  public CanvasManager(){
    layers = new ArrayList();
    renderLayers = new ArrayList();
    shaderLayers = new ArrayList();

    mergeLayer = new MergeLayer();
    // begin stack
    addLayer(new TracerLayer());
    addLayer(new ShaderLayer()).loadFile("shaders/fragThree.glsl");
    addLayer(mergeLayer);
    //addLayer(new ShaderLayer()).loadFile("userdata/fragTwo.glsl");
    addLayer(new RenderLayer()).setName("Untraced");
    addLayer(mergeLayer);
    //addLayer(new ShaderLayer()).loadFile("userdata/fragZero.glsl");

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
  ///////     Masking
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  /**
   * Parse a image to make a mask.
   * @param PImage to make into mask
   */

  // Set a flag to generate mask next render.
  public void generateMask(){
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
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void oscSetTrails(int _t){
    //((TracerLayer)tracerLayer).setTrails(_t);
  }

  public int setTrails(int _t){
    return 0;//((TracerLayer)tracerLayer).setTrails(_t);
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
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////





}
