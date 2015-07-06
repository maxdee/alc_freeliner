/**
 * ##copyright##
 * See LICENSE.md
 * 
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


// add scrolling text and osc settable text

import oscP5.*;
import netP5.*;

FreeLiner freeliner;
PFont font;
PFont introFont;
boolean doSplash = true;
PImage backgroundImage = null;

// OSC parts
OscP5 oscP5;
// where to send a sync message
NetAddress toPDpatch;
OscMessage tickmsg = new OscMessage("/freeliner/tick");

////////////////////////////////////////////////////////////////////////////////////
///////
///////     OPTIONS!
///////
////////////////////////////////////////////////////////////////////////////////////

// set if the sketch is FULLSCREEN by default
// if true, the resolution will be automaticaly set
//final boolean FULLSCREEN = true;
final boolean FULLSCREEN = false;

// default window size if not FULLSCREEN
int xres = 1024;
int yres = 768;

// for the glitch gallery ballpit
boolean ballPit = false;//true;

// invert colors
boolean INVERTED_COLOR = false;

// add a image path to load a background image.
final String BG_IMAGE_FILE = "data/###backgroundImage.jpg";

// are you using OSX? I do not, I use GNU/Linux
final boolean OSX = false;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     LED system
///////
////////////////////////////////////////////////////////////////////////////////////

// enable LEDsystem
final boolean LED_MODE = false;
FreeLEDing freeLED;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  setupGraphics();
  noCursor();

  // load fonts
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  
  splash();
  freeliner = new FreeLiner();

  // osc setup
  oscP5 = new OscP5(this,6667);
  toPDpatch = new NetAddress("127.0.0.1",6668);

  if(LED_MODE) setupLEDs();

  // cruft
  // attempting to skip anoying white screen on startup
  //frame.setBackground(new java.awt.Color(0, 0, 0));
  //textureMode(NORMAL);
}

/**
 * Setup the canvas, load a background image if provided
 */
void setupGraphics(){
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

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Draw
///////
////////////////////////////////////////////////////////////////////////////////////

// do the things
void draw() {
  if(backgroundImage != null) image(backgroundImage,0,0);
  else background(0);
  if(doSplash) splash();
  freeliner.update();
  if(LED_MODE) updateLEDs();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Input
///////
////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////
///////
///////    OSC
///////
////////////////////////////////////////////////////////////////////////////////////

void oscEvent(OscMessage theOscMessage) {  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern("/freeliner/tweak")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ssi")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      char tp = theOscMessage.get(0).stringValue().charAt(0);
      char kay = theOscMessage.get(1).stringValue().charAt(0);
      int val = theOscMessage.get(2).intValue();
      freeliner.keyboard.oscDistribute(tp, kay, val);
    }  
  }
  if(theOscMessage.checkAddrPattern("/freeliner/color")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("siiii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      char id = theOscMessage.get(0).stringValue().charAt(0);
      color col = color(
        theOscMessage.get(1).intValue(),
        theOscMessage.get(2).intValue(),
        theOscMessage.get(3).intValue(),
        theOscMessage.get(4).intValue());
      freeliner.templateManager.setCustomColor(id, col);
    }  
  }
}

void oscTick(){
  oscP5.send(tickmsg, toPDpatch); 
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    LED system
///////
////////////////////////////////////////////////////////////////////////////////////

void setupLEDs(){
  // init the subclass of freeLEDing
  //freeLED = new FreeLEDing();
  freeLED = new OctoLEDing(this, "/dev/ttyACM0");
  // load a ledmap file
  freeLED.parseLEDfile("data/led_landr2.xml");
}

void updateLEDs(){
  // parse the graphics
  freeLED.parseGraphics(freeliner.getCanvas());
  // draw the LED statuses
  //octoLED.drawLEDstatus(this.g);
  // output to whatever
  freeLED.output();
  // draw the LED map
  image(freeLED.getMap(),0,0);
}

