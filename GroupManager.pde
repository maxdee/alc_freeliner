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
 * Manage segmentGroups!
 *
 */
class GroupManager{

  //selects groups to control, -1 for not selected
  int selectedIndex;
  int lastSelectedIndex;
  int snappedIndex;
  int SNAP_DIST = 10;
  // list of PVectors that are snapped
  ArrayList<PVector> snappedList;

  //manages groups of points
  ArrayList<SegmentGroup> groups;
  int groupCount = 0;

/**
 * Constructor, inits default values
 */
  public GroupManager(){
  	groups = new ArrayList();
    snappedList = new ArrayList();
  	groupCount = 0;
    selectedIndex = -1;
    lastSelectedIndex = -1;
    snappedIndex = -1;
    newItem();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // create a new item.
  public void newItem() {
    //if (groupCount == 0) groups.add(new SegmentGroup(groupCount));
    //else 
    groups.add(new SegmentGroup(groupCount));
    selectedIndex = groupCount;
    groupCount++;
  }

  // tab and shift-tab through groups
  public void tabThrough(boolean _shift) {
    if(!isFocused()) selectedIndex = lastSelectedIndex;
    else if (_shift)selectedIndex--;
    else selectedIndex++;
    selectedIndex = wrap(selectedIndex, groupCount-1);
  }

  //add an other renderer to all groups who have the first renderer.
  public void groupAddRenderer(Renderer _toAdd, Renderer _toMatch){
    if(groups.size() > 0 && _toAdd != null && _toMatch != null){
      for (SegmentGroup sg : groups) {
        ArrayList<Renderer> rl = sg.getRenderList().getAll();
        if(rl != null)
          if(rl.contains(_toMatch))         
            sg.toggleRender(_toAdd);
      }
    }
  }


  public PVector snap(PVector _pos){
    PVector snap = new PVector(0, 0);
    snappedList.clear();
    snappedIndex = -1;
    ArrayList<Segment> segs;
    for (int i = 0; i < groupCount; i++) {
      segs = groups.get(i).getSegments();
      for(Segment seg : segs){
        if(_pos.dist(seg.getRegA()) < SNAP_DIST){
          snappedList.add(seg.getRegA());
          snap = seg.getRegA();
          snappedIndex = i;        }
        else if(_pos.dist(seg.getRegB()) < SNAP_DIST){
          snappedList.add(seg.getRegB());
          snap = seg.getRegB();
          snappedIndex = i;
        }
        if(!isFocused()) lastSelectedIndex = i; 
      }
    }
    if (snappedIndex != -1) return snap;// snappedList.get(0);
    else return _pos;
  }

  public void nudger(Boolean axis, int dir, boolean _shift){
    PVector ndg = new PVector(0, 0);
    if (axis && _shift) ndg.set(10*dir, 0);
    else if (!axis && _shift) ndg.set(0, 10*dir);
    else if (axis && !_shift) ndg.set(1*dir, 0);
    else if (!axis && !_shift) ndg.set(0, 1*dir);
    //println("-------"+snappedList);
    if(snappedList.size()>0){
      for(PVector _vert : snappedList){
        // println(_vert);
        _vert.add(ndg);
      }
    }
    else if(isFocused()) getSelectedGroup().nudgeLastPoint(ndg);
    // else if (isFocused() && snappedIndex == selectedIndex) {
    //   getSelectedGroup().nudgeSnapped(ndg, _pos); 
    // } 
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Save and load prototypes
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public void saveVertices(){
    ArrayList<PVector> pnts = new ArrayList();
    for(SegmentGroup grp : groups){
      ArrayList<Segment> segs = grp.getSegments(); 
      for(Segment seg : segs){
        if(!isDuplicate(pnts, seg.getRegA())) pnts.add(seg.getRegA());
        if(!isDuplicate(pnts, seg.getRegB())) pnts.add(seg.getRegB());
      }
    }
    XML vertices = new XML("vertices");
    //toSave.removeChild(toSave.getChild("vertices"));
    for(PVector pnt : pnts){
      XML vertx = vertices.addChild("vertex");
      vertx.setFloat("x", pnt.x);
      vertx.setFloat("y", pnt.y);
    }
    saveXML(vertices, "data/vertices.xml");
  }

  private boolean isDuplicate(ArrayList<PVector> _pnts, PVector _pv){
    for(PVector pnt : _pnts){
      if(pnt.dist(_pv) < 0.001) return true;
    }
    return false;
  }

  public void loadVertices(){
    XML file;
    try {
      file = loadXML("data/vertices.xml");
    }
    catch (Exception e){
      println("No vertices.xml");
      return;
    }
    XML[] vertices = file.getChildren("vertex");
    newItem();
    PVector pos = new PVector(0,0);
    for(XML vert : vertices){
      pos.set(vert.getFloat("x"), vert.getFloat("y"));
      getSelectedGroup().mouseInput(LEFT, pos);
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void unSelect(){
    lastSelectedIndex = selectedIndex;
    selectedIndex = -1;
  }

  public int setSelectedGroupIndex(int _i) {
    selectedIndex = _i % groupCount;
    return selectedIndex;
  }

  public int setSnapDist(int _i){
    SNAP_DIST = numTweaker(_i, SNAP_DIST);
    return SNAP_DIST;
  }

  // public void toggle(Renderer _rn){
  //   renderList.toggle(_rn);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public RenderList getRenderList(){
    SegmentGroup sg = getSelectedGroup();
    if(sg != null) return sg.getRenderList();
    else return null;
  }

  boolean isFocused(){
    if(snappedIndex != -1 || selectedIndex != -1) return true;
    else return false;
  }

  public int getSelectedIndex(){
    return selectedIndex;
  }

  public SegmentGroup getSelectedGroup(){
    if(snappedIndex != -1 && selectedIndex == -1) return groups.get(snappedIndex);
    else if(selectedIndex != -1 && selectedIndex <= groupCount) return groups.get(selectedIndex);
    else return null;
  }

  public SegmentGroup getLastSelectedGroup(){
    if(lastSelectedIndex != -1 ) return groups.get(lastSelectedIndex);
    else return null;
  }

  public SegmentGroup getGroup(int _i){
    if(_i >= 0 && _i < groupCount) return groups.get(_i);
    else return null;
  }

  public ArrayList<SegmentGroup> getGroups(){
    return groups;
  }

  public PVector getPreviousPosition() {
    if (isFocused()) return getSelectedGroup().getLastPoint();
    else return new PVector(width/2, height/2, 0);
  }

}