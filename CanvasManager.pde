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
    //graphics buffers
    PGraphics drawingCanvas;
    PGraphics fxCanvas;
    // optional background image
    PImage backgroundImage;
    // Masking
    PImage maskImage;
    boolean makeMask = false;
    boolean useMask = false;
    //draw a solid or transparent
    boolean trails;
    int trailmix;
    // Shaders
    FLShader[] flShaders;
    boolean useShader;
    int shaderIndex;
    final int SHADER_COUNT = 4;
    // for video recording
    boolean record;
    int clipCount;
    int frameCount;

    public CanvasManager(){
      // init canvases
      drawingCanvas = createGraphics(width, height, P2D);
      fxCanvas = createGraphics(width, height, P2D);
      drawingCanvas.smooth(0);
      fxCanvas.smooth(0);
      // canvas.strokeCap(STROKE_CAP);
      // canvas.strokeJoin(STROKE_JOIN);

      // init variables
      trails = false;
      trailmix = 30;
      record = false;
      frameCount = 0;

      // experimental
      //flShader = new FLShader("shaders/basicFrag.glsl");
      flShaders = new FLShader[SHADER_COUNT];
      flShaders[0] = new FLShader("shaders/fragZero.glsl");
      flShaders[1] = new FLShader("shaders/fragOne.glsl");
      flShaders[2] = new FLShader("shaders/fragTwo.glsl");
      flShaders[3] = new FLShader("shaders/fragThree.glsl");
      shaderIndex = 0;
      useShader = false;
      // check for background image, usefull for tracing paterns
      try { backgroundImage = loadImage("userdata/background.png");}
      catch(Exception _e) {backgroundImage = null;}
    }


    /**
     * Begin redering process. Make sure to end it with endRender();
     */
    public void beginRender(){
      drawingCanvas.beginDraw();
      // either clear or fade the last frame.
      if(trails) alphaBG(drawingCanvas, trailmix);
      else drawingCanvas.clear();
      if(backgroundImage != null) image(backgroundImage,0,0);
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

      // save frame if recording
      if(record){
        String fn = String.format("%06d", frameCount);
        fxCanvas.save("userdata/capture/clip_"+clipCount+"/frame-"+fn+".tif");
        frameCount++;
      }
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
    void makeMask(PImage _source){
      useMask = true;
      makeMask = false;
      maskImage = null;
      maskImage = _source.get();
      maskImage.loadPixels();
      color _col;
      for(int i = 0; i< width * height; i++){
        // check the green pixels.
        if(((maskImage.pixels[i] >> 8) & 0xFF) > 100) maskImage.pixels[i] = color(100, 0);
        else maskImage.pixels[i] = color(0,255);
      }
      maskImage.updatePixels();
      saveMask("userdata/mask_image.png");
    }

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
    public int setTrails(int v){
      trailmix = numTweaker(v, trailmix);
      if(v == 255) trails = false;
      else trails = true;
      return trailmix;
    }

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


class FLShader{
  PShader shader;
  String fileName;
  boolean valuesUpdated;
  float[] uniforms;

  public FLShader(String _file){
    fileName = _file;
    reloadShader();
    valuesUpdated = true;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5};
  }

  public void useShader(PGraphics _pg){
    if(shader == null) return;
    if(valuesUpdated){
      passUniforms();
      valuesUpdated = false;
    }
    try{_pg.shader(shader);}
    catch(RuntimeException _e){
      println("shader no good");
      _pg.resetShader();
    }
  }

  public void setUniforms(int _i, float _val){
    uniforms[_i % 4] = _val;
    valuesUpdated = true;
  }

  public void passUniforms(){
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
  }

  /**
   * Reload default shader
   */
  public void reloadShader(){
    try{
      shader = loadShader(fileName);
    }
    catch(Exception _e){
      println("Could not load shader... ");
      println(_e);
      shader = null;
    }
  }
}
