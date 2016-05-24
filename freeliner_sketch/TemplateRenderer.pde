/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * View part
 * The template renderer is where the rendering process begins.
 */

class TemplateRenderer extends Mode{
  // rendering modes and repetition
  // arraySizes in config.pde
  RenderMode[] renderModes;
  Repetition[] repeaters;
  Enabler[] enablers;
  PVector[] translations;
  int renderModeCount = 6;
  int repetitionModeCount = 6;
  int enablerModeCount = 7;
  /**
   * Constructor
   */
	public TemplateRenderer(){
    name="TemplateRenderer";
    description="regular template renderer";
    // add renderModes
    renderModes = new RenderMode[renderModeCount];
    renderModes[0] = new BrushSegment(0);
    renderModes[1] = new LineSegment(1);
    renderModes[2] = new WrapLine(2);
    renderModes[3] = new Geometry(3);
    renderModes[4] = new TextRenderMode(4);
    renderModes[5] = new CircularSegment(5);
    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])renderModes, 'b', this, "RenderModes");
    // add repetitionModes
    repeaters = new Repetition[repetitionModeCount];
    repeaters[0] = new Single(0);
    repeaters[1] = new EvenlySpaced(1);
    repeaters[2] = new EvenlySpacedWithZero(2);
    repeaters[3] = new ExpoSpaced(3);
    repeaters[4] = new TwoFull(4);
    repeaters[5] = new TwoSpaced(5);
    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])repeaters, 'i', this, "RepetitionModes");

    // add enablers
    enablers = new Enabler[enablerModeCount];
    enablers[0] = new Disabler(0);
    enablers[1] = new Enabler(1);
    enablers[2] = new Triggerable(2);
    enablers[3] = new Triggerable(3);
    enablers[4] = new SweepingEnabler(4);
    enablers[5] = new SwoopingEnabler(5);
    enablers[6] = new RandomEnabler(6);
    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])enablers, 'u', this, "Enablers");

    translations = new PVector[26];
    for(int i = 0; i < 26; i++) translations[i] = new PVector(0,0,0);
	}

  /**
   * Render a renderable template.
   * @param RenderableTemplate to render.
   */
  public void render(RenderableTemplate _rt, PGraphics _pg){
    if(_rt == null) return;
    if(_rt.getSegmentGroup() == null) return;
    if(_rt.getSegmentGroup().isEmpty()) return;
    _rt.setCanvas(_pg);

    // check the enabler, it may modify the unitInterval
    if(!enablers[_rt.getEnablerMode()%enablerModeCount].enable(_rt)) return;
    // get multiple unit intervals to use
    FloatList flts = getRepeater(_rt.getRepetitionMode()).getFloats(_rt);
    int repetitionCount = 0;

    _pg.pushMatrix(); // new
    PVector _trans = getTranslation(_rt.getTemplateID());
    _pg.translate(_trans.x*width, _trans.y*height);
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

    _pg.popMatrix();
  }

  public void translate(String _tags, float x, float y, float z){
    int _index = 0;
    for(int i = 0; i < _tags.length(); i++){
      getTranslation(_tags.charAt(i)).set(x,y,z);
    }
  }

  public PVector getTranslation(char _c){
    int _index = int(_c)-65;
    if(_index >= 0 && _index < 26) return translations[_index];
    else return new PVector(0,0,0);
  }


  //needs work
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
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public RenderMode getRenderer(int _index){
    if(_index >= renderModeCount) _index = renderModeCount - 1;
    return renderModes[_index];
  }

  public Repetition getRepeater(int _index){
    if(_index >= repetitionModeCount) _index = repetitionModeCount - 1;
    return repeaters[_index];
  }
}
