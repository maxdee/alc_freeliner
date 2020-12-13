/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * HELLO THERE! WELCOME to FREELINER
 *
 * webGUI: http://localhost:8000/index.html
 **/

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////
import static javax.swing.JOptionPane.*;
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

// fonts
PFont font;
PFont introFont;


boolean createNewProject = true;
void settings(){
    String[] lastProjectPath = loadStrings(dataPath("last_project_path"));
    if(lastProjectPath != null){
        if(lastProjectPath.length > 0){
            projectConfig.load(lastProjectPath[0]);
            createNewProject = false;
        }
    }
    else {
        // make a small window to dissuade from using.
        projectConfig.windowWidth = 200;
        projectConfig.windowHeight = 100;
        projectConfig.fullscreen = false;
        println("-------------- YES");
    }
    // setup screen
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
}

// callback for the file browser invoked with "fl new"
public void newWithDir(File selection){
    println("[project] selected dir and RESTART "+selection.getPath());
    projectConfig.newProject(selection.getPath());
    String[] _dir = {projectConfig.fullPath};
    saveStrings(dataPath("last_project_path"), _dir);
    exit();
    // createNewProject = false;
    // reset();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
    reset();
  // final String id = showInputDialog("Please enter new ID");
}

void reset(){
    println("[project] running reset with : "+projectConfig.fullPath);
    surface.setResizable(false);
    if(projectConfig.fullscreen) {
        projectConfig.windowWidth = displayWidth;
        projectConfig.windowHeight = displayHeight;
    }
    // surface.setSize(projectConfig.windowWidth, projectConfig.windowHeight);
    // surface.setResizable(false);
    surface.setTitle("freeliner - "+projectConfig.projectName);
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
    if(createNewProject){
        selectFolder("pick directory for new project", "newWithDir");
    }
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
