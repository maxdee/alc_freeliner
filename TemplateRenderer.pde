/**
 * View part
 * The template renderer is where the rendering process begins.
 *
 *
 */

class TemplateRenderer implements FreelinerConfig{
  // rendering modes and repetition
  RenderMode[] renderModes;
  final int RENDERER_COUNT = 6;

  Repetition[] repeaters;
  final int REPEATER_COUNT = 4;

  Enabler[] enablers;
  final int ENABLER_COUNT = 6;

  //graphics for rendering
  PGraphics canvas;

  //draw a solid or transparent
  boolean trails;
  int trailmix;

  // for video recording
  boolean record;
  int clipCount;
  int frameCount;

  /**
   * Constructor
   */
	public TemplateRenderer(){
    // init canvas
    canvas = createGraphics(width, height, P2D);
    canvas.smooth(1);
    canvas.strokeCap(STROKE_CAP);
    canvas.strokeJoin(STROKE_JOIN);
    //canvas.ellipseMode(CENTER);

    // init variables
    trails = false;
    trailmix = 30;

    record = false;
    clipCount = 0;
    frameCount = 0;

    // add renderModes
    renderModes = new RenderMode[RENDERER_COUNT];
    renderModes[0] = new BrushSegment();
    renderModes[1] = new LineSegment();
    renderModes[2] = new WrapLine();
    renderModes[3] = new Geometry();
    renderModes[4] = new TextLine();
    renderModes[5] = new CircularSegment();

    // add repetitionModes
    repeaters = new Repetition[REPEATER_COUNT];
    repeaters[0] = new Single();
    repeaters[1] = new EvenlySpaced();
    repeaters[2] = new EvenlySpacedWithZero();
    repeaters[3] = new TwoFull();

    // add enablers
    enablers = new Enabler[ENABLER_COUNT];
    enablers[0] = new Disabler();
    enablers[1] = new Enabler();
    enablers[2] = new Triggerable();
    enablers[3] = new SweepingEnabler();
    enablers[4] = new SwoopingEnabler();
    enablers[5] = new RandomEnabler();
	}

  public RenderMode getRenderer(int _index){
    if(_index >= RENDERER_COUNT) _index = RENDERER_COUNT - 1;
    return renderModes[_index];
  }

  public Repetition getRepeater(int _index){
    if(_index >= REPEATER_COUNT) _index = REPEATER_COUNT - 1;
    return repeaters[_index];
  }

  /**
   * Render a arrayList of renderable templates.
   * @param ArrayList<RenderableTemplate> to render.
   */
	public void beginRender(){
    canvas.beginDraw();
    // either clear or fade the last frame.
    if(trails) alphaBG(canvas, trailmix);
    else canvas.clear();
	}

  public void render(ArrayList<RenderableTemplate> _toRender){

    // copy arraylist
    ArrayList<RenderableTemplate> lst = new ArrayList<RenderableTemplate>(_toRender);
    // render templates
    if(lst.size() > 0)
      for(RenderableTemplate rt : lst)
        renderTemplate(rt);
  }


  public void endRender(){
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
    if(_rt.getSegmentGroup().isEmpty()) return;
    // push canvas to template
    _rt.setCanvas(canvas);
    // check the enabler, it may modify the unitInterval
    if(!enablers[_rt.getEnablerMode()%ENABLER_COUNT].enable(_rt)) return;
    // get multiple unit intervals to use
    FloatList flts = getRepeater(_rt.getRepetitionMode()).getFloats(_rt);
    int repetitionCount = 0;

    for(float flt : flts){
      // Repition object return arrayList of unit intervals.
      // negative values indicates going in reverse
      if(flt < 0){
        _rt.setLerp(flt+1);
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
  // yes a mess!
  public void tweakAngle(RenderableTemplate _rt){
    int rotMode = _rt.getRotationMode();
    float _ang = 0;
    if(rotMode == 0) _rt.setAngleMod(0);
    else {
      if(rotMode < 4){
        if(_rt.getSegmentGroup().isClockWise()) _ang = _rt.getLerp()*PI*-rotMode;
        else _ang = _rt.getLerp()*PI*rotMode;
      }
      else if(rotMode == 4) _ang = -_rt.getLerp()*PI;
      else if(rotMode == 5) _ang = _rt.getLerp()*PI;

      if(_rt.getDirection()) _ang -= PI;
      _rt.setAngleMod(_ang);
    }

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
    _pg.fill(BACKGROUND_COLOR, _alpha);
    _pg.stroke(BACKGROUND_COLOR, _alpha);
    _pg.rect(0, 0, width, height);
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
