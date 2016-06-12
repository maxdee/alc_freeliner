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
  // ledCount is the channel Count...

  public FancyFixtures(PApplet _pa, int _pipeline, String _port){
    super(_pa, _pipeline);
    connectSerial(_pa, _port);
    dmxBuffer = new byte[channelCount+1];
    for(byte _b : dmxBuffer) _b = byte(0);
    println("Connected to "+_port+" with "+channelCount+" channels");
    populateFixtures();
  }

  // will take a xml file later ;)
  public void populateFixtures(){
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

  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }

  public void toggleExtraGraphics(){
		showOverlay = !showOverlay;
	}

}
