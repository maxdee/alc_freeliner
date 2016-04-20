/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
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
  int segCount = 0;
  ArrayList<Segment> sortedSegments;
  int sortedSegCount = 0;
  ArrayList<ArrayList<Segment>> treeBranches;

  TemplateList templateList;
  PVector center;
  PVector segmentStart;
  boolean firstPoint;
  boolean seperated;

  boolean centered;
  boolean centerPutting;

  boolean launchit = false;
  boolean incremented = false;

  //for roations
  boolean clockwise = false;

  // new string
  String groupText = "";

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
    sortedSegments = new ArrayList();
    treeBranches = new ArrayList();
    templateList = new TemplateList();
    segmentStart = new PVector(-10, -10, -10);
    center = new PVector(-10, -10, -10);
    firstPoint = true;
    centered = false;
    centerPutting = false;
    seperated = false;
    generateShape();
    groupText = "hi, im geometry "+ID;
  }

  public void updateGeometry(){
    findRealNeighbors();
    sortSegments();
    setNeighbors();
    updateAngles();
    clockwise = findDirection();
    if(centered) placeCenter(center);
    generateShape();
    if(segments.size() == 0) sortedSegments.clear();
  }


  private void updateAngles(){
    for(Segment seg : segments) seg.updateAngle();
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

  /**
   * Make a segment by giving a start and a end
   * @param PVector starting coordinate
   * @param PVector ending coordinate
   */
  public void addSegment(PVector _a, PVector _b){
    segments.add(new Segment(_a, _b));
    segCount++;
    updateGeometry();
  }

  /**
   * Make a segment by giving a start and a end
   * @param Segment to add
   */
  public void addSegment(Segment _seg){
    segments.add(_seg);
    segCount++;
    updateGeometry();
  }

  /**
   * Remove a specific segment.
   * @param Segment to remove
   */
  public void deleteSegment(Segment _seg){
    if(segments.remove(_seg)){
      segCount--;
      updateGeometry();
    }
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

  /**
   * Set the center point
   * @param PVector center coordinate
   */
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

  /**
   * Uncenter
   * @param PVector center coordinate
   */
  private void unCenter() {
    centered = false;
    for(Segment seg : segments)
      seg.unCenter();
    centerPutting = false;
  }


  /**
   * Make a PShape of the geometry
   */
  private void generateShape() {
    itemShape = createShape();
    itemShape.textureMode(NORMAL);
    itemShape.beginShape();
    itemShape.strokeJoin(ROUND);
    itemShape.strokeCap(ROUND); //strokeCap(SQUARE);
    float _x = 0;
    float _y = 0;
    if(segCount!=0){
      for (Segment seg : sortedSegments){
        _x = seg.getPointA().x;
        _y = seg.getPointA().y;
        itemShape.vertex(_x, _y, _x/width, _y/height);
      }
      _x = sortedSegments.get(0).getPointA().x;
      _y = sortedSegments.get(0).getPointA().y;
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

  /**
   * Generate a 2D segment ArrayList starting from the first segment
   */
  private void findRealNeighbors(){
    if(segments.size() < 1) return;
    treeBranches = new ArrayList();
    ArrayList<Segment> roots = new ArrayList();
    // find first segments, layer 1
    boolean root = true;
    for(Segment toCheck : segments){
      root = true;
      for(Segment seg : segments){
        if(toCheck.getPointA().dist(seg.getPointB()) < 0.1){
          root = false;
        }
      }
      if(toCheck == segments.get(0)) root = true; // added to force segment 0 as a root
      if(root) roots.add(toCheck);
    }
    if(roots.size() == 0) roots.add(segments.get(0));
    treeBranches.add(roots);

    boolean keepSearching = true;
    int ind = 0;
    while(keepSearching){
      ArrayList<Segment> next = getNext(treeBranches.get(ind++));
      if(next.size() > 0) treeBranches.add(next);
      else keepSearching = false;
    }
  }

  /**
   * Looks for segments not sorted.
   */
  private ArrayList<Segment> getNext(ArrayList<Segment> _segs){
    ArrayList<Segment> nextSegs = new ArrayList();
    boolean duplicate = false;
    for(Segment seg : _segs){
      for(Segment next : segments){
        if(seg.getPointB().dist(next.getPointA()) < 0.001){
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

  /**
   * segments need to be sorted if a segments gets deleted and remplaced by 2 or more new segments.
   */
  private void sortSegments(){
    sortedSegments.clear();
    for(ArrayList<Segment> brnch : treeBranches)
      for(Segment seg : brnch)
        sortedSegments.add(seg);
    sortedSegCount = sortedSegments.size();
    if(sortedSegCount != segCount){
      sortedSegments.clear();
      for(Segment seg : segments)
        sortedSegments.add(seg);
      sortedSegCount = sortedSegments.size();
    }
  }

  /**
   * Set each segments direct neighbors
   */
  private void setNeighbors() {
    int v1 = 0;
    int v2 = 0;
    if (segCount>0) {
      for (int i = 0; i < sortedSegCount; i++) {
        v1 = i-1;
        v2 = i+1;
        if (i==0) v1 = sortedSegCount-1; // maybe wrong
        if (i >= sortedSegCount-1) v2 = 0;
        Segment s1 = getSegment(v1);
        Segment s2 = getSegment(v2);
        if(s1 != null && s2 != null)
          getSegment(i).setNeighbors(s1, s2);
        //segments.get(i).setNeighbors(segments.get(v1), segments.get(v2));
      }
    }
  }

  private boolean findDirection(){
    for(Segment seg : sortedSegments){
      if(seg != null) return seg.isClockWise();
      // int ax = int(seg.getPointA().x);
      // int bx = int(seg.getPointB().x);
      // if( ax > bx) return true;
      // else if (ax < bx) return false;
    }
    return false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment access
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // deprecate
  public final ArrayList<Segment> getSegments() {
    return sortedSegments;
  }

  // Segment accessors
  public Segment getSegment(int _index){
    //if(_index >= segments.size()) return null;
    if(_index >= 0 && _index < sortedSegCount) return sortedSegments.get(_index);
    return null;
  }

  // Segment accessors
  public Segment getSegmentSequence(int _index){
    //if(_index >= segments.size()) return null;
    if(_index >= 0) return sortedSegments.get(_index%sortedSegCount);
    return null;
  }


  public ArrayList<ArrayList<Segment>> getBranches(){
    return treeBranches;
  }

  public ArrayList<Segment> getBranch(int _i){
    if(treeBranches.size() == 0 || _i < 0) return null;
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
  // check_this
  public void setText(String w, int v) {
    if (segCount >= 1 && v == -1) segments.get(segCount-1).setText(w);
    else if (v<segCount) segments.get(v).setText(w);
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

  public void setTemplateList(TemplateList _tl){
    templateList.copy(_tl);
  }

  public void setText(String _txt){
    groupText = _txt;
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
    //if(centered) return center;
    //else return segmentStart;
  }

  public final PVector getTagPosition(){
    if(centered) return center;
    else return segmentStart;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }

  public final boolean isEmpty(){
    return segments.isEmpty();
  }

  public final boolean isClockWise(){
    return clockwise;
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

  public final String getText(){
    return groupText;
  }

}
