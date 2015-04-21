/**
 * ##copyright##
 * See LICENSE.md
 * 
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


import oscP5.*;
import netP5.*;
import java.net.InetAddress;

FreeLiner fl;
PFont font;
PFont introFont;

// for the glitch gallery ballpit
boolean ballPit = false;//true;

// for the liquid crystal table
boolean liquid = false;//true;//

// set if the sketch is FULLSCREEN by default
//boolean FULLSCREEN = true;
final boolean FULLSCREEN = false;

// default window size if not FULLSCREEN
int xres = 1024;
int yres = 768;

// add a image path to load a background image.
final String BG_IMAGE_FILE = "data/backgroundImage.png";
PImage backgroundImage = null;

void setup() {
  try {
    backgroundImage = loadImage(BG_IMAGE_FILE);
  }
  catch (Exception e){
    println("No background image found");
  }
  if(backgroundImage == null){
    if(!FULLSCREEN) size(xres, yres, P2D);
    else size(displayWidth, displayHeight, P2D);
  }
  else {
    size(backgroundImage.width, backgroundImage.height, P2D);
  }

  // attempting to skip anoying white screen on startup
  //frame.setBackground(new java.awt.Color(0, 0, 0));
  
  frameRate(30); //is this helpfull?
  //textureMode(NORMAL);
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  
  noCursor();
  splash();
  fl = new FreeLiner();
  delay(1000);
  //loadTest();
  //traceShape(loadShape("texture_1.svg"));
}

// lets processing know if we want it FULLSCREEN
boolean sketchFullScreen() {
  return FULLSCREEN;
}

void splash(){
  background(0);
  stroke(100);
  fill(150);
  textMode(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
}

void draw() {
  if(backgroundImage != null) image(backgroundImage,0,0);
  else background(0);
  fl.update();
}
  


//relay the inputs to the mapper
void keyPressed() {
  fl.keyboard.processKey(key, keyCode);
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  fl.keyboard.processRelease(key, keyCode);
}

void mousePressed(MouseEvent event) {
  fl.mouse.press(mouseButton);
}

void mouseDragged() {
  if(ballPit && mouseX < width/2) fl.mouse.drag(mouseButton, 
                                              -(int((mouseY/(float)height)*(width/2.0)))+width/2,
                                              (int((mouseX/(width/2.0))*height)));
  else fl.mouse.drag(mouseButton, mouseX, mouseY);
}

void mouseMoved() {
  if(ballPit && mouseX < width/2) fl.mouse.move(-(int((mouseY/(float)height)*(width/2.0)))+width/2,
                                              (int((mouseX/(width/2.0))*height))); 
  else fl.mouse.move(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) {
  fl.mouse.wheeled(event.getCount());
}






// void traceShape(PShape _shape){
//   PShape buff = createShape();
//   PVector pos;
//   for(int i = _shape.getVertexCount()-1; i >= 0; i--){
//     fl.keyboard.processKey('n', keyCode);

//       pos = _shape.getVertex(i);
//       println("child : "+i+"  vertx : "+i+"  position : "+pos);
//       fl.mouse.move((int)pos.x, (int)pos.y);
//       fl.mouse.press(LEFT);
    
//   }
// }


//   // for(int i = _shape.getChildCount()-1; i >= 0; i--){
//   //   //buff = _shape.getChild(i);
//   //   fl.keyboard.processKey('n', keyCode);
//   //   println(_shape.getChildCount());
//   //   for(int j = buff.getVertexCount()-1; j >= 0; j--){
//   //     pos = buff.getVertex(j);
//   //     println("child : "+i+"  vertx : "+j+"  position : "+pos);
//   //     fl.mouse.move((int)pos.x, (int)pos.y);
//   //     fl.mouse.press(LEFT);
//   //   }
//   // }




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     weird testing tool, sorry for the wtf
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


void loadTest(){
  execute(":1000x :100y . :800x:100y . :600x:100y . :400x:100y .");
  execute("n, :20140x:200y . :800x:200y . :800x:600y . :200x:600y . :200x:200y .");
  execute("A, B,");
  execute("c, :500x :500y .");
  execute("+ A, q, 2, > + B, b, 4, >");
}

void execute(String cmd){
  boolean makeNum = false;
  boolean sendKey = false;
  String num = "";
  char chr = '_';
  int xpos = 0;
  int ypos = 0;

  for(int i = 0; i<cmd.length(); i++){
    if(cmd.charAt(i) == ' ');
    else if(cmd.charAt(i) == ':'){
      makeNum = true;
    }
    else if(cmd.charAt(i) == ','){
      fl.keyboard.processKey(chr, keyCode);
    }
    else if(cmd.charAt(i) == '>'){
      fl.keyboard.processKey('_', 10);
    }
    else if(cmd.charAt(i) == '+'){
      fl.keyboard.processKey('_', 27);
    }
    else if(cmd.charAt(i) == '.'){
      fl.mouse.move(xpos, ypos);
      fl.mouse.press(37);
    }
    else {
      if(makeNum){
        if(cmd.charAt(i) == 'x') { xpos = Integer.parseInt(num); num =""; makeNum = false;} 
        else if(cmd.charAt(i) == 'y') { ypos = Integer.parseInt(num); num =""; makeNum = false;}
        else num += cmd.charAt(i);
      }
      else chr = cmd.charAt(i);
    }
  }
}

