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
 * Here are some settings. There are more settings in the Config.pde file.
 */
void settings(){
  // set the resolution, or fullscreen and display
  //if(FreelinerConfig.FULLSCREEN) fullScreen(P2D,2);
  //else size(FreelinerConfig.WINDOW_WIDTH, FreelinerConfig.WINDOW_HEIGHT, P2D);
  size(1024, 768, P2D);

  //noSmooth();
  //size(1024, 683, P2D);
  //fullScreen(P2D, 2);
  //fullScreen(P2D, SPAN);
  // needed for syphon!
  PJOGL.profile=1;
}

/**
 * Your color pallette! customize it!
 * Use hex value or color(0,100,200);
 */
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

final String VERSION = "0.4.1";
boolean doSplash = true;
boolean OSX = false;

ExternalGUI externalGUI = null; // set specific key to init gui
boolean runGui = false;
Documenter documenter;
////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  documenter = new Documenter();
  // pick your flavour of freeliner
  freeliner = new FreeLiner(this);
  //freeliner = new FreelinerSyphon(this); // <- FOR SYPHON // implement in layer
  //freeliner = new FreelinerSpout(this); // <- FOR SPOUT
  //freeliner = new FreelinerLED(this,"led_fullstrips.xml");//tunnel_map_two.xml"); // implement in layer?
  //freeliner = new FreelinerLED(this,"tenDMX.xml"); // implement in layer?


  surface.setResizable(false);
  surface.setTitle("a!Lc Freeliner");
  noCursor();
  hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");

  // detect OSX
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else OSX = false;
  // perhaps use -> PApplet.platform == MACOSX
  background(0);
  splash();
  if(runGui) launchGUI();
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
  freeliner.getKeyboard().keyPressed(keyCode);
  if(key == '~') launchGUI();
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  freeliner.getKeyboard().keyReleased(keyCode);
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
