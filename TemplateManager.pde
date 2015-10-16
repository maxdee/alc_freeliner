/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
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
  SequenceSync sync;

  GroupManager groupManager;


  public TemplateManager(){
    sync = new SequenceSync();
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
    trigger(sync.getStepList());
    // check for events?
    // set the unitinterval/beat for all templates
    syncTemplates(loops);
    syncTemplates(eventList);
    ArrayList<RenderableTemplate> toKill = new ArrayList();
    for(RenderableTemplate _tp : eventList){
      if(((KillableTemplate) _tp).isDone()) toKill.add(_tp);
    }
    if(toKill.size()>0){
      for(RenderableTemplate _rt : toKill){
        eventList.remove(_rt);
      }
    }
  }

  // synchronise renderable templates lists
  private void syncTemplates(ArrayList<RenderableTemplate> _tp){
    ArrayList<RenderableTemplate> lst = new ArrayList<RenderableTemplate>(_tp);
    int beatDv = 1;
    if(_tp.size() > 0){
      for (RenderableTemplate rt : lst) {
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
    sync.templateInput(_tp);
  }

  public void trigger(TweakableTemplate _tp){
    if(_tp == null) return;
    // get groups with template
    ArrayList<SegmentGroup> _groups = groupManager.getGroups(_tp);
    if(_groups.size() > 0){
      for(SegmentGroup _sg : _groups){
        //print(_sg.getID()+", ");
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

  // trigger a templateList
  public void trigger(TemplateList _tl){
    if(_tl == null) return;
    ArrayList<TweakableTemplate> _tp = _tl.getAll();
    if(_tp == null) return;
    if(_tp.size() > 0){
      for(TweakableTemplate tw : _tp) trigger(tw);
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
    copyedTemplate = templateList.getIndex(0);
    TweakableTemplate toGetCopy = templateList.getIndex(1);
    if(copyedTemplate != null && toGetCopy != null) toGetCopy.copyParameters(copyedTemplate);
  }

  /**
   * Paste a previously copyed template into an other
   */
  public void pasteTemplate(){
    TweakableTemplate toGetCopy = templateList.getIndex(0);
    if(copyedTemplate != null && toGetCopy != null) toGetCopy.copyParameters(copyedTemplate);
  }

  public void groupAddTemplate(){
    TweakableTemplate a = templateList.getIndex(0);
    TweakableTemplate b = templateList.getIndex(1);
    if(a != null && b !=null) groupManager.groupAddTemplate(a, b);
  }

  /**
   * Set a template's custom color, this is done with OSC.
   */
  public void setCustomColor(String _tags, color _c){
    for(int i = 0; i < _tags.length(); i++){
      TweakableTemplate tp = getTemplate(_tags.charAt(i));
      if(tp != null) tp.setCustomColor(_c);
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
      for(TweakableTemplate temp : temps)
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

  public SequenceSync getSynchroniser(){
    return sync;
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

}
