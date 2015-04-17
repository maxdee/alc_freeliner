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
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */


/**
 * A segment consist of two vertices with special other data as a offset line.
 */
class Segment {
  PVector pointA;
  PVector pointB;

  PVector ranA;
  PVector ranB;
  
  PVector offA;
  PVector offB;
  
  // previous and or next segments, needed to create offset line
  Segment neighbA;
  Segment neighbB;

  PVector center;
  
  float scaledSize;
  
  float angle;
  //float anglePI;
  boolean centered;

  float ranFloat;

  String segmentText;

  public Segment(PVector pA, PVector pB) {

    pointA = pA.get();
    pointB = pB.get();
    center = new PVector(0, 0, 0);
    newRan();
    offA = new PVector(0,0,0);
    offB = new PVector(0,0,0);
    scaledSize = 10;
    centered = false;
    updateAngle();
    segmentText = "freeliner!";
  }

  public void updateAngle(){
    angle = atan2(pointA.y-pointB.y, pointA.x-pointB.x);
    //anglePI = angle + PI;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void newRan(){
    ranA = new PVector(pointA.x+random(-100, 100), pointA.y+random(-100, 100), 0);
    ranB = new PVector(pointB.x+random(-100, 100), pointB.y+random(-100, 100), 0);
    ranFloat = 1+random(50)/100.0;
  }

  public void setNeighbors(Segment a, Segment b){
    neighbA = a;
    neighbB = b;
  }

  private void findOffset() {
    offA = inset(pointA, neighbA.getRegA(), pointB, center, scaledSize);
    offB = inset(pointB, pointA, neighbB.getRegB(), center, scaledSize);
  }

  public void setPointA(PVector p){
    pointA = p.get();
    
  }

  public void setPointB(PVector p){
    pointB = p.get();
    updateAngle();
  }

  public void setCenter(PVector c) {
    centered = true;
    //scaledSize = 0;
    center = c.get();
    findOffset();
  }

  public void unCenter(){
    centered = false;
  }

  public void setSize(float _s){
    if(_s != scaledSize && centered){ 
      scaledSize = _s;
      findOffset();
    }
  }

  public void setWord(String w){
    segmentText = w;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Offset by brush size
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * This is to generate new vertices in relation to brush size.
   * @param PVector vertex to offset
   * @param PVector previous neighboring vertex
   * @param PVector following neighboring vertex
   * @param PVector center of shape
   * @param float distance to offset
   * @return PVector offseted vertex
   */
  PVector inset(PVector p, PVector pA, PVector pB, PVector c, float d) {
    float angleA = (atan2(p.y-pA.y, p.x-pA.x));
    float angleB = (atan2(p.y-pB.y, p.x-pB.x));  
    float A = radianAbs(angleA); 
    float B = radianAbs(angleB); 
    float ang = abs(A-B)/2; //the shortest angle

    d = (d/2)/sin(ang);
    if (A<B) ang = (ang+angleA);
    else ang = (ang+angleB);

    PVector outA = new PVector(cos(ang)*d, sin(ang)*d, 0);
    PVector outB = new PVector(cos(ang+PI)*d, sin(ang+PI)*d, 0);
    outA.add(p);
    outB.add(p);

    PVector offset;
    if (c.dist(outA) < c.dist(outB)) return outA;
    else  return outB;  
  }

  float radianAbs(float a) {
    while (a<0) {
      a+=TWO_PI;
    }
    while (a>TWO_PI) {
      a-=TWO_PI;
    } 
    return a;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // public final int getSize(){
  //   return scaledSize;
  // }

  public final PVector getPos(float l) {
    if (centered) return getOffPos(l);
    else return getRegPos(l);
  }

  public final PVector getOffPos(float l){
    return vecLerp(offA, offB, l);
  }

  public final PVector getRegPos(float l){
    return vecLerp(pointA, pointB, l);
  }

  // return centered if centered  
  public final PVector getA() {
    if(centered) return offA;
    else return pointA;
  }

  public final PVector getB() {
    if(centered) return offB;
    else return pointB;
  }

  //get offset pos from predetermined angle
  //add a recentOffA with a recent scaledSize
  public final PVector getOffA() {
    return offA;
  }

  public final PVector getOffB() {
    return offB;
  }
  //original points
  public final PVector getRegA(){
    return pointA;
  }

  public final PVector getRegB(){
    return pointB;
  }

  //random pos
  public final PVector getRanA() {
    return ranA;
  }
  
  public final PVector getRanB() {
    return ranB;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }

  public final float getAngle(boolean inv) {
    if(inv) return angle+PI;
    return angle;
  }

  public final float getRanFloat(){
    return ranFloat;
  }

  public final float getLength() {
    return dist(pointA.x, pointA.y, pointB.x, pointB.y);
  }

  public final PVector getCenter() {
    return center;
  }

  public final String getText(){
    return segmentText;
  }
}

