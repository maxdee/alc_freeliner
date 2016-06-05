/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

import oscP5.*;
import netP5.*;

/**
 * HELLO THERE! WELCOME to FREELINER
 * There is a bunch of settings in the Config.pde file.
 */

// for loading configuration
// false -> use following parameters
// true -> use the configuration saved in data/userdata/configuration.xml
boolean fetchConfig = false; // set to true for #packaging
int configuredWidth = 1024;
int configuredHeight = 768;
int useFullscreen = 0;
int useDisplay = 1; // SPAN is 0
int usePipeline = 0;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;
// fonts
PFont font;
PFont introFont;

final String VERSION = "0.4.2";
boolean doSplash = true;
boolean OSX = false;

ExternalGUI externalGUI = null; // set specific key to init gui
// documentation compiler
Documenter documenter;

void settings(){
  if( fetchConfig ) fetchConfiguration();
  if(useFullscreen == 1){
    fullScreen(P2D,2);
  }
  else {
    size(configuredWidth, configuredHeight, P2D);
  }
  // needed for syphon!
  PJOGL.profile=1;
}

// single configuration file for the moment.
void fetchConfiguration(){
  XML _file = null;
  try{
    _file = loadXML(sketchPath()+"/data/userdata/configuration.xml");
  }
  catch(Exception e) {
    println("No configuration.xml file found.");
  }
  if(_file != null) {
    configuredWidth = _file.getInt("width");
    configuredHeight = _file.getInt("height");
    useFullscreen = _file.getInt("fullscreen");
    useDisplay = _file.getInt("display");
    usePipeline = _file.getInt("pipeline");
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  documenter = new Documenter();
  //pick your flavour of freeliner
  freeliner = new FreeLiner(this, usePipeline);
  //freeliner = new FreelinerSyphon(this, usePipeline); // <- FOR SYPHON // implement in layer
  //freeliner = new FreelinerSpout(this, usePipeline); // <- FOR SPOUT
  //freeliner = new FreelinerLED(this, usePipeline, "newHoops.xml");//tunnel_map_two.xml"); // implement in layer?
  //freeliner = new FreelinerLED(this,"catpartyDMX.xml");//tunnel_map_two.xml"); // implement in layer?

  surface.setResizable(false);
  surface.setTitle("a!Lc Freeliner");
  noCursor();
  // add in keyboard, as hold - or = to repeat. beginners tend to hold keys down which is problematic
  if(FreelinerConfig.ENABLE_KEY_REPEAT) hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("fonts/MiniKaliberSTTBRK-48.vlw");
  font = loadFont("fonts/Arial-BoldMT-48.vlw");

  // detect OSX
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else OSX = false;
  // perhaps use -> PApplet.platform == MACOSX
  background(0);
  splash();
}

// splash screen!
void splash(){
  stroke(100);
  fill(150);
  //setText(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
  textSize(24);
  fill(255);
  text("V"+VERSION+" - made with PROCESSING", 10, (height/2)+20);
}

//external GUI launcher
void launchGUI(){
  if(externalGUI != null) return;
  externalGUI = new ExternalGUI(freeliner);
  String[] args = {"Freeliner GUI", "--display=1"};
  PApplet.runSketch(args, externalGUI);
  externalGUI.loop();
}
void closeGUI(){
  if(externalGUI != null) return;
  //PApplet.stopSketch();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Draw
///////
////////////////////////////////////////////////////////////////////////////////////

// do the things
void draw() {
  background(0);
  freeliner.update();
  if(doSplash) splash();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Input
///////
////////////////////////////////////////////////////////////////////////////////////

void webSocketServerEvent(String _cmd){
  freeliner.getCommandProcessor().queueCMD(_cmd);
}

// relay the inputs to the mapper
void keyPressed() {
  freeliner.getKeyboard().keyPressed(keyCode, key);
  if(key == '~') launchGUI();
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  freeliner.getKeyboard().keyReleased(keyCode, key);
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
