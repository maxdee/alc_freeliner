// Abstraction for the decorator


// Colors, stroke weight and such
// have a global one to overide all!!
class Stylist {

  int strokeMode; // for stroke() 0 is noStroke()
  int fillMode; // for fill() 0 is noFill()
  int strokeWidth;
  int alphaValue; // maybe get implemented.
  int increment;
  int randomer;
  float fluct; // fluctuating value

  //custom colors?
  color[] pallet = {
                    color(255,0,0),
                    color(0,255,0),
                    color(0,0,255),
                    color(0,255,255),
                    color(255,255,0),
                    color(255,22,255),
                    color(100,3,255),
                    color(255,0,255),
                  };

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Constructors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public Stylist(){
    strokeMode = 1;
    fillMode = 1;
    strokeWidth = 3;
    fluct = 0.0;
    //alphaValue = 255;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Apply style to
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //apply settings to a shape
  public void apply(PShape _s){
    if (fillMode != 0){
      _s.setFill(true);
      _s.setFill(colorizer(fillMode));
    }
    else _s.setFill(false);
    if(strokeMode != 0) {
      _s.setStroke(colorizer(strokeMode));
      _s.setStrokeWeight(strokeWidth);//*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));
    }
    else _s.noStroke();
  }

  //apply settings to a canvas
  public void apply(PGraphics _g){
    
    if(fillMode != 0){
      _g.fill(colorizer(fillMode));
    }
    else _g.noFill();

    if(strokeMode != 0) {
      _g.stroke(colorizer(strokeMode));
      _g.strokeWeight(strokeWidth);
    }
    else _g.noStroke();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Color Selection
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  private color colorizer(int c) {
    switch (c){
      case 0:
        return color(0);
      case 1:
        return color(255, 255, 255);//, alphaValue);
      case 2:
        return color(255, 0, 0);//, alphaValue);
      case 3:
        return color(0, 255, 0);//, alphaValue);
      case 4:
        return color(0, 0, 255);//, alphaValue);
      case 5:
        return color(random(255));
      case 6:
        return color(random(255), random(255), random(255));//, alphaValue);
      case 7:
        return colorShift();
      case 8:
        return color(100);//lerpColor(colA, colB, lerper);
      case 9:
        return colorizer((increment%4)+1);
      case 10:
        return colorizer((randomer%4)+1);
      case 11:
        return shiftedColor();
      case 12:
        return color(0);//pallet[increment%7];
      case 13:
        return color(0);//pallet[c-20];
      case 14:
        return color(0);
    }
    return color(255,0,255);
  }

  color colorShift() {
    fluct += 0.0002;
    fluct =  fltMod(fluct);
    return java.awt.Color.HSBtoRGB(fluct, 1.0, 1.0);//abs(sin(colFloat)), 1.0, 1.0);
  }

  // this would take a snapshot of the color
  color shiftedColor() {
    return java.awt.Color.HSBtoRGB(fluct, 1.0, 1.0);//abs(sin(colFloat)), 1.0, 1.0);
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public color getStroke(){
    return colorizer(strokeMode);
  }

  public color getFill(){
    return colorizer(fillMode);
  }

  public int getStrokeWidth(){
    return strokeWidth;
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  public void setIncrement(int _i){
    increment = _i;
  }

  public void setRandomer(int _i){
    randomer = _i;
  }

  public int setStrokeMode(int _v) {
    strokeMode = numTweaker(_v, strokeMode);
    return strokeMode;
  }

  public int setFillMode(int _v) {
    fillMode = numTweaker(_v, fillMode);
    return fillMode;
  }

  public int setStrokeWeight(int _v) {
    strokeWidth = numTweaker(_v, strokeWidth);
    return strokeWidth; 
  }

  public int setAlpha(int _v){
    alphaValue = numTweaker(_v, alphaValue);
    return alphaValue;
  }
}



// Basic class to make shape subclasses
class Brush {

  // idealy would be static...
  int sizer;
  int scaledSize;
  int halfSize;
  int increment;
  int randomer;

  float scalar;
  int shpMode;

  PShape shp;
  PShape customShape;
  
  Brush(){
    sizer = 20;
    setScale(1.0);
    //halfSize = sizer/2;
    scalar = 1.0;
    shpMode = 0;
    updateShape();
    customShape = shp;
  }

  public void updateShape(){
    switch (shpMode) {
      case 0:
        pnt();
        break;
      case 1:
        perpLine();
        break;
      case 2:
        chevron();
        break;
      case 3:
        square();
        break;
      case 4:
        otherShape();
        break;
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Shape makers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  void perpLine() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(halfSize, 0);
    shp.endShape();
  }

  void chevron() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(0, halfSize);
    shp.vertex(halfSize, 0);
    shp.endShape();
  }

  void square() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(0, halfSize);
    shp.vertex(halfSize, 0);
    shp.vertex(0, -halfSize);
    shp.vertex(-halfSize, 0);
    shp.endShape(CLOSE);
  }

  public void pnt() {
    shp = createShape();
    shp.beginShape(POINTS);
    shp.vertex(0, 0);
    shp.endShape();
  }

  public void otherShape(){ //how to grab a mapitem??
    shp = cloneShape(customShape, float(scaledSize)/100, new PVector(0,0));
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  public PShape getShape(){
    if(shpMode == 4) updateShape();
    return shp;
  }

  public int getShapeMode(){
    return shpMode;
  }

  public int getScaledSize(){
    return scaledSize;
  }

  public int getHalfSize(){
    return halfSize;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  
  public void setIncrement(int _i){
    increment = _i;
  }

  public void setRandomer(int _i){
    randomer = _i;
  }

  public int setSize(int v) {
    sizer = numTweaker(v, sizer);
    halfSize = sizer/2;  
    updateShape(); //or scale shape
    return sizer;
  }

  // set the scale according to item's scalar
  public void setScale(float _s){
    scaledSize = int(sizer*_s);
    halfSize = scaledSize/2;
    updateShape(); //or scale shape
  }

  public int setShapeMode(int _v) {
    shpMode = numTweaker(_v, shpMode);
    updateShape();
    return shpMode;
  }

  public void setCustomShape(PShape _p){
    customShape = _p;
    updateShape();
  }
}

