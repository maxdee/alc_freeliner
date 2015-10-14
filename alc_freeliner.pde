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

FreeLiner freeliner;

// fonts
PFont font;
PFont introFont;

// OSC parts
OscP5 oscP5;
// where to send a sync message
NetAddress toPDpatch;
OscMessage tickmsg = new OscMessage("/freeliner/tick");

final float VERSION = 0.3;
////////////////////////////////////////////////////////////////////////////////////
///////
///////     OPTIONS!
///////
////////////////////////////////////////////////////////////////////////////////////

// are you using OSX? I do not, I use GNU/Linux
boolean OSX = false; // should set itself to true if OSX

// invert colors
final boolean INVERTED_COLOR = false;

// disable splash logo
boolean doSplash = true;

// UDP Port for incomming messages
final int OSC_IN_PORT = 6667;

// UDP Port for outgoing sync message
final int OSC_OUT_PORT = 6668;

// IP address to send sync messages to
final String OSC_OUT_IP = "127.0.0.1";

// lovely new feature of p3! set your graphics preferences.
void settings(){
  // set the resolution, or fullscreen and display
  //size(1024, 768, P2D);
  size(600, 600, P2D);
  //fullScreen(P2D, 2);
  smooth();
  //noSmooth();
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
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  surface.setResizable(false); // needs to scale other PGraphics
  //surface.setAlwaysOnTop(boolean);
  noCursor();
  hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  splash();

  // pick your flavour of freeliner
  freeliner = new FreeLiner();
  //freeliner = new FreelinerLED(this, "ledstarmap.xml");
  //freeliner = new FreelinerSyphon(this);

  // osc setup
  oscP5 = new OscP5(this, OSC_IN_PORT);
  toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);

  // set OS
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else OSX = false;
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
  freeliner.getMouse().drag(mouseButton, mouseX, mouseY);
}

void mouseMoved() {
  freeliner.getMouse().move(mouseX, mouseY);
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
  // tweak parameters
  if(theOscMessage.checkAddrPattern("/freeliner/tweak")) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ssi")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String tags = theOscMessage.get(0).stringValue();
      char kay = theOscMessage.get(1).stringValue().charAt(0);
      int val = theOscMessage.get(2).intValue();
      freeliner.keyboard.oscDistribute(tags, kay, val);
    }
  }
  // trigger animations
  else if(theOscMessage.checkAddrPattern("/freeliner/trigger")) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("s")) {
      String tags = theOscMessage.get(0).stringValue();
      freeliner.templateManager.oscTrigger(tags, -1);
    }
    if(theOscMessage.checkTypetag("si")) {
      String tags = theOscMessage.get(0).stringValue();
      freeliner.templateManager.oscTrigger(tags, theOscMessage.get(1).intValue());
    }
  }
  // enable diable and set intencity of trails
  else if(theOscMessage.checkAddrPattern("/freeliner/trails")) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("i")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int tval = theOscMessage.get(0).intValue();
      freeliner.oscSetTrails(tval);
    }
  }
  // change the colors in the userPallette
  else if(theOscMessage.checkAddrPattern("/freeliner/pallette")){
    if(theOscMessage.checkTypetag("iiii")){
      int _index = theOscMessage.get(0).intValue();
      int _r = theOscMessage.get(1).intValue();
      int _g = theOscMessage.get(2).intValue();
      int _b = theOscMessage.get(3).intValue();
      setUserPallette(_index, color(_r, _g, _b));
    }
  }
  // set the custom color
  else if(theOscMessage.checkAddrPattern("/freeliner/color")) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("siiii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String tags = theOscMessage.get(0).stringValue();
      color col = color(
        theOscMessage.get(1).intValue(),
        theOscMessage.get(2).intValue(),
        theOscMessage.get(3).intValue(),
        theOscMessage.get(4).intValue());
      freeliner.templateManager.setCustomColor(tags, col);
    }
  }
  else if(theOscMessage.checkAddrPattern("/freeliner/text")){
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("iis")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int grp = theOscMessage.get(0).intValue();
      int seg = theOscMessage.get(1).intValue();
      String txt = theOscMessage.get(2).stringValue();
      freeliner.groupManager.setText(grp, seg, txt);
    }
  }
}

void oscTick(){
  oscP5.send(tickmsg, toPDpatch);
}

void setUserPallette(int _i, color _c){
  if(_i >= 0 && _i < PALLETTE_COUNT) userPallet[_i] = _c;
}
