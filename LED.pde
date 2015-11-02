/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
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

  /********************* OLD FILE LOADER *********************/
  // parse a xml file for led positions
  // public void parseLEDfile(String _file){
  //   leds = new ArrayList();
  //   XML file;
  //   try {
  //     file = loadXML(_file);
  //     XML[] segment = file.getChildren("segments");
  //
  //     for(XML ledData : XMLleds){
  //       addLEDs(ledData.getInt("from"),
  //               ledData.getInt("to"),
  //               ledData.getFloat("aX"),
  //               ledData.getFloat("aY"),
  //               ledData.getFloat("bX"),
  //               ledData.getFloat("bY"));
  //     }
  //     ledCount = leds.size();
  //     drawLEDmap();
  //   }
  //   catch(Exception e){
  //     println("LEDmap XML file "+_file+" not found");
  //     exit();
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
    brightness = _f;
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     FreeLEDing systems
///////
////////////////////////////////////////////////////////////////////////////////////

// OscLEDing to send LED data via OSC
// FastLEDing to send LED data to a duino with FastLED Library
// OctoLEDing to send LED data to a teensy 3.X with OctoWS11 Library

/**
 * use for OSC led thing
 */
// class OscLEDing extends FreeLEDing {
//   NetAddress ledServer;
//   int packetSize;
//
//   public OscLEDing(String _ip, int _port){
//     super();
//     ledServer = new NetAddress(_ip, _port);
//     ledCount = 1;
//     packetSize = (ledCount*3)+1;
//
//     println("LED server "+_ip+" port "+_port);
//   }
//
//   // overide to get ledCount
// 	public void parseLEDfile(String _file){
// 		super.parseLEDfile(_file);
// 		ledCount = leds.size();
// 		packetSize = ledCount*3;
// 	}
//
//   // make a packet and send it
//   public void output(){
//     byte[] ledData = new byte[packetSize];
//
//     for(int i = 1; i < packetSize; i++) ledData[i] = byte(0);
//
//     for(RGBled led : leds){
//       int adr = led.getIndex();
//       //ledCount = 62; // idk whats up
//       if(adr < ledCount){
//         adr = (adr*3);
//         ledData[adr] = led.getRed();
//         ledData[adr+1] = led.getGreen();
//         ledData[adr+2] = led.getBlue();
//       }
//     }
//     OscMessage mess = new OscMessage("/alc/freeLEDing/blob");
//     mess.add(ledData);
//     oscP5.send(mess, ledServer);
//   }
// }


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
