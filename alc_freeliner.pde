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
boolean doSplash = true;

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
final String BG_IMAGE_FILE = "###data/backgroundImage.png";
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
  
  splash();
  noCursor();
  fl = new FreeLiner();
}

// lets processing know if we want it FULLSCREEN
boolean sketchFullScreen() {
  return FULLSCREEN;
}

// splash screen!
void splash(){
  background(0);
  stroke(100);
  fill(150);
  textMode(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
  textSize(24);
  fill(255);
  text("V0.02 - made with PROCESSING", 10, (height/2)+20);
}

// do the things
void draw() {
  if(backgroundImage != null) image(backgroundImage,0,0);
  else background(0);
  if(doSplash) splash();
  fl.update();
}
  

// relay the inputs to the mapper
void keyPressed() {
  fl.keyboard.processKey(key, keyCode);
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  fl.keyboard.processRelease(key, keyCode);
}

void mousePressed(MouseEvent event) {
  doSplash = false;
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




