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
  final int N_TEMPLATES = 26;

  // events to render
  ArrayList<RenderableTemplate> eventList;
  ArrayList<RenderableTemplate> loops;
  // synchronise things
  Synchroniser sync;


  public TemplateManager(){
    sync = new Synchroniser();
  	templateList = new TemplateList();
    loops = new ArrayList();
    eventList = new ArrayList();
  	init();
  }

  private void init() {
    templates = new ArrayList();
    for (int i = 0; i < N_TEMPLATES; i++) {
      TweakableTemplate te = new TweakableTemplate(char(65+i));
      templates.add(te);
    }
  }

  // update the render events
  void update() {
    sync.update();
    int beatDv = 1;
    if(loops.size() > 0){
      for (RenderableTemplate rt : loops) {
        beatDv = rt.getBeatDivider();
        rt.setTime(sync.getLerp(beatDv), sync.getPeriod(beatDv));
      }
    }
    if(eventList.size() > 0){
      for (RenderableTemplate rt : eventList) {
        beatDv = rt.getBeatDivider();
        rt.setTime(sync.getLerp(beatDv), sync.getPeriod(beatDv));
      }
    }
  }



  void launchLoops(ArrayList<SegmentGroup> _groups){
    if(_groups.size() == 0) return;
    ArrayList<RenderableTemplate> toKeep = new ArrayList<RenderableTemplate>();
    // check to add new loops
    for(SegmentGroup sg : _groups){
      ArrayList<TweakableTemplate> tmps = sg.getTemplateList().getAll();
      if(tmps != null){
        for(TweakableTemplate te : tmps){
          RenderableTemplate rt = getByIDandGroup(loops, te.getTemplateID(), sg);
          if(rt != null) toKeep.add(rt);
          else toKeep.add(eventFactory(te, sg));
        }
      }
    }
    loops = toKeep;
  }


  RenderableTemplate getByIDandGroup(ArrayList<RenderableTemplate> _tps, char _id, SegmentGroup _sg){
    for(RenderableTemplate tp : _tps){
      if(tp.getTemplateID() == _id && tp.getSegmentGroup() == _sg) return tp;
    }
    return null;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     ETemplate array methods
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  

  // private ArrayList<Template> getByID(ArrayList<Template> _tps, char _id){
  //   ArrayList<RenderableTemplate> tmps = new ArrayList();
  //   for(Template tmp : _tps){
  //     if(tmp.getTemplateID() == _id) tmps.add(tmp);
  //   } 
  //   return tmp;
  // }

  // remove a template from a list by ID
  // private void removeByID(ArrayList<Template> _tps, char _id){
  //   ArrayList<Template> toRemove = new ArrayList();
  //   for(Template tp : _tps){
  //     if(tp.getTemplateID() == _id) toRemove.add(tp);
  //   }
  //   if(toRemove.size() > 0)
  //     for(Template tp : toRemove)
  //       _tps.remove(tp);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Event Factory
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // set size as per scalar
  public RenderableTemplate eventFactory(TweakableTemplate _te, SegmentGroup _sg){
    println("new event");
    return new RenderableTemplate(_te, _sg);
  }




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Rendering
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // new effects here for nuance!
  // such as one groups renderer
  // X number of groups
  // left to right things

  void renderGroup(SegmentGroup _sg){
    // ArrayList<TweakableTemplate> rList = _sg.getTemplateList().getAll();
    // if(rList != null){
    //   for (TweakableTemplate r_ : rList) {
    //     r_.renderGroup(_sg);
    //   }
    // }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public void trigger(char _c){
    TweakableTemplate r_ = getTemplate(_c);
    // Factory!
    //if(r_ != null) r_.trigger(1);
  }

  public void trigger(SegmentGroup _sg){

  }

  public void focusAll() {
    templateList.clear();
    for (TweakableTemplate r_ : templates) {
      templateList.toggle(r_);
    }
  }

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
  ///////     Sub templates
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  // template swaping system? template copying system A -> B

  public void saveTemplate(Template _t){

  }




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Mutators
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public boolean toggleLooping() {
    // allLoop = !allLoop;
    // for (int i = 0; i<N_TEMPLATES; i++) {
    //   templates.get(i).setLooper(allLoop);
    // }
    // return allLoop;
    return false;
  }

  public void unSelect(){
    templateList.clear();
  }

  public void toggle(char _c){
    templateList.toggle(getTemplate(_c));
  }

  // public void toggle(TweakableTemplate _rn){
  //   templateList.toggle(_rn);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public Synchroniser getSynchroniser(){
    return sync;
  }

  public ArrayList<RenderableTemplate> getEvents(){
    // ArrayList<RenderableTemplate> rt = new ArrayList<RenderableTemplate>(loops);
    // rt.add()
    return loops;//eventList;
  } 

  public boolean isFocused(){
    return templateList.getIndex(0) != null;
  }

  public TweakableTemplate getTemplate(char _c){
    if(_c >= 'A' && _c <= 'Z') return templates.get(int(_c)-'A');
    else return null;
  }

  // public ArrayList<TweakableTemplate> getSelected(){
  //   return templateList.getAll();
  // }
  
  public TemplateList getTemplateList(){
    return templateList;
  }

}