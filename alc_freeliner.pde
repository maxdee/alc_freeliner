/**
 * ##copyright##
 * See LICENSE.md
 * 
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


///////   bug removing branch renderer from item...

import oscP5.*;
import netP5.*;
import java.net.InetAddress;

FreeLiner freeliner;
PFont font;
PFont introFont;
boolean doSplash = true;

// for the glitch gallery ballpit
boolean ballPit = false;//true;

// for the liquid crystal table
boolean liquid = false;//true;//

// set if the sketch is FULLSCREEN by default
boolean FULLSCREEN = true;
//final boolean FULLSCREEN = false;

// default window size if not FULLSCREEN
int xres = 1024;
int yres = 768;

// add a image path to load a background image.
final String BG_IMAGE_FILE = "###data/backgroundImage.png";
PImage backgroundImage = null;

void setup() {
  // check if background image provided
  try {
    backgroundImage = loadImage(BG_IMAGE_FILE);
  }
  catch (Exception e){
    println("No background image found");
  }
  // if no background image provided set size to default or fullscreen
  if(backgroundImage == null){
    if(!FULLSCREEN) size(xres, yres, P2D);
    else size(displayWidth, displayHeight, P2D);
  }
  // if background image is provided set the size of the image.
  else {
    size(backgroundImage.width, backgroundImage.height, P2D);
  }

  // attempting to skip anoying white screen on startup
  //frame.setBackground(new java.awt.Color(0, 0, 0));
  
  //is this helpfull?
  //frameRate(30); 
  
  //textureMode(NORMAL);
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  
  splash();
  noCursor();
  freeliner = new FreeLiner();
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
  freeliner.update();
}
  

// relay the inputs to the mapper
void keyPressed() {
  freeliner.getKeyboard().processKey(key, keyCode);
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  freeliner.getKeyboard().processRelease(key, keyCode);
}

void mousePressed(MouseEvent event) {
  doSplash = false;
  freeliner.getMouse().press(mouseButton);
}

void mouseDragged() {
  if(ballPit && mouseX < width/2) freeliner.getMouse().drag(mouseButton, 
                                              -(int((mouseY/(float)height)*(width/2.0)))+width/2,
                                              (int((mouseX/(width/2.0))*height)));
  else freeliner.getMouse().drag(mouseButton, mouseX, mouseY);
}

void mouseMoved() {
  if(ballPit && mouseX < width/2) freeliner.getMouse().move(-(int((mouseY/(float)height)*(width/2.0)))+width/2,
                                              (int((mouseX/(width/2.0))*height))); 
  else freeliner.getMouse().move(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) {
  freeliner.getMouse().wheeled(event.getCount());
}




