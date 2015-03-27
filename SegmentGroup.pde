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
  float sizeScaler = 1.0;
  int sizer = 10;
  int randomNum = 0;
  PShape itemShape;

  ArrayList<Segment> segments;

  ArrayList<ArrayList<Segment>> treeBranches; 
  int segCount = 0;
  RenderList renderList;
  PVector center;
  PVector placeA;
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
    renderList = new RenderList();
    placeA = new PVector(-10, -10, -10);
    center = new PVector(-10, -10, -10);
    firstPoint = true;
    centered = false;
    centerPutting = false;
    seperated = false;
    generateShape();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Management, Segment creation and such
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void startSegment(PVector p) {
    if(firstPoint) center = p.get();
    placeA = p.get();
    firstPoint = false;
  }

  private void endSegment(PVector p) {
    segments.add(new Segment(placeA, p));
    segCount++;
    placeA = p.get();
    seperated = false;
    setNeighbors();
    findRealNeighbors();
    generateShape();
  }

  private void breakSegment(PVector p) {
    seperated = true;
    placeA = p.get();
  }

  private void nudgePoint(PVector p) {
    PVector np = placeA.get();
    if (!centerPutting) {
      np.add(p);
      if (segCount == 0 || seperated) breakSegment(np);
      else {
        undoSegment();
        endSegment(np);
      }
    } 
    else {
      np = center.get();
      np.add(p);
      placeCenter(np);
      centerPutting = true;
    }
    setNeighbors();
  }

  // needs to deal better with two points that are close together
  public void nudgeSnapped(PVector p, PVector m) {
    boolean nud = false;
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        if (m.dist(segments.get(i).getRegA()) < 0.001 ) segments.get(i).getRegA().add(p);
        if (m.dist(segments.get(i).getRegB()) < 0.001 ) segments.get(i).getRegB().add(p);
      }
      if (checkProx(m, center)) {
        center.add(p);
        placeCenter(center);
      }
      generateShape();
      setNeighbors();
    }
  }

  private void undoSegment() {
    if (segCount > 0) {
      float dst = placeA.dist(segments.get(segCount-1).pointB.get());
      if(dst > 0.001){
        placeA = segments.get(segCount-1).pointB.get();
      }
      else {
        placeA = segments.get(segCount-1).pointA.get();
        segments.remove(segCount-1);
        segCount--;
      }
      setNeighbors();
    }
  }

  private void placeCenter(PVector c) {
    center = c.get();
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        segments.get(i).setCenter(center);
      }
      centered = true;
    }
    centerPutting = false;
  }

  private void unCenter() {
    centered = false;
    for (int i = 0; i< segCount; i++) {
      segments.get(i).unCenter();
    }
    centerPutting = false;
  }


  public PVector snapVerts(PVector m) {
    if (segCount>0) {
      if (checkProx(m, center)) return center;
      for (int i = 0; i<segCount; i++) {
        if (checkProx(m, segments.get(i).getRegA())) return segments.get(i).getRegA();
        if (checkProx(m, segments.get(i).getRegB())) return segments.get(i).getRegB();
      }
    }
    return new PVector(0, 0, 0);
  }

  boolean checkProx(PVector g, PVector f) {
    //abs(g.x-f.x) < snapVal && abs(g.y-f.y) < snapVal
    if (g.dist(f) < snapVal) return true;
    else return false;
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

  private void findRealNeighbors(){
    treeBranches = new ArrayList();
    treeBranches.add(new ArrayList());
    // find first segments, layer 1
    for(Segment seg : segments){
      if(segments.get(0).getRegA().dist(seg.getRegA()) < 0.001)
        treeBranches.get(0).add(seg);
    }
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

  public ArrayList<Segment> getBranch(int _i){
    return treeBranches.get(_i%treeBranches.size());
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment access
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // deprecate
  public final ArrayList getSegments() {
    return segments;
  }

  // Segment accessors
  public Segment getSegment(int _index){
    return segments.get(_index % segCount);
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
  ///////     GUI
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void showLines(PGraphics g) {
    for (int i = 0; i<segCount; i++) {
      segments.get(i).drawLine(g);
    }
    // if(segCount!=0){
    //   itemShape.setFill(false);
    //   itemShape.setStroke(100);
    //   //itemShape.set
    //   g.shape(itemShape);
    // }
  }

  private void previewLine(PGraphics g, PVector c) {
    if (!firstPoint) {
      g.stroke(255);
      g.strokeWeight(3);
      g.line(placeA.x, placeA.y, c.x, c.y);
    }
  }

  public void showTag(PGraphics g) {
    PVector pos = centered ? center : placeA; 
    g.noStroke();
    g.fill(255);
    g.text(str(ID), pos.x - (16+int(ID>9)*6), pos.y+6);
    g.text(renderList.getString(), pos.x + 6, pos.y+6);
    g.noFill();
    g.stroke(255);
    g.strokeWeight(1);
    g.ellipse(pos.x, pos.y, 10, 10);
  }

  private void showText(PGraphics pg){
    for (int i = 0; i<segCount; i++) {
      segments.get(i).simpleText(g, int(sizeScaler*10));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void toggleRender(char c) {
    renderList.toggle(c);
  }

  public void setWord(String w, int v) {
    if (segCount >= 1 && v == -1) segments.get(segCount-1).setWord(w);
    else if (v<segCount) segments.get(v).setWord(w);
  } 

  public void newRan(){
    randomNum = (int)random(1000);
    for (int i = 0; i < segCount; i++) {
      segments.get(i).newRan();
    }
  }

  public boolean toggleCenterPutting(){
    centerPutting = !centerPutting;
    return centerPutting;
  }

  public int setScaler(int s){
    sizer = numTweaker(s, sizer); 
    sizeScaler = sizer/10.0;
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

  public final int getRan(){
    return randomNum;
  }
  public final PShape getShape(){
    return itemShape;
  }

  public final PVector getCenter(){
    return center;
  }

  public final RenderList getRenderList() {
    return renderList;
  }

  public final PVector getLastPoint() {
    if (segCount>0)  return segments.get(segCount-1).getRegA();
    else return new PVector(0, 0, 0);
  }

  public final float getScaler(){
    return sizeScaler;
  }

}


