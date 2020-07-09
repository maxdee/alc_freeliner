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

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;


final String VERSION = "0.4.8";
boolean doSplash = true;
boolean OSX = false;
boolean WIN = false;

// documentation compiler, has to be super global
Documenter documenter;
boolean MAKE_DOCUMENTATION = true;

// this object has the defaults
FreelinerProject projectConfig =  new FreelinerProject();
// no other way to make a global gammatable...
int[] gammatable = new int[256];
float gamma = 3.2; // 3.2 seems to be nice
// fonts
PFont font;
PFont introFont;

void settings(){
    String[] lastProjectPath = loadStrings(dataPath("last_project_path"));
    projectConfig.load(lastProjectPath[0]);
    // loadProjectPath(lastProjectPath[0]);
    println("[config] window height "+projectConfig.windowHeight);
    // // check if directory exists
    // File f = new File(lastProjectPath[0]);
    // if(f.isDirectory()){
    // }


    if(projectConfig.fullscreen == true){
        fullScreen(P2D, projectConfig.fullscreenDisplay);
    }
    else {
        size(
            projectConfig.windowWidth,
            projectConfig.windowHeight,
            P2D
        );
    }
    // needed for syphon!
    PJOGL.profile=1;
    smooth(projectConfig.smoothLevel);

    //
    // projectConfig.save();
}

// void loadProjectPath(String _folderName){
//     projectConfig.load(_folderName);
// }

public void newWithDir(File selection){
    println("selected dir"+selection.getPath());
    projectConfig.newProject(selection.getPath());
    String[] _dir = {projectConfig.fullPath};
    saveStrings(dataPath("last_project_path"), _dir);
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
    // String[] lastProjectPath = loadStrings(dataPath("last_project_path"));
    // println("loading once ");
    // projectConfig.load(lastProjectPath[0]);
    reset();
}

void reset(){
    println("running reset with : "+projectConfig.fullPath);
    surface.setResizable(true);
    // maybe add fullscreen
    surface.setSize(projectConfig.windowWidth, projectConfig.windowHeight);
    surface.setResizable(false);
    surface.setTitle("freeliner");
    frameRate(projectConfig.maxfps);

    // load fonts
    introFont = loadFont("fonts/MiniKaliberSTTBRK-48.vlw");
    font = loadFont("fonts/Monospaced.bold-64.vlw");

    background(0);
    doSplash = projectConfig.splash;
    splash();
    // removeBorder();
    documenter = new Documenter();
    strokeCap(projectConfig.STROKE_CAP);
    strokeJoin(projectConfig.STROKE_JOIN);
    // detect OS
    if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
    else if(System.getProperty("os.name").charAt(0) == 'L') WIN = false;
    else WIN = true;

    // init freeliner
    freeliner = new FreeLiner(this);

    noCursor();
    // add in keyboard, as hold - or = to repeat. beginners tend to hold keys down which is problematic
    if(projectConfig.keyRepeat) hint(ENABLE_KEY_REPEAT); // usefull for performance



    // perhaps use -> PApplet.platform == MACOSX

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

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Custom Draw (called by customDrawLayer)
///////
////////////////////////////////////////////////////////////////////////////////////

PGraphics customDraw(PGraphics _input){
    _input.clear();
    _input.background(255,0,0);
    return _input;
}
