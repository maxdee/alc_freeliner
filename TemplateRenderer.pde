

/**
 * View part
 * The template renderer is where the rendering process begins. 
 *
 *
 */

class TemplateRenderer {
  // rendering modes and repetition
  RenderMode[] renderModes;
  final int RENDERER_COUNT = 3;

  Repetition[] repeaters;
  final int REPEATER_COUNT = 4;

  //graphics for rendering
  PGraphics canvas;

  //draw a solid or transparent 
  boolean trails;
  int trailmix;

  // for video recording
  boolean record;
  int clipCount;
  int frameCount;

  // experimental
  PShader fadefrag;
  boolean useP2D = false;

  /**
   * Constructor
   */
	public TemplateRenderer(){
    // init canvas
    canvas = createGraphics(width, height);
    canvas.smooth(0);
    canvas.ellipseMode(CENTER);

    fadefrag = loadShader("data/fadefrag.glsl");
    // init variables
    trails = false;
    trailmix = 30;

    record = false;
    clipCount = 0;
    frameCount = 0;

    // add renderModes
    renderModes = new RenderMode[RENDERER_COUNT];
    renderModes[0] = new PerSegment();
    renderModes[1] = new Geometry();
    renderModes[2] = new WrapLine();

    // add repetitionModes
    repeaters = new Repetition[REPEATER_COUNT];
    repeaters[0] = new Single();
    repeaters[1] = new EvenlySpaced();
    repeaters[2] = new EvenlySpacedWithZero();
    repeaters[3] = new TwoFull();
	}

  public RenderMode getRenderer(int _index){
    if(_index >= RENDERER_COUNT) _index = RENDERER_COUNT - 1;
    return renderModes[_index]; 
  }

  public Repetition getRepeater(int _index){
    if(_index >= REPEATER_COUNT) _index = RENDERER_COUNT - 1;
    return repeaters[_index];
  }

  /**
   * Render a arrayList of renderable templates.
   * @param ArrayList<RenderableTemplate> to render.
   */
	public void render(ArrayList<RenderableTemplate> _toRender){
    canvas.beginDraw();
    // either clear or fade the last frame.
    if(trails){
      if(!useP2D) alphaBG(canvas, trailmix);
      else canvas.filter(fadefrag); //alphaBG(canvas, trailmix);//
    }
    else canvas.clear();

    // for liquid crystal project
    if(liquid){
      fill(255);
      rect(1024,0,1024,768);
    }
    // render templates
    if(_toRender.size() > 0)
      for(RenderableTemplate rt : _toRender)
        renderTemplate(rt);

    canvas.endDraw();
    // save frame if recording
    if(record){
      String fn = String.format("%06d", frameCount);
      canvas.save("capture/clip_"+clipCount+"/frame-"+fn+".tif");
      frameCount++;
    }
	}

  /**
   * Render a renderable template.
   * @param RenderableTemplate to render.
   */
  public void renderTemplate(RenderableTemplate _rt){
    // push canvas to template
    _rt.setCanvas(canvas);
    // get multiple unit intervals to use
    FloatList flts = getRepeater(_rt.getRepetitionMode()).getFloats(_rt);
    int repetitionCount = 0;
    for(float flt : flts){
      // Repition object return arrayList of unit intervals.
      // negative values indicates going in reverse
      if(flt < 0){
        _rt.setLerp(abs(flt));
        _rt.setDirection(true);
      }
      else {
        _rt.setLerp(abs(flt));
        _rt.setDirection(false);
      }
      // push the repetition count to template
      _rt.setRepetition(repetitionCount); 
      repetitionCount++;
      // modify angle modifier
      tweakAngle(_rt);
      // pass template to renderer
      getRenderer(_rt.getRenderMode()).doRender(_rt);
    }
  }


  /**
   * One of the last few things to expand into 
   * @param RenderableTemplate to render.
   */ 
  public void tweakAngle(RenderableTemplate _rt){
    int rotMode = _rt.getRotationMode();
    if(rotMode > 0){
      if(rotMode < 4) _rt.setAngleMod(_rt.getLerp()*PI*-rotMode);
      else if(rotMode >= 4) _rt.setAngleMod(_rt.getLerp()*PI*(rotMode-3));
    }
    else _rt.setAngleMod(0);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Effects
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * SetBackground with alpha value
   * @param PGraphics to draw
   * @param int alpha value of black
   */ 
  private void alphaBG(PGraphics _pg, int _alpha) {
    _pg.fill(0, _alpha);
    _pg.stroke(0, _alpha);
    _pg.rect(0, 0, width, height);
  }

  public boolean toggleP2D(){
    useP2D = !useP2D;
    if(useP2D) canvas = createGraphics(width, height, P2D);
    else canvas = createGraphics(width, height);
    return useP2D;
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
    fadefrag.set("fadeforce", float(trailmix)/255);
    return trailmix;
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

  /**
   * Access the rendering canvas
   * @return PGraphics
   */
	public final PGraphics getCanvas(){
    return canvas;
  }
}
