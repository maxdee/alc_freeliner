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

class FancyFixtures implements FreelinerConfig {
  PApplet applet;
  Serial port;
  int channelCount;
  byte[] byteBuffer;

  ArrayList<Fixture> fixtures;
  ArrayList<Fixture> individualFixtures;

  PGraphics overLayCanvas;
  PGraphics colorCanvas;
  PVector areaSize;
  PVector areaPos;

  boolean initialised;

  public FancyFixtures(PApplet _pa){
    applet = _pa;
    fixtures = new ArrayList<Fixture>();
    areaSize = new PVector(0,0);
    areaPos = new PVector(0,0);
    initialised = false;
  }
  // it all starts here
  public void loadFile(String _file){
    XML _xml = getXML(_file);
    if(_xml == null) return;
    if(parseSetup(_xml)){ // only continue if setup provided
      parseGroups(_xml);
      parseFixtures(_xml);
      cumulateFixtures();
      findSize();
      overLayCanvas =  createGraphics((int)areaSize.x, (int)areaSize.y, P2D);
      colorCanvas =  createGraphics((int)areaSize.x, (int)areaSize.y, P2D);
      drawAllFixtures();
      listFixtures();
      initialised = true;
      println("New led thingy at "+areaPos+" "+areaSize);
    }
  }

  public boolean parseSetup(XML _xml){
    XML setup = _xml.getChild("setup");
    if(setup.getString("type") != null){
      if(setup.getString("type").equals("LED")){
        int _size = connectSerial(applet, setup.getString("port"), setup.getInt("baud"))*3;
        setupByteBuffer(_size);
        return true;
      }
      else if(setup.getString("type").equals("DMX")){
        int _size = connectSerial(applet, setup.getString("port"), setup.getInt("baud"));
        setupByteBuffer(_size);
        return true;
      }
    }
    return false;
  }

  public void parseGroups(XML _xml){
    XML[] groupData = _xml.getChildren("group");
    for(XML xgroup : groupData){
      XML[] xseg = xgroup.getChildren("segment");
      Segment _seg;
      for(XML seg : xseg) segmentStrip(seg);
    }
  }

  public void parseFixtures(XML _xml){
    XML[] _fixtures = _xml.getChildren("fixture");
    for(XML _fix : _fixtures)
      parseFixture(_fix);
  }

  public void setupByteBuffer(int _size){
    channelCount = _size;
    byteBuffer = new byte[channelCount+1]; // plus one for header
    for(byte _b : byteBuffer) _b = byte(0);
  }

  // finds the smallest buffer size;
  public void findSize(){
    float _minX = width;
    float _minY = height;
    float _maxX = 0;
    float _maxY = 0;
    PVector _pos;
    for(Fixture _fix : individualFixtures){
      _pos = _fix.getPosition();
      if(_minX > _pos.x) _minX = _pos.x;
      if(_maxX < _pos.x) _maxX = _pos.x;
      if(_minY > _pos.y) _minY = _pos.y;
      if(_maxY < _pos.y) _maxY = _pos.y;
    }
    int _margin = 10;
    areaPos.set(_minX - _margin, _minY - _margin);
    areaSize.set(_maxX + (_margin*2), _maxY + (_margin*2));
    areaSize.sub(areaPos);
    // if(areaSize.x < 2) areaSize.x = 10;
    // if(areaSize.y < 2) areaSize.y = 10;
    for(Fixture _fix : individualFixtures){
      _pos = _fix.getPosition();
      _pos.sub(areaPos);
      _fix.setPosition((int)_pos.x, (int)_pos.y);
    }
  }

  public void cumulateFixtures(){
    individualFixtures = new ArrayList();
    for(Fixture _fix : fixtures){
      findSubFixtures(_fix);
    }
  }

  public void findSubFixtures(Fixture _fix){
    if(!individualFixtures.contains(_fix)) individualFixtures.add(_fix);
    if(_fix.getSubFixtures() != null){
      for(Fixture _child : _fix.getSubFixtures()) findSubFixtures(_child);
    }
  }

  public void drawAllFixtures(){
    overLayCanvas.beginDraw();
    overLayCanvas.clear();
    overLayCanvas.stroke(255);
    overLayCanvas.noFill();
    overLayCanvas.rect(0,0,areaSize.x-1,areaSize.y-1);
    for(Fixture _fix : fixtures) _fix.drawFixtureOverlay(overLayCanvas);
    overLayCanvas.endDraw();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     FixtureCreation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public void parseFixture(XML _xml){

  }

  // XML segment to RGBStrip fixture
  // in this case its /led START_ADR LED_COUNT
  void segmentStrip(XML _seg){
    String[] cmd = split(_seg.getString("txt"), " ");
    if(cmd[0].equals("/rgb") && cmd.length>1){
      // println(cmd[1]);
      int addr = int(cmd[1]);
      // println("Adding LEDs from: "+from+"  to: "+to);
      addRGBFixture(addr, (int)_seg.getFloat("aX"), (int)_seg.getFloat("aY"));
    }
    else if(cmd[0].equals("/led") && cmd.length>2){
      // println(cmd[1]);
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
      _fix.drawFixtureOverlay(overLayCanvas);
    }
  }

  public void addRGBFixture(int _adr, int _x, int _y){
    Fixture _fix = new RGBFixture(_adr);
    _fix.setPosition(_x,_y);
    _fix.drawFixtureOverlay(overLayCanvas);
    fixtures.add(_fix);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Operation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void update(PGraphics _pg){
    if(!initialised || _pg == null) return;
    colorCanvas.beginDraw();
    colorCanvas.clear();
    colorCanvas.image(_pg, -areaPos.x, -areaPos.y);
    colorCanvas.endDraw();
    // updateFixtures
    parseGraphics(colorCanvas);
    updateBuffer();
    // outputData
    // debugBuffer();
    byteBuffer[0] = byte(42);
    port.write(byteBuffer);
    // println(getMessage());
  }

  public void drawMap(PGraphics _pg){
    if(initialised && _pg != null){
      _pg.image(colorCanvas, areaPos.x, areaPos.y);
      _pg.image(overLayCanvas, areaPos.x, areaPos.y);
    }
  }

  void debugBuffer(){
    println("|---------------------------------------------------=");
    for(int i = 0; i < 512; i++){
      print(" ("+i+" -> "+int(byteBuffer[i])+") ");
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
      _fix.bufferChannels(byteBuffer);
  }

  public Fixture getFixture(int _ind){
    if(_ind < fixtures.size() && _ind >= 0) return fixtures.get(_ind);
    else return null;
  }

  public XML getXML(String _file){
    XML _xml = null;
    try {
      _xml = loadXML("userdata/"+_file);
    }
    catch(Exception e){
      println("FixtureMap XML file "+_file+" not found");
    }
    return _xml;
  }

  /**
   * Connect to a serial port
   * @param String portPath
   */
  private int connectSerial(PApplet _pa, String _port, int _baud){
    // connect to port
    try{
      port = new Serial(_pa, _port, _baud);
    }
    catch(Exception e){
      println(_port+" does not seem to work...");
      exit();
    }
    delay(100);
    int _chanCount = 0;
    for(int i = 0; i < 4; i++){
      port.write('?');
      delay(300);
      try{
        _chanCount = Integer.parseInt(getMessage());
        println("Connected to "+_port+" with "+_chanCount+" channels");
        break;
      } catch (Exception e){
        println("Could not get channel count.");
      }
    }
    return _chanCount;
  }

  // gets message from the serialPort
  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
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
