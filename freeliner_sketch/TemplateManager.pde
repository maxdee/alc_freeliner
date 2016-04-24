/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * Manage all the templates
 *
 */
class TemplateManager{
	//selects templates to control
  TemplateList templateList;

  //templates all the basic templates
  ArrayList<TweakableTemplate> templates;
  TweakableTemplate copyedTemplate;
  final int N_TEMPLATES = 26;

  // events to render
  ArrayList<RenderableTemplate> eventList;
  ArrayList<RenderableTemplate> loops;
  // synchronise things
  Synchroniser sync;
  Sequencer sequencer;
  GroupManager groupManager;


  public TemplateManager(){
    sync = new Synchroniser();
    sequencer = new Sequencer();
  	templateList = new TemplateList();
    loops = new ArrayList();
    eventList = new ArrayList();
    copyedTemplate = null;
  	init();
    groupManager = null;
  }

  public void inject(GroupManager _gm){
    groupManager = _gm;
  }

  private void init() {
    templates = new ArrayList();
    for (int i = 0; i < N_TEMPLATES; i++) {
      TweakableTemplate te = new TweakableTemplate(char(65+i));
      templates.add(te);
    }
  }

  // update the render events
  public void update() {
    sync.update();
    sequencer.update(sync.getPeriodCount());
    trigger(sequencer.getStepList());
    //println("tags "+sequencer.getStepList().getTags());
    // check for events?
    // set the unitinterval/beat for all templates
    syncTemplates(loops);
    syncTemplates(eventList);
    ArrayList<RenderableTemplate> toKill = new ArrayList();
    synchronized(eventList){
      ArrayList<RenderableTemplate> _safe = new ArrayList(eventList);
      for(RenderableTemplate _tp : _safe){
        if(_tp == null) return;
        if(((KillableTemplate) _tp).isDone()) toKill.add(_tp);
      }
      if(toKill.size()>0){
        for(RenderableTemplate _rt : toKill){
          eventList.remove(_rt);
        }
      }
    }
  }

  // synchronise renderable templates lists
  private void syncTemplates(ArrayList<RenderableTemplate> _tp){
    ArrayList<RenderableTemplate> lst = new ArrayList<RenderableTemplate>(_tp);
    int beatDv = 1;
    if(_tp.size() > 0){
      for (RenderableTemplate rt : lst) {
        // had a null pointer here...
        if(rt == null) continue; // does this fix?
        beatDv = rt.getBeatDivider();
        rt.setUnitInterval(sync.getLerp(beatDv));
        rt.setBeatCount(sync.getPeriod(beatDv));
        rt.setRawBeatCount(sync.getPeriod(0));
      }
    }
  }

  /**
   * Makes sure there is a renderable template for all the segmentGroup / Template pairs.
   * @param ArrayList<SegmentGroup>
   */
  public void launchLoops(){
    ArrayList<SegmentGroup> _groups = groupManager.getGroups();
    if(_groups.size() == 0) return;
    ArrayList<RenderableTemplate> toKeep = new ArrayList();
    //check to add new loops
    for(SegmentGroup sg : _groups){
      ArrayList<TweakableTemplate> tmps = sg.getTemplateList().getAll();
      if(tmps != null){
        for(TweakableTemplate te : tmps){
          RenderableTemplate rt = getByIDandGroup(loops, te.getTemplateID(), sg);
          if(rt != null) toKeep.add(rt);
          else toKeep.add(loopFactory(te, sg));
        }
      }
    }
    loops = toKeep;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Event Factory
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // set size as per scalar
  public RenderableTemplate loopFactory(TweakableTemplate _te, SegmentGroup _sg){
    return new RenderableTemplate(_te, _sg);
  }

    // set size as per scalar
  public RenderableTemplate eventFactory(TweakableTemplate _te, SegmentGroup _sg){
    RenderableTemplate _rt = new KillableTemplate(_te, _sg);
    ((KillableTemplate) _rt).setOffset(sync.getLerp(_rt.getBeatDivider()));
    return _rt;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Playing functions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // trigger but catch with synchroniser
  public void trigger(char _c){
    TweakableTemplate _tp = getTemplate(_c);
    if(_tp == null) return;
    trigger(_tp);
    // sync.templateInput(_tp);
  }

  public void trigger(TweakableTemplate _tp){
    if(_tp == null) return;
    _tp.launch(); // increments the launchCount
    // get groups with template
    ArrayList<SegmentGroup> _groups = groupManager.getGroups(_tp);
    if(_groups.size() > 0){
      for(SegmentGroup _sg : _groups){
        eventList.add(eventFactory(_tp, _sg));
      }
    }
  }

  // trigger a letter + group
  public void trigger(char _c, int _id){
    SegmentGroup _sg = groupManager.getGroup(_id);
    if(_sg == null) return;
    TweakableTemplate _tp = getTemplate(_c);
    if(_tp == null) return;
    eventList.add(eventFactory(_tp, _sg));
  }

  // trigger a templateList, in this case via the
  public void trigger(TemplateList _tl){
    if(_tl == null) return;
    ArrayList<TweakableTemplate> _tp = _tl.getAll();
    if(_tp == null) return;
    if(_tp.size() > 0){
      for(TweakableTemplate tw : _tp){
        if(tw.getEnablerMode() != 3) trigger(tw); // check if is in the right enabler mode
      }
    }
  }

  // osc trigger many things and gps
  public void oscTrigger(String _tags, int _gp){
    for(int i = 0; i < _tags.length(); i++){
      if(_gp != -1) trigger(_tags.charAt(i), _gp);
      else trigger(_tags.charAt(i));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Select all the templates in order to tweak them all. Triggered by ctrl-a
   */
  public void focusAll() {
    templateList.clear();
    for (TweakableTemplate r_ : templates) {
      templateList.toggle(r_);
    }
  }

  /**
   * unSelect templates
   */
  public void unSelect(){
    templateList.clear();
  }

  /**
   * toggle template selection
   */
  public void toggle(char _c){
    templateList.toggle(getTemplate(_c));
  }


  /**
   * Copy one template into an other. Triggered by ctrl-c with 2 templates selected.
   */
  // public void copyPaste(){
  //   Template a = templateList.getIndex(0);
  //   Template b = templateList.getIndex(1);
  //   if(a != null && b !=null) b.copyParameters(a);
  // }

  /**
   * Copy a template and maybe paste it automaticaly. Triggered by ctrl-c with 2 templates selected.
   */
  public void copyTemplate(){
    TweakableTemplate toCopy = templateList.getIndex(0);
    TweakableTemplate pasteInto = templateList.getIndex(1);
    copyTemplate(toCopy, pasteInto);
  }

  // for ABCD (A->BCD)
  public void copyTemplate(String _tags){
    ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
    if(_tmps == null) return;
    if(_tmps.size() == 1) copyTemplate(_tmps.get(0), null);
    else
      for(int i = 1; i < _tmps.size(); i++)
        copyTemplate(_tmps.get(0), _tmps.get(i));
  }

  public void copyTemplate(TweakableTemplate _toCopy, TweakableTemplate _toPaste){
    copyedTemplate = _toCopy;
    if(copyedTemplate != null && _toPaste != null) _toPaste.copyParameters(copyedTemplate);
  }

  /**
   * Paste a previously copyed template into an other
   */
  public void pasteTemplate(){
    pasteTemplate(templateList.getTags());
  }

  public void pasteTemplate(String _tags){
    ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
    if(_tmps == null) return;
    if(_tmps.size() == 1) pasteTemplate(_tmps.get(0));
    else
      for(int i = 0; i < _tmps.size(); i++)
        pasteTemplate(_tmps.get(i));
  }

  public void pasteTemplate(TweakableTemplate _pasteInto){
    if(copyedTemplate != null && _pasteInto != null) _pasteInto.copyParameters(copyedTemplate);
  }

  /**
   * Toggle a template for groups matching first template
   */
  public void groupAddTemplate(){
    groupAddTemplate(templateList.getTags());
  }

  public void groupAddTemplate(String _tags){
    ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
    if(_tmps == null) return;
    if(_tmps.size() == 1) return;
    else
      for(int i = 1; i < _tmps.size(); i++)
        groupAddTemplate(_tmps.get(0), _tmps.get(i));
  }

  public void groupAddTemplate(TweakableTemplate _a, TweakableTemplate _b){
    if(_a != null && _b !=null) groupManager.groupAddTemplate(_a, _b);
  }

  /**
   * Swap Templates (AB), swaps their related geometry also
   */
  public void swapTemplates(String _tags){
    ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
    if(_tmps.size() < 2) return;
    else swapTemplates(_tmps.get(0), _tmps.get(1));
  }

  // might remove the copy? not sure.
  public void swapTemplates(TweakableTemplate _a, TweakableTemplate _b){
    TweakableTemplate _c = new TweakableTemplate();
    _c.copyParameters(_a);
    _a.copyParameters(_b);
    _b.copyParameters(_c);
    groupSwapTemplate(_a, _b);
  }

  public void groupSwapTemplate(TweakableTemplate _a, TweakableTemplate _b){
    if(_a != null && _b !=null) groupManager.groupSwapTemplate(_a, _b);
  }

  /**
   * ResetTemplate
   */
  public void resetTemplate(){
   resetTemplate(templateList.getTags());
  }

  public void resetTemplate(String _tags){
    if(_tags == null) return;
    else if(_tags.length() > 0){
      ArrayList<TweakableTemplate> _tps = getTemplates(_tags);
      if(_tps != null) for(TweakableTemplate _tp : _tps) _tp.reset();
    }
  }
  /**
   * Set a template's custom color, this is done with OSC.
   */
  public void setCustomColor(String _tags, color _c){
    ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
    if(_tmps == null) return;
    for(TweakableTemplate _tp : _tmps){
      if(_tp != null) _tp.setCustomColor(_c);
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Saving and loading with XML
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void saveTemplates(){
    saveTemplates("../userdata/templates.xml");
  }

  /**
   * Simple save templates to xml file.
   */
  public void saveTemplates(String _fn){
    XML _templates = new XML("templates");
    for(Template _tp : templates){
      XML _tmp = _templates.addChild("template");
      _tmp.setString("ID", str(_tp.getTemplateID()));
      _tmp.setInt("renderMode", _tp.getRenderMode());
      _tmp.setInt("segmentMode", _tp.getSegmentMode());
      _tmp.setInt("animationMode", _tp.getAnimationMode());
      _tmp.setInt("interpolateMode", _tp.getInterpolateMode());
      _tmp.setInt("strokeMode", _tp.getStrokeMode());
      _tmp.setInt("fillMode", _tp.getFillMode());
      _tmp.setInt("strokeAlpha", _tp.getStrokeAlpha());
      _tmp.setInt("fillAlpha", _tp.getFillAlpha());
      _tmp.setInt("rotationMode", _tp.getRotationMode());
      _tmp.setInt("easingMode", _tp.getEasingMode());
      _tmp.setInt("reverseMode", _tp.getReverseMode());
      _tmp.setInt("repetitionMode", _tp.getRepetitionMode());
      _tmp.setInt("repetitionCount", _tp.getRepetitionCount());
      _tmp.setInt("beatDivider", _tp.getBeatDivider());
      _tmp.setInt("strokeWidth", _tp.getStrokeWeight());
      _tmp.setInt("brushSize", _tp.getBrushSize());
      _tmp.setInt("miscValue", _tp.getMiscValue());
      _tmp.setInt("enablerMode", _tp.getEnablerMode());
      _tmp.setInt("renderLayer", _tp.getRenderLayer());
    }
    saveXML(_templates, "../userdata/"+_fn);
  }

  public void loadTemplates(){
    loadTemplates("templates.xml");
  }

  public void loadTemplates(String _fn){
    XML file;
    try {
      file = loadXML("../userdata/"+_fn);
    }
    catch (Exception e){
      println(_fn+" cant be loaded");
      return;
    }
    XML[] _templateData = file.getChildren("template");
    TweakableTemplate _tmp;
    for(XML _tp : _templateData){
      _tmp = getTemplate(_tp.getString("ID").charAt(0));
      if(_tmp == null) continue;
      _tmp.setRenderMode(_tp.getInt("renderMode"));
      _tmp.setSegmentMode(_tp.getInt("segmentMode"));
      _tmp.setAnimationMode(_tp.getInt("animationMode"));
      _tmp.setInterpolateMode(_tp.getInt("interpolateMode"));
      _tmp.setStrokeMode(_tp.getInt("strokeMode"));
      _tmp.setFillMode(_tp.getInt("fillMode"));
      _tmp.setStrokeAlpha(_tp.getInt("strokeAlpha"));
      _tmp.setFillAlpha(_tp.getInt("fillAlpha"));
      _tmp.setRotationMode(_tp.getInt("rotationMode"));
      _tmp.setEasingMode(_tp.getInt("easingMode"));
      _tmp.setReverseMode(_tp.getInt("reverseMode"));
      _tmp.setRepetitionMode(_tp.getInt("repetitionMode"));
      _tmp.setRepetitionCount(_tp.getInt("repetitionCount"));
      _tmp.setBeatDivider(_tp.getInt("beatDivider"));
      _tmp.setStrokeWidth(_tp.getInt("strokeWidth"));
      _tmp.setBrushSize(_tp.getInt("brushSize"));
      _tmp.setMiscValue(_tp.getInt("miscValue"));
      _tmp.setEnablerMode(_tp.getInt("enablerMode"));
      _tmp.setRenderLayer(_tp.getInt("renderLayer"));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Setting custom shapes
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // set a decorator's shape
  private void setCustomShape(SegmentGroup _sg){
    if(_sg == null) return;
    ArrayList<TweakableTemplate> temps = _sg.getTemplateList().getAll();

    if(_sg.getShape() == null) return;

    PShape sourceShape = cloneShape(_sg.getShape(), 1.0, _sg.getCenter());
    //println("Setting customShape of "+temp.getTemplateID()+" with a shape of "+sourceShape.getVertexCount()+" vertices");

    int vertexCount = sourceShape.getVertexCount();
    if(vertexCount > 0){
      // store the widest x coordinate
      float maxX = 0.0001;
      float minX = -0.0001;
      float mx = 0;
      float mn = 0;
      // check how wide the shape is to scale it to the BASE_SIZE
      for(int i = 0; i < vertexCount; i++){
        mx = sourceShape.getVertex(i).x;
        mn = sourceShape.getVertex(i).y;
        if(mx > maxX) maxX = mx;
        if(mn < minX) minX = mn;
      }
      // return a brush scaled to the BASE_SIZE
      float baseSize = (float)new PointBrush().BASE_SIZE;
      PShape cust = cloneShape(sourceShape, baseSize/(maxX+abs(minX)), new PVector(0,0));
      if(temps != null)
        for(TweakableTemplate temp : temps)
          if(temp != null)
            temp.setCustomShape(cust);
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Mutators
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public Synchroniser getSynchroniser(){
    return sync;
  }

  public Sequencer getSequencer(){
    return sequencer;
  }

  public ArrayList<RenderableTemplate> getLoops(){
    return loops;
  }

  public ArrayList<RenderableTemplate> getEvents(){
    return eventList;
  }

  public boolean isFocused(){
    return templateList.getIndex(0) != null;
  }

  public TweakableTemplate getTemplate(char _c){
    if(_c >= 'A' && _c <= 'Z') return templates.get(int(_c)-'A');
    else return null;
  }

  public RenderableTemplate getByIDandGroup(ArrayList<RenderableTemplate> _tps, char _id, SegmentGroup _sg){
    for(RenderableTemplate tp : _tps){
      if(tp.getTemplateID() == _id && tp.getSegmentGroup() == _sg) return tp;
    }
    return null;
  }

  public TemplateList getTemplateList(){
    return templateList;
  }

  public ArrayList<TweakableTemplate> getTemplates(){
    return templates;
  }

  // a fancier accessor, supports "ANCD" "*"
  public ArrayList<TweakableTemplate> getTemplates(String _tags){
    if(_tags.length() < 1) return null;
    ArrayList<TweakableTemplate> _tmps = new ArrayList();
    if(_tags.length() == 0) return null;
    else if(_tags.charAt(0) == '$'){
      if(templateList.getAll() == null) return null;
      if(templateList.getAll().size() == 0) return null;
      for(TweakableTemplate _tw : templateList.getAll()){
        if(_tw != null) _tmps.add(_tw);
      }
    }
    else if(_tags.charAt(0) == '*'){
      for(TweakableTemplate _tw : getTemplates()){
        if( _tw != null) _tmps.add(_tw);
      }
    }
    else {
      for(int i = 0; i < _tags.length(); i++){
        TweakableTemplate _tw = getTemplate(_tags.charAt(i));
        if( _tw != null) _tmps.add(_tw);
      }
    }
    return _tmps;
  }

}
