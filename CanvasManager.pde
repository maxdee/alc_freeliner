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

  PGraphics outputCanvas;
  ArrayList<Layer> layers;

  public CanvasManager(){
    outputCanvas = createGraphics(width, height, P2D);
    layers = new ArrayList();

    layers.add(new RenderLayer());
    layers.add(new RenderLayer());
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
    for(Layer _lr : layers) _lr.endDrawing();
    outputCanvas.beginDraw();
    outputCanvas.background(100,0,0);
    outputCanvas.image(layers.get(0).getCanvas(),0,0);
    outputCanvas.scale(0.7);
    outputCanvas.image(layers.get(1).getCanvas(),0,0);
    outputCanvas.endDraw();
    println(layers.get(0).getCanvas()+"  "+layers.get(1).getCanvas());
  }

  public final PGraphics getCanvas(){
    return outputCanvas;
  }

  public final PGraphics getDrawingCanvas(int _index){
    _index %= layers.size();
    return layers.get(_index).getCanvas();
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
