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

  //manages groups of points
  ArrayList<SegmentGroup> groups;
  int groupCount = 0;
  //selects groups to control, -1 for not selected
  int selectedIndex;
  int lastSelectedIndex;
  int snappedIndex;
  int snapDist = 15;
  // list of PVectors that are snapped
  ArrayList<PVector> snappedList;
  Segment snappedSegment;

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
    snappedSegment = null;
    newGroup();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Create a new group.
 */
  public void newGroup() {
    groups.add(new SegmentGroup(groupCount));
    selectedIndex = groupCount;
    groupCount++;
  }

/**
 * Tab the focus through groups.
 * @param boolean reverse direction (shift+tab) 
 */
  public void tabThrough(boolean _shift) {
    if(!isFocused()) selectedIndex = lastSelectedIndex;
    else if (_shift) selectedIndex--;
    else selectedIndex++;
    selectedIndex = wrap(selectedIndex, groupCount-1);
  }

/**
 * Add an other renderer to all groups who have the first renderer.
 * @param renderer to add
 * @param renderer to match
 */
  public void groupAddTemplate(TweakableTemplate _toAdd, TweakableTemplate _toMatch){
    if(groups.size() > 0 && _toAdd != null && _toMatch != null){
      for (SegmentGroup sg : groups) {
        TemplateList tl = sg.getTemplateList();
        if(tl != null)
          if(tl.contains(_toMatch))         
            tl.toggle(_toAdd);
      }
    }
  }

/**
 * Snap puts all the PVectors that are near the position given into a arrayList.
 * The snapDist can be adjusted like anything else. 
 * It returns the place it snapped to to adjust cursor.
 * @param PVector of the cursor
 * @return PVector where it snapped.
 */
  public PVector snap(PVector _pos){
    PVector snap = new PVector(0, 0);
    snappedList.clear();
    snappedIndex = -1;
    snappedSegment = null;
    ArrayList<Segment> segs;
    for (int i = 0; i < groupCount; i++) {
      segs = groups.get(i).getSegments();
      // check if snapped to center
      if(_pos.dist(groups.get(i).getCenter()) < snapDist){
        snappedList.add(groups.get(i).getCenter());
        snap = groups.get(i).getCenter();
        snappedIndex = i;    
      }
      for(Segment seg : segs){
        if(_pos.dist(seg.getRegA()) < snapDist){
          snappedList.add(seg.getRegA());
          snap = seg.getRegA();
          snappedIndex = i;        }
        else if(_pos.dist(seg.getRegB()) < snapDist){
          snappedList.add(seg.getRegB());
          snap = seg.getRegB();
          snappedIndex = i;
        }
        else if (_pos.dist(seg.getMidPoint()) < snapDist){
          snappedSegment = seg;
          snap = seg.getMidPoint();
          snappedIndex = i;
        }
      }
    }    
    if (snappedIndex != -1){
      if(selectedIndex == -1) lastSelectedIndex = snappedIndex; 
      return snap;// snappedList.get(0);
    }
    else return _pos;
  }

/**
 * Nudge all PVectors of the snappedList.
 * If the snapped list is empty and we are focused on a group, nudge the segmentStart.
 * @param boolean verticle/horizontal
 * @param int direction (1 or -1)
 * @param boolean nudge 10X more
 */
  public void nudger(Boolean axis, int dir, boolean _shift){
    PVector ndg = new PVector(0, 0);
    if(_shift) dir*=10;
    if (axis) ndg.set(dir, 0);
    else ndg.set(0, dir);
    if(snappedList.size()>0){
      for(PVector _pv : snappedList){
        _pv.add(ndg);
      }
      //setCenter(center);
      reCenter();
    }
    else if(isFocused()) getSelectedGroup().nudgeSegmentStart(ndg);
  }

  private void reCenter(){
    for(SegmentGroup sg : groups){
      if(sg.isCentered()
        ) sg.placeCenter(sg.getCenter());
    }
  }

  private void deleteSegment(){
    if(snappedSegment == null || getSelectedGroup() == null) return;
    getSelectedGroup().deleteSegment(snappedSegment);
    snappedSegment = null;
    snappedIndex = -1;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Save and load
  ///////
  ////////////////////////////////////////////////////////////////////////////////////



  public void saveGroups(){
    //ArrayList<PVector> pnts = new ArrayList();
    XML groupData = new XML("groups");
    for(SegmentGroup grp : groups){
      XML xgroup = groupData.addChild("group");
      xgroup.setInt("ID", grp.getID());
      xgroup.setFloat("centerX", grp.getCenter().x);
      xgroup.setFloat("centerY", grp.getCenter().y);
      for(Segment seg : grp.getSegments()){
        XML xseg = xgroup.addChild("segment");
        xseg.setFloat("aX",seg.getRegA().x);
        xseg.setFloat("aY",seg.getRegA().y);
        xseg.setFloat("bX",seg.getRegB().x);
        xseg.setFloat("bY",seg.getRegB().y);
      }
      saveXML(groupData, "data/groups.xml");
    }
  }


  // what a mess what a mess
  // we cant have that we cant have that
  // clean it up clean it up
  public void loadGroups(){
    XML file;
    try {
      file = loadXML("data/groups.xml");
    }
    catch (Exception e){
      println("No groups.xml");
      return;
    }

    XML[] groupData = file.getChildren("group");
    PVector posA = new PVector(0,0);
    PVector posB = new PVector(0,0);
    boolean first = true;

    for(XML xgroup : groupData){
      if(first){
        first = false;
        continue;
      }
      newGroup();
      XML[] xseg = xgroup.getChildren("segment");
      for(XML seg : xseg){
        posA.set(seg.getFloat("aX"), seg.getFloat("aY"));
        posB.set(seg.getFloat("bX"), seg.getFloat("bY"));
        getSelectedGroup().addSegment(posA.get(), posB.get()); 
      }
      getSelectedGroup().mouseInput(LEFT, posB);
      getSelectedGroup().setNeighbors();
      posA.set(xgroup.getFloat("centerX"), xgroup.getFloat("centerY"));
      // bug with centering? seems ok...
      if(abs(posA.x - getSelectedGroup().getSegment(0).getA().x) > 2) getSelectedGroup().placeCenter(posA);
    }
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Unselect selected group
 */  
  public void unSelect(){
    lastSelectedIndex = selectedIndex;
    selectedIndex = -1;
  }

/**
 * Unselect selected group
 */  
  // public int setSelectedGroupIndex(int _i) {
  //   selectedIndex = _i % groupCount;
  //   return selectedIndex;
  // }

/**
 * Adjust the snapping distance.
 * @param int adjustement to make
 * @return int new value
 */  
  public int setSnapDist(int _i){
    snapDist = numTweaker(_i, snapDist);
    return snapDist;
  }

  // public void toggle(TemplateEvent _rn){
  //   renderList.toggle(_rn);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Get renderList of the selected group, null if no group selected.
 * @return renderList
 */  
  public TemplateList getTemplateList(){
    SegmentGroup sg = getSelectedGroup();
    if(sg != null) return sg.getTemplateList();
    else return null;
  }

/**
 * Check if a group is focused
 * @return boolean 
 */  
  boolean isFocused(){
    if(snappedIndex != -1 || selectedIndex != -1) return true;
    else return false;
  }

/**
 * Get the selectedGroupIndex, will return -1 if nothing selected, used by gui
 * @return int index
 */  
  public int getSelectedIndex(){
    return selectedIndex;
  }

/**
 * Get the selectedGroup, or the snapped one, or null
 * @return SegmentGroup
 */ 
  public SegmentGroup getSelectedGroup(){
    if(snappedIndex != -1 && selectedIndex == -1) return groups.get(snappedIndex);
    else if(selectedIndex != -1 && selectedIndex <= groupCount) return groups.get(selectedIndex);
    else return null;
  }

/**
 * Get the previously selected group, or null
 * Used to set the previously selected group as a renderer's custom shape.
 * @return SegmentGroup
 */ 
  public SegmentGroup getLastSelectedGroup(){
    if(lastSelectedIndex != -1 ) return groups.get(lastSelectedIndex);
    else return null;
  }

/**
 * Get a specific group
 * @return SegmentGroup
 */
  public SegmentGroup getGroup(int _i){
    if(_i >= 0 && _i < groupCount) return groups.get(_i);
    else return null;
  }

/**
 * Get all the groups
 * @return SegmentGroup
 */
  public ArrayList<SegmentGroup> getGroups(){
    return groups;
  }

/**
 * Get the snappedSegment
 * @return Segment
 */
  public Segment getSnappedSegment(){
    return snappedSegment;
  }



/**
 * Get the last point of a group
 * @return SegmentGroup
 */
  public PVector getPreviousPosition() {
    if (isFocused()) return getSelectedGroup().getLastPoint();
    else return new PVector(width/2, height/2, 0);
  }

}