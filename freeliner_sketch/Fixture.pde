/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-06-10
 */

// DMX fixture objects
class Fixture  {
    String name;
    String description;
    int address;
    int channelCount;
    byte[] buffer;
    // position on the canvas;
    PVector position;
    ArrayList<Fixture> subFixtures;

    public Fixture(int _adr) {
        name = "genericFixture";
        description = "describe fixture";
        address = _adr;
        channelCount = 3;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }

    // to override
    public void parseGraphics(PGraphics _pg) {

    }

    // to override
    void drawFixtureOverlay(PGraphics _pg) {

    }

    public void bufferChannels(byte[] _buff) {
        for(int i = 0; i < channelCount; i++) {
            // println(address+i+" -> "+int(buffer[i]));
            if(address+i < _buff.length && i >= 0 && address >= 0) {
                _buff[address+i] += buffer[i];
                // if(_buff[address+i] < buffer[i]) {
                //     _buff[address+i] = buffer[i];
                // }
            }
        }
    }

    void setPosition(int _x, int _y) {
        position.set(_x, _y);
    }

    void setChannelManual(int _chan, int _val) {
        int _c = _chan - address;
        if(_c < channelCount && _c >= 0) buffer[_c] = byte(_val);
    }

    int getAddress() {
        return address;
    }

    String getName() {
        return name;
    }

    String getDescription() {
        return description;
    }

    PVector getPosition() {
        return position.get();
    }
    ArrayList<Fixture> getSubFixtures() {
        return subFixtures;
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Strip
///////
////////////////////////////////////////////////////////////////////////////////////

// class for RGB ledStrips
class RGBStrip extends Fixture {
    int ledCount;
    int ledChannels;

    public RGBStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by) {
        super(_adr);
        name = "RGBStrip";
        description = "A series of RGBFixtures";
        ledCount = _cnt;
        ledChannels = 3;
        channelCount = ledCount * ledChannels;
        buffer = new byte[channelCount];
        position = new PVector(_ax, _ay);

        subFixtures = new ArrayList<Fixture>();
        addRGBFixtures(ledCount, _ax, _ay, _bx, _by);
    }

    protected void addRGBFixtures(int _cnt, float _ax, float _ay, float _bx, float _by) {
        float gap = 1.0/(_cnt-1);
        int ind;
        int x;
        int y;
        RGBFixture _fix;
        int _adr = 0;
        for(int i = 0; i < _cnt; i++) {
            ind = int(lerp(0, _cnt, i*gap));
            x = int(lerp(_ax, _bx, i*gap));
            y = int(lerp(_ay, _by, i*gap));
            // _fix = new RGBFixture(address+(i*ledChannels));
            _adr = i*ledChannels;
            _adr += address;
            _fix = new RGBFixture(_adr);//address+(i*ledChannels));

            _fix.setPosition(x,y);
            subFixtures.add(_fix);
            // println(ledChannels+"   "+i+"   "+address+"  "+_adr);
        }
        // }
    }

    public void parseGraphics(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.parseGraphics(_pg);
    }

    // override
    void drawFixtureOverlay(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.drawFixtureOverlay(_pg);
    }

    public void bufferChannels(byte[] _buff) {
        for(Fixture _fix : subFixtures)
            _fix.bufferChannels(_buff);
    }
}


class RGBStripPad extends RGBStrip{

    public RGBStripPad(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by) {
        super(_adr, _cnt, _ax, _ay, _bx, _by);
        name = "RGBStripPad";
        description = "A series of RGBFixtures with padding";
        ledCount = _cnt;
        ledChannels = 3;
        channelCount = ledCount * ledChannels;
        buffer = new byte[channelCount];
        position = new PVector(_ax, _ay);

        subFixtures = new ArrayList<Fixture>();
        addRGBFixtures(ledCount, _ax, _ay, _bx, _by);
    }

    protected void addRGBFixtures(int _cnt, float _ax, float _ay, float _bx, float _by) {
        float gap = 1.0/(_cnt+1);
        int ind;
        int x;
        int y;
        RGBFixture _fix;
        int _adr = 0;
        for(int i = 0; i < _cnt; i++) {
            ind = int(lerp(0, _cnt, i*gap));
            x = int(lerp(_ax, _bx, (i+1)*gap));
            y = int(lerp(_ay, _by, (i+1)*gap));
            // _fix = new RGBFixture(address+(i*ledChannels));
            _adr = i*ledChannels;
            _adr += address;
            _fix = new RGBFixture(_adr);//address+(i*ledChannels));

            _fix.setPosition(x,y);
            subFixtures.add(_fix);
            // println(ledChannels+"   "+i+"   "+address+"  "+_adr);
        }
        // }
    }
}

// class for RGB ledStrips
class RGBWStrip extends RGBStrip {

    public RGBWStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by) {
        super(_adr, _cnt, _ax, _ay, _bx, _by);
        name = "RGBWStrip";
        description = "A series of RGBFixtures";
        ledCount = _cnt;
        ledChannels = 4;
        channelCount = ledCount * ledChannels;
        buffer = new byte[channelCount];
        position = new PVector(_ax, _ay);

        subFixtures = new ArrayList<Fixture>();
        addRGBFixtures(ledCount, _ax, _ay, _bx, _by);
    }
    // protected void addRGBFixtures(int _cnt, float _ax, float _ay, float _bx, float _by) {
    //     float gap = 1.0/(_cnt-1);
    //     int ind;
    //     int x;
    //     int y;
    //     RGBFixture _fix;
    //     int _adr = 0;
    //     for(int i = 0; i < _cnt; i++) {
    //         ind = int(lerp(0, _cnt, i*gap));
    //         x = int(lerp(_ax, _bx, i*gap));
    //         y = int(lerp(_ay, _by, i*gap));
    //         // _fix = new RGBFixture(address+(i*ledChannels));
    //         _adr = i*ledChannels;
    //         _adr += address;
    //         _fix = new RGBFixture(_adr);//address+(i*ledChannels));
    //
    //         _fix.setPosition(x,y);
    //         subFixtures.add(_fix);
    //         // println(ledChannels+"   "+i+"   "+address+"  "+_adr);
    //     }
    //     // }
    // }
}


class SingleColorStrip extends RGBStrip {

    int theColor = 0;
    public SingleColorStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by, int _col) {
        super(_adr, _cnt, _ax, _ay, _bx, _by);
        theColor = _col;
        name = "SingleColorStrip";
        description = "A series of single color Fixtures";
        ledCount = _cnt;
        ledChannels = 1;
        channelCount = ledCount * ledChannels;
        buffer = new byte[channelCount];
        position = new PVector(_ax, _ay);

        subFixtures = new ArrayList<Fixture>();
        addFixtures(ledCount, _ax, _ay, _bx, _by);
    }

    protected void addFixtures(int _cnt, float _ax, float _ay, float _bx, float _by) {
        float gap = 1.0/(_cnt+1);
        int ind;
        int x;
        int y;
        SingleColorFixture _fix;
        int _adr = 0;
        for(int i = 0; i < _cnt; i++) {
            ind = int(lerp(0, _cnt, i*gap));
            x = int(lerp(_ax, _bx, (i+1)*gap));
            y = int(lerp(_ay, _by, (i+1)*gap));
            // _fix = new RGBFixture(address+(i*ledChannels));
            _adr = i;
            _adr += address;
            _fix = new SingleColorFixture(_adr, theColor);
            _fix.setPosition(x,y);
            subFixtures.add(_fix);
        }
    }
}

class SingleColorFixture extends RGBFixture {
    // boolean correctGamma = true;
    color col;
    int theColor = 0;
    public SingleColorFixture(int _adr, int _col) {
        super(_adr);
        theColor = _col;
        name = "SingleColorFixture";
        description = "a light fixture";
        channelCount = 1;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }

    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int value = 0;
        switch(theColor) {
            case 0:
                value = (col >> 16) & 0xFF;
                break;
            case 1:
                value = (col >> 8) & 0xFF;
                break;
            case 2:
                value = col & 0xFF;
                break;
        }
        buffer[0] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? value : gammatable[value]);
    }
}




////////////////////////////////////////////////////////////////////////////////////
///////
///////     RGBFixture
///////
////////////////////////////////////////////////////////////////////////////////////

// a base class for RGB fixture.
class RGBFixture extends Fixture {
    // boolean correctGamma = true;
    color col;
    public RGBFixture(int _adr) {
        super(_adr);
        name = "RGBFixture";
        description = "a RGB light fixture";
        channelCount = 3;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }

    // override
    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = int(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // override
    void drawFixtureOverlay(PGraphics _pg) {
        if(_pg == null) return;
        _pg.stroke(255, 100);
        _pg.noFill();
        _pg.ellipseMode(CENTER);
        _pg.ellipse(position.x, position.y, 10, 10);
        if(projectConfig.DRAW_FIXTURE_ADDRESS){
            _pg.textSize(10);
            _pg.fill(255);
            _pg.text(str(address), position.x, position.y);
        }
    }

    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[0] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
        buffer[1] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? green : gammatable[green]);
        buffer[2] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? blue : gammatable[blue]);
        // println(buffer[0]+" "+buffer[1]+" "+buffer[2]);
    }

    public color getColor() {
        return col;
    }

    public int getX() {
        return int(position.x);
    }
    public int getY() {
        return int(position.y);
    }
}











// for other light channels
class ColorFlexWAUV extends RGBFixture {
    public ColorFlexWAUV(int _adr) {
        super(_adr);
        name = "ColorFlexUVW";
        description = "fixture for uv and whites for Neto ColorFlex";
        channelCount = 3;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }
    public void bufferChannels(byte[] _buff) {
        for(int i = 0; i < channelCount; i++) {
            _buff[address+i+3] = buffer[i];
            // println(address+i+" -> "+int(buffer[i]));
        }
    }

}


///////////////////////////////////////////////////////
// a base class for RGB fixture.
class RGBPar extends Fixture {
    // boolean correctGamma = true;
    color col;
    public RGBPar(int _adr) {
        super(_adr);
        name = "RGBAWPar";
        description = "a RGB light fixture";
        channelCount = 4;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }
    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = int(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[1] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
        buffer[2] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? green : gammatable[green]);
        buffer[3] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? blue : gammatable[blue]);
        buffer[0] = byte(255);
    }
    // override
    void drawFixtureOverlay(PGraphics _pg) {
        if(_pg == null) return;
        _pg.stroke(255, 100);
        _pg.noFill();
        _pg.ellipseMode(CENTER);
        _pg.ellipse(position.x, position.y, 10, 10);
        _pg.textSize(10);
        _pg.fill(255);
        _pg.text(str(address), position.x, position.y);
    }
}

class AWPar extends Fixture {
    // boolean correctGamma = true;
    color col;
    public AWPar(int _adr) {
        super(_adr);
        name = "AWPar";
        description = "a RGB light fixture";
        channelCount = 2;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }
    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = int(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }
    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        // int blue = col & 0xFF;
        buffer[0] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
        buffer[1] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? green : gammatable[green]);
        // buffer[2] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? blue : gammatable[blue]);
    }
    // override
    void drawFixtureOverlay(PGraphics _pg) {
        if(_pg == null) return;
        _pg.stroke(255, 100);
        _pg.noFill();
        _pg.ellipseMode(CENTER);
        _pg.ellipse(position.x, position.y, 10, 10);
        _pg.textSize(10);
        _pg.fill(255);
        _pg.text(str(address), position.x, position.y);
    }
}


///////////////////////////////////////////////////////////////////////////////////
///////
///////     `Mp`anel
///////
////////////////////////////////////////////////////////////////////////////////////

// class for RGB ledStrips
class MPanel extends Fixture {
    final int PAN_CHANNEL = 0;
    final int TILT_CHANNEL = 2;
    final int MPANEL_SIZE = 160;

    public MPanel(int _adr, int _x, int _y) {
        super(_adr);
        name = "MPanel";
        description = "Neto's crazy MPanel fixture";
        channelCount = 121;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(_x, _y);
        subFixtures = new ArrayList<Fixture>();
        addMatrix();
    }

    private void addMatrix() {
        RGBWStrip _fix;
        int _gap = MPANEL_SIZE/5;
        int _adr = 0;
        for(int i = 0; i < 5; i++) {
            _adr = address+20+(i*20);
            _fix = new RGBWStrip(_adr, 5, int(position.x), int(position.y+(i*_gap)), int(position.x)+MPANEL_SIZE, int(position.y+(i*_gap)));
            subFixtures.add(_fix);
        }
    }

    public void parseGraphics(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.parseGraphics(_pg);
    }

    // override
    void drawFixtureOverlay(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.drawFixtureOverlay(_pg);
    }

    public void bufferChannels(byte[] _buff) {
        for(int i = 0; i < channelCount; i++) {
            _buff[address+i] = buffer[i];
        }
        mpanelRules();
        for(Fixture _fix : subFixtures)
            _fix.bufferChannels(_buff);
    }

    public void mpanelRules() {
        // buffer[0] = byte(map(mouseX, 0, width, 0, 255));
        // buffer[2] = byte(map(mouseY, 0, height, 0, 255));

        buffer[1] = byte(127);
        buffer[15] = byte(255);
        // println("tilt "+int(buffer[TILT_CHANNEL]));
        // buffer[19] = byte(255);

        // buffer[118] = byte(255);
        //
        // buffer[118] = byte(255);
        // buffer[119] = byte(255);
    }
}


///////////////////////////////////////////////////////////////////////////////////
///////
///////     Neto PAR5
///////
////////////////////////////////////////////////////////////////////////////////////


class NetoParFive extends Fixture {
    // boolean correctGamma = true;
    color col;

    public NetoParFive(int _adr) {
        super(_adr);
        name = "NetoPAR5";
        description = "a fixture for the Neto PAR5";
        channelCount = 9;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }
    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = int(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[0] = byte(255);
        if(red == green && green == blue) {
            buffer[1] = 0;
            buffer[2] = 0;
            buffer[3] = 0;
            buffer[4] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
        } else {
            buffer[1] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
            buffer[2] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? green : gammatable[green]);
            buffer[3] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? blue : gammatable[blue]);
            buffer[4] = 0;
        }
    }
    // override
    void drawFixtureOverlay(PGraphics _pg) {
        if(_pg == null) return;
        _pg.stroke(255, 100);
        _pg.noFill();
        _pg.ellipseMode(CENTER);
        _pg.ellipse(position.x, position.y, 20, 20);
        _pg.textSize(10);
        _pg.fill(255);
        _pg.text(str(address), position.x, position.y);
    }
}

///////////////////////////////////////////////////////////////////////////////////
///////
///////     WS2812 zigzag
///////
////////////////////////////////////////////////////////////////////////////////////

class ZigZagMatrix extends Fixture {
    // boolean correctGamma = true;
    color col;
    int matrixSpacing = 16;
    int matrixWidth = 0;
    int matrixHeight = 0;

    public ZigZagMatrix(int _adr, int _width, int _height, int _spacing) {
        super(_adr);
        name = "ZigZagMatrix";
        description = "a ZigZagMatrix of RGB pixels";
        channelCount = _width * _height;
        address = _adr;
        matrixWidth = _width;
        matrixHeight = _height;
        matrixSpacing = _spacing/_height;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
        subFixtures = new ArrayList<Fixture>();
        println("makeing matrix\naddr: "+address+" "+_width+" "+_height+" "+_spacing);
    }

    public void init(){
        addMatrix();
    }

    private void addMatrix() {
        RGBFixture _fix;
        int _gap = matrixSpacing;
        int _adr = 0;
        PVector _start = new PVector(0,0);
        PVector _end = new PVector(0,0);
        for(int i = 0; i < matrixWidth; i++) {
            for(int j = 0; j < matrixHeight; j++) {
                _adr = address+(i*matrixHeight*3 + j*3);
                _fix = new RGBFixture(_adr);
                if(i % 2 == 1){
                    _fix.setPosition(int(position.x + i* _gap), int(position.y + matrixHeight*_gap - _gap - j* _gap));
                }
                else {
                    _fix.setPosition(int(position.x + i* _gap), int(position.y + j* _gap));
                }
                subFixtures.add(_fix);
            }
        }
    }

    public void parseGraphics(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.parseGraphics(_pg);
    }

    // override
    void drawFixtureOverlay(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.drawFixtureOverlay(_pg);
    }

    public void bufferChannels(byte[] _buff) {
        for(Fixture _fix : subFixtures)
            _fix.bufferChannels(_buff);
    }
}


///////////////////////////////////////////////////////////////////////////////////
///////
///////     Orion Orcan2
///////
////////////////////////////////////////////////////////////////////////////////////

class OrionOrcan extends Fixture {
    // boolean correctGamma = true;
    color col;
    final int masterBrightChannel = 0;
    final int strobeChannel = 1;
    final int effectChannel = 2;
    final int effectSpeedChannel = 3;
    final int redChannel = 4;
    final int greenChannel = 5;
    final int blueChannel = 6;

    public OrionOrcan(int _adr) {
        super(_adr);
        name = "Orcan2";
        description = "orion orcan 2 RGB light fixture";
        channelCount = 7;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
        buffer[strobeChannel] = 0;
    }

    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = int(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // RGBFixture specific
    public void setColor(color _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[masterBrightChannel]  = byte(255);
        buffer[effectChannel]  = byte(0);
        buffer[effectSpeedChannel]  = byte(0);

        buffer[redChannel] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? red : gammatable[red]);
        buffer[greenChannel] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? green : gammatable[green]);
        buffer[blueChannel] = byte(projectConfig.FIXTURE_CORRECT_GAMMA ? blue : gammatable[blue]);


    }
    // override
    void drawFixtureOverlay(PGraphics _pg) {
        if(_pg == null) return;
        _pg.stroke(255, 100);
        _pg.noFill();
        _pg.ellipseMode(CENTER);
        _pg.ellipse(position.x, position.y, 10, 10);
        _pg.textSize(10);
        _pg.fill(255);
        _pg.text(str(address), position.x, position.y);
    }
}
