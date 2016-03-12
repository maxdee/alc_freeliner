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
    ArrayList<Layer> renderLayers;
    ArrayList<Layer> shaderLayers;

    Layer guiLayer;
    Layer maskLayer;
    Layer tracerLayer;

    //graphics buffers
    PGraphics canvas;

    public CanvasManager(){
      // init canvases
      canvas = createGraphics(width, height, P2D);
      canvas.smooth(0);

      guiLayer = new RenderLayer();

      guiLayer.setName("GUI");
      maskLayer = new MaskLayer();

      tracerLayer = new TracerLayer();
      tracerLayer.setEnable(false);

    }


    /**
     * Begin redering process. Make sure to end it with endRender();
     */
    public void beginRender(){
      canvas.beginDraw();
  	}

    /**
     * End redering process.
     */
    public void endRender(){
      // mask, could be applied to fxCanvas or drawingCanvas
      if(useMask && !makeMask && !useShader) drawingCanvas.image(maskImage,0,0);
      drawingCanvas.endDraw();
      if(makeMask) makeMask(drawingCanvas);

      if(useShader) applyFX();
      else noFX();

      // // save frame if recording
      // if(record){

      // }
    }

    public void applyFX(){
      // experimental rendering pipeline
      fxCanvas.beginDraw();
      fxCanvas.clear();
      //if(EXPERIMENTAL) useShader();
      getSelectedShader().useShader(fxCanvas);
      fxCanvas.image(drawingCanvas, 0, 0);

      if(useMask && !makeMask) {
        fxCanvas.resetShader();
        fxCanvas.image(maskImage,0,0);
      }
      fxCanvas.endDraw();
    }

    public void noFX(){
      fxCanvas.beginDraw();
      fxCanvas.resetShader();
      fxCanvas.clear();
      fxCanvas.image(drawingCanvas, 0, 0);
      fxCanvas.endDraw();
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void screenShot(){
      // save screenshot to capture/screenshots/datetime.png
    }

    /**
     * SetBackground with alpha value
     * @param PGraphics to draw
     * @param int alpha value of black
     */
    private void alphaBG(PGraphics _pg, int _alpha) {
      _pg.fill(BACKGROUND_COLOR, _alpha);
      _pg.stroke(BACKGROUND_COLOR, _alpha);
      _pg.strokeWeight(1);
      _pg.rect(0, 0, width, height);
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Shaders
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // public void setShader(String _file){
    //   flShader = new FLShader(_file);
    // }


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
      makeMask = true;
    }

    public boolean toggleMask(){
      if(useMask){
        useMask = false;
        return useMask;
      }
      else {
        generateMask();
        return true;
      }
    }

    /**
     * Load a image as the mask (transparent png for now...)
     * @param String mask png file
     */
    public void loadMask(String _file){
      try {
        makeMask(loadImage("userdata/background.png"));
      }
      catch(Exception _e) {
        println("Mask file could not be loaded : "+_file);
        useMask = false;
      }
    }

    public void saveMask(String _file){
      maskImage.save(_file);
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void oscSetTrails(int _t){
      trailmix = _t;
    }

    public boolean setBackgroundImage(String _file){
      return false;
    }

    /**
     * Toggle the use of background with alpha value
     * @return boolean value given
     */
    public boolean toggleTrails(){
      trails = !trails;
      return trails;
    }

    /**
     * Set the alpha value of the background
     * @param int tweaking value
     * @return int value given
     */


    /**
     * Toggle the use of shaders
     * @return boolean value given
     */
    public boolean toggleShader(){
      useShader = !useShader;
      getSelectedShader().reloadShader();
      getSelectedShader().passUniforms();
      return useShader;
    }

    /**
     * Shader to use of whatever
     * @param int tweaking value
     * @return int value given
     */
    public int setShader(int v){
      shaderIndex = numTweaker(v, shaderIndex);
      getSelectedShader().reloadShader();
      getSelectedShader().passUniforms();
      return shaderIndex;
    }

    /**
     * Turn on and off frame capture
     * @return boolean value given
     */
    public boolean toggleRecording(){
      record = !record;
      if(record) {
        clipCount++;
        frameCount = 0;
      }
      return record;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    public FLShader getSelectedShader(){
      return flShaders[shaderIndex%SHADER_COUNT];
    }

    /**
     * Access the drawingCanvas
     * @return PGraphics
     */
  	public final PGraphics getDrawingCanvas(){
      return drawingCanvas;
    }

    /**
     * Access the drawingCanvas
     * @return PGraphics
     */
  	public final PGraphics getFXCanvas(){
      return fxCanvas;
    }
  }




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////   Shader object
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
