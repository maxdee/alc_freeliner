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



class FloatSmoother {
  boolean firstValue;
  FloatList flts;
  int smoothSize;

  public FloatSmoother(int s, float f){
    firstValue = true;
    smoothSize = s;
    flts = new FloatList();
    fillArray(f);
  }

  public float addF(float s){
    if(firstValue){
      firstValue = false;
      fillArray(s);
    } 
    flts.append(s);
    flts.remove(0);
    return arrayAverager();
  }

  private void fillArray(float f) {
    flts.clear();
    for(int i = 0; i < smoothSize; i++){
      flts.append(f);
    }
  }

  private float arrayAverager() {
    float sum = 0;
    for(int i = 0; i < smoothSize; i++){
      sum += flts.get(i);
    }
    return sum / smoothSize;
  }
}




PVector vecLerp(PVector a, PVector b, float l){
  return new PVector(lerp(a.x, b.x, l), lerp(a.y, b.y, l), 0);
}

PVector angleMove(PVector p, float a, float s){
  PVector out = new PVector(cos(a)*s, sin(a)*s, 0);
  out.add(p);
  return out; 
}

PVector vectorMirror(PVector p){
  float newX = 0;
  if(p.x<width/2) newX = width-p.x;
  else newX = -(p.x-width/2)+width/2;
  return new PVector(newX, p.y, p.z);
}

void vecLine(PGraphics p, PVector a, PVector b){
  p.line(a.x,a.y,b.x,b.y);
}

//4 am victory
// find angle with generic size? then offer offset by andgle and size?
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

float fltMod(float f) {
  if (f>1) f-=1;
  else if (f<0) f+=1; 
  return f;
}

//wrap around
static int wrap(int v, int n) {
  if (v<0) v = n;
  if (v>n) v = 0;
  return v;
}

int numTweaker(int v, int n){
  if(v >= 0) return v;
  else if (v == -1) return n+1;
  else if (v == -2 && n-1>=0) return n-1;
  else return n;
}

boolean maybe(int _p){
  return random(100) < _p;
}

/**
 * PShape clone/resize/center, the centerPosition will translate everything making it 0,0
 * @param  source PShape
 * @param  scalar float
 * @param  centerPoint PVector
 * @return new PShape
 */

PShape cloneShape(PShape _source, float _scale, PVector _center){
  PShape shp = createShape();
  shp.beginShape();
  PVector tmp = new PVector(0,0);
  for(int i = 0; i < _source.getVertexCount(); i++){
    tmp = _source.getVertex(i);
    tmp.sub(_center);
    tmp.mult(_scale);
    shp.vertex(tmp.x, tmp.y);
  }
  shp.endShape();
  return shp;
}