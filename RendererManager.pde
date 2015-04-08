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
 * Manage all the renderers
 *
 */
class RendererManager{
	//selects renderers to control
  RenderList renderList;

  Synchroniser sync;

  //enable or disable all the renderers
  boolean allLoop = true;

  //renderers
  ArrayList<Renderer> renderers;
  final int N_RENDERERS = 26;

  //graphics for rendering
  PGraphics canvas;

  //draw a solid or transparent 
  boolean trails;
  int trailmix;


  public RendererManager(){
    sync = new Synchroniser();
  	renderList = new RenderList();
    canvas = createGraphics(width, height);
    canvas.smooth(0);
    canvas.ellipseMode(CENTER);
    trails = false;
    trailmix = 30;
  	init();
  }

  private void init() {
    renderers = new ArrayList();
    for (int i = 0; i < N_RENDERERS; i++) {
      renderers.add(new Renderer(char(65+i)));
    }
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

  void update(ArrayList<SegmentGroup> _sgarray) {
    sync.update();
    
    canvas.beginDraw();
    if(trails) alphaBG(canvas);
    else canvas.clear();
    if(liquid){
      fill(255);
      rect(1024,0,1024,768);
    }
    for (Renderer r_ : renderers) {
      r_.passLerper(sync.getLerp(r_.getDivider()));
      r_.passCycle(sync.getCycle(r_.getDivider()));
    }
    for(SegmentGroup sg : _sgarray){
      renderGroup(sg);
    }
    
    canvas.endDraw();
  }


  void renderGroup(SegmentGroup _sg){
    ArrayList<Renderer> rList = _sg.getRenderList().getAll();
    if(rList != null){
      for (Renderer r_ : rList) {
        r_.passCanvas(canvas);
        r_.passSegmentGroup(_sg);
        r_.iterator();
      }
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Effects
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void alphaBG(PGraphics _pg) {
    _pg.fill(0, 0, 0, trailmix);
    _pg.stroke(0, 0, 0, trailmix);
    _pg.rect(0, 0, width, height);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public void trigger(char _c){
    Renderer r_ = getRenderer(_c);
    if(r_ != null) r_.trigger();
  }

  public void focusAll() {
    renderList.clear();
    for (Renderer r_ : renderers) {
      renderList.toggle(r_);
    }
  }

  // set a decorator's shape
  private void setCustomShape(SegmentGroup _sg){
    Renderer r_ = renderList.getIndex(0);
    if(r_ != null) r_.setCustomShape(cloneShape(_sg.getShape(), 1.0, _sg.getCenter()));
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Mutators
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public boolean toggleLooping() {
    allLoop = !allLoop;
    for (int i = 0; i<N_RENDERERS; i++) {
      renderers.get(i).setLooper(allLoop);
    }
    return allLoop;
  }

  public boolean toggleTrails(){
    trails = !trails;
    return trails;
  }

  public int setTrails(int v){
    trailmix = numTweaker(v, trailmix);
    return trailmix;
  }

  public void unSelect(){
    renderList.clear();
  }

  public void toggle(char _c){
    renderList.toggle(getRenderer(_c));
  }

  // public void toggle(Renderer _rn){
  //   renderList.toggle(_rn);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean isFocused(){
    return renderList.getIndex(0) != null;
  }

  public Renderer getRenderer(char _c){
    if(_c >= 'A' && _c <= 'Z') return renderers.get(int(_c)-'A');
    else return null;
  }

  // public ArrayList<Renderer> getSelected(){
  //   return renderList.getAll();
  // }
  
  public RenderList getRenderList(){
    return renderList;
  }

  public PGraphics getCanvas(){
    return canvas;
  }
}