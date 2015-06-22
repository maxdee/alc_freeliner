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
int xres = 1300;//1024;
int yres = 700;//768;

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

  if(LED_MODE) setupLEDs();
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
  ///////    LED
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

void setupLEDs(){
  // init the subclass of freeLEDing
  freeLED = new OctoLEDing(this, "/dev/ttyACM0");
  // load a ledmap file
  freeLED.parseLEDfile("data/ledstarmap.xml");
}

void updateLEDs(){
  freeLED.parseGraphics(freeliner.getCanvas());
  //octoLED.drawLEDstatus(this.g);
  freeLED.output();
  image(freeLED.getMap(),0,0);
}




import processing.serial.*;

class FreeLEDing {
  // array of RGB leds to control
  ArrayList<RGBled> leds;
  // a canvas with led LED positions
  PGraphics ledMap;
  // number of LEDs to control
  int ledCount;
  // 1.0 of brightness
  float brightness;

  public FreeLEDing(){
    leds = new ArrayList();
    ledMap = createGraphics(width, height); //switch to P2D
  }

  // override to send data to a LED system
  public void output(){}

  // parse a PGraphics for led colors
  public void parseGraphics(PGraphics _pg){
    _pg.loadPixels();
    int ind; 
    int max = _pg.width*_pg.height;
    for(RGBled led : leds){
      ind = led.getX() + (led.getY()*width);
      if(ind < max) led.setColor(_pg.pixels[ind]);
    }
  }

  // parse a xml file for led positions
  public void parseLEDfile(String _file){
    leds = new ArrayList();
    XML file;
    try {
      file = loadXML(_file);
      XML[] XMLleds = file.getChildren("led");
      
      for(XML ledData : XMLleds){
        addLEDs(ledData.getInt("from"),
                ledData.getInt("to"),
                ledData.getFloat("aX"),
                ledData.getFloat("aY"),
                ledData.getFloat("bX"),
                ledData.getFloat("bY"));
      } 
      ledCount = leds.size();
      drawLEDmap();
    }
    catch(Exception e){
      println("LEDmap XML file "+_file+" not found");
      exit();
    }
  }

  // add LEDs with interpolation if necessary
  private void addLEDs(int from, int to, float aX, float aY, float bX, float bY){
    int ledCnt = abs(from-to);
    float gap = 1.0/ledCnt;
    int ind;
    int x;
    int y;
    if(from == to) leds.add(new RGBled(from, int(aX), int(aY)));
    else {
      for(int i = 0; i <= ledCnt; i++){
        ind = int(lerp(from, to, i*gap));
        x = int(lerp(aX, bX, i*gap));
        y = int(lerp(aY, bY, i*gap));
        leds.add(new RGBled(ind, x, y));
      }
    }
  }

  // simple displaying of LEDs on top of a canvas
  public void drawLEDstatus(PGraphics _pg){
    for(int i = 0; i< leds.size(); i++){
      _pg.strokeWeight(8);
      _pg.stroke(255);
      _pg.point((i*8)+10, 10);
      _pg.strokeWeight(8);
      _pg.stroke(leds.get(i).getColor());
      _pg.point((i*8)+10, 10);
    }
  }

  // draw LEDs position / address on a canvas
  public void drawLEDmap(){
    ledMap.beginDraw();
    ledMap.clear();
    for(RGBled led : leds){
      ledMap.stroke(255);
      ledMap.strokeWeight(4);
      ledMap.point(led.getX(), led.getY());
      ledMap.text(str(led.getIndex()), led.getX(), led.getY());
    }
    ledMap.endDraw();
  }
  
  public PGraphics getMap(){
    return ledMap;
  }

  public void setBrightness(float _f){
    brightness = _f;
  }
}






class FastLEDing extends FreeLEDing {
  Serial port;
  int packetSize;
  
  public FastLEDing(PApplet _pa, String _port){
    super();
    try{
      port = new Serial(_pa, _port, 115200);
    }
    catch(Exception e){
      println(_port+" does not seem to work");
      exit();
    }
    delay(100);
    port.write('?');
    delay(100);
    ledCount = Integer.parseInt(getMessage());
    packetSize = (ledCount*3)+1;

    println("Connected to "+_port+" with "+ledCount+" LEDs");
  }

  // make a packet and send it
  public void output(){
    byte[] ledData = new byte[packetSize];
    ledData[0] = '*';
    for(int i = 1; i < packetSize; i++) ledData[i] = byte(0);

    for(RGBled led : leds){
      int adr = led.getIndex();
      ledCount = 62; // idk whats up
      if(adr < ledCount){
        adr = (adr*3)+1;
        ledData[adr] = led.getRed();
        ledData[adr+1] = led.getGreen();
        ledData[adr+2] = led.getBlue();
      }
    }
    port.write(ledData);
  }

  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }
}





// use for teensy / octows11 setup
class OctoLEDing extends FreeLEDing {
  Serial port;
  int packetSize;
  
  public OctoLEDing(PApplet _pa, String _port){
    super();
    try{
      port = new Serial(_pa, _port, 115200);
    }
    catch(Exception e){
      println(_port+" does not seem to work");
      exit();
    }
    delay(100);
    port.write('?');
    delay(100);
    ledCount = Integer.parseInt(getMessage());
    packetSize = (ledCount*3)+1;
    delay(100);
    println("Connected to "+_port+" with "+ledCount+" LEDs");
  }

  // make a packet and send it
  public void output(){
    byte[] ledData = new byte[packetSize];
    ledData[0] = '*';
    for(int i = 1; i < packetSize; i++) ledData[i] = byte(0);

    for(RGBled led : leds){
      int adr = led.getIndex();
      if(adr < ledCount){
        adr = (adr*3)+1;
        ledData[adr] = led.getRed();
        ledData[adr+1] = led.getGreen();
        ledData[adr+2] = led.getBlue();
      }
    }
    port.write(ledData);
  }

  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }
}






class RGBled{
  int index;
  int xPos;
  int yPos;

  byte red;
  byte green;
  byte blue;

  color col;
  
  public RGBled(int _i, int _x, int _y){
    index = _i;
    xPos = _x;
    yPos = _y;
  }

  public void setColor(color _c){
    col = _c;
    int threshold = 7;
    red = byte((col >> 16) & 0xFF);
    //if(red < threshold) red = byte(0);
    green = byte((col >> 8) & 0xFF);
    //if(green < threshold) green = byte(0);
    blue = byte(col & 0xFF);
    //if(blue < threshold) blue = byte(0);
  }

  public color getColor(){
    return col;
  }
  
  public byte getRed(){
    return red;
  }
  
  public byte getGreen(){
    return green;
  }
  
  public byte getBlue(){
    return blue;
  }

  public int getIndex(){
    return index;
  }
  public int getX(){
    return xPos;
  }
  public int getY(){
    return yPos;
  }
}


