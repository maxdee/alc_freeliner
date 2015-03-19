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
  int rendererCount = 24;

  //graphics buffers
  PGraphics canvas;

  //draw a solid or transparent 
  boolean trails;
  int trailmix = 20;


  public RendererManager(){
    sync = new Synchroniser();
  	renderList = new RenderList();
    canvas = createGraphics(width, height);
    canvas.smooth(0);

    ellipseMode(CENTER);

    trails = false;
  	init();
  }

  private void init() {
    renderers = new ArrayList();
    for (int i = 0; i < rendererCount; i++) {
      renderers.add(new Renderer(char(65+i)));
    }
  }

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
    renderers.get(charIndex(_c)).trigger();
  }

  public void focusAll() {
    renderList.clear();
    for (int i = 0; i < rendererCount; i++) {
      renderList.toggle(renderers.get(i).getID());
    }
  }

  public int charIndex(char c){
    int ind = 0;
    if(c >= 65) ind = int(c)-65;
    return ind % rendererCount;
  }

  // new effects here for nuance!
  // such as one groups renderer
  // X number of groups
  // left to right things
  void update(ArrayList<SegmentGroup> _sgarray) {
    float lrp = 0;
    int rndr = 0;
    int dv = 0;
    int inc = 0;
    RenderList fl;
    sync.update();
    canvas.beginDraw();
    if(trails) alphaBG(canvas);
    else canvas.clear();   

    for (int j = 0; j < rendererCount; j++) {
      dv = renderers.get(j).getDivider();
      lrp = sync.clocks.get(dv).getLerper();
      inc = sync.clocks.get(dv).getIncrement();
      renderers.get(j).clockWorks(lrp, inc);
    }
    for(SegmentGroup sg : _sgarray){
      renderGroup(sg);
    }
    
    canvas.endDraw();
  }


  void renderGroup(SegmentGroup _sg){
    RenderList rList = _sg.getRenderList();
    for (int j = 0; j < rendererCount; j++) {
      if (rList.has(renderers.get(j).getID())) {
        renderers.get(j).passData(canvas, _sg);
        renderers.get(j).iterator();
      }
    }
  }
  //add some auto modes!

  private void triggerGroups(char k) {

  }
  
  // set a decorator's shape 
  private void setCustomShape(SegmentGroup _sg){
      //println("CustomShape with item : "+ n);
    char c_ = renderList.getFirst();
    if(c_ != '_'){
      renderers.get(charIndex(c_)).setCustomShape(cloneShape(_sg.getShape(), 1.0, _sg.getCenter()));
    }
  }

  private int getRendererIndex(char c) {
    int i = int(c)-'A';
    if (i>=rendererCount) {
      println("Not a decorator");
      return 0;
    } else return i;
  }


  public final boolean isAdeco(char c){
    boolean ha = false;
    for (int i = 0; i < rendererCount; i++) {
      if(renderers.get(i).getID() == c) ha =true;
    }
    return ha;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public boolean toggleLooping() {
    allLoop = !allLoop;
    for (int i = 0; i<rendererCount; i++) {
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

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean isFocused(){
    return renderList.getFirst() != '_';
  }

  public Renderer getRenderer(char _c){
    if(isAdeco(_c)) return renderers.get(charIndex(_c));
    else return null;
  }

  public ArrayList<Renderer> getSelected(){
    ArrayList<Renderer> selected_ = new ArrayList();
    for (int i = 0; i < rendererCount; i++) {
      if(renderList.has(renderers.get(i).getID())){
      selected_.add(renderers.get(i));
      }
    }
    return selected_;
  }
  
  public RenderList getList(){
    return renderList;
  }

  public PGraphics getCanvas(){
    return canvas;
  }
}