/**
 * ##copyright##
 * See LICENSE.md
 * 
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


////!!!!!!! bank saving, if template was loading save back?
//// load 0 to make a new one?

// add scrolling text and osc settable text

import oscP5.*;
import netP5.*;
import processing.serial.*;

OscP5 oscP5;
NetAddress toPDpatch;
OscMessage tickmsg = new OscMessage("/freeliner/tick");

FreeLiner freeliner;
PFont font;
PFont introFont;
boolean doSplash = true;
PImage backgroundImage = null;


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

// enable LEDsystem
final boolean LED_MODE = true;

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
  
  //textureMode(NORMAL);
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  
  splash();
  noCursor();
  freeliner = new FreeLiner();

  oscP5 = new OscP5(this,6667);
  toPDpatch = new NetAddress("127.0.0.1",6668);

  if(LED_MODE){
    setupLEDS();
    backgroundImage = drawLEDs();
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

// do the things
void draw() {
  if(backgroundImage != null) image(backgroundImage,0,0);
  else background(0);
  if(doSplash) splash();
  freeliner.update();
  if(LED_MODE) parseImageLEDS(freeliner.templateRenderer.getCanvas());
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

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    OSC
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
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
}

void oscTick(){
  oscP5.send(tickmsg, toPDpatch); 
}


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    LEDs :P
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

Serial duino;
PGraphics ledMap;
ArrayList<WSled> wsleds;
int ledCount = 0;

void setupLEDS(){
  //duino = new Serial(this, "/dev/ttyACM0", 9600);
  // load led file
  loadLEDFile();
}

void writeToLEDs(){
  byte[] data = new byte[ledCount*3];
  int ind;
  for(WSled led : wsleds){
    ind = led.index*3; 
    data[ind] = byte((led.c & 0xFF0000) >> 16);
    data[ind+1] = byte((led.c & 0x00FF00) >> 8);
    data[ind+2] = byte((led.c & 0x0000FF));
  }
  //duino.write(data);
}

void loadLEDFile(){
  wsleds = new ArrayList();
  XML file = loadXML("data/ledmap.xml");
  XML[] leds = file.getChildren("led");
  ledCount = leds.length;
  for(XML ledData : leds){
    addLEDs(ledData.getInt("from"),
            ledData.getInt("to"),
            ledData.getFloat("aX"),
            ledData.getFloat("aY"),
            ledData.getFloat("bX"),
            ledData.getFloat("bY"));
  } 
}

void addLEDs(int from, int to, float x1, float y1, float x2, float y2){
  int ledCnt = abs(from-to);
  float gap = 1.0/ledCnt;
  int ind;
  int x;
  int y;
  for(int i = 0; i <= ledCnt; i++){
    ind = int(lerp(from, to, i*gap));
    x = int(lerp(x1, x2, i*gap));
    y = int(lerp(y1, y2, i*gap));
    wsleds.add(new WSled(ind, x, y));
  }
}

void parseImageLEDS(PGraphics _pg){
  _pg.loadPixels();
  for(WSled led : wsleds){
    led.setColor(_pg.pixels[led.x + (led.y*width)]);
  }
  strokeWeight(6);
  for(int i = 0; i< wsleds.size(); i++){
    stroke(wsleds.get(i).c);
    point((i*8)+10, 10);
  }
}

int pxl(int x, int y){
  return x + (y*x);
}

PGraphics drawLEDs(){
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.background(0);
  pg.stroke(255);
  pg.strokeWeight(2);
  for(WSled led : wsleds){
    pg.point(led.x, led.y);
    pg.text(str(led.index), led.x, led.y);
  }
  pg.endDraw();
  return pg;
}

class WSled{
  int index;
  int x;
  int y;
  color c;
  public WSled(int _i, int _x, int _y){
    index = _i;
    x = _x;
    y = _y;
  }
  public void setColor(color _c){
    c = _c;
  }
}