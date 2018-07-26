/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-06-10
 */

// a few FreeLEDing systems for fancy DMX fixtures

// packet size should be implemented in serial specificaly, pushing only the buffer size.
// mode artnet universe

class FancyFixtures implements FreelinerConfig {
    PApplet applet;
    int channelCount;
    byte[] byteBuffer;
    ByteSender byteSender;

    ArrayList<Fixture> fixtures;
    ArrayList<Fixture> individualFixtures;

    PGraphics overLayCanvas;
    PGraphics colorCanvas;
    PVector areaSize;
    PVector areaPos;

    boolean initialised;
    boolean recording = false;
    ArrayList<Byte> recordingBuffer;
    int clipCount = 0;

    // to check channels
    int testChannel = -1;
    int testValue = 255;
    int ledStart = 0;

    public FancyFixtures(PApplet _pa) {
        applet = _pa;
        fixtures = new ArrayList<Fixture>();
        areaSize = new PVector(0,0);
        areaPos = new PVector(0,0);
        initialised = false;
    }

    // it all starts here
    public void loadFile(String _file) {
        initialised = false;
        if(byteSender instanceof SerialSender) byteSender.disconnect();
        fixtures = new ArrayList<Fixture>();
        XML _xml = getXML(_file);
        if(_xml == null) return;
        if(parseSetup(_xml)) { // only continue if setup provided
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

    public boolean parseSetup(XML _xml) {
        XML setup = _xml.getChild("setup");
        if(setup == null) return false;
        if(setup.getString("type") != null) {
            if(setup.getString("type").equals("LED")) {
                byteSender = new SerialSender(applet);
                byteSender.connect(setup.getString("port"), setup.getInt("baud"));
                int _size = ((SerialSender)byteSender).getCount()*3;
                setupByteBuffer(_size);
                return true;
            } else if(setup.getString("type").equals("DMX")) {
                byteSender = new SerialSender(applet);
                byteSender.connect(setup.getString("port"), setup.getInt("baud"));
                int _size = ((SerialSender)byteSender).getCount();
                setupByteBuffer(_size);
                return true;
            } else if(setup.getString("type").equals("ARTNET")) {
                ArtNetSender _sender = new ArtNetSender();
                XML[] _hostsXML = setup.getChildren("host");
                for(XML _h : _hostsXML){
                    _sender.addHost(_h.getString("ip"), _h.getInt("start"), _h.getInt("end"));
                    println("adding host  "+_h.getString("ip")+" universes: "+_h.getInt("start")+"-"+_h.getInt("end"));
                }
                byteSender = _sender;

                setupByteBuffer(setup.getInt("universes")*512);
                // byteSender.connect(setup.getString("host"));
                // ((ArtNetSender)byteSender).setStartUniverse(setup.getInt("startUniverse"));
                return true;
            }
        }
        return false;
    }

    public void parseGroups(XML _xml) {
        XML[] groupData = _xml.getChildren("group");
        for(XML xgroup : groupData) {
            XML[] xseg = xgroup.getChildren("segment");
            Segment _seg;
            for(XML seg : xseg) segmentStrip(seg);
        }
    }

    public void parseFixtures(XML _xml) {
        XML[] _fixtures = _xml.getChildren("fixture");
        for(XML _fix : _fixtures)
            parseFixture(_fix);
    }



    public void parseFixture(XML _xml) {
        //   for(XML)
        XML[] _fix = _xml.getChildren("xyled");
        int _cnt = 0;
        for(XML _xyled : _fix){
            int _adr = (int) _xyled.getFloat("a");
            int _x = (int) _xyled.getFloat("x");
            int _y = (int) _xyled.getFloat("y");
            if(_x < width && _x >= 0){
                if(_y < height && _y >= 0){
                    if(_adr < channelCount && _adr >= 0){
                        addRGBFixture(_adr, _x, _y);
                        _cnt++;
                    }
                }
            }
        }
        println("Added  "+_cnt+" LEDs");
        //
        // println("**********************************************");
        // println("**********************************************");
        // println("**********************************************");
        // println(_fix);
        // println("**********************************************");
        // println("**********************************************");
        // println("**********************************************");

    }

    public void addRGBFixture(int _adr, int _x, int _y) {
        Fixture _fix = new RGBFixture(_adr);
        _fix.setPosition(_x,_y);
        _fix.drawFixtureOverlay(overLayCanvas);
        fixtures.add(_fix);
    }






    public void setupByteBuffer(int _size) {
        channelCount = _size;
        byteBuffer = new byte[channelCount]; // plus one for header
        for(byte _b : byteBuffer) _b = byte(0);
    }

    // finds the smallest buffer size;
    public void findSize() {
        float _minX = width;
        float _minY = height;
        float _maxX = 0;
        float _maxY = 0;
        PVector _pos;
        for(Fixture _fix : individualFixtures) {
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
        for(Fixture _fix : individualFixtures) {
            _pos = _fix.getPosition();
            _pos.sub(areaPos);
            _fix.setPosition((int)_pos.x, (int)_pos.y);
        }
    }

    public void cumulateFixtures() {
        individualFixtures = new ArrayList();
        for(Fixture _fix : fixtures) {
            findSubFixtures(_fix);
        }
    }

    public void findSubFixtures(Fixture _fix) {
        if(!individualFixtures.contains(_fix)) individualFixtures.add(_fix);
        if(_fix.getSubFixtures() != null) {
            for(Fixture _child : _fix.getSubFixtures()) findSubFixtures(_child);
        }
    }

    public void drawAllFixtures() {
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


    // XML segment to RGBStrip fixture
    // in this case its /led START_ADR LED_COUNT
    void segmentStrip(XML _seg) {
        String[] cmd = split(_seg.getString("txt"), " ");
        if(cmd[0].equals("/rgb") && cmd.length>1) {
            // println(cmd[1]);
            int addr = int(cmd[1]);
            Fixture _fix = new RGBPar(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.drawFixtureOverlay(overLayCanvas);
            fixtures.add(_fix);
            // println("Adding LEDs from: "+from+"  to: "+to);
            //   addRGBFixture(addr,(int)_seg.getFloat("aX"), (int)_seg.getFloat("aY"));
        } else if(cmd[0].equals("/aw") && cmd.length>1) {
            // println(cmd[1]);
            int addr = int(cmd[1]);
            Fixture _fix = new AWPar(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.drawFixtureOverlay(overLayCanvas);
            fixtures.add(_fix);
            // println("Adding LEDs from: "+from+"  to: "+to);
            //   addRGBFixture(addr,(int)_seg.getFloat("aX"), (int)_seg.getFloat("aY"));
        }
        // else if(cmd[0].equals("/led") && cmd.length>2) {
        //     // println(cmd[1]);
        //     int addr = int(cmd[1])*3;
        //     int count = int(cmd[2]);
        //     // println("Adding LEDs from: "+from+"  to: "+to);
        //     RGBStrip _fix;
        //     _fix = new RGBStrip(addr, count,
        //                         (int)_seg.getFloat("aX"),
        //                         (int)_seg.getFloat("aY"),
        //                         (int)_seg.getFloat("bX"),
        //                         (int)_seg.getFloat("bY"));
        //     fixtures.add(_fix);
        //     _fix.drawFixtureOverlay(overLayCanvas);
        // }
        else if(cmd[0].equals("/led") && cmd.length>2) {
            // println(cmd[1]);
            int addr = int(cmd[1])*3;
            int count = 1+int(cmd[2])-int(cmd[1]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            RGBStrip _fix;
            _fix = new RGBStripPad(addr, count,
                                (int)_seg.getFloat("aX"),
                                (int)_seg.getFloat("aY"),
                                (int)_seg.getFloat("bX"),
                                (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
        else if(cmd[0].equals("/rgbw") && cmd.length>2){
            // println(cmd[1]);
            int addr = int(cmd[1])*3;
            int count = 1+int(cmd[2])-int(cmd[1]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            RGBStrip _fix;
            _fix = new RGBWStrip(addr, count,
                                (int)_seg.getFloat("aX"),
                                (int)_seg.getFloat("aY"),
                                (int)_seg.getFloat("bX"),
                                (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
        else if(cmd[0].equals("/par5") && cmd.length>1) {
            // println(cmd[1]);
            int addr = int(cmd[1]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            NetoParFive _fix;
            _fix = new NetoParFive(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
                                // (int)_seg.getFloat("bX"),
                                // (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
        else if(cmd[0].equals("/matrix") && cmd.length > 3){
            ZigZagMatrix _fix;
            int _spacing = abs((int)_seg.getFloat("aY") - (int)_seg.getFloat("bY"));
            _fix = new ZigZagMatrix(int(cmd[1]), int(cmd[2]), int(cmd[3]), _spacing);
            println(int(cmd[1])+" "+int(cmd[2])+" "+int(cmd[3])+" "+_spacing);

            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.init();
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
        else if(cmd[0].equals("/orcan") && cmd.length > 1) {
            // println(cmd[1]);
            int addr = int(cmd[1]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            OrionOrcan _fix;
            _fix = new OrionOrcan(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
                                // (int)_seg.getFloat("bX"),
                                // (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
    }



    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Operation
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void update(PGraphics _pg) {
        if(!initialised || _pg == null) return;
        colorCanvas.beginDraw();
        colorCanvas.clear();
        colorCanvas.image(_pg, -areaPos.x, -areaPos.y);
        colorCanvas.endDraw();
        // updateFixtures
        parseGraphics(colorCanvas);
        updateBuffer();

        if(testChannel >= 0) {
            byteBuffer[testChannel*3] = (byte)testValue;
            byteBuffer[testChannel*3+1] = (byte)testValue;
            byteBuffer[testChannel*3+2] = (byte)testValue;
        }
        // outputData
        if(byteBuffer.length > 0) {
            byteSender.sendData(byteBuffer);
            if(recording) record(byteBuffer);
        }
    }

    public void setChannel(int _ind, int _val) {
        if(_ind < byteBuffer.length) {
            byteBuffer[_ind] = (byte)_val;
            //   println(_ind+" "+_val);
        }
        for(Fixture _fix : fixtures){
            _fix.setChannelManual(_ind, _val);
        }
    }
    // force on a channel
    public void setTestChannel(int _chan, int _val){

        if(byteBuffer == null) return;
        // turn off previous
        if(testChannel >= 0){
            byteBuffer[testChannel*3] = 0;
            byteBuffer[testChannel*3+1] = 0;
            byteBuffer[testChannel*3+2] = 0;
        }
        // set new
        if( _chan*3+2 < byteBuffer.length){
            testValue = (byte)_val;
            testChannel = _chan;
        }
    }

    public void enableRecording(boolean _b) {
        recording = _b;
        if(recording) {
            recordingBuffer = new ArrayList<Byte>();
            // make a header with channelCount
            recordingBuffer.add((byte)((byteBuffer.length) >> 8)); // MSB
            recordingBuffer.add((byte)(byteBuffer.length & 0xFF)); // LSB
        } else {
            byte[] ha = new byte[recordingBuffer.size()];
            for(int i = 0; i < ha.length; i++) {
                ha[i] = recordingBuffer.get(i);
            }
            saveBytes(dataPath(PATH_TO_CAPTURE_FILES)+"/fixture_animations/"+String.format("ani_%02d.bin", clipCount++), ha);
            println("Saved led animation");
        }
    }

    private void record(byte[] _buff) {
        for(int i = 0; i < _buff.length; i++) {
            recordingBuffer.add(_buff[i]);
        }
    }

    public void drawMap(PGraphics _pg) {
        if(initialised && _pg != null) {
            _pg.image(overLayCanvas, areaPos.x, areaPos.y);
            // debugBuffer();
        }
    }

    void debugBuffer() {
        if(byteBuffer == null) return;
        println("|---------------------------------------------------=");
        for(int i = 0; i < 512; i++) {
            print(" ("+i+" -> "+int(byteBuffer[i])+") ");
            if(i%8 == 1) println();
        }
        println(" ");
        println("|---------------------------------------------------=");
    }

    void listFixtures() {
        println("|--------DMX FIXTURES---------|");
        int _cnt = 0;
        for(Fixture _fix : fixtures) {
            println("============ "+(_cnt++)+" ==============");
            println("Address : "+_fix.getAddress());
            println("Name : "+_fix.getName());
            println("description : "+_fix.getDescription());
            println("=============================");
        }
    }

    void parseGraphics(PGraphics _pg) {
        _pg.loadPixels();
        for(Fixture _fix : fixtures)
            _fix.parseGraphics(_pg);
    }

    void updateBuffer() {
        for(Fixture _fix : fixtures)
            _fix.bufferChannels(byteBuffer);
    }

    public Fixture getFixture(int _ind) {
        if(_ind < fixtures.size() && _ind >= 0) return fixtures.get(_ind);
        else return null;
    }

    public XML getXML(String _file) {
        XML _xml = null;
        try {
            _xml = loadXML(dataPath(PATH_TO_FIXTURES)+"/"+_file);
        } catch(Exception e) {
            println("FixtureMap XML file "+_file+" not found");
        }
        return _xml;
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
