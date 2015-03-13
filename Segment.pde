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



// a group of two points.

class Segment {
  PVector pointA;
  PVector pointB;

  PVector ranA;
  PVector ranB;
  
  PVector offA;
  PVector offB;
  
  Segment neighbA;
  Segment neighbB;

  PVector center;
  
  int sizer;
  
  float angle;
  float anglePI;
  boolean centered;

  float ranFloat;
  float growFloat;

  String werd;

  public Segment(PVector pA, PVector pB) {
    pointA = pA.get();
    pointB = pB.get();
    center = new PVector(0, 0, 0);
    newRan();
    offA = new PVector(0,0,0);
    offB = new PVector(0,0,0);
    sizer = 1;
    centered = false;
    updateAngle();
    werd = "haha!";
  }

  public void updateAngle(){
    angle = atan2(pointA.y-pointB.y, pointA.x-pointB.x);
    anglePI = angle + PI;
  }

  //for teh gui
  public void drawLine(PGraphics g) {
    g.stroke(170);
    g.strokeWeight(1);
    vecLine(g, pointA, pointB);
    if(centered) vecLine(g, offA, offB);
    g.stroke(200);
    g.strokeWeight(3);
    g.point(pointA.x, pointA.y);
    g.point(pointB.x, pointB.y);
  }

  public void simpleText(PGraphics pg, int s){
    int l = werd.length();
    PVector pos = new PVector(0,0,0);
    pg.pushStyle();
    pg.fill(255);
    pg.noStroke();
    pg.textFont(font);
    pg.textSize(s);
    char[] carr = werd.toCharArray();
    for(int i = 0; i < l; i++){
      pos = getRegPos(-((float)i/(l+1) + 1.0/(l+1))+1);
      pg.pushMatrix();
      pg.translate(pos.x, pos.y);
      pg.rotate(angle);
      pg.translate(0,5);
      pg.text(carr[i], 0, 0);
      pg.popMatrix();
    }
    pg.popStyle();
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
    offA = inset(pointA, neighbA.getRegA(), pointB, center, sizer);
    offB = inset(pointB, pointA, neighbB.getRegB(), center, sizer);
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
    sizer = 0;
    center = c.get();
  }

  public void unCenter(){
    centered = false;
  }

  public void setSize(int s){
    if(s != sizer){ 
      sizer = s;
      findOffset();
    }
  }

  public void setWord(String w){
    werd = w;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

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
  //add a recentOffA with a recent sizer
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
    if(inv) return anglePI;
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

  public final String getWord(){
    return werd;
  }
}

