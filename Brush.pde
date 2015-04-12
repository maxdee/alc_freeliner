
// // Basic class to make shape subclasses
// abstract class Brush {
//   int size;
//   int scaledSize;
//   int halfSize;
//   float scalar;
  

//   PShape shp;
//   PShape customShape;
  
//   Brush(){
//     sizer = 20;
//     setScale(1.0);
//     //halfSize = sizer/2;
//     scalar = 1.0;
//     shpMode = 0;
//     updateShape();
//     customShape = shp;
//   }

//   public void updateShape(){
//     switch (shpMode) {
//       case 0:
//         pnt();
//         break;
//       case 1:
//         perpLine();
//         break;
//       case 2:
//         chevron();
//         break;
//       case 3:
//         square();
//         break;
//       case 4:
//         otherShape();
//         break;
//     }
//   }


//   ////////////////////////////////////////////////////////////////////////////////////
//   ///////
//   ///////     Shape makers
//   ///////
//   ////////////////////////////////////////////////////////////////////////////////////  

//   void perpLine() {
//     shp = createShape();
//     shp.beginShape();
//     shp.vertex(-halfSize, 0);
//     shp.vertex(halfSize, 0);
//     shp.endShape();
//   }

//   void chevron() {
//     shp = createShape();
//     shp.beginShape();
//     shp.vertex(-halfSize, 0);
//     shp.vertex(0, halfSize);
//     shp.vertex(halfSize, 0);
//     shp.endShape();
//   }

//   void square() {
//     shp = createShape();
//     shp.beginShape();
//     shp.vertex(-halfSize, 0);
//     shp.vertex(0, halfSize);
//     shp.vertex(halfSize, 0);
//     shp.vertex(0, -halfSize);
//     shp.vertex(-halfSize, 0);
//     shp.endShape(CLOSE);
//   }

//   public void pnt() {
//     shp = createShape();
//     shp.beginShape(POINTS);
//     shp.vertex(0, 0);
//     shp.endShape();
//   }

//   public void otherShape(){ //how to grab a mapitem??
//     shp = cloneShape(customShape, float(scaledSize)/100, new PVector(0,0));
//   }

//   ////////////////////////////////////////////////////////////////////////////////////
//   ///////
//   ///////     accessors
//   ///////
//   ////////////////////////////////////////////////////////////////////////////////////  

//   public PShape getShape(){
//     if(shpMode == 4) updateShape();
//     return shp;
//   }

//   public int getShapeMode(){
//     return shpMode;
//   }

//   public int getScaledSize(){
//     return scaledSize;
//   }

//   public int getSize(){
//     return sizer;
//   }
//   public int getHalfSize(){
//     return halfSize;
//   }

//   ////////////////////////////////////////////////////////////////////////////////////
//   ///////
//   ///////     Modifiers
//   ///////
//   ////////////////////////////////////////////////////////////////////////////////////  
  
//   public void setIncrement(int _i){
//     increment = _i;
//   }

//   public void setRandomer(int _i){
//     randomer = _i;
//   }

//   public int setSize(int v) {
//     sizer = numTweaker(v, sizer);
//     halfSize = sizer/2;  
//     updateShape(); //or scale shape
//     return sizer;
//   }

//   // set the scale according to item's scalar
//   public void setScale(float _s){
//     scaledSize = int(sizer*_s);
//     halfSize = scaledSize/2;
//     updateShape(); //or scale shape
//   }

//   public int setShapeMode(int _v) {
//     shpMode = numTweaker(_v, shpMode);
//     updateShape();
//     return shpMode;
//   }

//   public void setCustomShape(PShape _p){
//     customShape = _p;
//     updateShape();
//   }
// }

