/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-06-10
 */


// a few FreeLEDing systems for fancy DMX fixtures

// Fancy fixtures controls one DMX universe via an arduino
// FastLEDing could be implemented as a fixture...

class FancyFixtures extends FreeLiner {

  Serial port;
  int channelCount = 512;
  byte[] dmxBuffer;

  ArrayList<Fixture> fixtures;

  PGraphics overLay;
  boolean showOverlay = true;

  public FancyFixtures(PApplet _pa, int _pipeline, String _port){
    super(_pa, _pipeline);
    connectSerial(_pa, _port);
    dmxBuffer = new byte[channelCount+1];
    for(byte _b : dmxBuffer) _b = byte(0);
    println("Connected to "+_port+" with "+channelCount+" channels");
    populateFixtures();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     FixtureCreation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  // will take a xml file later ;)
  public void populateFixtures(){
    overLay = createGraphics(width, height, P2D);
    overLay.beginDraw();
    overLay.clear();

    fixtures = new ArrayList<Fixture>();

    // construct fixtures here.
    // Fixture _fix = new ColorFlexWAUV(2);
    // _fix.setPosition(448, 64);
    // _fix.drawFixtureOverlay(overLay);
    // fixtures.add(_fix);
    parseXMLfile("dmxSetup.xml");

    overLay.endDraw();
    listFixtures();
  }

  public void parseXMLfile(String _file){
    XML file = null;
    try {
      file = loadXML("userdata/"+_file);
    }
    catch(Exception e){
      println("LEDmap XML file "+_file+" not found");
      exit();
    }
    if(file != null){
      println("file found "+_file);
      XML[] groupData = file.getChildren("group");
      PVector posA = new PVector(0,0);
      PVector posB = new PVector(0,0);
      int from = 0;
      int to = 0;
      for(XML xgroup : groupData){
        XML[] xseg = xgroup.getChildren("segment");
        Segment _seg;
        for(XML seg : xseg) segmentStrip(seg);
      }
    }
  }

  // XML segment to RGBStrip fixture
  // in this case its /led START_ADR LED_COUNT
  void segmentStrip(XML _seg){
    String[] cmd = split(_seg.getString("txt"), " ");
    if(cmd[0].equals("/led") && cmd.length>2){
      println(cmd[1]);
      int addr = int(cmd[1]);
      int count = int(cmd[2]);
      // println("Adding LEDs from: "+from+"  to: "+to);
      RGBStrip _fix;
      _fix = new RGBStrip(addr, count,
                          (int)_seg.getFloat("aX"),
                          (int)_seg.getFloat("aY"),
                          (int)_seg.getFloat("bX"),
                          (int)_seg.getFloat("bY"));
      fixtures.add(_fix);
      _fix.drawFixtureOverlay(overLay);
    }
  }

  void addFixture(Fixture _fix){

  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Operation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void update(){
    super.update();
    // updateFixtures
    parseGraphics(canvasManager.getCanvas());
    updateBuffer();
    // outputData
    // debugBuffer();
    dmxBuffer[0] = byte(42);
    port.write(dmxBuffer);
    // println(getMessage());
    if(showOverlay) image(overLay,0,0);
  }


  void debugBuffer(){
    println("|---------------------------------------------------=");
    for(int i = 0; i < 512; i++){
      print(" ("+i+" -> "+int(dmxBuffer[i])+") ");
      if(i%8 == 1) println();
    }
    println(" ");
    println("|---------------------------------------------------=");
  }


  void listFixtures(){
    println("|--------DMX FIXTURES---------|");
    int _cnt = 0;
    for(Fixture _fix : fixtures){
      println("============ "+(_cnt++)+" ==============");
      println("Address : "+_fix.getAddress());
      println("Name : "+_fix.getName());
      println("description : "+_fix.getDescription());
      println("=============================");
    }
  }

  void parseGraphics(PGraphics _pg){
    _pg.loadPixels();
    for(Fixture _fix : fixtures)
      _fix.parseGraphics(_pg);
  }

  void updateBuffer(){
    for(Fixture _fix : fixtures)
      _fix.bufferChannels(dmxBuffer);
  }

  public Fixture getFixture(int _ind){
    if(_ind < fixtures.size() && _ind >= 0) return fixtures.get(_ind);
    else return null;
  }

  /**
   * Connect to a serial port
   * @param String portPath
   */
  private void connectSerial(PApplet _pa, String _port){
    // connect to port
    try{
      port = new Serial(_pa, _port, 115200);
    }
    catch(Exception e){
      println(_port+" does not seem to work...");
      exit();
    }
    delay(100);
    for(int i = 0; i < 4; i++){
      port.write('?');
      delay(300);
      try{
        channelCount = Integer.parseInt(getMessage());
        break;
      } catch (Exception e){
        channelCount = 0;
      }
    }
    if(channelCount == 0){
      println("Could not get channel count.");
      exit();
    }
  }

  // gets message from the serialPort
  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }

  public void toggleExtraGraphics(){
		showOverlay = !showOverlay;
	}

}











/*
// will take a xml file later ;)
public void populateFixturesISM(){
  overLay = createGraphics(width, height, P2D);
  overLay.beginDraw();
  overLay.clear();

  fixtures = new ArrayList<Fixture>();

  // construct fixtures here.
  Fixture _fix = new ColorFlexWAUV(2);
  _fix.setPosition(448, 64);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  _fix = new RGBFixture(2);
  _fix.setPosition(448, 128);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  _fix = new ColorFlexWAUV(12);
  _fix.setPosition(480, 64);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  _fix = new RGBFixture(12);
  _fix.setPosition(480, 128);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  _fix = new MPanel(22, 64, 64);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  _fix = new MPanel(152, 256, 64);
  _fix.drawFixtureOverlay(overLay);
  fixtures.add(_fix);

  overLay.endDraw();
  listFixtures();
}
*/
