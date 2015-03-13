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



// class to take all the rendering bits from mapitem

//layer level?
//have a whole canvasraphics?

//polka shift
//decorator swap! swap A with C
//canvas effects? shaders?
 
// fix probability and such

class Decorator {
	
  // a capital letter to represent the decorator
  final char ID;
  Stylist style;
  Brush brush;

  Clock clk;
  Mapitem item;
  ArrayList<Vertix> verts;
  int vertsCnt;
  
  boolean enableDeco;
  boolean looper;
  boolean launchit;
  boolean internalClock;
  boolean invertLerp;
  boolean updateItemFlag;
  boolean fillit;

  float lerper;
  float vertAngle;

  int aniMode;
  int renderMode;
  int vertMode;
  int lerpMode;
  int iterationMode;
  int shpMode;
  int rotationMode;

  int polka;
  int probability;

  int divider;
  int increment;
  int randomer; // should be in verts? or item
  int largeRan;

  PGraphics canvas; // do image effects such as tint and shit.
  PVector center;
  boolean centered;

  //mul all the angles 
  float rotater;
  float modulator; // use for rotation speed and other.

  char letter;

  public Decorator(char _d){
  	ID = _d;
    init();
  }

  public void init(){
    style = new Stylist();
    brush = new Brush();
    verts = new ArrayList();
    clk = new Clock(2);
    letter = ID;
    
    center = new PVector(0,0);

    enableDeco = true;
    looper = true;
    launchit = false;
    internalClock = false;
    invertLerp = false;
    updateItemFlag = false;
    fillit = false;

    vertsCnt = 0;
    aniMode = 0;
    renderMode = 0;
    vertMode = 0;
    lerpMode = 0;
    iterationMode = 0;
    shpMode = 0;
    rotationMode = 0;

    polka = 5;
    probability = 100;

    divider = 2;
    increment = 0;
    randomer = 0;
    largeRan = 0;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Synchronising
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void passData(PGraphics pg, Mapitem m) { // bro, do we even update now?
    canvas = pg; 
    item = m;
    verts = item.getVerts();
    vertsCnt = verts.size();
    setScale(item.getScaler());

    if(updateItemFlag) item.newRan();

    largeRan = int(item.getRan()*((float(ID)/200)+1));
    randomer = largeRan%100; // was 20
    brush.setRandomer(randomer);
    style.setRandomer(randomer);
    //println("Item : "+item.getID()+"  Decor : "+ID+ "  randomer : "+randomer);
  }
 
  private void clockWorks(float lrp, int inc){
    if(internalClock){
      clk.internal();
      inc = clk.getIncrement();
      lrp = clk.getLerper();
    }

    lerper = lerpStyle(lrp); 
    updateItemFlag = false;
    if(inc != increment) {
      increment = inc;
      incrementThings();
      updateItemFlag = true;
    }
  }

  private void incrementThings(){
    //println("Item : "+item.getID()+"  Decor : "+ID+ "  randomer : "+randomer);
 
    if(!looper && launchit){
      enableDeco = true;
      launchit = false;
    }
    else if(!looper) enableDeco = false;
    else enableDeco = true;

    style.setIncrement(increment);
    brush.setIncrement(increment);
  }


  public void launch() {
    launchit = true;
    if(internalClock){
      clk.reset();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     lerpStuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private float lerpStyle(float lrp){
    if(lrp > 1) lrp = 1;
    if(invertLerp) lrp = -lrp+1;
    switch (lerpMode){
      case 0:
        return lrp;
      case 1:
        return backAndForth(lrp);
      case 2:
        return pow(lrp, 2);
      case 3:
        return sin(lrp*PI);
      case 4:
        return random(2000)/2000;
    }
    return float(lerpMode - 5)/10;
  }

  //there is a slight glitch here
  private float backAndForth(float l){
    if(increment % 2 == 0) return -l+1;
    else return l;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     iterations
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void iterator(){
    float origLerp = lerper;
    if( vertsCnt > 0 && enableDeco && randomer < probability){
      switch (iterationMode){
        case 0:
          doDeco();  
          break;
        case 1:  
          manyThings();
          break;
        case 2:
          middler();
          break;
        case 3:
          twoFull();
          break;
      }
    }
    lerper = origLerp;
  }

  private void manyThings() {
    float ll = 0;
    float lerpol = lerper/polka;
    float pold = 1.0/polka;
    for (int i = 0; i < polka; i++) {
      lerper = (pold*i)+lerpol;
      doDeco();
    }
  }

  private void middler() {
    float oldLerp = lerper;
    lerper = (oldLerp/-2)+0.5;
    doDeco(); 
    lerper = (oldLerp/2)+0.5;
    doDeco();
    lerper = oldLerp;
  }

  private void twoFull(){
    doDeco();
    invertLerp = !invertLerp;
    doDeco();
    invertLerp = !invertLerp;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     rendermodes
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  private void doDeco() {
    style.apply(canvas);
    if(rotationMode != 0) rotater = lerper*TWO_PI*rotationMode;
    else rotater = 0;
    if (lerper <= 1 && lerper >= 0){// && vertsCnt > 0 && enableDeco && randomer < probability){
      if(verts.get(0).isCentered()){
        center = verts.get(0).getCenter().get();
        centered = true;
      }
      else centered = false;
      if(renderMode < 4) vertPicker();
      else decorateItem();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Select and decorates verts
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 

  private void vertPicker(){
    switch (vertMode){
      case 0:
        allVerts();
        break;
      case 1:
        vertPerVert();
        break;
      case 2:
        alternateLerp();
        break;
      case 3:
        //vertChase();
        break;
      case 4:
        randomVert();
        break;
    }
  }

  //vertix render style
  public void allVerts() {
    for (int i = 0; i < vertsCnt; i++) {
      vertDecorator(verts.get(i));
    }
  }

  public void randomVert() {
    int i = largeRan % vertsCnt;
    if (lerper <= 1) vertDecorator(verts.get(i));
  }

  //one vert at a time
  private void vertPerVert() {
    int v = increment%vertsCnt;
    vertDecorator(verts.get(v));
  }


  // private void vertChase(){
  //   int v = increment%vertsCnt;
  //   vertDecorator(verts.get(v));
  //   if(millis() % 200 == 1) increment++;
  //   println(increment);
  // }

  private void alternateLerp() {
    boolean bkp = invertLerp;
    for (int i = 0; i < vertsCnt; i++) {
      vertDecorator(verts.get(i));
      invertLerp = !invertLerp;
    }
    invertLerp = bkp;
  }

  // then go back to render modes to distribute further
  private void vertDecorator(Vertix _v){
    if(centered) _v.setSize(brush.getScaledSize());
    vertAngle = _v.getAngle(invertLerp);
    switch (renderMode){
      case 0:
        applyBrush(_v);
        break;
      case 1:
        edgeLight(_v);
        break;
      case 2:
        miscDec(_v);
        break;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Applying brush
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  


  public void applyBrush(Vertix _v) {
    switch (aniMode) {
      case 0:
        putShape( _v.getPos(lerper), vertAngle);    
        break;
      case 1:
        spiralesk(_v);
        break;
      // case 2:
      //   wavy(_v);
      //   break;
    }
  }

  private void putShape(PVector _p, float _a){  
    PShape shape_; 
    if(brush.getShapeMode() < 5) {
      shape_ = brush.getShape();
      style.apply(shape_);
    }
    else shape_ = specialShapes(brush.getShapeMode());
    
    canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a + HALF_PI + rotater); 
    canvas.shape(shape_);
    canvas.popMatrix();
  }
  
  private void spiralesk(Vertix _v){
    PVector pv = _v.getPos(lerper).get();
    pv = vecLerp(pv, _v.getCenter(), lerper).get();
    putShape(pv, vertAngle);
  }

  // special shapes that need to handle style differently
  private PShape specialShapes(int _s){
    switch(_s){
      case 5:
        return sprinkles();
    }
    return brush.getShape();
  }

  private PShape sprinkles(){
    PShape shape_;
    shape_ = createShape();
    shape_.beginShape(POINTS);
    
    PVector pos = new PVector(0,0);
    int sz = brush.getHalfSize();
    int ran = 0;
    int tenpol = polka * 10;
    style.apply(shape_);

    for(int i = 0; i < tenpol; i++){
      // pos = v.getPos(i/tenpol);
      // ran = int(random(100));
      // pos = vecLerp(pos, v.getCenter(), ran/100);
      pos.set(random(-sz, sz), random(-sz, sz));
      shape_.stroke(style.getStroke());
      shape_.vertex(pos.x, pos.y);
    }
    shape_.endShape();
    return shape_;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Applying lines
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  
  private void edgeLight(Vertix _v){
    switch (aniMode){
      case 0:
        grow(_v);
        break;
      case 1:
        autoMap(_v);
        break;
      case 2:
        flashLine(_v);
        break;
      case 3:
        strobeLine(_v);
        break;
    }
  }

  private void liner(PVector _a, PVector _b){
    canvas.line(_a.x, _a.y, _b.x, _b.y);
  }

  private void autoMap(Vertix v) {
    float l = lerper;// * v.getRanFLoat();
    if(l>1) l = 1;
    PVector a = vecLerp(v.getRanA(), v.getRegA(), l);
    PVector b = vecLerp(v.getRanB(), v.getRegB(), l);
    liner(a, b);
  }

  private void highLighter(Vertix v) {
    if(invertLerp) liner(v.getRegB(), v.getRegPos(-lerper+1));
    else liner(v.getRegA(), v.getRegPos(lerper));
  }

  private void grow(Vertix v){
    if(invertLerp) liner(v.getRegB(), v.getRegPos((lerper*-1)+1));
    else liner(v.getRegA(), v.getRegPos(lerper));
  }

  private void flashLine(Vertix _v){
    if(random(polka) < 1) liner(_v.getRegA(), _v.getRegB());
    else {
      canvas.pushStyle();
      canvas.stroke(0);
      liner(_v.getRegA(), _v.getRegB());
      canvas.popStyle();
    }
  }

  private void strobeLine(Vertix _v){
    if(maybe(polka)) liner(_v.getRegA(), _v.getRegB());
  }


  //BETA
  private void worms(Vertix _v) {
    // if( lerper <= 1){
    //   canvas.stroke(colorizer(strokeMode));
    //   canvas.strokeWeight(strokeW);
    //   //vert to vert lines...
    //   PVector tmpA = new PVector(0,0,0);
    //   PVector tmpB = new PVector(0,0,0);
    //   for (int i = 0; i<vertsCnt; i++) {
    //     tmpA = verts.get(i).getRegPos(lerper);
    //     if(lerper < 0.5){
    //       tmpB = verts.get(i).getRegA(); 
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //     else if(lerper >= 0.25 && lerper < 0.75){
    //       tmpB = verts.get(i).getRegPos(lerper - 0.25);
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //     else if(lerper >= 0.75){
    //       tmpB = verts.get(i).getRegB(); 
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //   }
    // }
  }





  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Other Vert decorations
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 


  public void miscDec(Vertix vert) {
    switch (aniMode){
      case 0:
        writer(vert);  
        break;
      case 1:  
        elipser(vert);
        break;
    //else if (m == 11) sprinkles(vert);
    }
  }

  public void writer(Vertix vert) {
    String werd = vert.getWord();
    int l = werd.length();
    PVector pos = new PVector(0,0,0);
    //setBrushes();
    canvas.textFont(font);
    canvas.textSize(brush.getScaledSize());
    char[] carr = vert.getWord().toCharArray();
    for(int i = 0; i < l; i++){
      pos = vert.getRegPos(-((float)i/(l+1) + 1.0/(l+1))+1); //optimise!!
      canvas.pushMatrix();
      canvas.translate(pos.x, pos.y);
      canvas.rotate(vert.getAngle(invertLerp));
      canvas.translate(0,5);
      canvas.text(carr[i], 0, 0);
      canvas.popMatrix();
    }
  }

  void elipser(Vertix _v){
    PVector pA = _v.getA();
    PVector pos = _v.getRegPos(lerper);
    float diam = 2*pos.dist(pA);
    canvas.ellipse(pA.x, pA.y, diam, diam);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     All vert renderers
  ///////
  ///////
  ///////     All vert renderers
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 

  public void decorateItem() {
    switch (renderMode){
      case 5:
        doFill();
        break;
      case 6:
        stringArt();
        break;
      case 7:
        //worms();
        break;
      }
  }

  private void doFill() {
    canvas.pushMatrix();
    
    PShape shpe = item.getShape();
    float lorp = 1-lerper;
    lorp*=lorp;
    PVector fp = verts.get(0).getRegA();
    PVector p = vecLerp(fp, center, -lorp+1);

    style.apply(shpe);

    //if(strokeMode != 0) shpe.setStrokeWeight(strokeW*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));

    canvas.translate(p.x, p.y);
    canvas.rotate(rotater);
    canvas.scale(lorp);
    canvas.translate(-fp.x, -fp.y);
    canvas.shapeMode(CORNER);
    
    canvas.shape(shpe);
    canvas.popMatrix();
  }

  //automatic string art
  private void stringArt() {
    int other = 0;
    float xA = 0;
    float yA = 0;
    float xB = 0;
    float yB = 0;
    //vert to vert lines...
    for (int i = 0; i<vertsCnt; i++) {
      other = (i + shpMode) % vertsCnt;
      xA = verts.get(i).getRegPos(lerper).x;
      yA = verts.get(i).getRegPos(lerper).y;
      xB = verts.get(other).getRegPos(lerper).x;
      yB = verts.get(other).getRegPos(lerper).y;
      canvas.line(xA, yA, xB, yB);
    }  
  }

  // private void doFill() {
  //   canvas.pushMatrix();
    
  //   PShape shpe = item.getShape();
  //   float lorp = lerper*lerper;
  //   PVector fp = verts.get(0).getRegA();
  //   PVector p = vecLerp(fp, center, -lorp+1);

  //   shpBrush(shpe);
  //   if(strokeMode != 0) shpe.setStrokeWeight(strokeW*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));

  //   canvas.translate(p.x, p.y);
  //   canvas.scale(lorp);
  //   canvas.translate(-fp.x, -fp.y);
  //   canvas.shapeMode(CORNER);
  //   canvas.shape(shpe);
  //   canvas.popMatrix();
  // }





  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public final int getDivider() {
    return divider;
  }

  public final char getID(){
  	return ID;
  }

  // public final int getSize() {
  //   return sizer;
  // }

  // public final int getStrokeWeight() {
  //   return strokeW;
  // }

  // public final int getshpMode() {
  //   return shpMode;
  // }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////
  // decorator settings
  //////////////////////////////////////////
  public int setProbability(int v){
    probability = numTweaker(v, probability);
    if(probability > 100) probability = 100;
    return probability;
  }

  public int setIncrement(int i){
    increment = i;
    return increment;
  }

  public void setLerp(float f) {
    lerper = f;
  }

  public boolean enableDeco(boolean b) {
    enableDeco = b;
    return enableDeco;
  }

  public boolean toggleInvertLerp(){
    invertLerp = !invertLerp;
    return invertLerp;
  }

  public boolean toggleInternal(){
    internalClock = !internalClock;
    return internalClock;
  }

  public boolean toggleLoop(){
    looper = !looper;
    return looper;
  }

  public void setInternal(boolean _b){
    internalClock = _b;
  }

  public void setLooper(boolean _b){
    looper = _b;
  }
  public int setAniMode(int _v) {
    aniMode = numTweaker(_v, aniMode);
    return aniMode;
  }

  public int setRenderMode(int _v) {
    renderMode = numTweaker(_v, renderMode);
    return renderMode;
  }

  public int setVertMode(int _v){
    vertMode = numTweaker(_v, vertMode);
    return vertMode;
  }

  public int setLerpMode(int v){
    lerpMode = numTweaker(v, lerpMode);
    return lerpMode;
  }

  public int setIterationMode(int v){
    println(iterationMode);
    iterationMode = numTweaker(v, iterationMode);
    return iterationMode;
  }

  public int setPolka(int v) {
    polka = numTweaker(v, polka);
    return polka;
  }

  public int setdivider(int v) {
    divider = numTweaker(v, divider);
    clk.setDiv(divider);
    return divider;
  }

  public int setTempo(int n){
    clk.setTempo(numTweaker(n, clk.getTempo()));
    return clk.getTempo();
  }

  public int setRotation(int _v){
    rotationMode = numTweaker(_v, rotationMode);
    return rotationMode;
  }
  //////////////////////////////////////////
  // pass style settings to stylist
  //////////////////////////////////////////
  public int setStrokeMode(int _v) {
    return style.setStrokeMode(_v);
  }

  public int setFillMode(int _v) {
    return style.setFillMode(_v);
  }

  public int setStrokeWeight(int _v) {
    return style.setStrokeWeight(_v); 
  }

  public int setAlpha(int _v){
    return style.setAlpha(_v);
  }

  //////////////////////////////////////////
  // pass shape settings
  //////////////////////////////////////////
  public int setSize(int _v) {
    return brush.setSize(_v);
  }

  public void setScale(float _s){
    brush.setScale(_s);
  }

  public int setShapeMode(int _v) {
    shpMode = brush.setShapeMode(_v);
    return shpMode;
  }

  public void setCustomShape(PShape _p){
    brush.setCustomShape(_p);
  }
}
