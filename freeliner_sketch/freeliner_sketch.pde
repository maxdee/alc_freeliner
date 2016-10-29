/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4gggggg
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
int useFullscreen = 1;
int useDisplay = 2; // SPAN is 0
int usePipeline = 1;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;
// fonts
PFont font;
PFont introFont;

final String VERSION = "0.4.4";
boolean doSplash = true;
boolean OSX = false;
boolean WIN = false;


ExternalGUI externalGUI = null; // set specific key to init gui
// documentation compiler, has to be super global
Documenter documenter;

// no other way to make a global gammatable...
int[] gammatable = new int[256];
float gamma = 3.2; // 3.2 seems to be nice

void settings(){
  if( fetchConfig ) fetchConfiguration();
  if(useFullscreen == 1){
    fullScreen(P2D,useDisplay);
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
  strokeCap(FreelinerConfig.STROKE_CAP);
  strokeJoin(FreelinerConfig.STROKE_JOIN);
  // detect OS
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else if(System.getProperty("os.name").charAt(0) == 'L') WIN = false;
  else WIN = true;

  // init freeliner
  freeliner = new FreeLiner(this, usePipeline);

  surface.setResizable(false);
  surface.setTitle("freeliner");
  noCursor();
  // add in keyboard, as hold - or = to repeat. beginners tend to hold keys down which is problematic
  if(FreelinerConfig.ENABLE_KEY_REPEAT) hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("fonts/MiniKaliberSTTBRK-48.vlw");
  font = loadFont("fonts/Arial-BoldMT-48.vlw");


  // perhaps use -> PApplet.platform == MACOSX
  background(0);
  splash();

  makeGammaTable();
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

void makeGammaTable(){
  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }
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
