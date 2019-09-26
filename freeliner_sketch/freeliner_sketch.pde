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
 *
 * webGUI: http://localhost:8000/index.html
 **/

// set the working directory of your project, folder must have all the freeliner files
String workingDirectory = null;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;
// fonts
PFont font;
PFont introFont;

final String VERSION = "0.4.8";
boolean doSplash = true;
boolean OSX = false;
boolean WIN = false;

// documentation compiler, has to be super global
Documenter documenter;

// no other way to make a global gammatable...
int[] gammatable = new int[256];
float gamma = 3.2; // 3.2 seems to be nice

void settings(){
    if(FreelinerConfig.USE_FULLSCREEN == true){
        fullScreen(P2D, FreelinerConfig.FULLSCREEN_DISPLAY);
    }
    else {
        size(
            FreelinerConfig.CONFIGURED_WIDTH,
            FreelinerConfig.CONFIGURED_HEIGHT,
            P2D
        );
    }
    // needed for syphon!
    PJOGL.profile=1;
    smooth(FreelinerConfig.SMOOTH_LEVEL);
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
    // surface.setResizable(true);
    //  surface.setSize(configuredWidth, configuredHeight);
    // removeBorder();
    if(workingDirectory != null) println(" *** CUSTOM WORKING DIRECTORY :\n"+workingDirectory);
    documenter = new Documenter();
    strokeCap(FreelinerConfig.STROKE_CAP);
    strokeJoin(FreelinerConfig.STROKE_JOIN);
    // detect OS
    if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
    else if(System.getProperty("os.name").charAt(0) == 'L') WIN = false;
    else WIN = true;

    // init freeliner
    freeliner = new FreeLiner(this, FreelinerConfig.RENDERING_PIPELINE);

    surface.setResizable(false);
    surface.setTitle("freeliner");
    noCursor();
    // add in keyboard, as hold - or = to repeat. beginners tend to hold keys down which is problematic
    if(FreelinerConfig.ENABLE_KEY_REPEAT) hint(ENABLE_KEY_REPEAT); // usefull for performance

    // load fonts
    introFont = loadFont("fonts/MiniKaliberSTTBRK-48.vlw");
    font = loadFont("fonts/Monospaced.bold-64.vlw");


    // perhaps use -> PApplet.platform == MACOSX
    background(0);
    splash();
    frameRate(60);
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

String dataDirectory(String _thing) {
    if(workingDirectory == null) return dataPath(_thing);
    else return workingDirectory+"/"+_thing;
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
