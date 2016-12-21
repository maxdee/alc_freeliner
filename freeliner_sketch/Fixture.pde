/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-06-10
 */

// DMX fixture objects
class Fixture implements FreelinerConfig {
  String name;
  String description;
  int address;
  int channelCount;
  byte[] buffer;
  // position on the canvas;
  PVector position;
  ArrayList<Fixture> subFixtures;

  public Fixture(int _adr){
    name = "genericFixture";
    description = "describe fixture";
    address = _adr;
    channelCount = 3;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }

  // to override
  public void parseGraphics(PGraphics _pg){

  }

  // to override
  void drawFixtureOverlay(PGraphics _pg){

  }

  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      // println(address+i+" -> "+int(buffer[i]));
      if(address+i < _buff.length) _buff[address+i] = buffer[i];
    }
  }

  void setPosition(int _x, int _y){
    position.set(_x, _y);
  }

  void setChannel(int _chan, int _val){
    if(_chan < channelCount && _chan >= 0) buffer[_chan] = byte(_val);
  }

  int getAddress(){
    return address;
  }

  String getName(){
    return name;
  }

  String getDescription(){
    return description;
  }

  PVector getPosition(){
    return position.get();
  }
  ArrayList<Fixture> getSubFixtures(){
    return subFixtures;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Strip
///////
////////////////////////////////////////////////////////////////////////////////////

// class for RGB ledStrips
class RGBStrip extends Fixture{
  int ledCount;
  int ledChannels;

  public RGBStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by){
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

  protected void addRGBFixtures(int _cnt, float _ax, float _ay, float _bx, float _by){
    float gap = 1.0/(_cnt-1);
    int ind;
    int x;
    int y;
    RGBFixture _fix;
    int _adr = 0;
    for(int i = 0; i < _cnt; i++){
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

  public void parseGraphics(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.parseGraphics(_pg);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.drawFixtureOverlay(_pg);
  }

  public void bufferChannels(byte[] _buff){
    for(Fixture _fix : subFixtures)
      _fix.bufferChannels(_buff);
  }
}

// class for RGB ledStrips
class RGBWStrip extends RGBStrip{

  public RGBWStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by){
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
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     RGBFixture
///////
////////////////////////////////////////////////////////////////////////////////////

// a base class for RGB fixture.
class RGBFixture extends Fixture {
  boolean correctGamma = true;
  color col;
  public RGBFixture(int _adr){
    super(_adr);
    name = "RGBFixture";
    description = "a RGB light fixture";
    channelCount = 3;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }

  // override
  public void parseGraphics(PGraphics _pg){
    if(_pg == null) return;
    int ind = int(position.x + (position.y*_pg.width));
    int max = _pg.width*_pg.height;
    if(ind < max) setColor(_pg.pixels[ind]);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    if(_pg == null) return;
    _pg.stroke(255, 100);
    _pg.noFill();
    _pg.ellipseMode(CENTER);
    _pg.ellipse(position.x, position.y, 10, 10);
    _pg.textSize(10);
    _pg.fill(255);
    _pg.text(str(address), position.x, position.y);
  }

  // RGBFixture specific
  public void setColor(color _c){
    col = _c;
    int red = (col >> 16) & 0xFF;
    int green = (col >> 8) & 0xFF;
    int blue = col & 0xFF;
    buffer[0] = byte(correctGamma ? red : gammatable[red]);
    buffer[1] = byte(correctGamma ? green : gammatable[green]);
    buffer[2] = byte(correctGamma ? blue : gammatable[blue]);
    // println(buffer[0]+" "+buffer[1]+" "+buffer[2]);
  }

  public color getColor(){
    return col;
  }

  public int getX(){
    return int(position.x);
  }
  public int getY(){
    return int(position.y);
  }
}

// for other light channels
class ColorFlexWAUV extends RGBFixture{
  public ColorFlexWAUV(int _adr){
    super(_adr);
    name = "ColorFlexUVW";
    description = "fixture for uv and whites for Neto ColorFlex";
    channelCount = 3;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }
  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      _buff[address+i+3] = buffer[i];
      // println(address+i+" -> "+int(buffer[i]));
    }
  }

}


///////////////////////////////////////////////////////
// a base class for RGB fixture.
class RGBPar extends Fixture {
  boolean correctGamma = true;
  color col;
  public RGBPar(int _adr){
    super(_adr);
    name = "RGBAWPar";
    description = "a RGB light fixture";
    channelCount = 3;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }
  public void parseGraphics(PGraphics _pg){
    if(_pg == null) return;
    int ind = int(position.x + (position.y*_pg.width));
    int max = _pg.width*_pg.height;
    if(ind < max) setColor(_pg.pixels[ind]);
  }

  // RGBFixture specific
  public void setColor(color _c){
    col = _c;
    int red = (col >> 16) & 0xFF;
    int green = (col >> 8) & 0xFF;
    int blue = col & 0xFF;
    buffer[0] = byte(correctGamma ? red : gammatable[red]);
    buffer[1] = byte(correctGamma ? green : gammatable[green]);
    buffer[2] = byte(correctGamma ? blue : gammatable[blue]);
  }
  // override
  void drawFixtureOverlay(PGraphics _pg){
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
  boolean correctGamma = true;
  color col;
  public AWPar(int _adr){
    super(_adr);
    name = "AWPar";
    description = "a RGB light fixture";
    channelCount = 2;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }
  public void parseGraphics(PGraphics _pg){
    if(_pg == null) return;
    int ind = int(position.x + (position.y*_pg.width));
    int max = _pg.width*_pg.height;
    if(ind < max) setColor(_pg.pixels[ind]);
  }
  // RGBFixture specific
  public void setColor(color _c){
    col = _c;
    int red = (col >> 16) & 0xFF;
    int green = (col >> 8) & 0xFF;
    // int blue = col & 0xFF;
    buffer[0] = byte(correctGamma ? red : gammatable[red]);
    buffer[1] = byte(correctGamma ? green : gammatable[green]);
    // buffer[2] = byte(correctGamma ? blue : gammatable[blue]);
  }
  // override
  void drawFixtureOverlay(PGraphics _pg){
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
class MPanel extends Fixture{
  final int PAN_CHANNEL = 0;
  final int TILT_CHANNEL = 2;
  final int MPANEL_SIZE = 160;

  public MPanel(int _adr, int _x, int _y){
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

  private void addMatrix(){
    RGBWStrip _fix;
    int _gap = MPANEL_SIZE/5;
    int _adr = 0;
    for(int i = 0; i < 5; i++){
      _adr = address+20+(i*20);
      _fix = new RGBWStrip(_adr, 5, int(position.x), int(position.y+(i*_gap)), int(position.x)+MPANEL_SIZE, int(position.y+(i*_gap)));
      subFixtures.add(_fix);
    }
  }

  public void parseGraphics(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.parseGraphics(_pg);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.drawFixtureOverlay(_pg);
  }

  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      _buff[address+i] = buffer[i];
    }
    mpanelRules();
    for(Fixture _fix : subFixtures)
      _fix.bufferChannels(_buff);
  }

  public void mpanelRules(){
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
