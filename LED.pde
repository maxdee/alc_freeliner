/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-06-01
 */

import processing.serial.*;
/**
 * LED mapping extention
 * Work in progress
 */

/**
 * Parent class for LED systems
 */
class FreeLEDing {
  // array of RGB leds to control
  ArrayList<RGBled> leds;
  // a canvas with led LED positions
  PGraphics ledMap;
  // number of LEDs to control
  int ledCount;
  // 1.0 of brightness
  float brightness;
  String ledMapFile;

  //dimmers
  float redDimmer = 1.0;
  float greenDimmer = 1.0;
  float blueDimmer = 1.0;

  // gamma correction
  boolean correctGamma = true;
  int[] gammatable = new int[256];
  float gamma = 7; // 3.2 seems to be nice

  public FreeLEDing(){
    leds = new ArrayList();
    ledMap = createGraphics(width, height); //switch to P2D
    // init gammatable
    for (int i=0; i < 256; i++) {
      gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
    }
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
      println("file found "+_file);
      XML[] groupData = file.getChildren("group");
      PVector posA = new PVector(0,0);
      PVector posB = new PVector(0,0);
      int from = 0;
      int to = 0;
      for(XML xgroup : groupData){
        XML[] xseg = xgroup.getChildren("segment");
        Segment _seg;
        for(XML seg : xseg){
          posA.set(seg.getFloat("aX"), seg.getFloat("aY"));
          posB.set(seg.getFloat("bX"), seg.getFloat("bY"));
          String[] cmd = split(seg.getString("txt"), " ");

          if(cmd[0].equals("/led") && cmd.length>2){
            println(cmd[1]);
            from = int(cmd[1]);
            to = int(cmd[2]);
            println("Adding LEDs from: "+from+"  to: "+to);
            //parse txt to from to
            addLEDs(from,
                    to,
                    posA.x,
                    posA.y,
                    posB.x,
                    posB.y);
          }
        }
      }
      ledCount = leds.size();
      drawLEDmap();
    }
    catch(Exception e){
      println("LEDmap XML file "+_file+" not found");
      exit();
    }
  }

  // private void addLEDsCircle(int from, int to, float aX, float aY, float bX, float bY){
  //   int ledCnt = abs(from-to);
  //   float angleIncrement = 3;
  //   float angle = atan2(aY-bY, aX-bX);
  //   float dist = dist(aX,aY, bX, bY);
  //   int ind;
  //   int x;
  //   int y;
  //   if(from == to) leds.add(new RGBled(from, int(aX), int(aY)));
  //   else {
  //     for(int i = from; i <= to; i++){
  //       ind = from+i;
  //       x = int((dist*cos(angle))+aX);
  //       y = int((dist*sin(angle))+aY);
  //       x = constrain(x,0, width);
  //       y = constrain(y,0, height);
  //       leds.add(new RGBled(ind, x, y));
  //       angle += angleIncrement;
  //     }
  //   }
  // }

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
    _f = constrain(_f, 0.0, 1.0);
    redDimmer = _f;
    greenDimmer = _f;
    blueDimmer = _f;
  }

  public void setRGBbrightness(float _r, float _g, float _blue){
    redDimmer = constrain(_r, 0.0, 1.0);
    greenDimmer = constrain(_r, 0.0, 1.0);
    blueDimmer = constrain(_r, 0.0, 1.0);
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     FreeLEDing systems
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * use for duino / FastLED library
 */
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
    for(int i = 0; i < 4; i++){
      port.write('?');
      delay(300);
      try{
        ledCount = Integer.parseInt(getMessage());
        break;
      } catch (Exception e){
        println("Could not get LED count");
      }
    }
    if(ledCount == 0){
      println("Could not get LED count.");
      exit();
    }
    packetSize = (ledCount*3)+1;

    println("Connected to "+_port+" with "+ledCount+" LEDs");
  }

  // make a packet and send it
  public void output(){
    byte[] ledData = new byte[packetSize];
    ledData[0] = '*';
    for(int i = 1; i < packetSize; i++) ledData[i] = byte(0);

    byte red = 0;
    byte green = 0;
    byte blue = 0;
    int cutoff = 3;
    for(RGBled led : leds){
      int adr = led.getIndex();
      if(ledCount != 142) ledCount = 142;
      //ledCount = 42; // idk whats up
      if(adr < ledCount){
        red = byte(led.getRed() * redDimmer);
        green = byte(led.getGreen() * greenDimmer);
        blue = byte(led.getBlue() * blueDimmer);

        red = byte(correctGamma ?  red : gammatable[red]);
        green = byte(correctGamma ?  green : gammatable[green]);
        blue = byte(correctGamma ?  blue : gammatable[blue]);
        adr = (adr*3)+1;
        if ((char)red > cutoff) ledData[adr] = red; else ledData[adr] = 0;
        if ((char)green > cutoff) ledData[adr+1] = green ; else ledData[adr+1] = 0;
        if ((char)blue > cutoff) ledData[adr+2] = blue; else ledData[adr+2] = 0;
      }
    }
    port.write(ledData);
    //println(t+" "+getMessage());
  }

  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }
}



/**
 * use for teensy / octows11 setup
 */
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


////////////////////////////////////////////////////////////////////////////////////
///////
///////     RGB led object
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * RGB LED object
 */
class RGBled{
  int index;
  int xPos;
  int yPos;
  float gamma = 1.7;
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
    int threshold = 4;
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
