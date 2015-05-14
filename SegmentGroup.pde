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
 * SegmentGroup is an arrayList of Segment with one center point
 * <p>
 * A group of segments that can have a center, renderer tags, a brush size scalar and a random number.
 * </p>
 *
 * @see Renderer
 */

class SegmentGroup {
  final int ID;
  float brushScaler = 1.0;
  int sizer = 10;
  PShape itemShape;

  ArrayList<Segment> segments;

  ArrayList<ArrayList<Segment>> treeBranches; 
  int segCount = 0;
  TemplateList templateList;
  PVector center;
  PVector segmentStart;
  boolean firstPoint;
  boolean seperated;

  boolean centered;
  boolean centerPutting;

  boolean launchit = false;
  boolean incremented = false;

  int snapVal = 10;

  /**
   * Create an new SegmentGroup
   * @param  identification interger
   */
  public SegmentGroup(int _id) {
    ID = _id;
    init();
  }


  /**
   * Initialises variables, can be used to reset a group.
   */
  public void init(){
    segments = new ArrayList();
    treeBranches = new ArrayList();
    templateList = new TemplateList();
    segmentStart = new PVector(-10, -10, -10);
    center = new PVector(-10, -10, -10);
    firstPoint = true;
    centered = false;
    centerPutting = false;
    seperated = false;
    generateShape();
  }

  public void updateGeometry(){
    setNeighbors();
    findRealNeighbors();
    if(centered) placeCenter(center);
    generateShape();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Management, Segment creation and such
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Start a new segment from a coordinate
   * @param PVector starting coordinate
   */
  private void startSegment(PVector p) {
    if(firstPoint) center = p.get();
    segmentStart = p.get();
    firstPoint = false;
  }

  /**
   * Make a segment by placing the second point.
   * A few things are updated such as the neighbors and shape.
   * @param PVector ending coordinate
   */
  private void endSegment(PVector p) {
    addSegment(segmentStart, p);
    segmentStart = p.get();
    seperated = false;
    updateGeometry();
  }

  public void addSegment(PVector _a, PVector _b){
    segments.add(new Segment(_a, _b));
    segCount++;
  }

  /**
   * Start a new segment somewhere else than the current segmentStart
   * A few things are updated such as the neighbors and shape.
   * @param PVector ending coordinate
   */
  private void breakSegment(PVector p) {
    seperated = true;
    segmentStart = p.get();
  }

  /**
   * Nudge the segmentStart or the center.
   * @param PVector ending coordinate
   */
  private void nudgeSegmentStart(PVector p) {
    PVector np = segmentStart.get();
    // nudge the last point.
    if (!centerPutting) {
      np.add(p);
      if (segCount == 0 || seperated) breakSegment(np);
      else {
        undoSegment();
        endSegment(np);
      }
    } 
    // nudge the center
    else {
      np = center.get();
      np.add(p);
      placeCenter(np);
      centerPutting = true;
      updateGeometry();
    }
  }

  /**
   * Nudge the segmentStart.
   * @param PVector ending coordinate
   */
  private void undoSegment() {
    if (segCount > 0) {
      float dst = segmentStart.dist(segments.get(segCount-1).pointB.get());
      if(dst > 0.001){
        segmentStart = segments.get(segCount-1).pointB.get();
      }
      else {
        segmentStart = segments.get(segCount-1).pointA.get();
        segments.remove(segCount-1);
        segCount--;
      }
      updateGeometry();
    }
  }

  private void placeCenter(PVector c) {
    center = c.get();
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        segments.get(i).setCenter(center);
      }
      centered = true;
      generateShape();
    }
    centerPutting = false;
  }

  private void unCenter() {
    centered = false;
    for(Segment seg : segments)
      seg.unCenter();
    centerPutting = false;
  }

  private void setNeighbors() {
    int v1 = 0;
    int v2 = 0;
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        v1 = i-1;
        v2 = i+1;
        if (i==0) v1 = segCount-1; // maybe wrong
        if (i==segCount-1) v2 = 0;
        segments.get(i).setNeighbors(segments.get(v1), segments.get(v2));
      }
    }
  }

  private void generateShape() {
    itemShape = createShape();
    itemShape.beginShape();
    itemShape.textureMode(NORMAL);
    itemShape.strokeCap(ROUND); //strokeCap(SQUARE);
    itemShape.strokeJoin(ROUND);
    float _x = 0;
    float _y = 0;
    if(segCount!=0){
      for (int i = 0; i < segCount; i++) {
        _x = segments.get(i).getRegA().x;
        _y = segments.get(i).getRegA().y;
        itemShape.vertex(_x, _y, _x/width, _y/height);
      }
      _x = segments.get(0).getRegA().x;
      _y = segments.get(0).getRegA().y;
      itemShape.vertex(_x, _y, _x/width, _y/height);
    }
    else {
      itemShape.vertex(0,0);
      itemShape.vertex(0,0);
    }

    itemShape.endShape(CLOSE);//CLOSE dosent work...
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment classification
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void findRealNeighbors(){
    treeBranches = new ArrayList();
    ArrayList<Segment> roots = new ArrayList();
    // find first segments, layer 1
    boolean root = true;
    for(Segment toCheck : segments){
      root = true;
      for(Segment seg : segments){
        if(toCheck.getRegA().dist(seg.getRegB()) < 0.1){
          root = false;
        }
      }
      if(root) roots.add(toCheck);
    }
    treeBranches.add(roots);

    boolean keepSearching = true;
    int ind = 0;
    while(keepSearching){
      ArrayList<Segment> next = getNext(treeBranches.get(ind++));
      if(next.size() > 0) treeBranches.add(next);
      else keepSearching = false;
    }
  }


  private ArrayList<Segment> getNext(ArrayList<Segment> _segs){
    ArrayList<Segment> nextSegs = new ArrayList();
    boolean duplicate = false;
    for(Segment seg : _segs){
      for(Segment next : segments){
        if(seg.getRegB().dist(next.getRegA()) < 0.001){
          // check duplicates
          duplicate = false;
          for(ArrayList<Segment> br : treeBranches){
            for(Segment se : br){
              if(next == se) duplicate = true;
            }
          }
          if(!duplicate) nextSegs.add(next);
        } 
      }
    } 
    return nextSegs;
  }

  // private boolean isDuplicate(ArrayList<ArrayList<Segment>> _tree, Segment seg) {
  //   for(ArrayList<Segment> br : treeBranches){
  //     for(Segment se : br){
  //       if(next == se) return true;
  //     }
  //   }
  //   return false;
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment access
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // deprecate
  public final ArrayList<Segment> getSegments() {
    return segments;
  }

  // Segment accessors
  public Segment getSegment(int _index){
    //if(_index >= segments.size()) return null;
    if(segments.size() > 0 && _index >= 0) return segments.get(_index % segments.size());
    return null;
  }
  
  public ArrayList<ArrayList<Segment>> getBranches(){
    return treeBranches; 
  } 

  public ArrayList<Segment> getBranch(int _i){
    //println("branches "+ treeBranches.size()+" index "+_i);
    if(treeBranches.size() == 0) return null;
    return treeBranches.get(_i%treeBranches.size());
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void mouseInput(int mb, PVector c) {
    if (mb == 37 && centerPutting) placeCenter(c);
    else if (mb == 39 && centerPutting) unCenter();
    else if (mb == 37 && firstPoint) startSegment(c); 
    else if (mb == 37 && !firstPoint) endSegment(c);
    else if (mb == 39) undoSegment();
    else if (mb == 3) breakSegment(c);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void toggleTemplate(TweakableTemplate _te) {
    templateList.toggle(_te);
  }

  public void setWord(String w, int v) {
    if (segCount >= 1 && v == -1) segments.get(segCount-1).setWord(w);
    else if (v<segCount) segments.get(v).setWord(w);
  } 

  public void newRan(){
    for (int i = 0; i < segCount; i++) {
      segments.get(i).newRan();
    }
  }

  public boolean toggleCenterPutting(){
    centerPutting = !centerPutting;
    return centerPutting;
  }

  public int setBrushScaler(int s){
    sizer = numTweaker(s, sizer); 
    brushScaler = sizer/10.0;
    return sizer;
  }

  public int setSnapVal(int s){
    snapVal = numTweaker(s, snapVal); 
    return snapVal;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final int getID(){
    return ID;
  }

  public int getCount(){
    return segCount;
  }


  public final PShape getShape(){
    return itemShape;
  }

  public final PVector getCenter(){
    return center;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }


  public final PVector getSegmentStart(){
    return segmentStart;
  }

  public final TemplateList getTemplateList() {
    return templateList;
  }

  public final PVector getLastPoint() {
    return segmentStart.get();
  }

  public final float getBrushScaler(){
    return brushScaler;
  }

}


