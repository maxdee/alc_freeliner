/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */

 import oscP5.*;
 import netP5.*;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     OPTIONS! (more in FreelinerConfig.pde)
///////
////////////////////////////////////////////////////////////////////////////////////

// invert colors
final boolean INVERTED_COLOR = false;

// UDP Port for incomming messages
final int OSC_IN_PORT = 6666;
// UDP Port for outgoing sync message
final int OSC_OUT_PORT = 6668;
// IP address to send sync messages to
final String OSC_OUT_IP = "192.168.0.141";

// lovely new feature of p3! set your graphics preferences.
void settings(){
  // set the resolution, or fullscreen and display
  //size(1200, 431, P2D);
  size(1024, 768, P2D);
  //fullScreen(P2D, 2);
  //fullScreen(P2D, SPAN);
  //orientation(LANDSCAPE);
  //pixelDensity(2);
  smooth();
  //noSmooth();
  //PJOGL.profile=1; // for syphon!?
}

// Your color pallette! customize it!
// use hex value or color(0,100,200);
final color[] userPallet = {
                  #ffff00,
                  #ffad10,
                  #ff0000,
                  #ff00ad,
                  #f700f7,
                  #ad00ff,
                  #0000ff,
                  #009cff,
                  #00c6ff,
                  #00deb5,
                  #a5ff00,
                  #f700f7,
                };

final int PALLETTE_COUNT = 12;



////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;
// fonts
PFont font;
PFont introFont;

final String VERSION = "0.3.1";
boolean doSplash = true;
boolean OSX = false;

OscP5 oscP5;
// where to send a sync message
NetAddress toPDpatch;
OscMessage tickmsg = new OscMessage("/freeliner/tick");

ExternalGUI externalGUI = null; // set specific key to init gui
boolean runGui = false;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  surface.setResizable(false); // needs to scale other PGraphics
  surface.setTitle("a!Lc Freeliner");
  //surface.setAlwaysOnTop(boolean);
  noCursor();
  hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  splash();

  // pick your flavour of freeliner
  freeliner = new FreeLiner(this);
  //freeliner = new FreelinerLED(this, "groups.xml");
  //freeliner = new FreelinerSyphon(this);

  //osc
  oscP5 = new OscP5(this, OSC_IN_PORT);
  toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);
  oscP5.addListener(freeliner.osc);
  // detect OSX
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else OSX = false;
  // perhaps use -> PApplet.platform == MACOSX

  if(runGui) launchGUI();
}

// splash screen!
void splash(){
  background(0);
  stroke(100);
  fill(150);
  //setText(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
  textSize(24);
  fill(255);
  text("V"+VERSION+" - made with PROCESSING", 10, (height/2)+20);
}

// external GUI launcher
void launchGUI(){
  if(externalGUI != null) return;
  externalGUI = new ExternalGUI(freeliner);
  String[] args = {"Freeliner GUI", "--display=1"};
  PApplet.runSketch(args, externalGUI);
  externalGUI.loop();
}
// void closeGUI(){
//   if(externalGUI != null) return;
//   PApplet.stopSketch
// }

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Draw
///////
////////////////////////////////////////////////////////////////////////////////////

// do the things
void draw() {
  background(0);
  if(doSplash) splash();
  freeliner.update();
}

// sync message to other software
void oscTick(){
 oscP5.send(tickmsg, toPDpatch);
}
////////////////////////////////////////////////////////////////////////////////////
///////
///////    Input
///////
////////////////////////////////////////////////////////////////////////////////////

// relay the inputs to the mapper
void keyPressed() {
  freeliner.getKeyboard().processKey(key, keyCode);
  if(key == '~') launchGUI();
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
  freeliner.getMouse().drag(mouseButton, mouseX, mouseY);
}

void mouseMoved() {
  freeliner.getMouse().move(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) {
  freeliner.getMouse().wheeled(event.getCount());
}
