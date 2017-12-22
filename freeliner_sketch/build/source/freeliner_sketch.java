import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.io.*; 
import java.net.*; 
import processing.serial.*; 
import java.util.Collections; 
import java.util.Arrays; 
import oscP5.*; 
import netP5.*; 
import websockets.*; 
import java.lang.reflect.Field; 
import processing.core.PApplet; 
import processing.core.PSurface; 
import java.awt.Toolkit; 
import java.awt.event.KeyEvent; 
import processing.video.*; 
import java.util.Date; 
import http.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class freeliner_sketch extends PApplet {

/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */




/**
 * HELLO THERE! WELCOME to FREELINER
 * There is a bunch of settings in the Config.pde file.
 */

// for loading configuration
// false -> use following parameters
// true -> use the configuration saved in data/userdata/configuration.xml
boolean fetchConfig = false; // set to true for #packaging
int configuredWidth = 1440;//1024;//768;
int configuredHeight = 900;//768;
int useFullscreen = 0;
int useDisplay = 2; // SPAN is 0
int usePipeline = 1;

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Not Options
///////
////////////////////////////////////////////////////////////////////////////////////

FreeLiner freeliner;
// fonts
PFont font;
PFont introFont;

final String VERSION = "0.4.5";
boolean doSplash = true;
boolean OSX = false;
boolean WIN = false;


ExternalGUI externalGUI = null; // set specific key to init gui
// documentation compiler, has to be super global
Documenter documenter;

// no other way to make a global gammatable...
int[] gammatable = new int[256];
float gamma = 3.2f; // 3.2 seems to be nice

public void settings(){
    if( fetchConfig ) fetchConfiguration();
    if(useFullscreen == 1){
        fullScreen(P2D,useDisplay);
    }
    else {
        size(configuredWidth, configuredHeight, P2D);
    }
    // needed for syphon!
    PJOGL.profile=1;
}

// single configuration file for the moment.
public void fetchConfiguration(){
    XML _file = null;
    try{
        _file = loadXML(sketchPath()+"/data/userdata/configuration.xml");
    }
    catch(Exception e) {
        println("No configuration.xml file found.");
    }
    if(_file != null) {
        configuredWidth = _file.getInt("width");
        configuredHeight = _file.getInt("height");
        useFullscreen = _file.getInt("fullscreen");
        useDisplay = _file.getInt("display");
        usePipeline = _file.getInt("pipeline");
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

public void setup() {
    documenter = new Documenter();
    strokeCap(FreelinerConfig.STROKE_CAP);
    strokeJoin(FreelinerConfig.STROKE_JOIN);
    // detect OS
    if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
    else if(System.getProperty("os.name").charAt(0) == 'L') WIN = false;
    else WIN = true;

    // init freeliner
    freeliner = new FreeLiner(this, usePipeline);

    surface.setResizable(false);
    surface.setTitle("freeliner");
    noCursor();
    // add in keyboard, as hold - or = to repeat. beginners tend to hold keys down which is problematic
    if(FreelinerConfig.ENABLE_KEY_REPEAT) hint(ENABLE_KEY_REPEAT); // usefull for performance

    // load fonts
    introFont = loadFont("fonts/MiniKaliberSTTBRK-48.vlw");
    font = loadFont("fonts/Arial-BoldMT-48.vlw");


    // perhaps use -> PApplet.platform == MACOSX
    background(0);
    splash();
    frameRate(60);//420);
    makeGammaTable();
}

// splash screen!
public void splash(){
  stroke(100);
  fill(150);
  //setText(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
  textSize(24);
  fill(255);
  text("V"+VERSION+" - made with PROCESSING", 10, (height/2)+20);
}

//external GUI launcher
public void launchGUI(){
    if(externalGUI != null) return;
    externalGUI = new ExternalGUI(freeliner);
    String[] args = {"Freeliner GUI", "--display=1"};
    PApplet.runSketch(args, externalGUI);
    externalGUI.loop();
}
public void closeGUI(){
    if(externalGUI != null) return;
    //PApplet.stopSketch();
}

public void makeGammaTable(){
    for (int i=0; i < 256; i++) {
        gammatable[i] = (int)(pow((float)i / 255.0f, gamma) * 255.0f + 0.5f);
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Draw
///////
////////////////////////////////////////////////////////////////////////////////////

// do the things
public void draw() {
    background(0);
    freeliner.update();
    if(doSplash) splash();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Input
///////
////////////////////////////////////////////////////////////////////////////////////

public void webSocketServerEvent(String _cmd){
    freeliner.getCommandProcessor().queueCMD(_cmd);
}

// relay the inputs to the mapper
public void keyPressed() {
    freeliner.getKeyboard().keyPressed(keyCode, key);
    if(key == '~') launchGUI();
    if (key == 27) key = 0;       // dont let escape key, we need it :)
}

public void keyReleased() {
    freeliner.getKeyboard().keyReleased(keyCode, key);
}

public void mousePressed(MouseEvent event) {
    doSplash = false;
    freeliner.getMouse().press(mouseButton);
}

public void mouseDragged() {
    freeliner.getMouse().drag(mouseButton, mouseX, mouseY);
}

public void mouseMoved() {
    freeliner.getMouse().move(mouseX, mouseY);
}

public void mouseWheel(MouseEvent event) {
    freeliner.getMouse().wheeled(event.getCount());
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * Abstract class for brushes.
 * Brushes are PShapes drawn along segments
 */
abstract class Brush extends Mode{
  // Size to generate brushes
	final int BASE_BRUSH_SIZE = 20;
  final int HALF_SIZE = BASE_BRUSH_SIZE/2;
  // The brush
  PShape brushShape;
  PShape scaledBrush;
  float scaledBrushSize;

  /**
   * Constructor, generates the shape
   */
  public Brush(){
    brushShape = generateBrush();
    scaledBrush = brushShape;
    scaledBrushSize = BASE_BRUSH_SIZE;
		name = "Brush";
		description = "A brush";
  }

  /**
   * Needs to implement the making of the brush
   * The PShape has a center of 0,0 and points upwards.
   * @return PShape of the brush
   */
  abstract public PShape generateBrush();

  /**
   * Brush accessor
   * Makes a copy of the brush scaled by scalar.
   * @param RenderableTemplate for brush size scaling
   * @return PShape of the brush
   */
  public PShape getShape(RenderableTemplate _rt){
    // only clone if the size changed
		// #p3 bug fix...
  	// if(abs(_rt.getScaledBrushSize() - scaledBrushSize) > 0.5){
    //   scaledBrushSize = _rt.getScaledBrushSize();
    //   scaledBrush = cloneShape(brushShape, scaledBrushSize/BASE_BRUSH_SIZE, new PVector(0,0));
    // }
  	// return scaledBrush;
		return brushShape;
  }

}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Subclasses, kept in the same file because too many files.
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * A brush that is just a point.
 */
class PointBrush extends Brush {

  public PointBrush(int _ind){
		modeIndex = _ind;
		name =  "PointBrush";//brush
		description = "Adjust its size with `w`.";
  }

	public PShape generateBrush(){
		PShape shp = createShape();
		shp.strokeJoin(STROKE_JOIN);
		shp.strokeCap(STROKE_CAP);
		shp.beginShape(POINTS);
    shp.vertex(0,0);
		shp.endShape();
		return shp;
	}
}

/**
 * A brush that is a perpendicular line.
 */
class LineBrush extends Brush {

  public LineBrush(int _ind){
		modeIndex = _ind;
		name =  "line";
		description = "Perpendicular line brush";
  }
	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

/**
 * Chevron brush >>>>
 */
class ChevronBrush extends Brush {


  public ChevronBrush(int _ind){
		modeIndex = _ind;
		name =  "chevron";//brush
		description = "Chevron v shaped style brush";
  }
	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(0, HALF_SIZE);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

/**
 * Square shaped brush
 */
class SquareBrush extends Brush {

  public SquareBrush(int _ind){
		modeIndex = _ind;
		name = "square";
		description = "Square shaped brush";
  }

	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(0, HALF_SIZE);
    shp.vertex(HALF_SIZE, 0);
    shp.vertex(0, -HALF_SIZE);
    shp.vertex(-HALF_SIZE, 0);
    shp.endShape(CLOSE);
    return shp;
	}
}

/**
 * Custom brush, a brush that is the segments of group.
 */
class CustomBrush extends Brush {

  /**
   * Constructor will generate a null shape.
   */
  public CustomBrush(int _ind){
		modeIndex = _ind;
		name = "custom";//brush
		description = "Template custom shape, add template to geometryGroup and press `ctrl-d` to set as custom shape.";
  }

  /**
   * Takes the sourceShape and makes the brush
   */
  public PShape generateBrush(){
    scaledBrushSize = 1;
    return null;
  }

  public PShape getShape(RenderableTemplate _rt){

    if(abs(_rt.getScaledBrushSize() - this.scaledBrushSize) > 0.5f || scaledBrush == null){
      //println(_rt.getScaledBrushSize() - scaledBrushSize);
      scaledBrushSize = _rt.getScaledBrushSize();
      scaledBrush = cloneShape( _rt.getCustomShape(), scaledBrushSize/BASE_BRUSH_SIZE, new PVector(0,0));
    }
    if(scaledBrush == null){
      PShape empty = createShape();
      empty.beginShape();
      empty.endShape(CLOSE);
      return empty;
    }
    return scaledBrush;
  }
}


/**
 * Circle shaped brush
 */
class CircleBrush extends Brush {

  public CircleBrush(int _ind){
		modeIndex = _ind;
		name =  "circle";//brush
		description = "Brush witha circular appearance.";
  }
  public PShape generateBrush(){
    PShape shp =  createShape(ELLIPSE, 0, 0, BASE_BRUSH_SIZE, BASE_BRUSH_SIZE);
    return shp;
  }
}

/**
 * Triangle shaped brush
 */
class TriangleBrush extends Brush {

  public TriangleBrush(int _ind){
		modeIndex = _ind;
		name = "triangle";
		description = "Triangular brush.";
  }
  public PShape generateBrush(){
    float hght = sqrt(sq(BASE_BRUSH_SIZE)+pow(HALF_SIZE,2));
    PShape shp = createShape(TRIANGLE, -HALF_SIZE, 0,
                                       HALF_SIZE, 0,
                                       0, BASE_BRUSH_SIZE*pow(3, 1/3.0f)/2);
    return shp;
  }
}


/**
 * X shaped brush
 */
class XBrush extends Brush {

  public XBrush(int _ind){
		modeIndex = _ind;
		name = "+";//brush
		description = "+ shaped brush";
  }
  public PShape generateBrush(){
    PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, -HALF_SIZE);
    shp.vertex(HALF_SIZE, HALF_SIZE);
    shp.vertex(-HALF_SIZE, HALF_SIZE);
    shp.vertex(HALF_SIZE, -HALF_SIZE);
    shp.endShape();
    return shp;
  }
}

/**
 * Leaf shaped brush
 */
class LeafBrush extends Brush {

  public LeafBrush(int _ind){
		modeIndex = _ind;
		name =  "leaf";
		description = "legalize it";
  }
  public PShape generateBrush(){
    PShape shp = createShape();
    shp.beginShape();
		shp.vertex(-0.6728153f, 7.683716f);
		shp.vertex(-0.4056158f, 2.7851562f);
		shp.vertex(-2.8896399f, 4.5375977f);
		shp.vertex(-4.957216f, 5.289551f);
		shp.vertex(-3.3653917f, 3.6522217f);
		shp.vertex(-0.48373985f, 2.5578613f);
		shp.vertex(-4.891837f, 2.8632812f);
		shp.vertex(-8.405435f, 0.9388428f);
		shp.vertex(-4.4208436f, 1.0469971f);
		shp.vertex(-0.46278572f, 2.366455f);
		shp.vertex(-4.9180675f, -0.93652344f);
		shp.vertex(-7.5094423f, -5.944824f);
		shp.vertex(-3.296897f, -2.949585f);
		shp.vertex(-0.4129467f, 2.2398682f);
		shp.vertex(-1.4464064f, -2.9370117f);
		shp.vertex(0.1256113f, -10.602173f);
		shp.vertex(1.3657084f, -3.0498047f);
		shp.vertex(0.0832119f, 2.2938232f);
		shp.vertex(3.0037231f, -2.4002686f);
		shp.vertex(8.227526f, -6.843628f);
		shp.vertex(5.1290474f, -0.6890869f);
		shp.vertex(0.1441145f, 2.5178223f);
		shp.vertex(4.1453266f, 1.0227051f);
		shp.vertex(8.281681f, 0.76416016f);
		shp.vertex(4.5554295f, 2.894287f);
		shp.vertex(0.081624985f, 2.7386475f);
		shp.vertex(2.7639713f, 3.6608887f);
		shp.vertex(4.9208336f, 5.5914307f);
		shp.vertex(1.978899f, 4.6070557f);
		shp.vertex(-0.193079f, 2.8511963f);
		shp.vertex(-0.35807228f, 7.8149414f);
    shp.endShape();
    return shp;
  }
}


/**
 * Sprinkles
 */
class SprinkleBrush extends Brush {

  public SprinkleBrush(int _ind){
		modeIndex = _ind;
		name =  "sprinkle";//brush
		description = "ms paint grafiti style";
	}
  // dosent apply here...
  public PShape generateBrush(){
    PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, -HALF_SIZE);
    shp.vertex(HALF_SIZE, HALF_SIZE);
    shp.endShape();
    return shp;
  }

  private PShape generateSprinkles(float _sz){
    PShape shp = createShape();
    shp.beginShape(POINTS);
    PVector pnt;
    PVector cent = new PVector(0,0);
    float half = _sz/2.0f;
    for(int i = 0; i < _sz*3; i++){
      pnt = new PVector(random(_sz) - (half), random(_sz) - (half));
      if(cent.dist(pnt) < half) shp.vertex(pnt.x, pnt.y);
    }
    shp.endShape();
    return shp;
  }

  public PShape getShape(RenderableTemplate _rt){
    return generateSprinkles(_rt.getScaledBrushSize());
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-10-17
 */






// A class to send byte arrays to lighting stuff.

public class ByteSender implements FreelinerConfig{

  public ByteSender(){

  }

  public void connect(String _port, int _baud){}
  public void connect(String _port){}
  public void disconnect(){}
  public void sendData(byte[] _data){}
  public int getCount(){return 0;}
}

public class SerialSender extends ByteSender{
  PApplet applet;
  Serial port;
  // byte[] packet;
  byte[] header = {42};
  int channelCount;

  public SerialSender(PApplet _ap){
    applet = _ap;
  }

  /**
 * Connect to a serial port
 * @param String portPath
 */
  public void connect(String _port, int _baud){
    // connect to port
    try{
      port = new Serial(applet, _port, _baud);
      delay(100);
      channelCount = 0;
      getMessage();
      for(int i = 0; i < 10; i++){
        port.write('?');
        delay(300);
        try{
          channelCount = Integer.parseInt(getMessage());
          println("Connected to "+_port+" with "+channelCount+" channels");
          break;
        } catch (Exception e){
          println("Could not get channel count.");
        }
      }
    }
    catch(Exception e){
      println(_port+" does not seem to work...");
    }
    if(channelCount == 0) disconnect();
  }

  public int getCount(){
    return channelCount;
  }

  public void disconnect(){
    if(port != null) port.stop();
  }
  // gets message from the serialPort
  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += PApplet.parseChar(port.read());
    return buff;
  }

  public void sendData(byte[] _data){
    port.write(header);
    port.write(_data);
    // if(frameCount % 4 == 1)println(getMessage());
  }
}


// send udp packets of variable length
public class ArtNetSender extends ByteSender{

  String host;
  int port = 6454;
  InetAddress address;
  DatagramSocket dsocket;

  public ArtNetSender(){}

  public void connect(String _adr){
    host = _adr;
    try{
      address = InetAddress.getByName(host);
      dsocket = new DatagramSocket();
    }
    catch(Exception e){
      println("artnet could not connect");
      exit();
    }
  }

  public void sendData(byte[] _data){
    byte[][] _universes = splitUniverses(_data);
    for(int i = 0; i < _universes.length; i++){
      sendUDP(makeArtNetPacket(_universes[i], i));
    }
  }


  public byte[][] splitUniverses(byte[] _data){

    int _universeCount = _data.length/510;
    int _ind = 0;
    byte[][] _universes = new byte[_universeCount][512];
    for(int u = 0; u < _universeCount; u++){ // temporary_plz_undo
      for(int i = 1; i < 510; i++){
        _ind = u*510+i;
        if(_ind < _data.length) _universes[u][i] = _data[_ind];
        else _universes[u][i] = 0;
      }
    }
    return _universes;
  }


  public byte[] makeArtNetPacket(byte[] _data, int _uni){
    //   boolean _drop = false;
    //   for(int i = 0; i < _data.length; i++){
    //       if(_data[i] != 0) _drop = true;
    //   }
    //   if(_drop) return null;
    long _size = _data.length;
    byte _packet[] = new byte[_data.length+18];
    _packet[0] = PApplet.parseByte('A');
    _packet[1] = PApplet.parseByte('r');
    _packet[2] = PApplet.parseByte('t');
    _packet[3] = PApplet.parseByte('-');
    _packet[4] = PApplet.parseByte('N');
    _packet[5] = PApplet.parseByte('e');
    _packet[6] = PApplet.parseByte('t');
    _packet[7] = 0; //just a zero
    _packet[8] = 0; //opcode
    _packet[9] = 80; //opcode
    _packet[10] = 0; //protocol version
    _packet[11] = 14; //protocol version
    _packet[12] = 0; //sequence
    _packet[13] = 0; //physical (purely informative)
    _packet[14] = (byte)(_uni%16); //Universe lsb? http://www.madmapper.com/universe-decimal-to-artnet-pathport/
    _packet[15] = (byte)(_uni/16); //Universe msb?
    _packet[16] = (byte)((_size & 0xFF00) >> 8); //length msb
    _packet[17] = (byte)(_size & 0xFF); //length lsb

    for(int i = 0; i < _size; i++){
      _packet[i+18] = _data[i];
    }
    return _packet;
  }

  public void sendUDP(byte[] _data) {
      if(_data == null) return;
    DatagramPacket packet = new DatagramPacket(_data, _data.length,
        address, port);
    try{
      dsocket.send(packet);
    }
    catch(Exception e){
      println("failed to send");
      connect(host);
    }
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-01-22
 */




/**
 * Manage the drawing buffer.
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */
abstract class CanvasManager implements FreelinerConfig {
    // Template renderer needed to do the rendering
    TemplateRenderer templateRenderer;
    public PGraphics guiCanvas;
    CommandProcessor commandProcessor;
    // applet needed for syhpon/spout layers
    PApplet applet;
    // shaders need to know whats up with time.
    Synchroniser sync;
    // boolean makeMaskFlag = false;

    //  abstract methods
    public abstract void render(ArrayList<RenderableTemplate> _toRender);
    public abstract PGraphics getCanvas();
    public abstract void setup();
    // concrete methods?
    public boolean layerCreator(String[] _args) {
        return false;
    }

    public int setTrails(int _t, int _max) {
        return 0;
    }

    // implemented methods
    public void inject(TemplateRenderer _tr) {
        templateRenderer = _tr;
    }
    public void inject(CommandProcessor _cp) {
        commandProcessor = _cp;
    }
    public void inject(Synchroniser _s) {
        sync = _s;
    }
    // no commands available
    public boolean parseCMD(String[] _args) {
        return false;
    }
    public String getLayerInfo() {
        return "none";
    }
}

/**
 * Simple CanvasManager subclass.
 * Lightest possible for faster performance on older hardware
 * AKA classic mode.
 */
class ClassicCanvasManager extends CanvasManager {
    TracerLayer tracerLayer;

    public ClassicCanvasManager(PApplet _applet, PGraphics _gui) {
        applet = _applet;
        guiCanvas = _gui;
    }

    public void setup() {
        tracerLayer = new TracerLayer();
    }

    public void render(ArrayList<RenderableTemplate> _toRender) {
        tracerLayer.beginDrawing();
        for(RenderableTemplate _rt : _toRender)
            templateRenderer.render(_rt, tracerLayer.getCanvas());

        tracerLayer.endDrawing();
        image(tracerLayer.getCanvas(),0,0);
        image(guiCanvas,0,0);
    }

    // unfortunatly for LEDs wont get the shader effects...
    public PGraphics getCanvas() {
        return tracerLayer.getCanvas();
    }

    public int setTrails(int _t, int _max) {
        return tracerLayer.setTrails(_t, _max);
    }
}

/**
 * Customizable rendering layer system
 * AKA custom deluxe
 */
class LayeredCanvasManager extends CanvasManager {
    // all of the layers?
    ArrayList<Layer> layers;
    // layers that can be drawn on
    ArrayList<RenderLayer> renderLayers;
    // MergeLayer mergeLayer;
    PGraphics mergeCanvas;

    public LayeredCanvasManager(PApplet _pa, PGraphics _gui) {
        applet = _pa;
        guiCanvas = _gui;
        layers = new ArrayList();
        renderLayers = new ArrayList();
        // mergeLayer = new MergeLayer();
        mergeCanvas = createGraphics(width, height, P2D);

    }

    public void setup() {
        // define the stack
        layerCreator("layer tracerOne tracerLayer");
        layerCreator("layer firstShader shaderLayer");
        layerCreator("layer secondShader shaderLayer");
        // layerCreator("layer squareMask maskLayer");
        layerCreator("layer mergeA mergeLayer");
        ////////////////////////////////////////////////////
        layerCreator("layer untraced renderLayer");
        layerCreator("layer thirdShader shaderLayer");
        layerCreator("layer fourthShader shaderLayer");
        // layerCreator("layer outMask maskLayer");
        layerCreator("layer mergeB mergeLayer");
        ////////////////////////////////////////////////////
        // layerCreator("layer cap captureLayer");
        // layerCreator("layer capMask maskLayer");
        // layerCreator("layer mergeC mergeLayer");
        ////////////////////////////////////////////////////

        layerCreator("layer mergeOutput mergeOutput");
        // led/dmx layer
        layerCreator("layer fix fixtureLayer");
        // layerCreator("layer cap captureLayer");
        layerCreator("layer gui guiLayer");
        // add frame sharing layers by default, they get deleted if they are not enabled.
        layerCreator("layer syphon syphonLayer");
        layerCreator("layer spout spoutLayer");

        // layerCreator("layer screenshot screenshotLayer");
        layerCreator("layer screen outputLayer");

        printLayers();
    }

    public int setTrails(int _t, int _max) {
        int _ret = 0;
        for(Layer _lyr : layers)
            if(_lyr instanceof TracerLayer)
                _ret = ((TracerLayer)_lyr).setTrails(_t, _max);
        return _ret;
    }

    public Layer addLayer(Layer _lr) {
        if(_lr == null) return null;
        layers.add(_lr);
        //if(_lr instanceof VertexShaderLayer)
        //  renderLayers.add((RenderLayer)_lr);
        //else
        if(_lr instanceof RenderLayer && !(_lr instanceof ShaderLayer))
            renderLayers.add((RenderLayer)_lr);
        return _lr;
    }

    public boolean layerCreator(String _s) {
        return layerCreator(split(_s, ' '));
    }

    // takes a cmd : layer newID type : layer myTracer tracerLayer
    public boolean layerCreator(String[] _args) {
        if(_args.length < 3) return false;
        // first check if there is a layer with the same Name or other subclass
        Layer _existingLayer = null;
        for(Layer _l : layers) {
            if(_l.getID().equals(_args[1])) {
                _existingLayer = _l;
                _args[2] = "containerLayer";
                _args[1] = getNewCloneName(_args[1]);
            }
        }

        Layer _lyr = null;

        switch(_args[2]) {
        case "renderLayer":
            _lyr = new RenderLayer();
            break;
        case "tracerLayer":
            _lyr = new TracerLayer();
            break;
        case "mergeLayer":
            _lyr = new MergeLayer();
            _lyr.setCanvas(mergeCanvas);
            break;
        case "mergeOutput":
            _lyr = new MergeOutput();
            _lyr.setCanvas(mergeCanvas);
            break;
        case "outputLayer":
            _lyr = new OutputLayer();
            break;
        case "maskLayer":
            _lyr = new MaskLayer();
            break;
        case "shaderLayer":
            _lyr = new ShaderLayer(sync);
            break;
        // case "vertexShaderLayer":
        //   _lyr = new VertexShaderLayer();
        //   break;
        case "imageLayer":
            _lyr = new ImageLayer();
            break;
        case "guiLayer":
            _lyr = new GuiLayer(guiCanvas);
            break;
        case "spoutLayer":
            _lyr = addSpoutLayer();
            break;
        case "syphonLayer":
            _lyr = addSyphonLayer();
            break;
        case "fixtureLayer":
            _lyr = new FixtureLayer(applet);
            break;
        case "captureLayer":
            _lyr = new CaptureLayer(applet);
            break;
        case "screenshotLayer":
            _lyr = new ScreenshotLayer();
            break;
        case "containerLayer":
            if(_existingLayer != null) {
                _lyr = new ContainerLayer();
                _lyr.setLayer(_existingLayer);
            }
            break;
        }
        if(_lyr != null) {
            _lyr.setID(_args[1]);
            addLayer(_lyr);
            return true;
        }
        return false;
    }

    private Layer addSyphonLayer() {
        Layer _lyr = new SyphonLayer(applet);
        if(_lyr.useLayer()) return _lyr;
        else return null;
    }

    private Layer addSpoutLayer() {
        Layer _lyr = new SpoutLayer(applet);
        if(_lyr.useLayer()) return _lyr;
        else return null;
    }

    /**
     * makes a different name for a same layer so the layer can be tapped at different places.
     */
    private String getNewCloneName(String _s) {
        for(Layer _l : layers) {
            if(_l.getID().equals(_s))
                return getNewCloneName(_s+"I");
        }
        return _s;
    }

    /**
     * Begin redering process. Make sure to end it with endRender();
     */
    public void render(ArrayList<RenderableTemplate> _toRender) {
        int _index = 0;
        for(Layer _rl : renderLayers) {
            _rl.beginDrawing();
            for(RenderableTemplate _rt : _toRender) {
                if(_rt.getRenderLayer() == _index) templateRenderer.render(_rt, _rl.getCanvas());
            }
            _rl.endDrawing();
            _index++;
        }

        mergeCanvas.beginDraw();
        mergeCanvas.clear();

        // and this is where the magic happens
        PGraphics _prev = null;
        for(Layer _lr : layers) _prev = _lr.apply(_prev);

        for(Layer _lr : layers) {
            if(_lr instanceof MaskLayer) {
                if(((MaskLayer)_lr).checkMakeMask()) ((MaskLayer)_lr).makeMask(mergeCanvas);
            }
            if(_lr.hasCMD()) {
                commandProcessor.queueCMD(_lr.getCMD());
            }
        }
    }

    public final PGraphics getCanvas() {
        return mergeCanvas;// mergeLayer.getCanvas();
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void updateOptions() {
        ArrayList<String> _shaders = freeliner.getFilesFrom(PATH_TO_SHADERS, ".glsl");
        ArrayList<String> _fixtures = freeliner.getFilesFrom(PATH_TO_FIXTURES, ".xml");
        ArrayList<String> _images = freeliner.getFilesFrom(PATH_TO_IMAGES, ".png");
        _images.addAll(freeliner.getFilesFrom(PATH_TO_IMAGES, ".png"));
        for(Layer _lyr : layers) {
            if(_lyr instanceof ImageLayer) _lyr.setOptions(sortAndArray(_images));
            else if(_lyr instanceof ShaderLayer) _lyr.setOptions(sortAndArray(_shaders));
            else if(_lyr instanceof FixtureLayer) _lyr.setOptions(sortAndArray(_fixtures));
        }
    }

    private String[] sortAndArray(ArrayList<String> _in){
        String[] _out = _in.toArray(new String[_in.size()]);
        Arrays.sort(_out);
        return _out;
    }

    public void printLayers() {
        println("+--------Layers--------+");
        for(Layer _lr : layers) println(_lr.getID());
        println("+--------details--------+");
        for(Layer _lr : layers) printLayer(_lr);
        println("+--------END-----------+");
    }

    // type-layerName
    // the rest can be figured out in JS
    public String getLayerInfo() {
        updateOptions();
        String _out = "";
        for(Layer _lyr : layers) {
            _out += _lyr.getID()+"-";
            _out += _lyr.getName()+"-";
            if(_lyr.useLayer()) _out += str(1)+"-";
            else _out += str(0)+"-";
            _out += _lyr.getSelectedOption()+"-";
            for(String _s : _lyr.getOptions()) _out += _s+"-";
            // _out += ((_lyr instanceof ShaderLayer) ? 1 : 0 )+"-";
            _out += " ";
        }
        return _out;
    }

    public void printLayer(Layer _lyr) {
        println(".............."+_lyr.getID()+"..............");
        println(_lyr.getDescription());
        for(String _cmd : _lyr.getCMDList() ) println(_cmd);
        println("enable "+_lyr.useLayer());
        println("............................................");
    }

    public void screenShot() {
        // save screenshot to capture/screenshots/datetime.png
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean parseCMD(String[] _args) {
        if(_args.length < 3) return false;
        else if(_args[2].equals("swap") ) {
            swapOrder(_args[1], stringInt(_args[3]));
            return true;
        } else if(_args[2].equals("delete") ) {
            return deleteLayer(getLayer(_args[1]));
        }

        Layer _lyr = getLayer(_args[1]);
        if(_lyr == null) return layerCreator(_args);
        else if(_lyr.parseCMD(_args)) return true;
        else return layerCreator(_args);
    }

    public Layer getLayer(String _id) {
        for(Layer _lyr : layers)
            if(_lyr.getID().equals(_id)) return _lyr;
        return null;
    }

    // seem to work!
    public void swapOrder(String _id, int _dir) {
        for(int i = 0; i < layers.size(); i++) {
            if(layers.get(i).getID().equals(_id)) {
                if(i + _dir >= 0 && i + _dir < layers.size()) {
                    Collections.swap(layers, i, i + _dir);
                    return;
                }
            }
        }
    }

    public boolean deleteLayer(Layer _lyr) {
        if(_lyr != null) layers.remove(_lyr);
        else return false;
        return true;
    }

    public void addLayer(String _id) {
        addLayer(new Layer()).setID(_id);
    }

    /**
     * Toggle the use of background with alpha value
     * @return boolean value given
     */
    public boolean toggleTrails() {
        //tracerLayer.toggleLayer();
        return false;//tracerLayer.useLayer();
    }
}

// base class for color picking
// add global color pallette to manipulate.
// then the color cycling modes can hop between pre determined colours.
class Colorizer extends Mode{
	//custom colors?

  public Colorizer(){
		name = "Colorizer";
		description = "Pics a color according to stuff.";
  }

  public int get(RenderableTemplate _event, int _alpha){
  	return alphaMod(color(255), _alpha);
  }

	// need to multiplex alpha value for fill & stroke, just fill, or just stroke.
  public int alphaMod(int  _c, int _alpha){
  	return color(red(_c), green(_c), blue(_c), _alpha);
  }

  public int HSBtoRGB(float _h, float _s, float _b){
  	return java.awt.Color.HSBtoRGB(_h, _s, _b);
  }

	public int getFromPallette(int _c){
		if(_c >= 0 || _c < PALLETTE_COUNT) return userPallet[_c];
		else return color(255);
	}

  public String getName(){
  	return name;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * Basic Color
 */
class SimpleColor extends Colorizer{
	int col;
	public SimpleColor(int _c, int _ind){
    modeIndex = _ind;
		col = _c;
    name = "#"+hex(_c,6);
    description = "simpleColor";

		// set the name when instantiating.
	}
	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(col , _alpha);
	}
}

/**
 * Colors from the user's pallette
 */
class PalletteColor extends Colorizer {
	int colorIndex;

	public PalletteColor(int _i, int _ind){
    modeIndex = _ind;
		colorIndex = _i;
		name = "pallette "+_i;
		description = "Color of "+_i+" index in colorPalette";
	}

	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(getFromPallette(colorIndex) , _alpha);
	}
}

/**
 * Working with primary colors
 */
class PrimaryColor extends Colorizer {

  public PrimaryColor(){}
	public PrimaryColor(int _ind){
    modeIndex = _ind;
		name = "PrimaryColor "+hex(getPrimary(_ind));
		description = "A primary color";
	}

	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(1), _alpha);
	}

	public int getPrimary(int _c){
		switch(_c){
			case 0:
				return 0xffff0000;
			case 1:
				return 0xff00ff00;
			default:
				return 0xff0000ff;
		}
	}
}

/**
 * Random primary color
 */
class RandomPrimaryColor extends PrimaryColor {
	public RandomPrimaryColor(int _ind){
    modeIndex = _ind;
		name = "RandomPrimaryColor";
		description = "Primary color that should change every beat.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(_event.getRandomValue()%3), _alpha);
	}
}

/**
 * Changes primary color on the beat regardless of divider
 */
class PrimaryBeatColor extends PrimaryColor {
	public PrimaryBeatColor(int _ind){
    modeIndex = _ind;
		name = "PrimaryBeatColor";
		description = "Cycles through primary colors on beat.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(_event.getRawBeatCount() % 3), _alpha);
	}
}

/**
 * Constantly changing random primary color
 */
class FlashyPrimaryColor extends PrimaryColor {
	public FlashyPrimaryColor(int _ind){
    modeIndex = _ind;
		name = "FlashyPrimaryColor";
		description = "Random primary color every frame.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary((int)random(3)), _alpha);
	}
}

/**
 * Per Repetition
 */
class JahColor extends Colorizer {

	int[] jah = {0xffCE000E,0xffE9FF00,0xff268E01};
	final int JAH_COUNT = 3;
	public JahColor(int _ind){
    modeIndex = _ind;
		name = "JahColor";
		description = "Red Green Yellow";
	}

	public int get(RenderableTemplate _event, int _alpha){
		int index = (_event.getBeatCount()-_event.getRepetition()+_event.getSegmentIndex()) % JAH_COUNT;
		index %= JAH_COUNT;
		if(index < 0) index = 0;
		int c = jah[index];
		return alphaMod(c , _alpha);
	}
}

/**
 * JahColor
 */
class RepetitionColor extends Colorizer {

	public RepetitionColor(int _ind){
    modeIndex = _ind;
		name = "RepetitionColor";
		description = "Cycles through colors of the pallette";
	}

	public int get(RenderableTemplate _event, int _alpha){
		int index = (_event.getBeatCount()-_event.getRepetition()+_event.getSegmentIndex()) % PALLETTE_COUNT;
		index %= PALLETTE_COUNT;
		if(index < 0) index = 0;
		int c = userPallet[index];
		return alphaMod(c , _alpha);
	}
}

/**
 * Constantly changing random value gray
 */
class FlashyGray extends Colorizer {
	public FlashyGray(int _ind){
    modeIndex = _ind;
		name = "FlashyGray";
		description = "Random shades of gray.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		int c = color(random(255));
		return alphaMod(c , _alpha);
	}
}


/**
 * Constantly changing random color
 */
class RandomRGB extends Colorizer {
	public RandomRGB(int _ind){
    modeIndex = _ind;
		name = "RGB";
		description = "Random red green and blue value every frame.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		int c = color(random(255),random(255),random(255));
		return alphaMod(c , _alpha);
	}
}

/**
 * Constantly changing random color
 */
class Strobe extends Colorizer {
	public Strobe(int _ind){
    modeIndex = _ind;
		name = "Strobe";
		description = "Strobes white";
	}

	public int get(RenderableTemplate _event, int _alpha){
		if(maybe(20)) return color(255);
		else return color(255,0);
	}
}

/**
 * flash once! then black?
 */
class Flash extends Colorizer {
	public Flash(int _ind){
    modeIndex = _ind;
		name = "Flash";
		description = "Flashes once per beat.";
	}

	public int get(RenderableTemplate _event, int _alpha){
		if(_event.getUnitInterval()<0.01f) return color(255, 255);
		else if(_event.getUnitInterval()>0.1f) return color(0,0);
		else return color(0, 255);
	}
}



/**
 * Fade through the HUE
 */
class MillisFade extends Colorizer {
	public MillisFade(int _ind){
    modeIndex = _ind;
		name = "MillisFade";
		description = "HSB fade goes along with millis.";
	}
	public int get(RenderableTemplate _event, int _alpha){

		int c = HSBtoRGB(PApplet.parseFloat(millis()%10000)/10000.0f, 1.0f, 1.0f);
		return alphaMod(c , _alpha);
	}
}

/**
 * Fade through the HUE
 */
class HSBLerp extends Colorizer {
	public HSBLerp(int _ind){
    modeIndex = _ind;
		name = "HSBLerp";
		description = "HSB fade through beat.";
	}
	public int get(RenderableTemplate _event, int _alpha){
		int c = HSBtoRGB(_event.getLerp(), 1.0f, 1.0f);
		return alphaMod(c , _alpha);
	}
}

/**
 * HSB Lerp
 */
class HSBFade extends Colorizer {
	public HSBFade(int _ind){
    modeIndex = _ind;
		name = "HSBFade";
		description = "HSBFade stored on template/event.";
	}
	public int get(RenderableTemplate _event, int _alpha){
		float hue = _event.getHue();
		int c = HSBtoRGB(hue, 1.0f, 1.0f);
		hue+=0.001f;
		hue = fltMod(hue);
		_event.setHue(hue);
		return alphaMod(c , _alpha);
	}
}

/**
 * Get template's custom color
 */
class CustomStrokeColor extends Colorizer {
	public CustomStrokeColor(int _ind){
    modeIndex = _ind;
		name = "CustomStrokeColor";
		description = "Custom stroke color for template.";
	}
	public int get(RenderableTemplate _event, int _alpha){
    if(_alpha >= 255)
      return _event.getCustomStrokeColor();
    else
      return alphaMod(_event.getCustomStrokeColor(), _alpha);
	}
}

/**
 * Get template's custom color
 */
class CustomFillColor extends Colorizer {
	public CustomFillColor(int _ind){
    modeIndex = _ind;
		name = "CustomColor";
		description = "Custom fill color for template.";
	}
	public int get(RenderableTemplate _event, int _alpha){
    if(_alpha >= 255)
      return _event.getCustomFillColor();
    else
      return alphaMod(_event.getCustomFillColor(), _alpha);
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * This distributes events to templates and stuff.
 */
class CommandProcessor implements FreelinerConfig {
    TemplateManager templateManager;
    TemplateRenderer templateRenderer;
    CanvasManager canvasManager;
    GroupManager groupManager;
    Synchroniser synchroniser;
    Sequencer sequencer;
    Keyboard keyboard;
    Mouse mouse;
    Gui gui;
    Looper looper;
    KeyMap keyMap;
    FreeLiner freeliner;
    OSCCommunicator oscComs;
    WebSocketCommunicator webComs;
    // this string gets set to whatever value was set
    String valueGiven = "";

    ArrayList<String> commandQueue;

    String[] commandList = {
        // for adressing templates use ABCD, or * for all, or $ for selected
        "tw AB q 3",
        "tr AB (3 4 5)",
        "tp stroke AB #ff0000",
        "tp fill AB #ff0000",
        "tp copy (AB)",
        "tp paste (AB)",
        "tp add (AB)",
        "tp reset (AB)",
        "tp save (cooleffects.xml)",
        "tp load (coolstuff.xml)",
        "tp swap AB",
        "tp select AB*",
        "tp toggle A 3",
        "tp lerp A 0.5",

        "tp translate AB 0.5 0.5 0.5",
        // add tp setshape (geometryIndex | char | .svg)
        /////////////////// Sequencer
        "seq tap (offset)",
        "seq edit -1,-2,step ????",
        "seq clear (step || AB)",
        "seq share A step",
        "seq toggle A (step)",
        "seq play 0,1",
        "seq stop // redundent play 0|1",
        "seq speed 0.5",
        "seq steady 0|1",
        ///////////////////  Loop CMD
        "loop 2", // loop 2 primes a loop (starts on input), 0 stops recording, kill loops lifo style

        "cmd rec 0|1|-3", // not implemented
        "cmd play 0|1|-3", // not implemented
        ///////////////////  Tools
        "tools lines 0|1|-3",
        "tools tags 0|1|-3",
        "tools capture", // not implemented should be in post????
        "tools snap (dist)",
        "tools grid (size)",
        "tools ruler (length)",
        "tools angle (angle)",
        ///////////////////  Geometry
        "geom txt (2 3) bunch of words",
        "geom save (coolMap.xml)",
        "geom load (coolMap.xml)",
        "geom toggle ABC (2 3 4)", // not implemented yet
        "geom webref",
        "geom priority (ABC|4) 3",
        ///////////////////  Post processing
        "post tracers (alpha)", // to be deprecated
        // "post shader (coolfrag.glsl)", // to be deprecated
        // "post mask (mask.png)", // to be deprecated
        "layer layerID cmd args",
        "layer layerID swap -1|1",
        "layer layerID load file.thing",
        "layer layerID enable (-3|0|1)",
        "layer layerID setID newID",
        "layer layerID layertype",

        /////////////////// Information Accessors
        "fetch-osc|fetch-ws infoline",
        "fetch-osc|fetch-ws tracker A",
        "fetch-osc|fetch-ws template A",
        "fetch-osc|fetch-ws seq",
        // "fetch-osc|fetch-ws fileList",
        "fetch-osc|fetch-ws layers",

        /////////////////// Configure
        "config width 1024",
        "config height 1024",
        "config fullScreen 0",
        "config display 1",
        /////////////////// Window
        "window location 10 10",
        ///////////////////
        // "fixture setchan 0 3 255", // fixture, channel, value
        "fixtures testchan 3",
        "fixtures setchan",
        /////////////////// Configure
        "hid kbd 'keyCode' 'char'",
        "setosc 127.0.0.1 6666",
        "colormap (file|0-1)"
    };

    /**
     * Constructor
     */
    public CommandProcessor() {
        commandQueue = new ArrayList();
        looper = new Looper();
    }

    /**
     * Dependency injection
     * @param FreeLiner
     */
    public void inject(FreeLiner _fl) {
        freeliner = _fl;

        templateManager = _fl.getTemplateManager();
        synchroniser = templateManager.getSynchroniser();
        sequencer = templateManager.getSequencer();
        templateRenderer = _fl.getTemplateRenderer();
        canvasManager = _fl.getCanvasManager();
        groupManager = _fl.getGroupManager();
        mouse = _fl.getMouse();
        keyboard = _fl.getKeyboard();
        gui = _fl.getGui();
        keyMap = freeliner.getKeyMap();
        oscComs = freeliner.getOscCommunicator();
        webComs = freeliner.getWebCommunicator();
        looper.inject(synchroniser);
        looper.inject(this);
    }


    public void update() {
        looper.update();
        processQueue();
    }

    /**
     * Add a command to the queue.
     * The external gui uses this to avoid concurent modification exceptions.
     * @param String command
     */
    public void queueCMD(String _cmd) {
        // println("adding to queue : "+_cmd);
        commandQueue.add(_cmd);
    }

    public void queueCMD(ArrayList<String> _cmds) {
        if(_cmds != null) {
            commandQueue.addAll(_cmds);
        }
    }

    /**
     * Process commands that are in the queue.
     */
    public void processQueue() {
        if(commandQueue.size() == 0) return;
        ArrayList<String> _q = new ArrayList(commandQueue);
        for(String _cmd : _q) processCMD(_cmd);
        commandQueue.clear();
        //gui.setValueGiven(getValueGiven());
    }

    /**
     * First level of command parsing, redistributes according to first argument of command.
     * @param String command
     */
    // public void processCMD(String _cmd){
    //
    // }

    public void processCMD(String _cmd) {
        if(_cmd == null) return;
        valueGiven = "_";

        String[] _args = split(_cmd, ' ');
        // println(_args);
        boolean _used = false;
        if(_args.length == 0) return;
        // first the ones that get filtered out of the looper
        else if(_args[0].equals("seq")) _used = sequencerCMD(_args);

        else if(_args[0].equals("window")) _used = windowCMD(_args);
        else if(_args[0].equals("addlayer")) _used = canvasManager.layerCreator(_args);
        else if(_args[0].equals("setosc")) _used = setOsc(_args);
        else if(_args[0].equals("colormap")) _used = colorMapCMD(_args);
        else if(_args[0].equals("config")) _used = configCMD(_args);
        else if(_args[0].equals("fl")) _used = flCMD(_args); // deprecated?
        else if(_args[0].equals("post")) _used = postCMD(_args);
        else if(_args[0].equals("tools")) _used = toolsCMD(_args);
        else if(_args[0].equals("geom")) _used = geometryCMD(_args);
        else if(_args[0].equals("fetch-osc") || _args[0].equals("fetch-ws")) _used = fetchCMD(_args);
        else if(_args[0].equals("hid")) _used = hidCMD(_args);
        else if(_args[0].equals("loop")) _used = loopCMD(_args);

        else if(_args[0].equals("tw")) _used = templateCMD(_args); // good
        else if(_args[0].equals("tr")) _used = templateCMD(_args); // need to check trigger group
        else if(_args[0].equals("tp")) _used = templateCMD(_args);
        else if(_args[0].equals("layer")) _used = layerCMD(_args);
        else if(_args[0].equals("fixtures")) _used = fixtureCMD(_args);

        // else if(_args[0].equals("fixture")) _used = fixtureCMD(_args);
        if(!_used) println("CMD fail : "+join(_args, ' '));

    }

    // keyboard triggered commands go through here? might be able to hack a undo feature...
    public void processCmdStack(String _cmd) {
        // add to stack
        processCMD(_cmd);
    }

    public boolean setOsc(String[] _args) {
        if(_args.length < 3) return false;
        int _port = stringInt(_args[2]);
        if(_port > 1)
            oscComs.setSyncAddress(_args[1], _port);
        else return false;
        return true;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     fixtures
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    public boolean fixtureCMD(String[] _args) {
        if(_args.length < 2) return false;
        if(_args[1].equals("setchan")) {
            groupManager.setChannel();
            valueGiven = "set";
        } else if(_args[1].equals("testchan") && _args.length > 2) {
            int _v = stringInt(_args[2]);
            if(_v == -42) return false;
            int _ha = groupManager.setTestChannel(_v);
            processCMD("layer fix testchan "+_ha+" 255");
            valueGiven = str(_ha);
        } else return false;
        return true;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     meta
    ///////
    ////////////////////////////////////////////////////////////////////////////////////


    public boolean colorMapCMD(String[] _args) {
        if(_args.length < 2) return false;
        int _v = stringInt(_args[1]);
        if(_v == -42) {
            PImage _map;
            try {
                _map = loadImage("userdata/images/"+_args[1]);
                templateRenderer.setColorMap(_map);
                gui.setColorMap(_map);
                println("loaded colormap "+_args[1]);
                return true;
            } catch(Exception e) {
                println("Error : could not load colormap "+_args[1]);
            }
        }
        return false;
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Window
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean windowCMD(String[] _args) {
        if(_args.length < 2) return false;
        else if(_args[1].equals("location")) return locationCMD(_args);
        else return false;
    }

    public boolean locationCMD(String[] _args) {
        if(_args.length < 4) return false;
        int _x = stringInt(_args[2]);
        int _y = stringInt(_args[3]);
        surface.setLocation(_x, _y);
        return true;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     config
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean configCMD(String[] _args) {
        if(_args.length < 2) return false;
        int _v = stringInt(_args[2]);
        if(_v == -42) return false;
        else if(_args[1].equals("width")) freeliner.configure(_args[1], _v);
        else if(_args[1].equals("height")) freeliner.configure(_args[1], _v);
        else if(_args[1].equals("fullscreen")) freeliner.configure(_args[1], _v);
        else if(_args[1].equals("display")) freeliner.configure(_args[1], _v);
        else if(_args[1].equals("pipeline")) freeliner.configure(_args[1], _v);

        // else if(_args[1].equals("open")) openCMD(_args);
        else return false;
        return true;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     layer
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    public boolean layerCMD(String[] _args) {
        if(_args.length > 3) {
            if(_args[2].equals("uniforms")) {
                looper.receive(join(_args, " "));
            }
        }
        return canvasManager.parseCMD(_args);
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     fl stuff load and such
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean flCMD(String[] _args) {
        if(_args.length < 2) return false;
        else if(_args[1].equals("save")) saveCMD(_args);
        else if(_args[1].equals("open")) openCMD(_args);
        else if(_args[1].equals("quit")) exit(); // via ctrl-q
        else return false;
        return true;
    }

    public void quitCMD() {
        // do a backup save?
        println("Freeliner quit via ctrl-Q, goodbye!");
        exit();
    }

    public void saveCMD(String[] _args) {
        processCMD("tp save");
        processCMD("geom save");
        gui.updateReference();//sketchPath()+"/data/webgui/reference.jpg");
        valueGiven = "sure";
    }

    public void openCMD(String[] _args) {
        processCMD("tp load");
        processCMD("geom load");
        valueGiven = "sure";
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     fetchCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean fetchCMD(String[] _args) {
        if(_args.length < 2) return false;
        if(_args[1].equals("infoline")) infoLineCMD(_args);
        else if(_args[1].equals("template")) templateStatCMD(_args);
        else if(_args[1].equals("tracker")) trackerCMD(_args);
        else if(_args[1].equals("seq")) seqStatCMD(_args);
        // else if(_args[1].equals("files")) fileListCMD(_args);
        else if(_args[1].equals("layers")) layerInfoCMD(_args);

        else return false;
        return true;
    }

    public void infoLineCMD(String[] _args) {
        String _info = "info "+gui.getInfo();
        fetchSend(_args, _info);
    }

    public void templateStatCMD(String[] _args) {
        if(_args.length < 3) return;
        TweakableTemplate _tp = templateManager.getTemplate(_args[2].charAt(0));
        if(_tp == null) return;
        String _info = _tp.getStatusString();
        fetchSend(_args, "template "+_info);
    }

    public void trackerCMD(String[] _args) {
        if(_args.length < 3) return;
        TweakableTemplate _tp = templateManager.getTemplate(_args[2].charAt(0));
        if(_tp == null) return;
        PVector _pos = _tp.getLastPosition();
        fetchSend(_args, "tracker "+_tp.getTemplateID()+" "+_pos.x/width+" "+_pos.y/height);
    }

    public void seqStatCMD(String[] _args) {
        String _stps = templateManager.getSequencer().getStatusString();
        fetchSend(_args, "seq "+_stps);
    }

    // void fileListCMD(String[] _args){
    //   String _files = freeliner.getFileNames();
    //   fetchSend(_args, "files "+_files);
    // }

    public void layerInfoCMD(String[] _args) {
        String _info = canvasManager.getLayerInfo();
        fetchSend(_args, "layers "+_info);
    }

    // send to apropriate destination
    public void fetchSend(String[] _args, String _mess) {
        if(_args[0].equals("fetch-osc")) {
            oscComs.send(_mess);
        } else if(_args[0].equals("fetch-ws")) {
            webComs.send(_mess);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     HID input
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean hidCMD(String[] _args) {
        if(_args.length < 4) return false;
        if(_args[3].length() < 1) return true; // catches the SPACEBAR
        if(_args[1].equals("press")) keyboard.keyPressed(stringInt(_args[2]), _args[3].charAt(0) );
        else if(_args[1].equals("release")) keyboard.keyReleased(stringInt(_args[2]), _args[3].charAt(0) );
        else return false;
        return true;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     toolsCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    // * tools lines
    // * tools tags
    // * tools capture
    // * tools snap (dist)
    // * tools grid (size)
    // * tools ruler (length)
    // * tools angle (angle)

    public boolean toolsCMD(String[] _args) {
        if(_args.length < 2) return false;
        if(_args[1].equals("lines")) valueGiven = str(gui.toggleViewLines());
        else if(_args[1].equals("tags")) valueGiven = str(gui.toggleViewLines());
        //else if(_args[1].equals("rec")) valueGiven = str(canvasManager.toggleRecording());
        else if(_args[1].equals("snap")) return snapCMD(_args);
        else if(_args[1].equals("grid")) return gridCMD(_args);
        else if(_args[1].equals("ruler")) return rulerCMD(_args);
        else if(_args[1].equals("angle")) return angleCMD(_args);
        else return false;
        return true;
    }

    public boolean snapCMD(String[] _args) {
        if(_args.length > 2) {
            int _v = stringInt(_args[2]);
            if(_v == -3) valueGiven = str(mouse.toggleSnapping());
            else if(_v != -42) valueGiven = str(groupManager.setSnapDist(_v));
            return true;
        }
        return false;
    }

    public boolean gridCMD(String[] _args) {
        if(_args.length > 2) {
            int _v = stringInt(_args[2]);
            if(_v == -3) valueGiven = str(mouse.toggleGrid());
            else if(_v != -42) valueGiven = str(mouse.setGridSize(_v));
            return true;
        }
        return false;
    }

    public boolean rulerCMD(String[] _args) {
        if(_args.length > 2) {
            int _v = stringInt(_args[2]);
            if(_v == -3) valueGiven = str(mouse.toggleFixedLength());
            else if(_v != -42) valueGiven = str(mouse.setLineLenght(_v));
            return true;
        }
        return false;
    }

    public boolean angleCMD(String[] _args) {
        if(_args.length > 2) {
            int _v = stringInt(_args[2]);
            if(_v == -3) valueGiven = str(mouse.toggleFixedAngle());
            else if(_v != -42) valueGiven = str(mouse.setLineAngle(_v));
            return true;
        }
        return false;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     geomCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    // * geom txt (2 3) word
    // * geom save (coolMap.xml)
    // * geom load (coolMap.xml)

    public boolean geometryCMD(String[] _args) {
        if(_args.length < 2) return false;
        if(_args[1].equals("save")) return saveGeometryCMD(_args);
        else if(_args[1].equals("load")) return loadGeometryCMD(_args);
        else if(_args[1].equals("text")) return textCMD(_args);
        else if(_args[1].equals("new")) valueGiven = str(groupManager.newGroup());
        else if(_args[1].equals("center")) valueGiven = str(groupManager.toggleCenterPutting());
        else if(_args[1].equals("webref")) webrefCMD();
        else if(_args[1].equals("breakline")) mouse.press(3);
        else if(_args[1].equals("priority")) priorityGeometryCMD(_args);

        else return false;
        return true;
    }

    // "geom priority (ABC|4) 3",
    public boolean priorityGeometryCMD(String[] _args){
        if(_args.length > 3){
            int _items = stringInt(_args[2]);
            int _priority = stringInt(_args[3]);
            if(_items == -42){
                valueGiven = str(groupManager.geometryPriority(_args[2], _priority));
            }
            else valueGiven = str(groupManager.geometryPriority(_items, _priority));
            return true;
        }
        else if(_args.length > 2){
            int _priority = stringInt(_args[2]);
            valueGiven = str(groupManager.geometryPriority(_priority));
            return true;
        }
        return false;
    }


    public void webrefCMD() {
        gui.updateReference(sketchPath()+"/data/webgui/reference.jpg");
        freeliner.getGUIWebServer().refreshFiles();
    }

    public boolean saveGeometryCMD(String[] _args) {
        if(_args.length == 2) groupManager.saveGroups();
        else if(_args.length == 3) groupManager.saveGroups(_args[2]);
        else return false;
        return true;
    }

    public boolean loadGeometryCMD(String[] _args) {
        if(_args.length == 2) groupManager.loadGeometry();
        else if(_args.length == 3) groupManager.loadGeometry(_args[2]);
        else return false;
        return true;
    }

    // geom txt (2 3) ahah yes
    // geom txt yes no
    public boolean textCMD(String[] _args) {
        if(_args.length == 3) groupManager.setText(_args[2]);
        else if(_args.length == 4) groupManager.setText(_args[2]+" "+_args[3]);
        else if(_args.length > 3) {
            int _grp = stringInt(_args[2]);
            int _seg = stringInt(_args[3]);
            if(_grp != -42) {
                if(_seg != -42)
                    groupManager.setText(_grp, _seg, remainingText(4, _args));
                else
                    groupManager.setText(_grp, remainingText(3, _args));
            } else {
                groupManager.setText(remainingText(2, _args));
            }
        } else return false;
        return true;
    }

    public String remainingText(int _start, String[] _args) {
        String _txt = "";
        for(int i = _start; i < _args.length; i++) _txt += _args[i]+" ";
        return _txt;
    }

    ///////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     postCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public boolean postCMD(String[] _args) {
        if(_args.length < 2) return false;
        else if(_args[1].equals("tracers")) trailsCMD(_args);
        //else if(_args[1].equals("mask")) maskCMD(_args);
        // else if(_args[1].equals("shader")) shaderCMD(_args);
        else return false;
        return true;
    }

    public boolean trailsCMD(String[] _args) {
        //if(_args.length < 2) return;
        //else if(_args[1].equals("trails")){
        if(_args.length > 2) {
            int _v = stringInt(_args[2]);
            //if(_v == -3) valueGiven = str(canvasManager.toggleTrails());
            //else valueGiven = str(canvasManager.setTrails(_v));
            valueGiven = str(canvasManager.setTrails(_v, keyMap.getMax('y')));
            return true;
        }
        return false;
        //}
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     LooperCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    public boolean loopCMD(String[] _args) {
        if(_args.length > 1) {
            int _v = stringInt(_args[1]);
            valueGiven = looper.setTimeDivider(_v, keyMap.getMax('z'));
            return true;
        }
        return false;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     sequencerCMD
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // * seq tap
    // * seq edit -1,-2,step
    // * seq clear (step || AB)
    // * seq toggle A (step)

    public boolean sequencerCMD(String[] _args) {
        //if(_args.length < 3) return;
        if(_args.length < 2) return false;
        else if(_args[1].equals("tap")) synchroniser.tap();
        else if(_args[1].equals("select")) selectStep(_args); // up down or specific
        else if(_args[1].equals("clear")) clearSeq(_args); //
        else if(_args[1].equals("toggle")) toggleStep(_args);
        else if(_args[1].equals("speed") && _args.length > 2) synchroniser.setTimeScaler(stringFloat(_args[2]));
        else if(_args[1].equals("steady") && _args.length > 2) synchroniser.setSteady(PApplet.parseBoolean(stringInt(_args[2])));
        else return false;
        return true;
    }

    public void selectStep(String[] _args) {
        if(_args.length == 3) valueGiven = str(sequencer.setEditStep(stringInt(_args[2])));
        gui.setTemplateString(sequencer.getStepToEdit().getTags());
        // valueGiven = sequencer.getStepToEdit().getTags();
        //println("tags   "+sequencer.getStepToEdit().getTags());
    }

    public void clearSeq(String[] _args) {
        if(_args.length == 2) sequencer.clear();
        if(_args.length > 2) {
            ArrayList<TweakableTemplate> _tps =  templateManager.getTemplates(_args[2]);
            if(_tps != null) {
                for(TweakableTemplate _tw : _tps)
                    sequencer.clear(_tw);
            } else {
                int _v = stringInt(_args[2]);
                if(_v != -42 && _v >= 0) sequencer.clear(_v);
                else sequencer.clear();
            }
        }
    }

    public void toggleStep(String[] _args) {
        if(_args.length > 2) {
            ArrayList<TweakableTemplate> _tp = templateManager.getTemplates(_args[2]);
            if(_tp == null) return;
            for(TweakableTemplate _tw : _tp)
                sequencer.toggle(_tw);
        }
        gui.setTemplateString(sequencer.getStepToEdit().getTags());
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Template commands ********TESTED********
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    // * tw AB q 3
    // * tr AB (geometry)
    // * tp copy (AB)
    // * tp paste (AB)
    // * tp share (AB)
    // * tp reset (AB)
    // * tp save (cooleffects.xml)
    // * tp load (coolstuff.xml)
    // * tp color AB r g b a

    public boolean templateCMD(String[] _args) {
        if(_args[0].equals("tw")) tweakTemplates(_args);
        else if(_args[0].equals("tr")) triggerTemplates(_args);
        else if(_args[0].equals("tp")) {
            if(_args.length < 2) return false;
            else if(_args[1].equals("copy")) copyCMD(_args);
            else if(_args[1].equals("paste")) pasteCMD(_args);
            else if(_args[1].equals("reset")) resetCMD(_args);
            else if(_args[1].equals("groupadd")) addCMD(_args);
            else if(_args[1].equals("swap")) swapCMD(_args);
            else if(_args[1].equals("save")) saveTemplateCMD(_args);
            else if(_args[1].equals("load")) loadTemplateCMD(_args);
            else if(_args[1].equals("link")) linkTemplateCMD(_args);

            else if(_args[1].equals("stroke")) strokeColorCMD(_args);
            else if(_args[1].equals("fill")) fillColorCMD(_args);
            else if(_args[1].equals("select")) tpSelectCMD(_args);
            else if(_args[1].equals("translate")) tpTranslateCMD(_args);
            else if(_args[1].equals("toggle")) toggleCMD(_args);
            else if(_args[1].equals("lerp")) lerpCMD(_args);

        } else return false;
        return true;
    }

    public void lerpCMD(String[] _args) {
        ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[2]);
        float _lrp = stringFloat(_args[3]);
        for(TweakableTemplate _tp : _tmps) _tp.setFixLerp(_lrp);
    }


    public void toggleCMD(String[] _args) {
        ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[2]);
        int _ind = stringInt(_args[3]);
        for(TweakableTemplate _tp : _tmps) groupManager.toggleTemplate(_tp, _ind);
    }

    public void tpSelectCMD(String[] _args) {
        if(_args.length < 3) return;
        else if(_args[2].equals("*")) {
            templateManager.focusAll();
            gui.setTemplateString("*All*");
        } else {
            templateManager.unSelect();
            for(int i = 0; i < _args[2].length(); i++) {
                templateManager.toggle(_args[2].charAt(i));
            }
        }
    }

    public void saveTemplateCMD(String[] _args) {
        if(_args.length == 2) templateManager.saveTemplates();
        else if(_args.length == 3) templateManager.saveTemplates(_args[2]);
    }

    public void loadTemplateCMD(String[] _args) {
        if(_args.length == 2) templateManager.loadTemplates();
        else if(_args.length == 3) templateManager.loadTemplates(_args[2]);
    }

    public void linkTemplateCMD(String[] _args) {
        if(_args.length == 3) templateManager.linkTemplates(_args[2]);
    }

    public void copyCMD(String[] _args) {
        if(_args.length == 3) templateManager.copyTemplate(_args[2]);
        else templateManager.copyTemplate();
    }

    public void pasteCMD(String[] _args) {
        if(_args.length == 3) templateManager.pasteTemplate(_args[2]);
        else templateManager.pasteTemplate();
    }

    public void swapCMD(String[] _args) {
        if(_args.length == 3) templateManager.swapTemplates(_args[2]);
    }

    public void resetCMD(String[] _args) {
        if(_args.length == 3) templateManager.resetTemplate(_args[2]);
        else templateManager.resetTemplate();
    }

    public void addCMD(String[] _args) {
        if(_args.length == 3) templateManager.groupAddTemplate(_args[2]);
        else templateManager.groupAddTemplate();
    }

    public void strokeColorCMD(String[] _args) {
        if(_args.length < 4) return;
        String _hex = _args[3];
        int _v = unhex(_hex.replaceAll("#","FF").toUpperCase());
        if(_v != -3) templateManager.setCustomStrokeColor(_args[2], _v);
    }

    public void fillColorCMD(String[] _args) {
        if(_args.length < 4) return;
        String _hex = _args[3];
        int _v = unhex(_hex.replaceAll("#","FF").toUpperCase());
        if(_v != -3) templateManager.setCustomFillColor(_args[2], _v);
    }

    // could be in tm
    public void triggerTemplates(String[] _args) {
        looper.receive(join(_args, " "));

        if(_args.length == 2) {
            for(int i = 0; i < _args[1].length(); i++) templateManager.trigger(_args[1].charAt(i));
        } else if(_args.length > 2) {
            for(int i = 0; i < _args[1].length(); i++)
                for(int j = 2; j < _args.length; j++) templateManager.trigger(_args[1].charAt(i), stringInt(_args[j]));
        }
    }

// tp translate AB 0.5 0.5 0.5
    public void tpTranslateCMD(String[] _args) {
        looper.receive(join(_args, " "));
        if(_args.length < 5) return;
        float x = stringFloat(_args[3]);
        float y = stringFloat(_args[4]);
        float z = 0;
        if(_args.length > 5) z = stringFloat(_args[5]);
        PVector _translate = new PVector(x,y,z);
        ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[2]);
        if(_tmps == null) return;
        for(TweakableTemplate _rt : _tmps) {
            _rt.setTranslation(_translate);
        }
    }

    /**
     * Template tweaking, any "tw" cmds.
     * Commands like "tw A q 3"
     * @param String command
     * @return boolean was used
     */
    public void tweakTemplates(String[] _args) {
        if(_args.length < 4) return;
        //if(_args[3] == "-3") return;
        ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[1]); // does handle wildcard
        if(_tmps == null) return;
        if(_args[2].length() == 0) return;
        char _k = _args[2].charAt(0);
        int _v = stringInt(_args[3]);
        for(TweakableTemplate _tp : _tmps) templateDispatch(_tp, _k, _v);

    }

    /**
     * Change the parameters of a template.
     * @param TweakableTemplate template to modify
     * @param char editKey
     * @param int value
     * @return boolean value used
     */
    public void templateDispatch(TweakableTemplate _template, char _k, int _n) {
        //println(_template.getID()+" "+_k+" ("+int(_k)+") "+n);
        if(_template == null) return;
        // mod commands
        else if (_k == 'a') valueGiven = str(_template.setAnimationMode(_n, keyMap.getMax('a')));
        else if (_k == 'b') valueGiven = str(_template.setRenderMode(_n, keyMap.getMax('b')));
        else if (_k == 'f') valueGiven = str(_template.setFillMode(_n, keyMap.getMax('f')));
        else if (_k == 'h') valueGiven = str(_template.setEasingMode(_n, keyMap.getMax('h')));
        else if (_k == 'i') valueGiven = str(_template.setRepetitionMode(_n, keyMap.getMax('i')));
        else if (_k == 'j') valueGiven = str(_template.setReverseMode(_n, keyMap.getMax('j')));
        else if (_k == 'k') valueGiven = str(_template.setStrokeAlpha(_n, keyMap.getMax('k')));
        else if (_k == 'l') valueGiven = str(_template.setFillAlpha(_n, keyMap.getMax('l')));
        else if (_k == 'm') valueGiven = str(_template.setMiscValue(_n, keyMap.getMax('m')));
        else if (_k == 'o') valueGiven = str(_template.setRotationMode(_n, keyMap.getMax('o')));
        else if (_k == 'e') valueGiven = str(_template.setInterpolateMode(_n, keyMap.getMax('e')));
        else if (_k == 'p') valueGiven = str(_template.setRenderLayer(_n, keyMap.getMax('p')));
        else if (_k == 'q') valueGiven = str(_template.setStrokeMode(_n, keyMap.getMax('q')));
        else if (_k == 'r') valueGiven = str(_template.setRepetitionCount(_n, keyMap.getMax('r')));
        else if (_k == 's') valueGiven = str(_template.setBrushSize(_n, keyMap.getMax('s')));
        else if (_k == 'u') valueGiven = str(_template.setEnablerMode(_n, keyMap.getMax('u')));
        else if (_k == 'v') valueGiven = str(_template.setSegmentMode(_n, keyMap.getMax('v')));
        else if (_k == 'w') valueGiven = str(_template.setStrokeWidth(_n, keyMap.getMax('w')));
        else if (_k == 'x') valueGiven = str(_template.setBeatDivider(_n, keyMap.getMax('x')));
        // else if (_k == '%') valueGiven = str(_template.setBankIndex(_n));
        // else if (_k == '$') valueGiven = str(_template.saveToBank()); // could take an _n to set bank index?
        if (PApplet.parseInt(_k) == 518) _template.reset();
        else if(_n != -3) looper.receive("tw "+_template.getTemplateID()+" "+_k+" "+valueGiven);

    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public String getValueGiven() {
        return valueGiven;
    }
}


// idea for a command class
//
class Cmd implements FreelinerConfig {
    String[] args;
    //
    public Cmd(String[] _args) {
        args = _args;
    }

    public Cmd(String _cmd) {
        args = split(_cmd, ' ');
    }

    public void append(String _arg) {
        //
    }

    public int getInt(int _i) {
        return 0;
    }
    public float gettFloat(float _flt) {
        return 0.0f;
    }

    public int length() {
        return args.length;
    }

    // is index equal to string
    public boolean is(int _i, String _s) {
        if(_i < args.length) {
            return args[_i].equals(_s);
        } else return false;
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

 
 
 

 /**
  * The FreelinerCommunicator handles communication with other programs over various protocols.
  */
class FreelinerCommunicator implements FreelinerConfig{

  CommandProcessor commandProcessor;
  PApplet applet;

  public FreelinerCommunicator(PApplet _pa, CommandProcessor _cp){
    commandProcessor = _cp;
    applet = _pa;
  }

  /**
  * Pass commands to the command processor
  * @param String cmd
  */
  public void receive(String _cmd){
    commandProcessor.queueCMD(_cmd);
  }

  /**
  * Send info to the communicating end.
  * @param String stuff
  */
  public void send(String _s){
    println("Sending : "+_s);
  }

}



/**
 * OSC communicator, send and receive messages with freeliner!
 */
class OSCCommunicator extends FreelinerCommunicator implements OscEventListener{
  // network
  OscP5 oscP5;
  NetAddress toPDpatch;
  OscMessage tickmsg = new OscMessage("/freeliner/tick");

  public OSCCommunicator(PApplet _pa, CommandProcessor _cp){
    super(_pa, _cp);
    oscP5 = new OscP5(applet, OSC_IN_PORT);
    toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);
    oscP5.addListener(this);
  }

  public void send(String _cmd){
    String _adr = "/"+_cmd.replaceAll(" ", "/");
    oscP5.send(new OscMessage(_adr), toPDpatch);
  }

  // oscMessage callback
  public void oscStatus(OscStatus theStatus){
  }

  public void setSyncAddress(String _ip, int _port){
    toPDpatch = new NetAddress(_ip, _port);
  }

  public void oscEvent(OscMessage _mess) {
    String _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
    receive(_cmd);
  }

}

/**
 * WebSocket for browser based gui!!
 */
class WebSocketCommunicator extends FreelinerCommunicator{
  WebsocketServer webSock;

  public WebSocketCommunicator(PApplet _pa, CommandProcessor _cp){
    super(_pa, _cp);
    webSock = new WebsocketServer(applet, WEBSOCKET_PORT,"/freeliner");
    //webSock.setNewCallback(this);
  }

  public void send(String _s){
    webSock.sendMessage(_s);
  }

  public void webSocketServerEvent(String _cmd){
    // it
    receive(_cmd);
  }
}

interface FreelinerConfig {

  // make these defaults? will be changed with configuration files...
  // UDP Port for incomming messages
  final int OSC_IN_PORT = 6667;
  // UDP Port for outgoing sync message
  final int OSC_OUT_PORT = 6668;
  // IP address to send sync messages to
  final String OSC_OUT_IP = "127.0.0.1";
  // Websocket port
  final int WEBSOCKET_PORT = 8025;
  // Disbale Webserving
  final boolean SERVE_HTTP = true;
  // HTTP server port
  final int HTTPSERVER_PORT = 8000;

  // very beta
  final boolean DOME_MODE = false;

  // bad for beginners but crucial
  boolean ENABLE_KEY_REPEAT = true;

  // Mouse options
  final int DEFAULT_GRID_SIZE = 64;
  final int DEFAULT_LINE_ANGLE = 30;
  final int DEFAULT_LINE_LENGTH = 128;
  final int MOUSE_DEBOUNCE = 100;
  // use scrollwheel as - +
  final boolean SCROLLWHEEL_SELECTOR = false;

  // GUI options
  final int CURSOR_SIZE = 18;
  final int CURSOR_GAP_SIZE = 6;
  final int CURSOR_STROKE_WIDTH = 3;
  final int GUI_TIMEOUT = 100000;
  final int GUI_FONT_SIZE = 20;
  // final int DEFAULT_GRID_SIZE = 32; // used by mouse too
  final int NODE_STROKE_WEIGTH = 5;
  final int NODE_COLOR = 0xff989898;
  final int PREVIEW_LINE_STROKE_WIDTH = 1;
  final int PREVIEW_LINE_COLOR = 0xffffffff;
  final int CURSOR_COLOR = 0xffFFFFFF;
  final int SNAPPED_CURSOR_COLOR = 0xff00C800;
  final int TEXT_COLOR = 0xffFFFFFF;
  final int GRID_COLOR = 0xff969696;//9696;
  final int SEGMENT_COLOR = 0xffBEBEBE;
  final int SEGMENT_COLOR_UNSELECTED = 0xff6E6E6E;

  // If you are using a DLP with no colour wheel
  final boolean BW_BEAMER = false;
  // If you are using a dual head setup
  final boolean DUAL_HEAD = false;
  // invert colors
  final boolean INVERTED_COLOR = true;

  // Rendering options
  final int BACKGROUND_COLOR = 0xff000000;
  final int STROKE_CAP = ROUND;//PROJECT;//SQUARE; // or ROUND
  final int STROKE_JOIN = ROUND;//MITER; // or BEVEL or ROUND
  final boolean BRUSH_SCALING = false;

  // Timing and stuff
  final int DEFAULT_TEMPO = 1300;
  final int SEQ_STEP_COUNT = 16; // change not recommended, there in spirit

  // Pick your rendering pipeline,
  // 0 is lightest, best for older hardware
  // 1 is fancy, but only good with newer hardware
  final int RENDERING_PIPELINE = 1;

  // to enable / disable experimental parts.
  final boolean EXPERIMENTAL = false;

  // generate documentation on startup, pretty much mandatory now.
  final boolean MAKE_DOCUMENTATION = true;
  /**
   * Your color pallette! customize it!
   * Use hex value or color(0,100,200);
   */
  final int[] userPallet = {
                    0xffffff00,
                    0xffffad10,
                    0xffff0000,
                    0xffff00ad,
                    0xfff700f7,
                    0xffad00ff,
                    0xff0000ff,
                    0xff009cff,
                    0xff00c6ff,
                    0xff00deb5,
                    0xffa5ff00,
                    0xfff700f7,
                  };

  final int PALLETTE_COUNT = 12;

  final String PATH_TO_SHADERS = "userdata/shaders/";
  final String PATH_TO_IMAGES = "userdata/images/";
  final String PATH_TO_FIXTURES = "userdata/fixtures/";
  final String PATH_TO_GEOMETRY = "userdata/geometry/";
  final String PATH_TO_TEMPLATES = "userdata/template/";
  final String PATH_TO_VECTOR_GRAPHICS = "userdata/svg/";
  final String PATH_TO_CAPTURE_FILES = "userdata/capture/";


  // Freeliner LED options
  // final String LED_SERIAL_PORT = "/dev/ttyACM0";
  // final int LED_SYSTEM = 1; // FastLEDing 1, OctoLEDing 2
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-04-01
 */

// for detecting fields



/**
 * The FreelinerCommunicator handles communication with other programs over various protocols.
 */
class Documenter implements FreelinerConfig{
  ArrayList<ArrayList<Mode>> docBuffer;
  ArrayList<String> sections;
  PrintWriter markDown;
  XML freelinerModes;
  IntDict modeLimits;

  JSONObject freelinerJSON;
  JSONObject modesJSON;

  /**
   * Constructor
   */
  public Documenter(){
    docBuffer = new ArrayList();
    sections = new ArrayList();
    // sections.add("First");
    freelinerJSON = new JSONObject();
    modesJSON = new JSONObject();

    freelinerModes = new XML("freelinerModes");
    modeLimits = new IntDict();
    markDown = createWriter(sketchPath()+"/data/doc/autodoc.md");
    markDown.println("Generated on "+year()+"/"+month()+"/"+day()+" with freeliner version "+VERSION);
  }

  /**
   * Add a array of "modes", their associated key, and their section name.
   * @param Mode[] array of modes to be added to doc.
   * @param char key associated with mode slection (q for stroke color)
   * @param String section name (ColorModes)
   */
  public void documentModes(Mode[] _modes, char _key, Mode _parent, String _section){
    if(!hasSection(_section)){
      sections.add(_section);
      addModesToMarkDown(_modes,_key,_parent);
      storeLimits(_key, _modes.length);
      addModesToJSON(_modes,_key,_parent);
    }
  }

  public void storeLimits(char _k, int _n){
    String _key = str(_k);
    if(modeLimits.hasKey(_key)){
      if(modeLimits.get(_key) < _n) modeLimits.set(_key, _n);
    }
    else modeLimits.add(_key, _n);
  }

  /**
   * As many things get instatiated we need to make sure we only add a section once
   * @param String sectionName
   */
  public boolean hasSection(String _section){
    for(String _s : sections){
      if(_section.equals(_s)) return true;
    }
    return false;
  }

  public void doDocumentation(KeyMap _km){

    // documentKeysMarkDown();
    // markDown.flush();
    // markDown.close();

    keyMapToJSON(_km);
    keyMapToMarkDown(_km);
    // addConfigToJSON();
    // miscInfoJSON();
    freelinerJSON.setJSONObject("modes", modesJSON);
    saveJSONObject(freelinerJSON, sketchPath()+"/data/webgui/freelinerData.json");
    println("**** Documentation Updated ****");
    markDown.flush();
    markDown.close();
  }

  // void miscInfoJSON(){
  //   // int _index = 0;
  //   JSONArray stuffArray = new JSONArray();
  //   JSONObject misc = new JSONObject();
  //   misc.setString("ip", getIP());
  //   stuffArray.append(misc);
  //   freelinerJSON.setJSONArray("misc", stuffArray);
  // }
  //
  // String getIP(){
  //   return Server.ip();
  // }

  // add modes to JSON data
  public void addModesToJSON(Mode[] _modes, char _key, Mode _parent){
    // int _index = 0;
    JSONArray modeArray = new JSONArray();
    for(Mode _m : _modes){
      JSONObject mode = new JSONObject();
      mode.setInt("index", _m.getIndex());
      //if(_key == 'a') mode.setInt("renderMode", _parent.getIndex());
      mode.setString("key", str(_key));
      mode.setString("name", _m.getName());
      mode.setString("description", _m.getDescription());
      modeArray.append(mode);
    }
    if(_key == 'a') modesJSON.setJSONArray(str(_key)+"_b"+_parent.getIndex(), modeArray);
    else modesJSON.setJSONArray(str(_key), modeArray);
  }

  public void addConfigToJSON(){
    Dummy  _dum = new Dummy();
    Field[] fields = _dum.getClass().getFields();
    for(Field _f : fields) {
      try {
        // if(_f.getType().equals(int.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
        // else if(_f.getType().equals(boolean.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
        // else if(_f.getType().equals(String.class)) javaScript.println("var "+_f.getName()+" = '"+_f.get(_dum)+"';");
      }
      catch (Exception _e){ println("Documenter : Field not reflected "+_f);}
    }
  }

  public void keyMapToJSON(KeyMap _km){
    JSONArray jsonKeyMap = new JSONArray();
    for(ParameterKey _pk : _km.getKeyMap()){
      if(_pk != null){
        JSONObject _jspk = new JSONObject();
        _jspk.setInt("ascii", PApplet.parseInt(_pk.getKey()));
        _jspk.setString("key", str(_pk.getKey()));
        _jspk.setInt("type", _pk.getType());
        _jspk.setString("name", _pk.getName());
        _jspk.setString("cmd", _pk.getCMD());
        _jspk.setInt("max", _pk.getMax());
        _jspk.setString("description", _pk.getDescription());
        jsonKeyMap.append(_jspk);
      }
    }
    freelinerJSON.setJSONArray("keys", jsonKeyMap);
  }

  public void addModesToMarkDown(Mode[] _modes, char _key, Mode _parent){
    // markDown.println("| "+_key+" |  for : "+_parent.getName()+" | Description |");
    // markDown.println("|:---:|---|---|");
    // int _index = 0;
    // for(Mode _m : _modes){
    //   markDown.println("| `"+_index+"` | "+_m.getName()+" | "+_m.getDescription()+" |");
    //   _index++;
    // }
    // markDown.println(" ");
  }


  /**
   * Creates markdown for keyboard shortcuts!
   */
  public void keyMapToMarkDown(KeyMap _km){
    String[] typeStrings = {"action","on off","on off + value","value","value","value","action"};
    // print keyboard type, osx? azerty?
    markDown.println("### keys ###");
    markDown.println("| key | parameter | type | description | cmd |");
    markDown.println("|:---:|---|---|---|---|");
    for(ParameterKey _pk : _km.getKeyMap()){
      if(_pk != null){
        int _k = (int)_pk.getKey();
        String _ctrlkey = (_k >= 65 && _k <=90) ? "ctrl-"+PApplet.parseChar(_k+32) : str(_pk.getKey());
        markDown.println("| `"+_ctrlkey+"` | "+
                              _pk.getName()+" |"+
                              typeStrings[_pk.getType()]+" |"+
                              _pk.getDescription()+" | `"+
                              _pk.getCMD()+"` |");
      }
    }
    markDown.println(" ");
  }
}


class Dummy implements FreelinerConfig{
  public Dummy(){}
}

/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class Easing extends Mode{

	public Easing(){}
	public Easing(int _ind){
		modeIndex = _ind;
		name = "easing";
		description = "ease the unti interval";
	}
	// passed seperatly cause I may want to ease other things than the unit interval
	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class NoEasing extends Easing {
	public NoEasing(int _ind){
		modeIndex = _ind;
		name = "linear";
		description = "Linear movement";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class Square extends Easing{
	public Square(int _ind){
		modeIndex = _ind;
		name = "square";
		description = "Power of 2.";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 2);
	}
}

class Sine extends Easing{
	public Sine(int _ind){
		modeIndex = _ind;
		name = "sine";
		description = "Sine ish";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin((_lrp)*PI);
	}
}

class Cosine extends Easing{
	public Cosine(int _ind){
		modeIndex = _ind;
		name = "cosine";
		description = "cosine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return cos(_lrp*PI);
	}
}

class Boost extends Easing{
	public Boost(int _ind){
		modeIndex = _ind;
		name = "boost";
		description = "half a sine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin((_lrp)*HALF_PI);
	}
}

class RandomUnit extends Easing{
	public RandomUnit(int _ind){
		modeIndex = _ind;
		name = "random";
		description = "random unitInterval every frame";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return random(1.0f);
	}
}

class Fixed extends Easing{
	float value;
	public Fixed(float _f, int _ind){
		modeIndex = _ind;
		value = _f;
		name = "fixed";
		description = "fixed at "+_f;
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return value;
	}
}

class EaseInOut extends Easing{

	public EaseInOut(int _ind){
		modeIndex = _ind;
		name = "EaseInOut";
		description = "Linera eas in and out";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
    if(_lrp < 0.5f)
      return _lrp *= 2;
    else
      return _lrp = -2*(_lrp-1.0f);
	}
}


class TargetNoise extends Easing{
	int target;
	int position;
	int frame;

	public TargetNoise(int _ind){
		modeIndex = _ind;
		target = 0;
		position = 0;
		frame = 0;
		name = "targetNoise";
		description = "fake audio response";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		// if new frame
		if(frame != frameCount){
			frame = frameCount;
			float ha = 10.0f+(abs(sin(PApplet.parseFloat(millis())/666))*5.0f);
			if(target < 0){
				position -= ha;
				if(position < target)
					target = abs(target);
				}
			else {
				position+=ha;
				if(position > target)
					target = PApplet.parseInt(-random(100)+20);
			}
			target = constrain(target, -100, 100);
		}
		return PApplet.parseFloat(position+100)/200.0f;
	}
}

class FixLerp extends Easing{
	public FixLerp(int _ind){
		modeIndex = _ind;
		name = "fixLerp";
		description = "is set to template's tp lerp AB 0.5";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return _rt.getFixLerp();
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class Enabler extends Mode{
	public Enabler(){}
	public Enabler(int _ind){
		modeIndex = _ind;
		name = "loop";
		description = "always render";
	}

	public boolean enable(RenderableTemplate _rt){
		return true;
	}
}

class Disabler extends Enabler{
	public Disabler(int _ind){
		modeIndex = _ind;
		name = "Disabler";
		description = "Never render";
	}

	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}

class Triggerable extends Enabler{
	public Triggerable(int _ind){
		modeIndex = _ind;
		name = "Triggerable";
		description = "only render if triggered";
	}
	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}

// something for triggerable but not from the seq


class RandomEnabler extends Enabler{
	public RandomEnabler(int _ind){
		modeIndex = _ind;
		name = "RandomEnabler";
		description = "Maybe render";
	}
	public boolean enable(RenderableTemplate _rt){
		if(_rt.getRandomValue()%6 == 1) return true;
		else return false;
	}
}



class SweepingEnabler extends Enabler{
	final float DIST = 200.0f;//float(width)/4.0;
	public SweepingEnabler(int _ind){
		modeIndex = _ind;
		name = "SweepingEnabler";
		description = "render per geometry from left to right";
	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x + DIST/2.0f;
		float tracker = _rt.getUnitInterval()*PApplet.parseFloat(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}

class SwoopingEnabler extends Enabler{
	final float DIST = 200.0f;//float(width)/4.0;
	public SwoopingEnabler(int _ind){
		modeIndex = _ind;
		name = "SwoopingEnabler";
		description = "render per geometry from right to left";
	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x - DIST/2.0f;
		float tracker = (-_rt.getUnitInterval()+1)*PApplet.parseFloat(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}

class StrobeEnabler extends Enabler{
	public StrobeEnabler(){}
	public StrobeEnabler(int _ind){
		modeIndex = _ind;
		name = "strobe enable";
		description = "very crunchy render, affected by miscValue";
	}

	public boolean enable(RenderableTemplate _rt){
		return (random(20+_rt.getMiscValue()) < 10);
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */




/**
 * ExternalGUI is a seperate PApplet launched by freeliner
 * aka the old gui, but we are keping it around because why not.
 */
public class ExternalGUI extends PApplet {

  // reference to the freeliner instance to control
  FreeLiner freeliner;
  CommandProcessor commandProcessor;
  // canvas to draw to, is needed to be passed to objects that need to draw.
  PGraphics canvas;
  // mouse cursor
  PVector cursor;
  // send keys from externalGUI to freeliner keyboard input
  boolean relayKeys = true;
  // externalGUI size, make sure you also change them in the settings() method
  final int GUI_WIDTH = 800;
  final int GUI_HEIGHT = 320;
  // ArrayList of widgets
  ArrayList<Widget> widgets;
  // the selected widget, aka the one that the cursor hovers
  Widget selectedWidget;

  boolean windowFocus;

  /**
   * Constructor,
   * @param Freeliner to control
   */
  public ExternalGUI(FreeLiner _fl){
    super();
    freeliner = _fl;
    commandProcessor = freeliner.getCommandProcessor();
    cursor = new PVector(0,0);
    windowFocus = true;
    widgets = new ArrayList();
    // InfoLine is the same info the regular GUI shows
    widgets.add(new InfoLine(new PVector(0,0), new PVector(GUI_WIDTH, 22), freeliner.getGui()));
    widgets.add(new SequenceGUI(new PVector(0, GUI_HEIGHT - 100),
                                new PVector(GUI_WIDTH, 100),
                                freeliner.getTemplateManager().getSequencer(),
                                freeliner.getTemplateManager().getTemplateList()));
    int _lp = 10;
    int _sz = 16;
    widgets.add(new Fader(new PVector(_lp,24+20), new PVector(128,_sz), "post shader 0"));
    widgets.add(new Fader(new PVector(_lp,48+20), new PVector(128,_sz), "post shader 1"));
    widgets.add(new Fader(new PVector(_lp,72+20), new PVector(128,_sz), "post shader 2"));
    widgets.add(new Fader(new PVector(_lp,96+20), new PVector(128,_sz), "post shader 3"));

    widgets.add(new Button(new PVector(256,24+20), new PVector(_sz,_sz), "post shader 0"));
    widgets.add(new Button(new PVector(256,48+20), new PVector(_sz,_sz), "post shader 1"));
    widgets.add(new Button(new PVector(256,72+20), new PVector(_sz,_sz), "post shader 2"));
    widgets.add(new Button(new PVector(256,96+20), new PVector(_sz,_sz), "post shader 3"));


    selectedWidget = null;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     PApplet Basics
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // your traditional sketch settings function
  public void settings(){
    size(GUI_WIDTH, GUI_HEIGHT, P2D);
    noSmooth();
  }

  // your traditional sketch setup function
  public void setup() {
    canvas = createGraphics(GUI_WIDTH, GUI_HEIGHT, P2D);
    canvas.textFont(font);
    surface.setResizable(false); // keep it pretty
    textMode(CORNER);
    hint(ENABLE_KEY_REPEAT); // usefull for performance
  }

  public void draw(){
    if(windowFocus != focused){
      freeliner.getKeyboard().forceRelease();
      windowFocus = focused;
    }
    background(50,50,50);
    // update the widgets with the mouse position
    if(!mousePressed) selectedWidget = null;
    for(Widget _wdgt : widgets){
      if(!mousePressed && _wdgt.update(cursor)) selectedWidget = _wdgt;
    }
    for(Widget _wdgt : widgets)
      commandProcessor.queueCMD(_wdgt.getCmd());



    // draw stuff
    canvas.beginDraw();
    canvas.clear();

    // display all the widgets
    for(Widget wdgt : widgets) wdgt.show(canvas);
    canvas.endDraw();
    image(canvas, 0, 0);
  }


  public void mouseMoved(){
    cursor.set(mouseX, mouseY);
  }

  public void mousePressed(){
    if(selectedWidget != null) selectedWidget.click(mouseButton);
  }

  public void mouseDragged(){
    cursor.set(mouseX, mouseY);
    if(selectedWidget != null) {
      selectedWidget.setCursor(cursor);
      selectedWidget.drag(mouseButton);
    }
  }

  public void keyPressed(){
    if(relayKeys) freeliner.getKeyboard().keyPressed(keyCode, key);
    if (key == 27) key = 0;       // dont let escape key, we need it :)
  }

  public void keyReleased(){
    if(relayKeys) freeliner.getKeyboard().keyReleased(keyCode, key);
  }
}
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
                byteSender = new ArtNetSender();
                setupByteBuffer(setup.getInt("universes")*512);
                byteSender.connect(setup.getString("host"));
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

    public void setupByteBuffer(int _size) {
        channelCount = _size;
        byteBuffer = new byte[channelCount]; // plus one for header
        for(byte _b : byteBuffer) _b = PApplet.parseByte(0);
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


    public void parseFixture(XML _xml) {
        //   for(XML)
    }

    // XML segment to RGBStrip fixture
    // in this case its /led START_ADR LED_COUNT
    public void segmentStrip(XML _seg) {
        String[] cmd = split(_seg.getString("txt"), " ");
        if(cmd[0].equals("/rgb") && cmd.length>1) {
            // println(cmd[1]);
            int addr = PApplet.parseInt(cmd[1]);
            Fixture _fix = new RGBPar(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.drawFixtureOverlay(overLayCanvas);
            fixtures.add(_fix);
            // println("Adding LEDs from: "+from+"  to: "+to);
            //   addRGBFixture(addr,(int)_seg.getFloat("aX"), (int)_seg.getFloat("aY"));
        } else if(cmd[0].equals("/aw") && cmd.length>1) {
            // println(cmd[1]);
            int addr = PApplet.parseInt(cmd[1]);
            Fixture _fix = new AWPar(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.drawFixtureOverlay(overLayCanvas);
            fixtures.add(_fix);
            // println("Adding LEDs from: "+from+"  to: "+to);
            //   addRGBFixture(addr,(int)_seg.getFloat("aX"), (int)_seg.getFloat("aY"));
        } else if(cmd[0].equals("/led") && cmd.length>2) {
            // println(cmd[1]);
            int addr = PApplet.parseInt(cmd[1])*3;
            int count = PApplet.parseInt(cmd[2]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            RGBStrip _fix;
            _fix = new RGBStrip(addr, count,
                                (int)_seg.getFloat("aX"),
                                (int)_seg.getFloat("aY"),
                                (int)_seg.getFloat("bX"),
                                (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        } else if(cmd[0].equals("/par5") && cmd.length>1) {
            // println(cmd[1]);
            int addr = PApplet.parseInt(cmd[1]);
            // println("Adding LEDs from: "+from+"  to: "+to);
            NetoParFive _fix;
            _fix = new NetoParFive(addr);
            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
                                // (int)_seg.getFloat("bX"),
                                // (int)_seg.getFloat("bY"));
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        } else if(cmd[0].equals("/matrix") && cmd.length > 3){
            ZigZagMatrix _fix;
            int _spacing = abs((int)_seg.getFloat("aY") - (int)_seg.getFloat("bY"));
            _fix = new ZigZagMatrix(PApplet.parseInt(cmd[1]), PApplet.parseInt(cmd[2]), PApplet.parseInt(cmd[3]), _spacing);
            println(PApplet.parseInt(cmd[1])+" "+PApplet.parseInt(cmd[2])+" "+PApplet.parseInt(cmd[3])+" "+_spacing);

            _fix.setPosition((int)_seg.getFloat("aX"),(int)_seg.getFloat("aY"));
            _fix.init();
            fixtures.add(_fix);
            _fix.drawFixtureOverlay(overLayCanvas);
        }
    }

    public void addRGBFixture(int _adr, int _x, int _y) {
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
        if(testChannel >= 0){
            byteBuffer[testChannel*3] = 0;
            byteBuffer[testChannel*3+1] = 0;
            byteBuffer[testChannel*3+2] = 0;
        }
        if( _chan < byteBuffer.length){
            testValue = (byte)_val;
            testChannel = (byte)_chan;
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

    public void debugBuffer() {
        if(byteBuffer == null) return;
        println("|---------------------------------------------------=");
        for(int i = 0; i < 512; i++) {
            print(" ("+i+" -> "+PApplet.parseInt(byteBuffer[i])+") ");
            if(i%8 == 1) println();
        }
        println(" ");
        println("|---------------------------------------------------=");
    }

    public void listFixtures() {
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

    public void parseGraphics(PGraphics _pg) {
        _pg.loadPixels();

        for(Fixture _fix : fixtures)
            _fix.parseGraphics(_pg);
    }

    public void updateBuffer() {
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

    // public void subFixturesParseGraphics(PGraphics _pg){
    //     if(subFixtures != null){
    //         for(Fixture _fix : subFixtures){
    //             if(_fix != null)_fix.parseGraphics(_pg);
    //         }
    //     }
    // }
    // to override
    public void drawFixtureOverlay(PGraphics _pg) {

    }

    public void bufferChannels(byte[] _buff) {
        for(int i = 0; i < channelCount; i++) {
            // println(address+i+" -> "+int(buffer[i]));
            if(address+i < _buff.length) _buff[address+i] = buffer[i];
        }
    }

    public void setPosition(int _x, int _y) {
        position.set(_x, _y);
    }

    public void setChannelManual(int _chan, int _val) {
        int _c = _chan - address;
        if(_c < channelCount && _c >= 0) buffer[_c] = PApplet.parseByte(_val);
    }

    public int getAddress() {
        return address;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public PVector getPosition() {
        return position.get();
    }
    public ArrayList<Fixture> getSubFixtures() {
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
        float gap = 1.0f/(_cnt-1);
        int ind;
        int x;
        int y;
        RGBFixture _fix;
        int _adr = 0;
        for(int i = 0; i < _cnt; i++) {
            ind = PApplet.parseInt(lerp(0, _cnt, i*gap));
            x = PApplet.parseInt(lerp(_ax, _bx, i*gap));
            y = PApplet.parseInt(lerp(_ay, _by, i*gap));
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
    public void drawFixtureOverlay(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.drawFixtureOverlay(_pg);
    }

    public void bufferChannels(byte[] _buff) {
        for(Fixture _fix : subFixtures)
            _fix.bufferChannels(_buff);
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
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     RGBFixture
///////
////////////////////////////////////////////////////////////////////////////////////

// a base class for RGB fixture.
class RGBFixture extends Fixture {
    boolean correctGamma = true;
    int col;
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
        int ind = PApplet.parseInt(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // override
    public void drawFixtureOverlay(PGraphics _pg) {
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
    public void setColor(int _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[0] = PApplet.parseByte(correctGamma ? red : gammatable[red]);
        buffer[1] = PApplet.parseByte(correctGamma ? green : gammatable[green]);
        buffer[2] = PApplet.parseByte(correctGamma ? blue : gammatable[blue]);
        // println(buffer[0]+" "+buffer[1]+" "+buffer[2]);
    }

    public int getColor() {
        return col;
    }

    public int getX() {
        return PApplet.parseInt(position.x);
    }
    public int getY() {
        return PApplet.parseInt(position.y);
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
    boolean correctGamma = true;
    int col;
    public RGBPar(int _adr) {
        super(_adr);
        name = "RGBAWPar";
        description = "a RGB light fixture";
        channelCount = 3;
        address = _adr;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
    }
    public void parseGraphics(PGraphics _pg) {
        if(_pg == null) return;
        int ind = PApplet.parseInt(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // RGBFixture specific
    public void setColor(int _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[0] = PApplet.parseByte(correctGamma ? red : gammatable[red]);
        buffer[1] = PApplet.parseByte(correctGamma ? green : gammatable[green]);
        buffer[2] = PApplet.parseByte(correctGamma ? blue : gammatable[blue]);
    }
    // override
    public void drawFixtureOverlay(PGraphics _pg) {
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
    int col;
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
        int ind = PApplet.parseInt(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }
    // RGBFixture specific
    public void setColor(int _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        // int blue = col & 0xFF;
        buffer[0] = PApplet.parseByte(correctGamma ? red : gammatable[red]);
        buffer[1] = PApplet.parseByte(correctGamma ? green : gammatable[green]);
        // buffer[2] = byte(correctGamma ? blue : gammatable[blue]);
    }
    // override
    public void drawFixtureOverlay(PGraphics _pg) {
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
            _fix = new RGBWStrip(_adr, 5, PApplet.parseInt(position.x), PApplet.parseInt(position.y+(i*_gap)), PApplet.parseInt(position.x)+MPANEL_SIZE, PApplet.parseInt(position.y+(i*_gap)));
            subFixtures.add(_fix);
        }
    }

    public void parseGraphics(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.parseGraphics(_pg);
    }

    // override
    public void drawFixtureOverlay(PGraphics _pg) {
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

        buffer[1] = PApplet.parseByte(127);
        buffer[15] = PApplet.parseByte(255);
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
    boolean correctGamma = true;
    int col;

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
        int ind = PApplet.parseInt(position.x + (position.y*_pg.width));
        int max = _pg.width*_pg.height;
        if(ind < max) setColor(_pg.pixels[ind]);
    }

    // RGBFixture specific
    public void setColor(int _c) {
        col = _c;
        int red = (col >> 16) & 0xFF;
        int green = (col >> 8) & 0xFF;
        int blue = col & 0xFF;
        buffer[0] = PApplet.parseByte(255);
        if(red == green && green == blue) {
            buffer[1] = 0;
            buffer[2] = 0;
            buffer[3] = 0;
            buffer[4] = PApplet.parseByte(correctGamma ? red : gammatable[red]);
        } else {
            buffer[1] = PApplet.parseByte(correctGamma ? red : gammatable[red]);
            buffer[2] = PApplet.parseByte(correctGamma ? green : gammatable[green]);
            buffer[3] = PApplet.parseByte(correctGamma ? blue : gammatable[blue]);
            buffer[4] = 0;
        }
    }
    // override
    public void drawFixtureOverlay(PGraphics _pg) {
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
///////     WS2812 8X32 zigzag
///////
////////////////////////////////////////////////////////////////////////////////////

class ZigZagMatrix extends Fixture {
    boolean correctGamma = true;
    int col;
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
        matrixSpacing = _spacing;
        buffer = new byte[channelCount];
        position = new PVector(0,0);
        subFixtures = new ArrayList<Fixture>();

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
                    _fix.setPosition(PApplet.parseInt(position.x + i* _gap), PApplet.parseInt(position.y + matrixHeight*_gap - _gap - j* _gap));
                }
                else {
                    _fix.setPosition(PApplet.parseInt(position.x + i* _gap), PApplet.parseInt(position.y + j* _gap));
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
    public void drawFixtureOverlay(PGraphics _pg) {
        for(Fixture _fix : subFixtures)
            _fix.drawFixtureOverlay(_pg);
    }

    public void bufferChannels(byte[] _buff) {
        for(Fixture _fix : subFixtures)
            _fix.bufferChannels(_buff);
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * Main class for alc_freeliner
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */
class FreeLiner implements FreelinerConfig {
    // model
    GroupManager groupManager;
    TemplateManager templateManager;
    // view
    TemplateRenderer templateRenderer;
    CanvasManager canvasManager; // new!
    Gui gui;
    GUIWebServer guiWebServer;
    // control
    Mouse mouse;
    Keyboard keyboard;
    KeyMap keyMap;
    // new parts
    CommandProcessor commandProcessor;
    OSCCommunicator oscComs;
    WebSocketCommunicator webComs;

    // misc
    boolean windowFocus;
    PApplet applet;

    PShader fisheye;

    public FreeLiner(PApplet _pa, int _pipeline) {
        applet = _pa;
        // instantiate
        // model
        groupManager = new GroupManager();
        templateManager =  new TemplateManager();
        // view
        templateRenderer = new TemplateRenderer();
        gui = new Gui();
        // pick a rendering system
        println("PIPELINE : "+_pipeline);
        if(_pipeline == 0) canvasManager = new ClassicCanvasManager(applet, gui.getCanvas());
        else if(_pipeline == 1) canvasManager = new LayeredCanvasManager(applet, gui.getCanvas());
        // control
        mouse = new Mouse();
        keyboard = new Keyboard();
        commandProcessor = new CommandProcessor();
        guiWebServer = new GUIWebServer(applet);
        // osc + webSocket
        oscComs = new OSCCommunicator(applet, commandProcessor);
        webComs = new WebSocketCommunicator(applet, commandProcessor);

        keyMap = new KeyMap();

        // inject dependence
        mouse.inject(groupManager, keyboard);
        keyboard.inject(this);
        gui.inject(groupManager, mouse);
        templateManager.inject(groupManager);
        groupManager.inject(templateManager);
        commandProcessor.inject(this);
        canvasManager.inject(templateRenderer);
        canvasManager.inject(commandProcessor);
        canvasManager.inject(templateManager.getSynchroniser());

        // canvasManager.setGuiCanvas(gui.getCanvas());
        templateRenderer.inject(commandProcessor);
        templateRenderer.inject(groupManager);

        // once all injected setup layers
        canvasManager.setup();

        windowFocus = true;

        keyMap.setLimits(documenter.modeLimits);
        documenter.doDocumentation(keyMap);
        if(DOME_MODE) {
            fisheye = loadShader(dataPath(PATH_TO_SHADERS)+"/"+"fisheye.glsl");
            fisheye.set("aperture", 180.0f);
            shader(fisheye);
        }
        // commandProcessor.queueCMD("colormap colorMap.png");
    }

    // sync message to other software
    public void oscTick() {
        oscComs.send("freeliner tick");
    }

    /**
     * It all starts here...
     */
    public void update() {
        //autoSave();

        // windowFocus
        if(windowFocus != focused) {
            keyboard.forceRelease();
            windowFocus = focused;
        }
        gui.update();
        commandProcessor.update();
        // update template models
        templateManager.update();
        templateManager.launchLoops();//groupManager.getGroups());

        // get templates to render
        ArrayList<RenderableTemplate> _toRender = new ArrayList(templateManager.getLoops());
        _toRender.addAll(templateManager.getEvents());

        canvasManager.render(_toRender);
    }

    // its a dummy for FreelinerLED
    public void reParse() { }
    // its a dummy for others
    public void toggleExtraGraphics() {}

    // need to make this better.
    private void autoSave() {
        if(frameCount % 1000 == 1) {
            // commandProcessor.processCMD("geom save userdata/autoSaveGeometry.xml");
            // commandProcessor.processCMD("tp save userdata/autoSaveTemplates.xml");
            // println("Autot saved");
        }
    }

    public void processCMD(String _cmd) {
        commandProcessor.processCMD(_cmd);
    }

    public void queueCMD(String _cmd) {
        commandProcessor.queueCMD(_cmd);
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Configure stuff
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void configure(String _param, int _v) {
        println("CONFIGURNING NOT ENABLED");
        // XML _file;
        // try {
        //     _file = loadXML(sketchPath()+"/data/userdata/configuration.xml");
        // } catch(Exception e) {
        //     _file = new XML("freelinerConfiguration");
        // }
        // _file.setInt(_param, _v);
        // saveXML(_file, sketchPath()+"/data/userdata/configuration.xml");
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // getFilesFrom("/shaders", ".glsl");
    public ArrayList<String> getFilesFrom(String _dir, String _type){
        ArrayList<String> _files = new ArrayList<String>();
        File _directory = new File(dataPath(_dir));
        File[] _list = _directory.listFiles();
        for (File _file : _list) {
            if (_file.isFile()) {
                if(_file.getName().contains(_type)){
                    _files.add(_file.getName());
                }
            }
        }
        return _files;
    }

    public KeyMap getKeyMap() {
        return keyMap;
    }

    public Mouse getMouse() {
        return mouse;
    }

    public Keyboard getKeyboard() {
        return keyboard;
    }

    public Gui getGui() {
        return gui;
    }

    public GroupManager getGroupManager() {
        return groupManager;
    }

    public TemplateManager getTemplateManager() {
        return templateManager;
    }

    public TemplateRenderer getTemplateRenderer() {
        return templateRenderer;
    }

    public CommandProcessor getCommandProcessor() {
        return commandProcessor;
    }

    public CanvasManager getCanvasManager() {
        return canvasManager;
    }

    public PGraphics getCanvas() {
        return canvasManager.getCanvas();
    }
    public OSCCommunicator getOscCommunicator() {
        return oscComs;
    }
    public WebSocketCommunicator getWebCommunicator() {
        return webComs;
    }
    public GUIWebServer getGUIWebServer() {
        return guiWebServer;
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Debug
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    private void printStatus() {
        //merp
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



/**
 * Manage segmentGroups!
 *
 */
class GroupManager implements FreelinerConfig{

    // guess we will add this too.
    TemplateManager templateManager;
    //manages groups of points
    ArrayList<SegmentGroup> groups;
    ArrayList<SegmentGroup> sortedGroups;

    int groupCount = 0;
    //selects groups to control, -1 for not selected
    int selectedIndex;
    int lastSelectedIndex;
    int snappedIndex;
    int snapDist = 15;
    // list of PVectors that are snapped
    ArrayList<PVector> snappedList;
    Segment snappedSegment;

    ArrayList<Segment> commandSegments;

    int testChannel = -1;
    int ledStart = 0;

    /**
     * Constructor, inits default values
     */
    public GroupManager() {
        groups = new ArrayList();
        sortedGroups = new ArrayList();

        snappedList = new ArrayList();
        groupCount = 0;
        selectedIndex = -1;
        lastSelectedIndex = -1;
        snappedIndex = -1;
        snappedSegment = null;
        // first group for gui text
        newGroup();
        // second group for reference group
        newGroup();
        // reselect group 0 to begin
        selectedIndex = 0;
        commandSegments = null;
    }


    public void inject(TemplateManager _tm) {
        templateManager = _tm;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     should not be here but whatever
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public int setTestChannel(int _i) {
        if(testChannel == 0 && _i == -2) testChannel = -1;
        else testChannel = numTweaker(_i, testChannel);
        return testChannel;
    }

    public void setChannel(){
        if(getSnappedSegment() == null){
            ledStart = testChannel;
            println("start = "+ledStart);
        }
        else{
            println("end = "+ledStart);
            setText("/led "+ledStart+" "+testChannel);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Create a new group.
     */
    public int newGroup() {
        groups.add(new SegmentGroup(groupCount));
        selectedIndex = groupCount;
        groupCount++;
        sortGeometry();
        return selectedIndex;
    }

    /**
     * Tab the focus through groups.
     * @param boolean reverse direction (shift+tab)
     */
    public void tabThrough(boolean _shift) {
        if(!isFocused()) selectedIndex = lastSelectedIndex;
        else if (_shift) selectedIndex--;
        else selectedIndex++;
        selectedIndex = wrap(selectedIndex, groupCount-1);
        // update ref.
        if(getSelectedGroup() != null)
            setReferenceGroupTemplateList(getSelectedGroup().getTemplateList());

    }

    /**
     * Add an other renderer to all groups who have the first renderer.
     * @param renderer to add
     * @param renderer to match
     */
    public void groupAddTemplate(TweakableTemplate _toMatch, TweakableTemplate _toAdd) {
        if(groups.size() > 0 && _toAdd != null && _toMatch != null) {
            for (SegmentGroup sg : groups) {
                TemplateList _tl = sg.getTemplateList();
                if(_tl != null)
                    if(_tl.contains(_toMatch))
                        _tl.toggle(_toAdd);
            }
        }
    }

    /**
     * Similar to groupAddTemplate, but a direct swap.
     * @param Template to swap
     * @param renderer to swap with
     */
    public void groupSwapTemplate(TweakableTemplate _a, TweakableTemplate _b) {
        if(groups.size() > 0 && _a != null && _b != null) {
            for (SegmentGroup sg : groups) {
                TemplateList tl = sg.getTemplateList();
                if(tl != null) {
                    if(tl.contains(_a) || tl.contains(_b)) {
                        tl.toggle(_a);
                        tl.toggle(_b);
                    }
                }
            }
        }
    }

    public void toggleTemplate(TweakableTemplate _tp, int _ind) {
        SegmentGroup _sg = getGroup(_ind);
        if(_sg != null && _tp != null) _sg.getTemplateList().toggle(_tp);
    }

    /**
     * Snap puts all the PVectors that are near the position given into a arrayList.
     * The snapDist can be adjusted like anything else.
     * It returns the place it snapped to to adjust cursor.
     * @param PVector of the cursor
     * @return PVector where it snapped.
     */
    public PVector snap(PVector _pos) {
        PVector snap = new PVector(0, 0);
        snappedList.clear();
        snappedIndex = -1;
        snappedSegment = null;
        ArrayList<Segment> segs;
        for (int i = 0; i < groupCount; i++) {
            segs = groups.get(i).getSegments();
            // check if snapped to center
            if(_pos.dist(groups.get(i).getCenter()) < snapDist) {
                snappedList.add(groups.get(i).getCenter());
                snap = groups.get(i).getCenter();
                snappedIndex = i;
            }
            for(Segment seg : segs) {
                if(_pos.dist(seg.getPointA()) < snapDist) {
                    snappedList.add(seg.getPointA());
                    snap = seg.getPointA();
                    snappedIndex = i;
                } else if(_pos.dist(seg.getPointB()) < snapDist) {
                    snappedList.add(seg.getPointB());
                    snap = seg.getPointB();
                    snappedIndex = i;
                } else if (_pos.dist(seg.getMidPoint()) < snapDist) {
                    snappedSegment = seg;
                    snap = seg.getMidPoint();
                    snappedIndex = i;
                }
            }
        }
        if (snappedIndex != -1) {
            if(selectedIndex == -1) lastSelectedIndex = snappedIndex;
            return snap;// snappedList.get(0);
        } else return _pos;
    }


    public void unSnap() {
        snappedList.clear();
        snappedIndex = -1;
        snappedSegment = null;
    }
    /**
     * Nudge all PVectors of the snappedList.
     * If the snapped list is empty and we are focused on a group, nudge the segmentStart.
     * @param boolean verticle/horizontal
     * @param int direction (1 or -1)
     * @param boolean nudge 10X more
     */
    public void nudger(Boolean axis, int dir, boolean _shift) {
        PVector ndg = new PVector(0, 0);
        if(_shift) dir*=10;
        if (axis) ndg.set(dir, 0);
        else ndg.set(0, dir);
        if(snappedList.size()>0) {
            for(PVector _pv : snappedList) {
                _pv.add(ndg);
            }
            //setCenter(center);
            reCenter();
        } else if(isFocused()) getSelectedGroup().nudgeSegmentStart(ndg);
    }

    public void drag(PVector _pos) {
        if(snappedList.size()>0) {
            for(PVector _pv : snappedList) {
                _pv.set(_pos);
            }
            //setCenter(center);
            reCenter();
        }
    }

    private void reCenter() {
        for(SegmentGroup sg : groups) {
            if(sg.isCentered()) sg.placeCenter(sg.getCenter());
            sg.updateGeometry();
            //else sg.placeCenter(sg.getSegmentStart());
        }
    }

    private void deleteSegment() {
        if(snappedSegment == null || getSelectedGroup() == null) return;
        getSelectedGroup().deleteSegment(snappedSegment);
        snappedSegment = null;
        snappedIndex = -1;
    }

    private void hideSegment() {
        if(snappedSegment == null) return;
        snappedSegment.toggleHidden();
    }


    public int geometryPriority(SegmentGroup _sg, int _v) {
        if(_sg == null) return 0;
        int _ha = _sg.tweakPriority(_v);
        sortGeometry();
        return _ha;
    }

    public int geometryPriority(int _order){
        SegmentGroup _sg = getSelectedGroup();
        if(_sg != null){
            return geometryPriority(_sg, _order);
        }
        return 0;
    }

    public int geometryPriority(int _geom, int _order){
        SegmentGroup _sg = getGroup(_geom);
        if(_sg != null){
            return geometryPriority(_sg, _order);
        }
        return 0;
    }

    public int geometryPriority(String _tags, int _order){
        ArrayList<TweakableTemplate> _temps = templateManager.getTemplates(_tags);
        // println(_tags+" "+_temps.size());
        int _val = 0;
        if(_temps == null){
            return geometryPriority(_order);
        }
        else if(_temps.size() == 0){
            return geometryPriority(_order);
        }
        else {
            for(SegmentGroup _sg : groups){
                TemplateList _list = _sg.getTemplateList();
                for(TweakableTemplate _tp : _temps){
                    if(_list.contains(_tp)){
                        _val = geometryPriority(_sg, _order);
                    }
                }
            }
        }
        return _val;
    }

    public void sortGeometry(){
        sortedGroups.clear();
        int _level = 0;
        while(sortedGroups.size() < groups.size()){
            for(SegmentGroup _sg : groups){
                if(_sg.getPriority() == _level){
                    sortedGroups.add(_sg);
                }
            }
            _level++;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     CMD segments
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void updateCmdSegments() {
        commandSegments = new ArrayList<Segment>();
        ArrayList<Segment> _segs;
        for(SegmentGroup _sg : groups) {
            if(!_sg.isEmpty()) {
                _segs = _sg.getSegments();
                if(_segs.get(0).getText().equals("/cmd")) {
                    for(Segment _seg : _segs)
                        commandSegments.add(_seg);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Save and load
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // argumentless
    public void saveGroups() {
        saveGroups("geometry.xml");
    }

    public void saveGroups(String _fn) {
        XML groupData = new XML("groups");
        for(SegmentGroup grp : groups) {
            groupData.setInt("width", width);
            groupData.setInt("height", height);

            if(grp.isEmpty()) continue;
            XML xgroup = groupData.addChild("group");
            xgroup.setInt("ID", grp.getID());
            xgroup.setString("text", grp.getText());

            if(grp.getID() == 0) xgroup.setString("type", "gui");
            else if(grp.getID() == 1) xgroup.setString("type", "ref");
            else xgroup.setString("type", "map");

            xgroup.setFloat("centerX", grp.getCenter().x);
            xgroup.setFloat("centerY", grp.getCenter().y);
            xgroup.setInt("centered", PApplet.parseInt(grp.isCentered()));
            xgroup.setString("tags", grp.getTemplateList().getTags());
            for(Segment seg : grp.getSegments()) {
                XML xseg = xgroup.addChild("segment");
                xseg.setFloat("aX",seg.getPointA().x);
                xseg.setFloat("aY",seg.getPointA().y);
                xseg.setFloat("bX",seg.getPointB().x);
                xseg.setFloat("bY",seg.getPointB().y);
                // for leds and such
                xseg.setString("txt",seg.getText());
            }
            saveXML(groupData, dataPath(PATH_TO_GEOMETRY)+"/"+_fn);
        }
    }

    public void loadGeometry() {
        loadGeometry("geometry.xml");
    }

    public void loadGeometry(String _file) {
        String[] _fn = split(_file, '.');
        if(_fn.length < 2) println("I dont know what kind of file this is : "+_file);
        else if(_fn[1].equals("svg")) loadGeometrySVG(_file);
        else if(_fn[1].equals("xml")) loadGeometryXML(_file);
    }

    // what a mess what a mess
    // we cant have that we cant have that
    // clean it up clean it up
    public void loadGeometryXML(String _fn) {
        XML file;
        try {
            file = loadXML(dataPath(PATH_TO_GEOMETRY)+"/"+_fn);
        } catch (Exception e) {
            println(_fn+" cant be loaded");
            return;
        }
        int sourceWidth = file.getInt("width");
        int sourceHeight = file.getInt("height");
        // println("ahhahah "+sourceWidth+ " "+sourceHeight);

        XML[] groupData = file.getChildren("group");
        PVector posA = new PVector(0,0);
        PVector posB = new PVector(0,0);
        PVector _offset = new PVector(0,0);
        if(sourceWidth != 0 && sourceHeight != 0) {
            _offset.sub(new PVector(sourceWidth/2, sourceHeight/2));
            _offset.add(new PVector(width/2, height/2));
        }
        for(XML xgroup : groupData) {

            if(xgroup.getString("type").equals("gui")) selectedIndex = 0;
            else if(xgroup.getString("type").equals("ref")) selectedIndex = 1;
            else newGroup();

            XML[] xseg = xgroup.getChildren("segment");
            Segment _seg;
            for(XML seg : xseg) {
                posA.set(seg.getFloat("aX"), seg.getFloat("aY"));
                posB.set(seg.getFloat("bX"), seg.getFloat("bY"));
                posA.add(_offset);
                posB.add(_offset);
                _seg = new Segment(posA.get(), posB.get());
                _seg.setText(seg.getString("txt"));
                getSelectedGroup().addSegment(_seg);
            }
            getSelectedGroup().mouseInput(LEFT, posB);
            // //getSelectedGroup().setNeighbors();
            // getSelectedGroup().updateGeometry();
            posA.set(xgroup.getFloat("centerX"), xgroup.getFloat("centerY"));
            posA.add(_offset);
            String _tags = xgroup.getString("tags");
            if(_tags.length()>0) {
                for(int i = 0; i < _tags.length(); i++) {
                    getSelectedGroup().getTemplateList().toggle(templateManager.getTemplate(_tags.charAt(i)));
                }
            }
            String _txt = xgroup.getString("text");
            if(_txt != null) getSelectedGroup().setText(_txt);
            // bug with centering? seems ok...
            //println(getSelectedGroup().sortedSegments.size());
            if(abs(posA.x - getSelectedGroup().getSegment(0).getPointB().x) > 2) getSelectedGroup().placeCenter(posA);
            if(!PApplet.parseBoolean(xgroup.getInt("centered"))) getSelectedGroup().unCenter();
        }
    }

    ///////////////////////// SVG

    public void loadGeometrySVG(String _fn) {
        PShape _shp;
        try {
            _shp = loadShape(dataPath(PATH_TO_VECTOR_GRAPHICS)+"/"+_fn);
        } catch (Exception e) {
            println(_fn+" cant be loaded");
            println(dataPath(PATH_TO_VECTOR_GRAPHICS)+"/"+_fn);
            return;
        }
        // PVector _offset = getInkscapeTransform(sketchPath()+"/data/userdata/"+_fn);
        PVector _offset = new PVector(0,0);
        _offset.sub(new PVector(_shp.width/2, _shp.height/2));
        _offset.add(new PVector(width/2, height/2));
        addSvgShapes(_shp, _offset.get());
    }

    // recursively add children
    public void addSvgShapes(PShape _shp, PVector _offset) {
        for(PShape _child : _shp.getChildren()) {
            if(_child.getVertexCount() != 0)
                if(_child.getFamily() == PShape.PATH)
                    if(_child.getKind() == 0)
                        shapeToGroup(_child, _offset);

            if(_child.getChildCount() != 0) addSvgShapes(_child, _offset);
        }
    }

    public void shapeToGroup(PShape _shp, PVector _offset) {
        newGroup();
        println("------------addingShape with "+_shp.getVertexCount()+" vertices------------");
        Segment _seg;
        ArrayList<PVector> _vertices = new ArrayList();
        PVector posA = new PVector(0,0);
        PVector posB = new PVector(0,0);

        for(int i = 0; i < _shp.getVertexCount()-1; i++) {
            posA = _shp.getVertex(i).get();
            posB = _shp.getVertex(i+1).get();
            posA.add(_offset);
            posB.add(_offset);
            _vertices.add(posA);
            _seg = new Segment(posA.get(), posB.get());
            getSelectedGroup().addSegment(_seg);
            print(posA.x+","+posA.y+" to "+posB.x+","+posB.y);
        }
        _vertices.add(posB);

        if(_shp.isClosed()) {
            posA = posB.get();
            posB = _shp.getVertex(0).get();
            posB.add(_offset);
            _seg = new Segment(posA.get(), posB.get());
            getSelectedGroup().addSegment(_seg);
            // getSelectedGroup().placeCenter(posB);
        }
        //place center
        getSelectedGroup().placeCenter(shapeCenter(_vertices));
        if(!_shp.isClosed()) getSelectedGroup().unCenter();
        getSelectedGroup().getTemplateList().toggle(templateManager.getTemplate('Z'));
        println();
    }

    public PVector shapeCenter(ArrayList<PVector> _vertices) {
        PVector _adder = new PVector(0,0);
        for(PVector _pv : _vertices) _adder.add(_pv);
        _adder.div(_vertices.size());
        return _adder;
    }

    // inkscape had an annoying transform thing
    public PVector getInkscapeTransform(String _fn) {
        PVector _offset = new PVector(0,0);
        XML _xml = loadXML(_fn);
        for(XML _child : _xml.getChildren()) {
            String _tf = _child.getString("transform");
            if(_tf != null) {
                String[] _splt = split(_tf, "(");
                if(_splt[0].equals("translate")) {
                    _tf = _splt[1].replaceAll("\\)", "");
                    String[] _xy = split(_tf, ',');
                    _offset.set(stringFloat(_xy[0]), stringFloat(_xy[1]));
                }
            }
        }
        return _offset;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Unselect selected group
     */
    public void unSelect() {
        lastSelectedIndex = selectedIndex;
        selectedIndex = -1;
    }

    /**
     * Adjust the snapping distance.
     * @param int adjustement to make
     * @return int new value
     */
    public int setSnapDist(int _i) {
        snapDist = numTweaker(_i, snapDist);
        return snapDist;
    }

    public void setText(int _grp, int _seg, String _txt) {
        SegmentGroup group = getGroup(_grp);
        if(group == null) return;
        Segment seg = group.getSegment(_seg);
        if(seg == null) return;
        seg.setText(_txt);
        updateCmdSegments();
    }

    public void setText(int _grp, String _txt) {
        SegmentGroup group = getGroup(_grp);
        if(group == null) return;
        group.setText(_txt);
        updateCmdSegments();
    }

    public void setText(String _txt) {
        if(getSnappedSegment() != null) getSnappedSegment().setText(_txt);
        else if(getSelectedGroup() != null) getSelectedGroup().setText(_txt);
        updateCmdSegments();

    }

    public void setReferenceGroupTemplateList(TemplateList _tl) {
        groups.get(1).setTemplateList(_tl);
    }

    public boolean toggleCenterPutting() {
        if(!isFocused()) return false;
        else return getSelectedGroup().toggleCenterPutting();
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Get renderList of the selected group, null if no group selected.
     * @return renderList
     */
    public TemplateList getTemplateList() {
        SegmentGroup _sg = getSelectedGroup();
        if(_sg != null) {
            if(_sg.getID() == 1) return null; // to prevent ref group from getting templates, could do it for the gui too.
            else return _sg.getTemplateList();
        } else return null;
    }

    /**
     * Check if a group is focused
     * @return boolean
     */
    public boolean isFocused() {
        // if(!focused) return false;
        if(snappedIndex != -1 || selectedIndex != -1) return true;
        else return false;
    }

    /**
     * Get the selectedGroupIndex, will return -1 if nothing selected, used by gui
     * @return int index
     */
    public int getSelectedIndex() {
        return selectedIndex;
    }

    /**
     * Get the selectedGroup, or the snapped one, or null
     * @return SegmentGroup
     */
    public SegmentGroup getSelectedGroup() {
        if(snappedIndex != -1 && selectedIndex == -1) return groups.get(snappedIndex);
        else if(selectedIndex != -1 && selectedIndex <= groupCount) return groups.get(selectedIndex);
        else return null;
    }

    /**
     * Get the previously selected group, or null
     * Used to set the previously selected group as a renderer's custom shape.
     * @return SegmentGroup
     */
    public SegmentGroup getLastSelectedGroup() {
        if(lastSelectedIndex != -1 ) return groups.get(lastSelectedIndex);
        else return null;
    }

    /**
     * Get a specific group
     * @return SegmentGroup
     */
    public SegmentGroup getGroup(int _i) {
        if(_i >= 0 && _i < groupCount) return groups.get(_i);
        else return null;
    }

    /**
     * Get all the groups
     * @return SegmentGroup
     */
    public ArrayList<SegmentGroup> getGroups() {
        return groups;
    }

    public ArrayList<SegmentGroup> getSortedGroups() {
        return sortedGroups;
    }


    /**
     * Get groups with a certain template
     * @return SegmentGroup arrayList
     */
    public ArrayList<SegmentGroup> getGroups(TweakableTemplate _tp) {
        ArrayList<SegmentGroup> _groups = new ArrayList();
        for(SegmentGroup _sg : groups) {
            if(_sg.getTemplateList().contains(_tp)) _groups.add(_sg);
        }
        return _groups;
    }



    /**
     * Get the snappedSegment
     * @return Segment
     */
    public Segment getSnappedSegment() {
        return snappedSegment;
    }

    /**
     * Get the last point of a group
     * @return SegmentGroup
     */
    public PVector getPreviousPosition() {
        if (isFocused()) return getSelectedGroup().getLastPoint();
        else return new PVector(width/2, height/2, 0);
    }

    public ArrayList<Segment> getCommandSegments() {
        return commandSegments;
    }
}


class GroupPainter extends Painter{

	public GroupPainter(){

	}

	public void paintGroup(RenderableTemplate _rt){
		super.paint(_rt);
	}

}


class Filler extends GroupPainter{
	public Filler(int _ind){
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float angle = _rt.getAngleMod();  //getRotationMode()*(_rt.getLerp()*TWO_PI);
		float lorp = 1-_rt.getLerp();
		lorp*=lorp;
		PVector center = _rt.getSegmentGroup().getCenter();
		PShape shpe = _rt.getSegmentGroup().getShape();

		float weight = event.getStrokeWeight();
		shpe.setStrokeWeight(weight/lorp);

		canvas.pushMatrix();
		applyColor(shpe);
		canvas.translate(center.x, center.y);
		canvas.rotate(angle);
		canvas.scale(lorp);
		canvas.shape(shpe, -center.x, -center.y);
		canvas.popMatrix();
	}
}


class InterpolatorShape extends GroupPainter{
	public InterpolatorShape(int _ind){
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		applyStyle(canvas);
		canvas.beginShape();
		PVector pos = new PVector(0,0);
		PVector pa = new PVector(0,0);
		boolean first = true;
		for(Segment _seg : event.getSegmentGroup().getSegments()){
			pos = getPosition(_seg);
			if(first){
				first = false;
				pa = pos.get();
			}
			canvas.vertex(pos.x, pos.y);
		}
		canvas.vertex(pa.x, pa.y);
		canvas.endShape(CLOSE);
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * The gui class draws various information to a PGraphics canvas.
 *
 * <p>
 * All grafical user interface stuff goes here.
 * </p>
 *
 * @see SegmentGroup
 */

class Gui implements FreelinerConfig {

    // depends on a group manager and a mouse
    GroupManager groupManager;
    Mouse mouse;
    // SegmentGroup used to display information, aka group 0
    SegmentGroup guiSegments;
    SegmentGroup refSegments;

    // canvas for all the GUI elements.
    PGraphics canvas;
    // PShape of the crosshair cursor
    PShape crosshair;

    // for displaying segment direction
    PShape arrow;

    //gui and line placing
    boolean showGui;
    boolean viewLines;
    boolean viewTags;
    boolean viewCursor;

    // reference gridSize and grid canvas, gets updated if the mouse gridSize changes.
    int gridSize = DEFAULT_GRID_SIZE;
    PShape grid;

    // for auto hiding the GUI
    int guiTimer = GUI_TIMEOUT;

    //ui strings
    // keyString is the parameter associated with lowercase keys, i.e. "q   strokeMode", "g   gridSize".
    String keyString = "derp";
    // value given to recently modified parameter
    String valueGiven = "__";
    // The TweakableTemplate tags of templates selected by the TemplateManager
    String renderString = "_";

    String[] allInfo = {"Geom", "Rndr", "Key", "Time", "FPS"};

    PImage colorMap;
    /**
     * Constructor
     * @param GroupManager dependency injection
     */
    public Gui() {
        // init canvas, P2D significantly faster
        canvas = createGraphics(width, height, P2D);//, FX2D)
        canvas.smooth(0);
        // make grid
        generateGrid(gridSize);
        // make the cursor PShape
        makecrosshair();
        makeArrow();
        // init options
        showGui = true;
        viewLines = false;
        viewTags = false;
        viewCursor = true;
        colorMap = null;
    }


    /**
     * Depends on a groupManager to display all the segment groups and a mouse to draw the cursor.
     * @param GroupManager dependency injection
     * @param Mouse instance dependency injection
     */
    public void inject(GroupManager _gm, Mouse _m) {
        groupManager = _gm;
        mouse = _m;
        // set the SegmentGroup used by the GUI
        guiSegments = groupManager.getGroup(0);
        refSegments = groupManager.getGroup(1);
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Main GUI parts
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Main update function, draws all of the GUI elements to a PGraphics
     */
    public void update() {
        updateInfo();
        if(mouse.hasMoved()) resetTimeOut();
        if(!doDraw()) {
            canvas.beginDraw();
            canvas.clear();
            canvas.endDraw();
        } else doUpdate();
    }

    private void doUpdate() {
        // prep canvas
        canvas.beginDraw();
        canvas.clear();
        canvas.textFont(font);
        canvas.textSize(15);
        //canvas.setText(CENTER);
        if(colorMap != null) canvas.image(colorMap,0,0);
        // draw the grid
        if (mouse.useGrid()) {
            // re-draw the grid if the size changed.
            if(mouse.getGridSize() != gridSize) generateGrid(mouse.getGridSize());
            canvas.shape(grid,0,0); // was without canvas before
        }
        // draw the cursor
        putCrosshair(mouse.getPosition(), mouse.isSnapped());

        // draw the segments of the selected group
        SegmentGroup sg = groupManager.getSelectedGroup();
        if(sg != null) {
            //canvas.fill(255);
            showTag(sg);
            showGroupLines(sg);
            if (viewCursor) previewLine(sg);
        }

        // draw other segment groups if necessary
        if(viewLines || viewTags) {
            for (SegmentGroup seg : groupManager.getGroups()) {
                groupGui(seg);
            }
        }

        showCmdSegments();
        // draw on screen information with group 0
        displayInfo();
        canvas.endDraw();
    }

    /**
     * This formats the information.
     */
    private void updateInfo() {
        // first segment shows which group is selected
        int geom = groupManager.getSelectedIndex();
        if(geom == -1) allInfo[0] = "[G : ]";
        else allInfo[0] = "[G : "+geom+"]";
        // second segment shows the Templates selected
        TemplateList _rl = groupManager.getTemplateList();
        String _tags = "";
        if (_rl != null) _tags = _rl.getTags();
        else _tags = renderString;
        if(_tags.length()>20) _tags = "*ALL*";
        allInfo[1] = "[T : "+_tags+"]";
        // third show the parameter associated with key and values given to parameters
        allInfo[2] = "["+keyString+": "+valueGiven+"]";
        // display how long we have been jamming
        allInfo[3] = "["+getTimeRunning()+"]";
        // framerate ish
        allInfo[4] = "["+(int)frameRate+"]";
    }

    /**
     * This displays the info on the gui group.
     */
    private void displayInfo() {
        if(guiSegments.getSegments().size() == 0) return;
        for(int i = 0; i < 5; i++) guiSegments.setText(allInfo[i], i);
        // draw the information that was just set to segments of group 0
        ArrayList<Segment> segs = guiSegments.getSegments();
        int sz = PApplet.parseInt(guiSegments.getBrushScaler()*20);
        if(segs != null)
            for(Segment seg : segs)
                simpleText(seg, GUI_FONT_SIZE);
    }



    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Cursor Parts
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Display the cursor.
     * If it is snapped we display it green.
     * If it seems like we are using a matrox dual head, rotates the cursor to show which projector you are on.
     * @param PVector cursor coordinates
     * @param boolean isSnapped
     */
    private void putCrosshair(PVector _pos, boolean _snap) {
        // if snapped, make cursor green, white otherwise
        if(_snap && !BW_BEAMER) crosshair.setStroke(SNAPPED_CURSOR_COLOR);
        else crosshair.setStroke(CURSOR_COLOR);
        crosshair.setStrokeWeight(CURSOR_STROKE_WIDTH);
        canvas.pushMatrix();
        canvas.translate(_pos.x, _pos.y);
        // if dual projectors rotate the cursor by 45 when on second projector
        if(DUAL_HEAD && _pos.x > width/2) {
            canvas.rotate(QUARTER_PI);
        }
        if(_snap && BW_BEAMER) canvas.rotate(QUARTER_PI);
        canvas.shape(crosshair);
        canvas.popMatrix();
    }

    /**
     * This shows a line between the last point and the cursor.
     * @param SegmentGroup selected
     */
    private void previewLine(SegmentGroup _sg) {
        PVector pos = _sg.getSegmentStart();
        if (pos.x > 0) {
            canvas.stroke(PREVIEW_LINE_COLOR);
            canvas.strokeWeight(PREVIEW_LINE_STROKE_WIDTH);
            vecLine(canvas, pos, mouse.getPosition());
        }
    }

    /**
     * Create the PShape for the cursor.
     */
    private void makecrosshair() {
        int out = CURSOR_SIZE;
        int in = CURSOR_GAP_SIZE;
        crosshair = createShape();
        crosshair.beginShape(LINES);
        //if(INVERTED_COLOR) crosshair.stroke(0);
        crosshair.vertex(-out, -out);
        crosshair.vertex(-in, -in);

        crosshair.vertex(out, out);
        crosshair.vertex(in, in);

        crosshair.vertex(out, -out);
        crosshair.vertex(in, -in);

        crosshair.vertex(-out, out);
        crosshair.vertex(-in, in);
        crosshair.endShape();
    }

    /**
     * Create the PShape for the arrows that point the direction of segments
     */
    private void makeArrow() {
        int sz = 5;
        arrow = createShape();
        arrow.beginShape(LINES);
        arrow.stroke(SEGMENT_COLOR);
        arrow.vertex(sz, -sz);
        arrow.vertex(0,0);
        arrow.vertex(0,0);
        arrow.vertex(sz,sz);
        arrow.endShape();
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Segment Group drawing
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Displays the segments of a SegmentGroup
     * @param SegmentGroup to draw
     */
    private void groupGui(SegmentGroup _sg) {
        canvas.fill(200);
        if(viewTags) showTag(_sg);
        if(viewLines) showGroupLines(_sg);
    }

    /**
     * Display the tag and center of a group
     * The tag has the group ID "5" and all the associated Template tags
     */
    public void showTag(SegmentGroup _sg) {
        // Get center if centered or last point made
        PVector pos = _sg.getTagPosition();//_sg.isCentered() ? _sg.getCenter() : _sg.getSegmentStart();
        canvas.noStroke();
        canvas.fill(TEXT_COLOR);
        // group ID and template tags
        int id = _sg.getID();
        String idTag = str(id);
        if(_sg == guiSegments) idTag = "info";
        else if(_sg == refSegments) idTag = "ref";
        String tTags = _sg.getTemplateList().getTags();
        // display left and right of pos
        int fset = (16+PApplet.parseInt(id>9)*6);
        if(idTag == "info") fset = 35;
        else if(idTag == "ref") fset = 28;
        canvas.text(idTag, pos.x - fset, pos.y+6);
        canvas.text(tTags, pos.x + 6, pos.y+6);
        canvas.noFill();
        canvas.stroke(TEXT_COLOR);
        canvas.strokeWeight(1);
        // ellipse showing center or last point
        canvas.ellipse(pos.x, pos.y, 10, 10);
    }

    /**
     * Display all the segments of a group
     */
    public void showGroupLines(SegmentGroup _sg) {
        ArrayList<Segment> segs =  _sg.getSegments();
        if(segs != null) {
            for (Segment seg : segs) {
                showSegmentLines(seg, _sg);
            }
        }
    }


    public void showCmdSegments() {
        ArrayList<Segment> cmdSegments = groupManager.getCommandSegments();
        if(cmdSegments == null) return;
        for (Segment seg : cmdSegments) {
            showCmdSegment(seg);
        }
    }

    public void showCmdSegment(Segment _seg) {
        PVector pos = _seg.getPointA();
        canvas.noStroke();
        canvas.fill(TEXT_COLOR);
        String cmd = _seg.getText();
        canvas.text(cmd, pos.x + 6, pos.y+6);
        canvas.noFill();
        canvas.stroke(TEXT_COLOR);
        canvas.strokeWeight(1);
        canvas.ellipse(pos.x, pos.y, 10, 10);
    }

    /**
     * Display the lines of a SegmentGroup, with nice little dots on corners.
     * If it is centered it also shows the path offset.
     * @param Segment segment to draw
     */
    public void showSegmentLines(Segment _s, SegmentGroup _sg) {
        if(groupManager.getSnappedSegment() == _s) canvas.stroke(SNAPPED_CURSOR_COLOR);
        else if(_sg == groupManager.getSelectedGroup()) canvas.stroke(SEGMENT_COLOR);
        else canvas.stroke(SEGMENT_COLOR_UNSELECTED);
        canvas.strokeWeight(1);
        vecLine(canvas, _s.getPointA(), _s.getPointB());
        //canvas.stroke(100);
        //if(_s.isCentered()) vecLine(g, _s.getOffA(), _s.getOffB());
        canvas.stroke(NODE_COLOR);
        canvas.strokeWeight(NODE_STROKE_WEIGTH);
        canvas.point(_s.getPointA().x, _s.getPointA().y);
        canvas.point(_s.getPointB().x, _s.getPointB().y);
        PVector midpoint = _s.getMidPoint();
        if(!_s.isHidden()) {
            canvas.pushMatrix();
            canvas.translate(midpoint.x, midpoint.y);
            canvas.rotate(_s.getAngle(false));
            canvas.shape(arrow);
            canvas.popMatrix();
        }
    }

    /**
     * Display the text of a segment. used with guiSegmentGroup
     * @param Segment
     * @param int size of text
     */
    public void simpleText(Segment _s, int _size) {
        String txt = _s.getText();
        int l = txt.length();
        PVector pos = new PVector(0,0);
        canvas.pushStyle();
        canvas.fill(TEXT_COLOR);
        canvas.noStroke();
        canvas.textFont(font);
        canvas.textSize(_size);
        char[] carr = txt.toCharArray();
        for(int i = 0; i < l; i++) {
            pos = _s.getStrokePos(-((float)i/(l+1) + 1.0f/(l+1))+1);
            canvas.pushMatrix();
            canvas.translate(pos.x, pos.y);
            canvas.rotate(_s.getAngle(false));
            canvas.translate(0,5);
            canvas.text(carr[i], 0, 0);
            canvas.popMatrix();
        }
        canvas.popStyle();
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     GUI tools
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * The idea is to see how long your mapping jams having been going on for.
     * @return String of time since session started
     */
    private String getTimeRunning() {
        int millis = millis();
        int h = millis/3600000;
        millis %= 3600000;
        int m = millis/60000;
        millis %= 60000;
        int s = millis/1000;
        return h+":"+m+":"+s;
    }

    /**
     * Makes a screenshot with all lines and itemNumbers/renderers.
     * This is helpfull to have a reference as to what is what when rocking out.
     * Gets called everytime a new group is create.
     */
    // disable cause too slooooow?
    private void updateReference() {
        updateReference(sketchPath()+"/data/userdata/reference.jpg");
    }

    private void updateReference(String _file) {
        boolean tgs = viewTags;
        boolean lns = viewLines;
        viewLines = true;
        viewTags = true;
        doUpdate();
        canvas.save(_file);
        viewTags = tgs;
        viewLines = lns;
    }

    /**
     * Generate a PGraphics with the grid.
     * @param int resolution
     */
    private void generateGrid(int _sz) {
        gridSize = _sz;
        //PShape grd;
        grid = createShape(GROUP);
        PShape _grd = createShape();
        _grd.beginShape(LINES);
        _grd.stroke(GRID_COLOR);
        _grd.strokeWeight(1);
        for (int x = 0; x < width/2; x+=gridSize) {
            for (int y = 0; y < height/2; y+=gridSize) {
                _grd.vertex(width/2 + x, 0);
                _grd.vertex(width/2 + x, height);
                _grd.vertex(width/2 - x, 0);
                _grd.vertex(width/2 - x, height);
                _grd.vertex(0, height/2 + y);
                _grd.vertex(width, height/2 + y);
                _grd.vertex(0, height/2 - y);
                _grd.vertex(width, height/2 - y);
            }
        }
        _grd.endShape();
        PShape _cross = createShape();
        _cross.beginShape(LINES);
        _cross.strokeWeight(3);
        _cross.stroke(255);
        _cross.vertex(width/2 + gridSize, height/2);
        _cross.vertex(width/2 - gridSize, height/2);
        _cross.vertex(width/2, height/2 + gridSize);
        _cross.vertex(width/2, height/2 - gridSize);
        _cross.endShape();
        grid.addChild(_grd);
        grid.addChild(_cross);
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    /**
     * Force auto hiding of GUI
     */
    public void hide() {
        guiTimer = -1;
    }

    /**
     * Reset the time of the GUI auto hiding
     */
    public void resetTimeOut() {
        guiTimer = GUI_TIMEOUT;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Check if GUI needs to be drawn and update the GUI timeout for auto hiding.
     */
    public boolean doDraw() {
        if (guiTimer > 0 && (mouse.useGrid() || focused)) { // recently added window focus
            guiTimer--;
            return true;
        } else return false;
    }

    public PGraphics getCanvas() {
        return canvas;
    }

    public String[] getAllInfo() {
        return allInfo;
    }
    public String getInfo() {
        return allInfo[0]+allInfo[1]+allInfo[2]+allInfo[3]+allInfo[4];
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Set the key-parameter combo to display.
     * @param String "e   example"
     */
    public void setKeyString(String _s) {
        String ks = _s.replaceAll(" ", "");
        keyString = ks.charAt(0)+" "+ks.substring(1);
    }

    /**
     * Display the latest value that was given to whatever.
     * @param String "true" "false" "haha" "123"
     */
    public void setValueGiven(String _s) {
        if(_s != null) valueGiven = _s;
    }

    /**
     * Display the list of templates currently selected.
     * @param String "ABC"
     */
    public void setTemplateString(String _s) {
        renderString = _s;
    }
    public void setColorMap(PImage _cm) {
        colorMap = _cm;
    }
    // modifiers with value return

    public boolean toggleViewPosition() {
        viewCursor = !viewCursor;
        return viewCursor;
    }

    public boolean toggleViewTags() {
        viewTags = !viewTags;
        return viewTags;
    }

    public boolean toggleViewLines() {
        viewLines = !viewLines;
        return viewLines;
    }
    public void hideStuff() {
        viewTags = false;
        viewLines = false;
        mouse.setGrid(false);
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// PositionGetters are responsible for fetching a position from a segment.
class Interpolator extends Mode{
  public Interpolator(){}
  public Interpolator(int _ind){
    modeIndex = _ind;
    name = "Interpolator";
    description = "Pics a position in relation to a segment";
  }

  /**
   * Fetch a point from a segment
   * @param Segment to interpolate from
   * @param RenderableTemplate template being rendered
   * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
   * @return PVector the resulting coordinate
   */
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    PVector _pos = findPosition(_seg, _tp, _painter);
    _tp.setLastPosition(_pos);
    // catch NaN or Infinit
    if(_pos.x != _pos.x || _pos.y!=_pos.y) _pos.set(0,0);
    return _pos;
  }

  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(useOffset(_painter)) return _seg.getBrushPos(_tp.getLerp());
    else return _seg.getStrokePos(_tp.getLerp());
  }
  /**
   * We also need to know a which angle the thing will be at.
   * @param Segment to interpolate from
   * @param RenderableTemplate template being rendered
   * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
   * @return float angle
   */
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return _seg.getAngle(false);
  }

  public boolean useOffset(Painter _painter){
    if(_painter instanceof BrushPutter) return true;
    else if(_painter instanceof TextWritter) return true;
    else return false;
  }
  // might be a thing
  // public PVector getStart(){
  // }
  // public PVector getEnd(){
  // }
}

class OppositInterpolator extends Interpolator{
  public OppositInterpolator(int _ind){
    modeIndex = _ind;
    name = "OppositInterpolator";
    description = "invert direction every segment";
  }
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    float _lrp = _tp.getLerp();
    if(_seg.getID()%2 == 0) _lrp = 1.0f-_lrp;
    if(useOffset(_painter)) return _seg.getBrushPos(_lrp);
    else return _seg.getStrokePos(_lrp);
  }

  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return _seg.getAngle(_seg.getID()%2 == 0);
  }
}

class SegmentOffsetInterpolator extends Interpolator{

  public SegmentOffsetInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "SegmentOffsetInterpolator";
    description = "Prototype thing that offsets the position according to segments X position.";
  }
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    float offset = _seg.getPointA().x/PApplet.parseFloat(width);

    float _lrp = fltMod(_tp.getLerp()+offset);
    if(useOffset(_painter)) return _seg.getBrushPos(_lrp);
    else return _seg.getStrokePos(_lrp);
  }
}


// front pointA to the center
class CenterSender extends Interpolator{

  public CenterSender(int _ind){
    modeIndex = _ind;
    //super();
    name = "CenterSender";
    description = "Moves between pointA and center";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(useOffset(_painter)) return vecLerp(_seg.getBrushOffsetA(), _seg.getCenter(), _tp.getLerp());
    else return vecLerp(_seg.getStrokeOffsetA(), _seg.getCenter(), _tp.getLerp());
  }
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
  }
}


// interpolated halfway to the center
class HalfWayInterpolator extends Interpolator{

  public HalfWayInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "HalfWayInterpolator";
    description = "Moves along segment, but halfway to center.";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(useOffset(_painter)) return vecLerp(_seg.getBrushPos(_tp.getLerp()), _seg.getCenter(), 0.5f);
    else return vecLerp(_seg.getStrokePos(_tp.getLerp()), _seg.getCenter(), 0.5f);
  }
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
  }
}

// on a radius of segment pointA
class RadiusInterpolator extends Interpolator{
  public RadiusInterpolator(){}
  public RadiusInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "RadiusInterpolator";
    description = "Rotates with segments as Radius.";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
	  float dist = 0;
    if(useOffset(_painter)) dist = _seg.getLength()-(_tp.getScaledBrushSize()/2.0f);
    else dist = _seg.getLength()-(_tp.getStrokeWeight()/2.0f);
    // good we got dist.
  	float ang = getAngle(_seg, _tp, _painter)-HALF_PI;
  	PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
  	pos.add(_seg.getPointA());
    return pos;
  }
  // added a clockwise counter clockwise option
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(!_seg.isClockWise()) return -(-_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
    return -(_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
  }
}

// from the middle of a segments
class DiameterInterpolator extends RadiusInterpolator{
  public DiameterInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "DiameterInterpolator";
    description = "Rotates with segments as diameter.";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
	  float dist = 0;
    if(useOffset(_painter)) dist = (_seg.getLength()-(_tp.getScaledBrushSize()/2.0f))/2.0f;
    else dist = (_seg.getLength()-(_tp.getStrokeWeight()/2.0f))/2.0f;
  	float ang = getAngle(_seg, _tp, _painter)-HALF_PI;

  	PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
  	pos.add(_seg.getMidPoint());
    return pos;
  }
}

class RandomInterpolator extends Interpolator{
  public RandomInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "RandomInterpolator";
    description = "Provides random position between segment and center.";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    PVector pos;
    if(useOffset(_painter)) pos = _seg.getBrushPos(random(0,1));
    else pos = _seg.getStrokePos(random(0,1));

    return vecLerp(pos, _seg.getCenter(), random(0,1));
  }

  //
  // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
  //   return random(TAU);
  // }
}


class RandomExpandingInterpolator extends Interpolator{
  public RandomExpandingInterpolator(int _ind){
    modeIndex = _ind;
    //super();
    name = "RandomExpandingInterpolator";
    description = "Provides an expanding random position between segment and center.";
  }
  // interpolate to center
  public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    PVector pos;
    if(useOffset(_painter)) pos = _seg.getBrushPos(random(0,1));
    else pos = _seg.getStrokePos(random(0,1));

    return vecLerp(_seg.getCenter(), pos, random(0,_tp.getLerp()));
  }

  //
  // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
  //   return random(TAU);
  // }
}



// // front midPoint to the center
// class MiddleCenterSender extends Interpolator{
//
//   public MiddleCenterSender(){
//     super();
//   }
//   // interpolate to center
//   public PVector findPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
//     PVector _pos;
//     if(useOffset(_painter)) _pos = vecLerp(_seg.getBrushOffsetA(), _seg.getBrushOffsetB(), 0.5);
//     else _pos = vecLerp(_seg.getStrokeOffsetA(), _seg.getStrokeOffsetB(), 0.5);
//     return vecLerp(_pos, _seg.getCenter(), _tp.getLerp());
//   }
//   public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
//     return atan2(_seg.getMidPoint().y - _seg.getCenter().y, _seg.getMidPoint().x - _seg.getCenter().x);
//   }
// }

/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-04-01
 */


class KeyMap {
    ParameterKey[] keymap;
    final int KEYTYPE_TRIGGER = 0;
    final int KEYTYPE_TOGGLE = 1;
    final int KEYTYPE_TOGGLE_VALUE = 2;
    final int KEYTYPE_VALUE_NUMBER = 3;
    final int KEYTYPE_VALUE_SLIDER = 4;
    final int KEYTYPE_VALUE = 5;
    final int KEYTYPE_FILE_OPEN = 6;


    public KeyMap() {
        keymap = new ParameterKey[255];
        // animationMode
        loadKeys();
    }

    public ParameterKey[] getKeyMap() {
        return keymap;
    }

    public void setLimits(IntDict _limits) {
        for(String _s : _limits.keys()) {
            keymap[_s.charAt(0)].setMax(_limits.get(_s));
        }
        keymap['f'].setMax(keymap['q'].getMax());
        // for(ParameterKey _pk : keymap) if(_pk != null) println(_pk.getKey()+" "+_pk.getMax());
    }

    public void loadKeys() {
        keymap['a'] = new ParameterKey('a');
        keymap['a'].setType(KEYTYPE_VALUE);
        keymap['a'].setName("animation");
        keymap['a'].setDescription("animate stuff");
        keymap['a'].setCMD("tw $ a");

        // renderMode
        keymap['b'] = new ParameterKey('b');
        keymap['b'].setType(KEYTYPE_VALUE);
        keymap['b'].setName("renderMode");
        keymap['b'].setDescription("picks the renderMode");
        keymap['b'].setCMD("tw $ b");

        // placeCenter
        keymap['c'] = new ParameterKey('c');
        keymap['c'].setType(0);
        keymap['c'].setName("placeCenter");
        keymap['c'].setDescription("Place the center of geometry on next left click, right click uncenters the geometry, middle click sets scene center.");
        keymap['c'].setCMD("geom center"); // -3 toggles other args for setting center?

        // breakline
        keymap['d'] = new ParameterKey('d');
        keymap['d'].setType(0);
        keymap['d'].setName("breakline");
        keymap['d'].setDescription("Detach line to new starting position.");
        keymap['d'].setCMD("geom breakline"); //

        // enterpolator
        keymap['e'] = new ParameterKey('e');
        keymap['e'].setType(KEYTYPE_VALUE);
        keymap['e'].setName("enterpolator");
        keymap['e'].setDescription("Enterpolator picks a position along a segment");
        keymap['e'].setCMD("tw $ e"); //

        // fillColor
        keymap['f'] = new ParameterKey('f');
        keymap['f'].setType(KEYTYPE_VALUE);
        keymap['f'].setName("fill");
        keymap['f'].setDescription("Pick fill color");
        keymap['f'].setCMD("tw $ f"); //

        // the grid
        keymap['g'] = new ParameterKey('g');
        keymap['g'].setType(KEYTYPE_TOGGLE_VALUE);
        keymap['g'].setName("grid");
        keymap['g'].setDescription("use snappable grid");
        keymap['g'].setCMD("tools grid"); // argument
        keymap['g'].setMax(255);

        // easing
        keymap['h'] = new ParameterKey('h');
        keymap['h'].setType(KEYTYPE_VALUE);
        keymap['h'].setName("easing");
        keymap['h'].setDescription("Set the easing mode.");
        keymap['h'].setCMD("tw $ h");

        // iteration
        keymap['i'] = new ParameterKey('i');
        keymap['i'].setType(KEYTYPE_VALUE);
        keymap['i'].setName("iteration");
        keymap['i'].setDescription("Iterate animation in different ways, `r` sets the amount.");
        keymap['i'].setCMD("tw $ i");

        // reverseMode
        keymap['j'] = new ParameterKey('j');
        keymap['j'].setType(KEYTYPE_VALUE);
        keymap['j'].setName("reverse");
        keymap['j'].setDescription("Pick different reverse modes");
        keymap['j'].setCMD("tw $ j"); //

        // strokeAlpha
        keymap['k'] = new ParameterKey('k');
        keymap['k'].setType(KEYTYPE_VALUE_SLIDER);
        keymap['k'].setName("strokeAlpha");
        keymap['k'].setDescription("Alpha value of stroke.");
        keymap['k'].setCMD("tw $ k"); //
        keymap['k'].setMax(256); //


        // fillAlpha
        keymap['l'] = new ParameterKey('l');
        keymap['l'].setType(KEYTYPE_VALUE_SLIDER);
        keymap['l'].setName("fillAlpha");
        keymap['l'].setDescription("Alpha value of fill.");
        keymap['l'].setCMD("tw $ l"); //
        keymap['l'].setMax(256); //


        // miscValue
        keymap['m'] = new ParameterKey('m');
        keymap['m'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['m'].setName("miscValue");
        keymap['m'].setDescription("A extra value that can be used by modes.");
        keymap['m'].setCMD("tw $ m"); //
        keymap['m'].setMax(1000); //


        // new geometry
        keymap['n'] = new ParameterKey('n');
        keymap['n'].setType(0);
        keymap['n'].setName("new");
        keymap['n'].setDescription("make a new geometry group");
        keymap['n'].setCMD("geom new");

        // rotationMode
        keymap['o'] = new ParameterKey('o');
        keymap['o'].setType(KEYTYPE_VALUE);
        keymap['o'].setName("rotation");
        keymap['o'].setDescription("Rotate stuff.");
        keymap['o'].setCMD("tw $ o"); //
        keymap['o'].setMax(12);

        // layer
        keymap['p'] = new ParameterKey('p');
        keymap['p'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['p'].setName("layer");
        keymap['p'].setDescription("Pick which layer to render on.");
        keymap['p'].setCMD("tw $ p");
        keymap['p'].setMax(KEYTYPE_VALUE); // need to fix this

        // strokeColor
        keymap['q'] = new ParameterKey('q');
        keymap['q'].setType(KEYTYPE_VALUE);
        keymap['q'].setName("strokeColor");
        keymap['q'].setDescription("Pick the stroke Color.");
        keymap['q'].setCMD("tw $ q"); //

        // polka
        keymap['r'] = new ParameterKey('r');
        keymap['r'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['r'].setName("polka");
        keymap['r'].setDescription("Number of iterations for the iterator, related to `i`.");
        keymap['r'].setCMD("tw $ r"); //
        keymap['r'].setMax(1000); //


        // Size
        keymap['s'] = new ParameterKey('s');
        keymap['s'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['s'].setName("size");
        keymap['s'].setDescription("Sets the brush size for `b-0`");
        keymap['s'].setCMD("tw $ s"); //
        keymap['s'].setMax(100000);


        // tapTempo
        keymap['t'] = new ParameterKey('t');
        keymap['t'].setType(0);
        keymap['t'].setName("tap");
        keymap['t'].setDescription("Tap tempo, tweaking nudges time.");
        keymap['t'].setCMD("seq tap");
        keymap['t'].setMax(1000);

        // enabler
        keymap['u'] = new ParameterKey('u');
        keymap['u'].setType(KEYTYPE_VALUE);
        keymap['u'].setName("enabler");
        keymap['u'].setDescription("Enablers decide if a render happens or not.");
        keymap['u'].setCMD("tw $ u"); //

        // segmentSelcetor
        keymap['v'] = new ParameterKey('v');
        keymap['v'].setType(KEYTYPE_VALUE);
        keymap['v'].setName("segSelect");
        keymap['v'].setDescription("Picks which segments get rendered.");
        keymap['v'].setCMD("tw $ v"); //

        // strokeWeight
        keymap['w'] = new ParameterKey('w');
        keymap['w'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['w'].setName("strokeWeight");
        keymap['w'].setDescription("Stroke weight.");
        keymap['w'].setCMD("tw $ w"); //
        keymap['w'].setMax(420);


        // beatDivider
        keymap['x'] = new ParameterKey('x');
        keymap['x'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['x'].setName("beatMultiplier");
        keymap['x'].setDescription("Set how many beats the animation will take.");
        keymap['x'].setCMD("tw $ x"); //
        keymap['x'].setMax(5000);

        // tracers
        keymap['y'] = new ParameterKey('y');
        keymap['y'].setType(KEYTYPE_VALUE_SLIDER);
        keymap['y'].setName("tracers");
        keymap['y'].setDescription("Set tracer level for tracer layer.");
        keymap['y'].setCMD("post tracers"); //
        keymap['y'].setMax(256);

        // z looping
        keymap['z'] = new ParameterKey('z');
        keymap['z'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['z'].setName("looper");
        keymap['z'].setDescription("Set how many beats the loop will be.");
        keymap['z'].setCMD("loop"); //
        keymap['z'].setMax(5000);

        ////////////////////////////////////////////////////////////////////////////////////
        ///////
        ///////    controlKeys (also capital letters, but they dont need to know this)
        ///////
        ////////////////////////////////////////////////////////////////////////////////////

        // selectAll
        keymap['A'] = new ParameterKey('A');
        keymap['A'].setType(0);
        keymap['A'].setName("selectAll");
        keymap['A'].setDescription("Select ALL the templates.");
        keymap['A'].setCMD("tp select *"); //
        // share
        keymap['B'] = new ParameterKey('B');
        keymap['B'].setType(0);
        keymap['B'].setName("add");
        keymap['B'].setDescription("Toggle second template on all geometry with first template.");
        keymap['B'].setCMD("tp groupadd $"); //
        // copy
        keymap['C'] = new ParameterKey('C');
        keymap['C'].setType(0);
        keymap['C'].setName("copy");
        keymap['C'].setDescription("Copy first selected template into second selected.");
        keymap['C'].setCMD("tp copy $"); //
        // customShape
        keymap['D'] = new ParameterKey('D');
        keymap['D'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['D'].setName("customShape");
        keymap['D'].setDescription("Set a template's customShape.");
        keymap['D'].setCMD("tp shape $"); //
        keymap['D'].setMax(1000);

        // reverseMouse
        keymap['I'] = new ParameterKey('I');
        keymap['I'].setType(KEYTYPE_TOGGLE);
        keymap['I'].setName("revMouseX");
        keymap['I'].setDescription("Reverse the X axis of mouse, trust me its handy.");
        keymap['I'].setCMD("tools revx"); //
        // masking
        keymap['M'] = new ParameterKey('M');
        keymap['M'].setType(0);
        keymap['M'].setName("mask");
        keymap['M'].setDescription("Generate mask for maskLayer, or set mask.");
        keymap['M'].setCMD("layer mask make"); //
        // masking
        keymap['L'] = new ParameterKey('L');
        keymap['L'].setType(0);
        keymap['L'].setName("link");
        keymap['L'].setDescription("Link one template to an other unidirectionaly, used for meta freelining.");
        keymap['L'].setCMD("tp link $"); //
        // open
        keymap['O'] = new ParameterKey('O');
        keymap['O'].setType(KEYTYPE_FILE_OPEN);
        keymap['O'].setName("open");
        keymap['O'].setDescription("Open stuff");
        keymap['O'].setCMD("fl open"); //
        // geometry layer
        keymap['P'] = new ParameterKey('P');
        keymap['P'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['P'].setName("priority");
        keymap['P'].setDescription("Change the geometry render order, if a group is selected, changes this groups render priority, or all groups with selected template.");
        keymap['P'].setCMD("geom priority $"); //
        // enterpolator
        keymap['Q'] = new ParameterKey('Q');
        keymap['Q'].setType(0);
        keymap['Q'].setName("quit");
        keymap['Q'].setDescription("quit freeliner!");
        keymap['Q'].setCMD("fl quit"); //
        // resetTamplate
        keymap['R'] = new ParameterKey('R');
        keymap['R'].setType(0);
        keymap['R'].setName("reset");
        keymap['R'].setDescription("Reset template.");
        keymap['R'].setCMD("tp reset $"); //
        // saveStuff
        keymap['S'] = new ParameterKey('S');
        keymap['S'].setType(0);
        keymap['S'].setName("save");
        keymap['S'].setDescription("Save stuff.");
        keymap['S'].setCMD("fl save");
        // Paste
        keymap['V'] = new ParameterKey('V');
        keymap['V'].setType(0);
        keymap['V'].setName("paste");
        keymap['V'].setDescription("Paste copied template into selected template.");
        keymap['V'].setCMD("tp paste $");
        // swap
        keymap['X'] = new ParameterKey('X');
        keymap['X'].setType(0);
        keymap['X'].setName("swap");
        keymap['X'].setDescription("Completely swap template tag, with `AB` A becomes B and B becomes A.");
        keymap['X'].setCMD("tp swap $");


        ////////////////////////////////////////////////////////////////////////////////////
        ///////
        ///////    other keys
        ///////
        ////////////////////////////////////////////////////////////////////////////////////

        // increase
        keymap['='] = new ParameterKey('=');
        keymap['='].setType(0);
        keymap['='].setName("increase");
        keymap['='].setDescription("Increase value of selectedKey.");
        // decrease
        keymap['-'] = new ParameterKey('-');
        keymap['-'].setType(0);
        keymap['-'].setName("decrease");
        keymap['-'].setDescription("Decrease value of selectedKey.");

        // snapping
        keymap['.'] = new ParameterKey('.');
        keymap['.'].setType(KEYTYPE_TOGGLE_VALUE);
        keymap['.'].setName("snapping");
        keymap['.'].setDescription("enable/disable snapping or set the snapping distance");
        keymap['.'].setCMD("tools snap"); // then check for selected segment, or execute cmd
        keymap['.'].setMax(255);
        // fixed angle
        keymap['['] = new ParameterKey('[');
        keymap['['].setType(KEYTYPE_TOGGLE_VALUE);
        keymap['['].setName("fixedAngle");
        keymap['['].setDescription("enable/disable fixed angles for the mouse");
        keymap['['].setCMD("tools angle"); // then check for selected segment, or execute cmd
        keymap['['].setMax(360);
        // fixed length
        keymap[']'] = new ParameterKey(']');
        keymap[']'].setType(KEYTYPE_TOGGLE_VALUE);
        keymap[']'].setName("fixedLength");
        keymap[']'].setDescription("enable/disable fixed length for the mouse");
        keymap[']'].setCMD("tools ruler"); // then check for selected segment, or execute cmd
        keymap[']'].setMax(5000);
        // showLines
        keymap['/'] = new ParameterKey('/');
        keymap['/'].setType(KEYTYPE_TOGGLE);
        keymap['/'].setName("showLines");
        keymap['/'].setDescription("Showlines of all geometry.");
        keymap['/'].setCMD("tools lines");
        // showTags
        keymap[','] = new ParameterKey(',');
        keymap[','].setType(KEYTYPE_TOGGLE);
        keymap[','].setName("showTags");
        keymap[','].setDescription("showTags of all groups");
        keymap[','].setCMD("tools tags");


        // text entry
        keymap['|'] = new ParameterKey('|');
        keymap['|'].setType(KEYTYPE_TOGGLE);
        keymap['|'].setName("enterText");
        keymap['|'].setDescription("enable text entry, type text and press return");
        keymap['|'].setCMD("text"); // then check for selected segment, or execute cmd

        // sequencer
        keymap['<'] = new ParameterKey('<');
        keymap['<'].setType(KEYTYPE_VALUE_NUMBER);
        keymap['<'].setName("sequencer");
        keymap['<'].setDescription("select sequencer steps to add or remove templates");
        keymap['<'].setCMD("seq select"); // tweak value select step
        keymap['<'].setMax(16);
        // play pause
        keymap['>'] = new ParameterKey('>');
        keymap['>'].setType(KEYTYPE_TOGGLE);
        keymap['>'].setName("play");
        keymap['>'].setDescription("toggle auto loops and sequencer"); // ?
        keymap['>'].setCMD("seq play"); // toggle sequencer playing or specify step to play from
        // seq clear
        keymap['^'] = new ParameterKey('^');
        keymap['^'].setType(0);
        keymap['^'].setName("clear");
        keymap['^'].setDescription("clear sequencer");
        keymap['^'].setCMD("seq clear $");

        // randomAction
        keymap['?'] = new ParameterKey('?');
        keymap['?'].setType(0);
        keymap['?'].setName("???");
        keymap['?'].setDescription("~:)"); // ?
        keymap['?'].setCMD("fl random"); // toggle sequencer playing or specify step to play from

        // setTestChannel
        keymap['('] = new ParameterKey('(');
        keymap['('].setType(KEYTYPE_TOGGLE_VALUE);
        keymap['('].setName("testChannel");
        keymap['('].setDescription("set the test channel, must use a fixture layer called fix"); // ?
        keymap['('].setCMD("fixtures testchan"); // toggle sequencer playing or specify step to play from
        // setLED
        keymap[')'] = new ParameterKey(')');
        keymap[')'].setType(0);
        keymap[')'].setName("setChannel");
        keymap[')'].setDescription("set the start led of a fixture, if snapped to segment middle, sets the end of fixture on that segment"); // ?
        keymap[')'].setCMD("fixtures setchan"); // toggle sequencer playing or specify step to play from
    }

    public ParameterKey getKey(int _ascii) {
        // fix a
        if(_ascii > keymap.length) return null;
        return keymap[_ascii];
    }

    // safe accessors
    public String getName(char _k) {
        if(keymap[_k] == null) return "not_mapped";
        else return keymap[_k].getName();
    }
    public String getDescription(char _k) {
        if(keymap[_k] == null) return "not_mapped";
        else return keymap[_k].getDescription();
    }
    public String getCMD(char _k) {
        if(keymap[_k] == null) return "nope";
        else return keymap[_k].getCMD();
    }
    public int getMax(char _k) {
        if(keymap[_k] == null) return -42;
        else return keymap[_k].getMax();
    }
}


class ParameterKey {
    char thekey;
    String name;
    String description;
    String cmd = "nope";
    int maxVal = -42; // for no max
    // type of control
    // 0 button
    // 1 toggle
    // 2 toogle+value
    // 3 Number
    // 4 slider
    // 5 menu
    // 6 file
    int type = 0;

    public ParameterKey(char _k) {
        thekey = _k;
    }


    public final void setName(String _n) {
        name = _n;
    }
    public final void setDescription(String _d) {
        description = _d;
    }
    public final void setCMD(String _c) {
        cmd = _c;
    }
    public final void setMax(int _i) {
        maxVal = _i;
    }
    public final void setType(int _t) {
        type =_t;
    }


    public final char getKey() {
        return thekey;
    }
    public final String getName() {
        return name;
    }
    public final String getDescription() {
        return description;
    }
    public final String getCMD() {
        return cmd;
    }
    public final int getMax() {
        return maxVal;
    }
    public final int getType() {
        return type;
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// imports for detecting capslock state







// text entry fix!

// void keyPressed() {
//   if (keyCode == BACKSPACE) {
//     if (myText.length() > 0 ) {
//       myText = myText.substring( 0 , myText.length()- 1 );
//     }
//   } else if (keyCode == DELETE) {
//     myText = "" ;
//   } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
//     myText = myText + key;
//   }
// }

/**
 * Manage a keyboard
 * <p>
 * KEYCODES MAPPING
 * ESC unselect
 * CTRL feather mouse + (ctrl)...
 * UP DOWN LEFT RIGHT move snapped or previous point, SHIFT for faster
 * TAB tab through segmentGroups, SHIFT to reverse
 * BACKSPACE remove selected segment
 */
class Keyboard implements FreelinerConfig {

    // dependecy injection
    GroupManager groupManager;
    TemplateManager templateManager;
    TemplateRenderer templateRenderer;
    CommandProcessor processor;
    Gui gui;
    Mouse mouse;
    FreeLiner freeliner;

    //key pressed
    boolean shifted;
    boolean ctrled;
    boolean alted;

    // more keycodes
    final int CAPS_LOCK = 20;

    // flags
    boolean enterText;

    //setting selector
    char editKey = ' '; // dispatches number maker to various things such as size color
    char editKeyCopy = ' ';

    //user input int and string
    String numberMaker = "";
    String wordMaker = "";

    KeyMap keyMap;
    /**
     * Constructor inits default values
     */
    public Keyboard() {
        shifted = false;
        ctrled = false;
        alted = false;
        enterText = false;
    }

    /**
     * Dependency injection
     * Receives references to the groupManager, templateManager, GUI and mouse.
     * @param Freeliner reference
     */
    public void inject(FreeLiner _fl) {
        freeliner = _fl;
        groupManager = freeliner.getGroupManager();
        templateManager = freeliner.getTemplateManager();
        templateRenderer = freeliner.getTemplateRenderer();
        gui = freeliner.getGui();
        mouse = freeliner.getMouse();
        processor = freeliner.getCommandProcessor();
        keyMap = freeliner.keyMap;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Starts Here
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * receive and key and keycode from papplet.keyPressed();
     * @param int the keyCode
     */
    public void keyPressed(int _kc, char _k) {
        gui.resetTimeOut(); // was in update, but cant rely on got input due to ordering
        // if in text entry mode
        if(processKeyCodes(_kc)) return; // TAB SHIFT and friends
        else if (enterText) textEntry(_k);
        else if (_kc >= 48 && _kc <= 57 && !shifted) numMaker(_k); // grab numbers into the numberMaker
        else if (isCapsLock()) processCapslocked(_k);
        else {
            // prevent caps here.
            if (ctrled || alted) modCommands(_kc); // alternate mappings related to ctrl and alt combos
            else if (_k == '-') commandMaker(editKey, -2); //decrease value
            else if (_k == '=') commandMaker(editKey, -1); //increase value
            else if (_k == ')') processor.processCMD("fixtures setchan"); //increase value

            else if (_k >= 65 && _k <=90) templateSelection(_k);
            else if (_k == '|') gui.setValueGiven(str(toggleEnterText())); // acts localy
            else {
                setEditKey(_k);
                commandMaker(editKey, -3);
            }
        }
    }

    public void commandMaker(char _k, int _n) {
        ParameterKey _pk = keyMap.getKey(_k);
        if(_pk == null) return;
        makeCMD(keyMap.getCMD(_k)+" "+_n);
        gui.setValueGiven(processor.getValueGiven());
    }

    public void makeCMD(String _cmd) {
        // println("making cmd : "+_cmd);
        if(groupManager.isFocused()) processor.processCMD(_cmd.replaceAll("\\$", "\\$\\$"));
        else processor.processCMD(_cmd);
    }

    public void setEditKey(char _k) {
        // println(_k);
        ParameterKey _pk = keyMap.getKey(_k);
        if(_pk == null) return;
        gui.setKeyString(_k+" "+_pk.getName());
        editKey = _k;
        numberMaker = "0";
        gui.setValueGiven("_");
    }

    /**
     * Process key release, mostly affecting coded keys.
     * @param char the key
     * @param int the keyCode
     */
    public void keyReleased(int _kc, char _k) {
        if (_kc == 16) shifted = false;
        else if (_kc == 17) ctrled = false;
        else if (_kc == 18) alted = false;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Interpretation
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Process key when capslock is on.
     * Basicaly just triggers templates
     * @param char the capital key to process
     */
    public void processCapslocked(char _k) {
        // for some reason OSX had inconsistent caps handling...
        if(OSX && _k >= 97 && _k <=122) _k -= 32;
        // if its a letter, trigger the template.
        if(_k >= 65 && _k <=90) {
            makeCMD("tr "+_k);
            // select it?
        }
    }

    /**
     * Do template selection.
     * Basicaly just triggers templates
     * @param char the template tag to select
     */
    public void templateSelection(char _k) {
        if(editKey == '>' && shifted) makeCMD("seq toggle "+_k);
        else if(groupManager.isFocused()) { //makeCMD("geom toggle "_k+" $");
            TemplateList _tl = groupManager.getTemplateList();
            if(_tl != null) {
                _tl.toggle(templateManager.getTemplate(_k));
                groupManager.setReferenceGroupTemplateList(_tl); // set ref
                gui.setTemplateString(_tl.getTags());
            }
        } else {
            templateManager.getTemplateList().toggle(templateManager.getTemplate(_k));
            gui.setTemplateString(templateManager.getTemplateList().getTags());
        }
    }

    /**
     * Process keycode for keys like ENTER or ESC
     * @param int the keyCode
     */
    public boolean processKeyCodes(int kc) {
        if (kc == SHIFT) shifted = true;
        else if (kc == ENTER && enterText) returnWord();
        else if (kc == ENTER && !enterText) returnNumber(); // grab enter
        else if (kc == ESC || kc == 27) unSelectThings();
        else if (kc == CONTROL) setCtrled(true);
        else if (kc == ALT) setAlted(true);
        else if (kc == UP) groupManager.nudger(false, -1, shifted);
        else if (kc == DOWN) groupManager.nudger(false, 1, shifted);
        else if (kc == LEFT) groupManager.nudger(true, -1, shifted);
        else if (kc == RIGHT) groupManager.nudger(true, 1, shifted);
        //tab and shift tab throug groups
        else if (kc == TAB) groupManager.tabThrough(shifted);
        else if (kc == BACKSPACE) backspaceAction();
        else if (kc == 92 && !shifted) backSlashAction();


        else return false;
        return true;
        //else if (kc==32 && OSX) mouse.press(3); // for OSX people with no 3 button mouse.
    }

    /**
     * Process a key differently if ctrl or alt is pressed.
     * @param int ascii value of the key
     */
    public void modCommands(int _kc) {
        ParameterKey _pk = keyMap.getKey(_kc);
        if(_pk == null) return;
        if(_pk.getKey() == 'P') {
            setEditKey('P');
            commandMaker(editKey, -3);
        }
        makeCMD(_pk.getCMD());
        gui.setKeyString(_pk.getName());
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Distribution of input to things
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    //distribute input!
    //check if its mapped to general things
    //then if an item has focus
    //check if it is mapped to an item thing
    //if not then pass it to the first decorator of the item.
    //if no item has focus, pass it to the slected renderers.

    // public void distributor(char _k, int _n){
    //   if (localDispatch(_k, _n)) return;
    //   SegmentGroup sg = groupManager.getSelectedGroup();
    //   TemplateList tl = null;
    //   if(sg != null){
    //     if(!segmentGroupDispatch(sg, _k, _n, _vg)) tl = sg.getTemplateList();
    //   }
    //   else tl = templateManager.getTemplateList();
    //
    //   if(tl != null){
    //     makeCMD("tw"+" "+tl.getTags()+" "+_k+" "+_n);
    //     if(_vg) gui.setValueGiven(processor.getValueGiven());
    //   }
    // }



    // PERHAPS MOVE
    // for the signature ***, char k, int n, boolean vg
    // char K is the editKey
    // int n, -3 is no number, -2 is decrease one, -1 is increase one and > 0 is value to set.
    // boolean vg is weather or not to update the value given. (osc?)

    public boolean localDispatch(char _k, int _n) {
        ParameterKey _pk = keyMap.getKey(_k);
        if(_pk == null) return false;
        makeCMD(keyMap.getCMD(_k)+' '+_n);
        gui.setValueGiven(processor.getValueGiven());
        return true;
    }

    /**
     * Distribute parameters for segmentGroups, such as place center, set scalar, or grab as cutom shape
     * @param SegmentGroup segmentGroup to affect
     * @param char editKey (like q for color)
     * @param int value to set
     * @param boolean display the valueGiven in the gui.
     * @return boolean if the key was used.
     */
    // #needswork put to command processor...
    // public boolean segmentGroupDispatch(SegmentGroup _sg, char _k, int _n) {
    //   boolean used_ = true;
    //   String valueGiven_ = null;
    //   if(_k == 'c') valueGiven_ = str(_sg.toggleCenterPutting());
    //   // else if(_k == 's') valueGiven_ = str(_sg.setBrushScaler(_n));
    //   // else if (int(_k) == 504) templateManager.setCustomShape(_sg);
    //   // else used_ = false;
    //   if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    //   return used_;
    // }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions?
    ///////
    ////////////////////////////////////////////////////////////////////////////////////



    public void forceRelease() {
        shifted = false;
        ctrled = false;
        alted = false;
    }

    private void backspaceAction() {
        if (!enterText) groupManager.deleteSegment();
    }

    private void backSlashAction() {
        if (!enterText) groupManager.hideSegment();
    }

    /**
     * The ESC key triggers this, it unselects segment groups / renderers, a second press will hid the gui.
     */
    private void unSelectThings() {
        if(!groupManager.isFocused() && !templateManager.isFocused()) gui.hide();
        else {
            templateManager.unSelect();
            groupManager.unSelect();
            gui.setTemplateString(" ");//templateManager.renderList.getString());
            groupManager.setReferenceGroupTemplateList(null);
        }
        // This should fix some bugs.
        alted = false;
        ctrled = false;
        shifted = false;
        editKey = ' ';
        enterText = false;
        wordMaker = "";
        gui.setKeyString("unselect");
        gui.setValueGiven(" ");
        gui.hideStuff();
        mouse.setGrid(false);
    }

    /**
     * CTRL-a selects all renderers as always.
     */
    private void focusAll() {
        groupManager.unSelect();
        templateManager.focusAll();
        gui.setTemplateString("*all*");
        wordMaker = "";
        enterText = false;
    }

    // /**
    //  * Toggle the recording state.
    //  * @return boolean value given
    //  */
    // public boolean toggleRecording(){
    //   boolean record = templateRenderer.toggleRecording();
    //   templateManager.getSynchroniser().setRecording(record);
    //   return record;
    // }

    /**
     * Save geometry and templates to default file.
     */
    public void saveStuff() {
        makeCMD("geom save");
        makeCMD("tp save");
    }

    /**
     * Load geometry and templates from default file.
     */
    public void loadStuff() {
        makeCMD("geom load");
        makeCMD("tp load");
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Typing in stuff
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    private void textEntry(char _k) {
        if (_k!=65535) wordMaker(_k);
        println("Making word:  "+wordMaker);
        gui.setValueGiven(wordMaker);
    }
    /**
     * Toggle text entry
     * @return boolean valueGiven
     */
    public boolean toggleEnterText() {
        enterText = !enterText;
        if(enterText) setEditKey('|');
        return enterText;
    }

    /**
     * Add a char to the text entry
     * @param char to add
     */
    private void wordMaker(char _k) {
        if(wordMaker.length() < 1) wordMaker = str(_k);
        else wordMaker = wordMaker + str(_k);
    }

    // failz
    private String removeLetter(String _s) {
        if(_s.length() > 1) {
            return _s.substring(0, _s.length()-1 );
        }
        return "";
    }

    /**
     * Use the word being typed. Mostly setting a segments text.
     * Perhaps write commands for the sequencer?
     */
    private void returnWord() {
        if(groupManager.getSnappedSegment() != null)
            makeCMD("geom text"+" "+wordMaker);
        else {
            makeCMD(wordMaker);
            gui.setKeyString("sure");
            gui.setValueGiven(wordMaker);
        }
        wordMaker = "";
        enterText = false;
    }

    /**
     * Compose numbers with 0-9
     * @param char character to add to the pending number
     */
    private void numMaker(char _k) {
        if(numberMaker.length() < 1) numberMaker = str(_k);
        else numberMaker = numberMaker + str(_k);
        if(numberMaker.charAt(0) == '0' && numberMaker.length()>1) numberMaker = numberMaker.substring(1);
        gui.setValueGiven(numberMaker);
    }

    /**
     * Use freshly typed number.
     */
    private void returnNumber() {
        try {
            commandMaker(editKey, Integer.parseInt(numberMaker));
        } catch (Exception e) {
            println("Bad number string");
        }
        numberMaker = "";
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Set the editKey
     * The edit key is very important, it selects what parameter to modify.
     * This also verbose the parameter in the GUI.
     * @param char the edit Key
     */
    // public void setEditKey(char _k, String[] _map) {
    //   if (keyIsMapped(_k, _map) && _k != '-' && _k != '=') {
    //     gui.setKeyString(_k+" "+getKeyString(_k, _map));
    //     editKey = _k;
    //     numberMaker = "0";
    //     gui.setValueGiven("_");
    //   }
    // }

    /**
     * Set if the ctrl key is pressed. Also sets the mousePointer origin to feather the mouse movement for non OSX.
     * @param boolean ctrl key status
     */
    public void setCtrled(boolean _b) {
        if(_b) {
            ctrled = true;
            if(!OSX) mouse.setOrigin();
        } else ctrled = false;
    }

    /**
     * Set if the alt key is pressed. Also sets the mousePointer origin to feather the mouse movement for OSX.
     * @param boolean alt key status
     */
    public void setAlted(boolean _b) {
        if(_b) {
            alted = true;
            if(OSX) mouse.setOrigin();
        } else alted = false;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    /**
     * Checks if the key is mapped by checking the keyMap to see if is defined there.
     * @param char the key
     */
    public boolean keyIsMapped(char _k, String[] _map) {
        for (int i = 0; i < _map.length; i++) {
            if (_map[i].charAt(0) == _k) return true;
        }
        return false;
    }

    /**
     * Gets the string associated to the key from the keyMap
     *
     * @param char the key
     */
    public String getKeyString(char _k, String[] _map) {
        for (int i = 0; i < _map.length; i++) {
            if (_map[i].charAt(0) == _k) return _map[i];
        }
        return "not mapped?";
    }

    /**
     * Is the ctrl key pressed? In OSX the ctrl key behavior is given to the alt key...
     * @return boolean valueGiven
     */
    public boolean isCtrled() {
        if(OSX) return alted;
        return ctrled;
    }

    public boolean isAlted() {
        return alted;
    }

    public boolean isShifted() {
        return shifted;
    }

    public boolean isCapsLock() {
        return Toolkit.getDefaultToolkit().getLockingKeyState(KeyEvent.VK_CAPS_LOCK);
    }

}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */



// ADD TRANSLATION LAYER
// add layer opacity!!

/**
* Something that acts on a PGraphics.
* Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
*/
class Layer extends Mode {
    String id;
    String filename;
    boolean enabled;
    PGraphics canvas;
    ArrayList<String> commandList;
    String[] options = {"none"};
    String selectedOption = "none";
    String command = "none"; // allows to execute commands :)
    boolean cmdFlag;

    public Layer() {
        name = "basicLayer";
        id = name;
        description = "a basic layer that does not do anything";
        commandList = new ArrayList<String>();
        commandList.add("enable (-3|0|1)");
        commandList.add("setName layerName");
        enabled = true;
        canvas = null;
        filename = "none";
        selectedOption = "none";
    }

    /**
     * implement how the options should be used in a layer.
     */
    public void selectOption(String _opt) {
        selectedOption = _opt;
    }

    public String[] getOptions() {
        return options;
    }

    public void setOptions(String[] _opt) {
        options = _opt;
    }

    /**
     * The apply method takes and resturns a PGraphics.
     * @param PGraphics source
     * @return PGraphics output
     */
    public PGraphics apply(PGraphics _pg) {
        return _pg;
    }

    /**
     * Default operation for beginDrawing
     */
    public void beginDrawing() {
        if(canvas != null) {
            canvas.beginDraw();
            canvas.clear();
        }
    }

    /**
     * Default operation for endDrawing
     */
    public void endDrawing() {
        if(canvas != null) canvas.endDraw();
    }

    /**
     * Since each layer are quite specific and require various inputs,
     * layers are just going to have to parse the CMDs themselve.
     * overiding this should include super
     * @param String[] arguments
     * @return boolean weather or not the CMD was parsed.
     */
    public boolean parseCMD(String[] _args) {
        if(_args.length > 3) {
            if(_args[2].equals("load")) loadFile(_args[3]);
            else if(_args[2].equals("enable")) setEnable(stringInt(_args[3]));
            else if(_args[2].equals("name")) setName(_args[3]);
            else if(_args[2].equals("option")) selectOption(_args[3]);
            else return false;
            return true;
        } else return false;
    }

    /**
     * Load a file, used with shaders masks images...
     * @param String filename
     */
    public Layer loadFile(String _file) {
        filename = _file;
        return this;
    }

    /**
     * Get the canvas
     * @return PGraphics
     */
    public PGraphics getCanvas() {
        return canvas;
    }

    public String getFilename() {
        return filename;
    }

    public String getSelectedOption() {
        return selectedOption;
    }

    public Layer setCanvas(PGraphics _pg) {
        canvas = _pg;
        return this;
    }

    /**
     * Set or toggle the enabled boolean
     * @param String name
     */
    public void setEnable(int _v) {
        if(_v == -3) enabled = !enabled;
        else if(_v == 0) enabled = false;
        else if(_v == 1) enabled = true;
    }

    /**
     * Set the name of the layer, like "shader fx.glsl"
     * @param String name
     */
    public Layer setID(String _id) {
        id = _id;
        return this;
    }

    public void setLayer(Layer _lyr) {
    }

    /**
     * Whether of not the layer is used.
     * @return Boolean
     */
    public boolean useLayer() {
        return enabled;
    }

    public String getID() {
        return id;
    }

    public String getCMD() {
        return command;
    }

    public boolean hasCMD() {
        if(cmdFlag) {
            cmdFlag = false;
            return true;
        }
        return false;
    }

    public void runCMD(String _s) {
        command = _s;
        cmdFlag = true;
    }

    public ArrayList<String> getCMDList() {
        return commandList;
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    subaclasses
///////
////////////////////////////////////////////////////////////////////////////////////
class ContainerLayer extends Layer {
    Layer containedLayer = null;
    public ContainerLayer() {
        name = "containerLayer";
        description = "a layer that contains an other";
    }

    public void setLayer(Layer _lyr) {
        containedLayer = _lyr;
    }

    public Layer setID(String _id) {
        this.id = _id;
        return this;
    }

    public String getID() {
        return this.id;
    }

    /////////// the rest is from the containedLayer
    public void selectOption(String _opt) {
        if (containedLayer != null) containedLayer.selectOption(_opt);
    }

    public String[] getOptions() {
        if (containedLayer != null) return containedLayer.getOptions();
        else return null;
    }

    public PGraphics apply(PGraphics _pg) {
        if (containedLayer != null) return containedLayer.apply(_pg);
        else return null;
    }

    public void beginDrawing() {
        if (containedLayer != null) containedLayer.beginDrawing();
    }

    public void endDrawing() {
        if (containedLayer != null) containedLayer.endDrawing();
    }

    public boolean parseCMD(String[] _args) {
        if (containedLayer != null) return containedLayer.parseCMD(_args);
        else return false;
    }

    public Layer loadFile(String _file) {
        if (containedLayer != null) return containedLayer.loadFile(_file);
        else return this;
    }

    public PGraphics getCanvas() {
        if (containedLayer != null) return containedLayer.getCanvas();
        else return null;
    }

    public String getFilename() {
        if (containedLayer != null) return containedLayer.getFilename();
        else return "none";
    }

    public String getSelectedOption() {
        if (containedLayer != null) return containedLayer.getSelectedOption();
        else return "none";
    }

    public Layer setCanvas(PGraphics _pg) {
        if (containedLayer != null) return containedLayer.setCanvas(_pg);
        else return this;
    }

    public void setEnable(int _v) {
        if (containedLayer != null) containedLayer.setEnable(_v);
    }

    public boolean useLayer() {
        if (containedLayer != null) return containedLayer.useLayer();
        else return false;
    }

    public ArrayList<String> getCMDList() {
        if (containedLayer != null) return containedLayer.getCMDList();
        else return null;
    }
}



/**
 * Simple layer twith a real PGraphics
 */
class CanvasLayer extends Layer {
    /**
     * Actualy make a PGraphics.
     */
    public CanvasLayer() {
        canvas = createGraphics(width,height,P2D);
        canvas.beginDraw();
        canvas.background(0);
        canvas.endDraw();
        enabled = true;
        name = "CanvasLayer";
        id = name;
        description = "a layer with a buffer";
    }

    /**
     * This layer's PG gets applied onto the incoming PG
     */
    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        else if(_pg == null) return canvas;
        else if(canvas == null) return _pg;
        _pg.beginDraw();
        _pg.image(canvas,0,0);
        _pg.endDraw();
        return _pg;
    }
}



/**
 * Simple layer twith a real PGraphics
 */
class GuiLayer extends Layer {
    /**
     * onlyconstructor is overiden
     */
    public GuiLayer(PGraphics _pg) {
        canvas = _pg;
        enabled = true;
        name = "GuiLayer";
        id = name;
        description = "A layer for the graphical user interface";
    }
    /**
     * This layer's PG gets applied onto the incoming PG
     */
    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        else if(_pg == null) return canvas;
        else if(canvas == null) return _pg;
        _pg.beginDraw();
        _pg.image(canvas,0,0);
        _pg.endDraw();
        return _pg;
    }
}

/**
 * Simple layer that can be drawn on by the rendering system.
 */
class RenderLayer extends CanvasLayer {
    public RenderLayer() {
        super();
        enabled = true;
        name = "renderLayer";
        id = name;
        description = "a layer that freeliner renders onto, set a template's layer with [p]";
    }
}

/**
 * Tracer layer
 */
class TracerLayer extends RenderLayer {
    int trailmix = 30;
    public TracerLayer() {
        super();
        commandList.add("layer name setTracers 30");
        name = "tracerLayer";
        id = name;
        description = "renderLayer with tracers, set a template's layer with [p]";
    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length > 3) {
            if(_args[2].equals("setTracers")) setTrails(stringInt(_args[3]), 255);
            else return false;
        } else return false;
        return true;
    }
    /**
     * Override parent's beginDrawing to draw a transparent background.
     */
    public void beginDrawing() {
        if(canvas != null) {
            canvas.beginDraw();
            canvas.fill(BACKGROUND_COLOR, trailmix);
            canvas.stroke(BACKGROUND_COLOR, trailmix);
            canvas.stroke(10);
            canvas.noStroke();
            canvas.rect(0,0,width,height);
        }
    }

    public int setTrails(int _v, int _max) {
        if(_v == -42) _v = trailmix;
        trailmix = numTweaker(_v, trailmix);
        if(trailmix >= _max) trailmix = _max - 1;
        return trailmix;
    }
}

/**
 * Layer that should reference the mergeCanvas.
 */
class MergeLayer extends Layer {
    int blendMode = LIGHTEST;
    public MergeLayer() {
        super();
        name = "mergeLayer";
        id = name;
        description = "used to merge layers together";
        String[] _opt = {"blend","add","subtract","darkest","lightest","difference","exclusion","multiply","screen","replace"};
        options = _opt;
    }

    public PGraphics apply(PGraphics _pg) {
        if(_pg == null) return null;
        if(!useLayer()) return _pg;
        canvas.blendMode(blendMode);
        canvas.image(_pg,0,0);
        return null;
    }

    public void selectOption(String _opt) {
        selectedOption = _opt;
        switch(_opt) {
        case "blend":
            blendMode = BLEND;
            break;
        case "add":
            blendMode = ADD;
            break;
        case "subtract":
            blendMode = SUBTRACT;
            break;
        case "darkest":
            blendMode = DARKEST;
            break;
        case "lightest":
            blendMode = LIGHTEST;
            break;
        case "difference":
            blendMode = DIFFERENCE;
            break;
        case "exclusion":
            blendMode = EXCLUSION;
            break;
        case "multiply":
            blendMode = MULTIPLY;
            break;
        case "screen":
            blendMode = SCREEN;
            break;
        case "replace":
            blendMode = REPLACE;
            break;
        default:
            blendMode = BLEND;
            break;
        }
    }
}

/**
 * Layer that outputs the rendering. maybe cannot be deleted...
 */
class MergeOutput extends Layer {
    public MergeOutput() {
        super();
        name = "mergeOutput";
        id = name;
        description = "outputs the merged stuff";
    }

    public PGraphics apply(PGraphics _pg) {
        if(!useLayer()) return _pg;
        canvas.endDraw();
        canvas.blendMode(ADD);
        return canvas;
    }
}

/**
 * Layer that outputs the rendering. maybe cannot be deleted...
 */
class OutputLayer extends Layer {
    public OutputLayer() {
        super();
        name = "outputLayer";
        id = name;
        description = "output layer that goes to screen";
    }

    public PGraphics apply(PGraphics _pg) {
        // if(!useLayer()) return _pg;
        if(_pg != null) {
            image(_pg, 0, 0);
        }
        return null;
    }
}



/**
 * For fragment shaders!
 */
class ShaderLayer extends RenderLayer { //CanvasLayer{
    PShader shader;
    String fileName;
    PVector center;// implements this (connect to some sort of geometry thingy)
    // uniforms to control shader params
    float[] uniforms;
    Synchroniser sync;

    public ShaderLayer(Synchroniser _s) {
        super();
        sync = _s;
        commandList.add("layer name uniforms 0 0.5");
        commandList.add("layer name loadFile fragShader.glsl");
        enabled = true;
        name = "ShaderLayer";
        id = name;
        description = "a layer with a fragment shader";

        shader = null;
        uniforms = new float[] {0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f};
    }

    // Overrirde
    public void setEnable(int _v) {
        super.setEnable(_v);
        reloadShader();
    }


    public void beginDrawing() {

    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length > 4) {
            if(_args[2].equals("uniforms")) {
                setUniforms(stringInt(_args[3]), stringFloat(_args[4]));
            }
        } else return false;
        return true;
    }

    public PGraphics apply(PGraphics _pg) {
        if(shader == null) return _pg;
        if(!enabled) return _pg;
        if(_pg == null) return null;

        try {
            canvas.shader(shader);
        } catch(RuntimeException _e) {
            println("shader no good");
            canvas.resetShader();
            return _pg;
        }
        passUniforms();
        canvas.beginDraw();
        canvas.image(_pg,0,0);
        canvas.endDraw();
        canvas.resetShader();
        return canvas;
    }

    public void selectOption(String _opt) {
        selectedOption = _opt;
        loadFile(_opt);
    }

    public Layer loadFile(String _file) {
        fileName = _file;
        reloadShader();
        return this;
    }

    public void reloadShader() {
        try {
            shader = loadShader(dataPath(PATH_TO_SHADERS)+"/"+fileName);
            println("Loaded shader "+fileName);
        } catch(Exception _e) {
            println("Could not load shader... "+fileName);
            println(_e);
            shader = null;
        }
    }

    public boolean isNull() {
        return (shader == null);
    }

    public void setUniforms(int _i, float _val) {
        if(_i < 0) return;
        uniforms[_i % 8] = _val;
    }

    public void passUniforms() {
        shader.set("u1", uniforms[0]);
        shader.set("u2", uniforms[1]);
        shader.set("u3", uniforms[2]);
        shader.set("u4", uniforms[3]);
        shader.set("u5", uniforms[4]);
        shader.set("u6", uniforms[5]);
        shader.set("u7", uniforms[6]);
        shader.set("u8", uniforms[7]);
        shader.set("time", sync.getUnit());
        shader.set("res", PApplet.parseFloat(width), PApplet.parseFloat(height));
    }
}

// only going to work with P3D :/
// class VertexShaderLayer extends ShaderLayer{
//   public VertexShaderLayer(){
//     super();
//     name = "VertexShaderLayer";
//     id = name;
//     description = "a layer which can be rendered to and has a vertex shader";
//     loadFile("aVertexShader.glsl");
//   }
//
//   public void beginDrawing(){
//     if(canvas != null){
//       canvas.beginDraw();
//       canvas.clear();
//       try {
//         canvas.shader(shader);
//       }
//       catch(RuntimeException _e){
//         println("vertex shader no good");
//         canvas.resetShader();
//       }
//     }
//   }
//
//   public PGraphics apply(PGraphics _pg){
//     if(!enabled) return _pg;
//     if(_pg == null) return canvas;
//     _pg.beginDraw();
//     _pg.clear();
//     _pg.image(canvas,0,0);
//     _pg.endDraw();
//     return _pg;
//   }
//
//   public void reloadShader(){
//     try{
//       shader = loadShader( sketchPath()+"/data/userdata/defaultFrag.glsl", sketchPath()+"/data/userdata/"+fileName);
//       println("Loaded vertex shader "+fileName);
//     }
//     catch(Exception _e){
//       println("Could not load vertex shader... "+fileName);
//       println(_e);
//       shader = null;
//     }
//   }
// }


/**
 * Just draw a image, like a background Image to draw.
 *
 */
class ImageLayer extends CanvasLayer {

    PImage imageToDraw;

    public ImageLayer() {
        super();
        commandList.add("layer name loadFile .jpg .png .???");
        name = "ImageLayer";
        id = name;
        description = "put an image as a layer";
    }

    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        if(imageToDraw == null) return _pg;
        if(_pg == null) return canvas; // maybe cast image to a PG???
        _pg.beginDraw();
        _pg.image(imageToDraw,0,0);
        _pg.endDraw();
        return _pg;
    }

    public void selectOption(String _opt) {
        selectedOption = _opt;
        loadFile(_opt);
        if(imageToDraw != null) {
            canvas.beginDraw();
            canvas.image(imageToDraw,0,0);
            canvas.endDraw();
        }
    }

    public Layer loadFile(String _file) {
        filename = _file;
        try {
            imageToDraw = loadImage(dataPath(PATH_TO_IMAGES)+"/"+_file);
        } catch(Exception _e) {
            imageToDraw = null;
        }
        return this;
    }
}

/**
 * Display video from devices like a webcam or capture card
 */
class CaptureLayer extends CanvasLayer {
    Capture cam;
    PApplet applet;

    public CaptureLayer(PApplet _ap) {
        super();
        commandList.add("layer name loadFile .jpg .png .???");
        name = "CaptureLayer";
        id = name;
        description = "webcams and capture cards";
        applet = _ap;
        options = Capture.list();
    }

    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        if(cam == null) return _pg;
        if(cam.available()) cam.read();
        if(_pg == null) {
            canvas.beginDraw();
            canvas.image(cam,0,0,width,height);
            canvas.endDraw();
            return canvas;
        } else {
            _pg.beginDraw();
            _pg.image(cam,0,0,width,height);
            _pg.endDraw();
            return _pg;
        }
    }

    public void selectOption(String _opt) {
        selectedOption = _opt;
        if(cam != null) cam.stop();
        cam = new Capture(applet, _opt);
        cam.start();
    }
}


/**
 * Take a image and make a mask where all the pixels with green go transparent, everything else black;
 * Needs to be fixed for INVERTED_COLOR...
 */
class MaskLayer extends ImageLayer {
    boolean maskFlag = false;
    public MaskLayer() {
        super();
        commandList.add("layer name loadFile mask.png");
        commandList.add("layer name makeMask");
        // try to load a mask if one is provided
        //loadFile("userdata/mask_image.png");
        name = "MaskLayer";
        id = name;
        description = "a configurable mask layer";
    }

    public void selectOption(String _opt) {
        if(_opt.equals("MAKE")) maskFlag = true;
        else {
            selectedOption = _opt;
            loadFile(_opt);
        }
    }

    public void setOptions(String[] _opts) {
        options = new String[_opts.length+1];
        for(int i = 0; i < _opts.length; i++) {
            options[i] = _opts[i];
        }
        options[_opts.length] = "MAKE";
    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length > 2) {
            if(_args[2].equals("makeMask")) maskFlag = true;
            else return false;
        } else return false;
        return true;
    }

    // pg.endDraw() -> then this ?
    public void makeMask(PGraphics _source) {
        imageToDraw = _source.get();
        imageToDraw.loadPixels();
        int _grn = 0;
        for(int i = 0; i< width * height; i++) {
            // check the green pixels.
            _grn = ((imageToDraw.pixels[i] >> 8) & 0xFF);
            if(_grn > 3) imageToDraw.pixels[i] = color(0, 255-_grn);
            else imageToDraw.pixels[i] = color(0,255);
        }
        imageToDraw.updatePixels();
        saveFile(dataPath(PATH_TO_IMAGES)+"/"+"mask_image.png"); // auto save mask
    }

    public void saveFile(String _file) {
        imageToDraw.save(_file);
    }

    public boolean checkMakeMask() {
        if(maskFlag) {
            maskFlag = false;
            return true;
        } else return false;
    }
}


/**
 * Saves frames to userdata/capture
 *
 */
class ScreenshotLayer extends Layer {
    int clipCount;
    int frameCount;
    Date date;

    public ScreenshotLayer() {
        name = "ScreenshotLayer";
        description = "save screenshots, in singleImage mode enabling the layer will take a single screenshot, in imageSequence enabling the layer will begin and end the sequence";
        id = name;
        enabled = false;
        String[] _op = {"singleImage", "imageSequence"};
        setOptions(_op);
        selectedOption = "singleImage";
        date = new Date();
    }

    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        if(selectedOption.equals("singleImage")) {
            _pg.save( dataPath(PATH_TO_CAPTURE_FILES)+"/"+"freeliner_"+date.getTime()+".png");
            enabled = false;
        } else {
            String fn = String.format("%06d", frameCount);
            _pg.save( dataPath(PATH_TO_CAPTURE_FILES)+"/"+"clip_"+clipCount+"/frame-"+fn+".tif");
            frameCount++;
        }
        return _pg;
    }

    /**
     * Set or toggle the enabled boolean
     * @param String name
     */
    public void setEnable(int _v) {
        if(_v == -3) enabled = !enabled;
        else if(_v == 0) enabled = false;
        else if(_v == 1) enabled = true;
        if(enabled && selectedOption.equals("imageSequence")) {
            clipCount++;
            frameCount = 0;
            runCMD("seq steady 1");
        } else if(!enabled) runCMD("seq steady 0");
    }
}

// Layer that manages a DMX or stuff.

class FixtureLayer extends Layer {

    FancyFixtures fixtures;

    public FixtureLayer(PApplet _pa) {
        super();
        commandList.add("layer name loadFile .xml");
        commandList.add("setchan 0 3 255");
        name = "FixtureLayer";
        id = name;
        description = "A layer that control DMX and whatnot.";
        fixtures = new FancyFixtures(_pa);
    }

    public PGraphics apply(PGraphics _pg) {
        if(_pg == null) return null; //
        fixtures.update(_pg); //
        if(enabled) {
            _pg.beginDraw();
            fixtures.drawMap(_pg);
            _pg.endDraw();
        }
        return _pg;
    }

    public void selectOption(String _opt) {
        selectedOption = _opt;
        loadFile(_opt);
    }

    public Layer loadFile(String _file) {
        filename = _file;
        fixtures.loadFile(_file);
        return this;
    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length > 2) {
            if(_args[2].equals("setchan")) setChanCMD(_args);
            else if(_args[2].equals("testchan")) testChanCMD(_args);
            else if(_args[2].equals("record")) recordCMD(_args);
            else return false;
        } else return false;
        return true;
    }

    public void testChanCMD(String[] _args) {
        if(_args.length < 5) return;
        else {
            int _chan = stringInt(_args[3]);
            int _val = stringInt(_args[4]);
            fixtures.setTestChannel(_chan, _val);
        }
    }

    public void setChanCMD(String[] _args) {
        if(_args.length < 5) return;
        else {
            int _chan = stringInt(_args[3]);
            int _val = stringInt(_args[4]);
            fixtures.setChannel(_chan, _val);
        }
    }
    public void recordCMD(String[] _args) {
        if(_args.length < 4) return;
        else {
            int _rec = stringInt(_args[3]);
            fixtures.enableRecording(_rec != 0);
        }
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-12-25
 */


class Looper implements FreelinerConfig{
	Synchroniser synchroniser;
	CommandProcessor commandProcessor;
	ArrayList<Loop> loops;
	int currentTimeDiv = 0;
	boolean recording;
	boolean lock = false;
	boolean primed;
	boolean overdub = false;
	float lastUnitInterval;
	Loop currentLoop;

	public Looper(){
		loops = new ArrayList<Loop>();
	}

	public void update(){
		float _time = synchroniser.getLerp(currentTimeDiv);
		ArrayList<String> _toex = new ArrayList<String>();
		if(loops.size() > 0){
			for(Loop _l : loops){
				_toex.addAll(_l.update(synchroniser.getLerp(_l.getDiv())));
			}
		}
		if(_toex.size() > 0){
			lock = true;
			for(String _str : _toex) commandProcessor.processCMD(_str);
			lock = false;
		}
		if(recording && currentLoop != null && !overdub){
			float _ha = synchroniser.getLerp(currentTimeDiv);
			_ha -= currentLoop.getOffset();
			if(_ha < 0.0f) _ha += 1.0f;
			if(_ha < lastUnitInterval) {
				recording = false;
				println("stopped loop");
			}
			lastUnitInterval = _ha;
		}
	}

	public void receive(String _cmd){
		if(lock) return;
		if(primed){
			currentLoop = new Loop(currentTimeDiv, synchroniser.getLerp(currentTimeDiv));
			loops.add(currentLoop);
			primed = false;
			recording = true;
		}
		if(recording){
			currentLoop.addCMD(_cmd, synchroniser.getLerp(currentTimeDiv));
		}
	}

	// inject
	public void inject(CommandProcessor _cp){
		commandProcessor = _cp;
	}
	public void inject(Synchroniser _sy){
		synchroniser = _sy;
	}

	public String setTimeDivider(int _v, int _max){
		if(_v == 0){
			primed = false;
			if(recording && overdub) {
				recording = false;
				return "stopped";
			}
			else if(loops.size() > 0) {
				loops.remove(loops.size()-1);
				return "delete";
			}
		}
		if(_v == -42 || _v == -3) {
			primed = false;
			return "stdb";
		}
		currentTimeDiv = numTweaker(_v, currentTimeDiv);
		if(currentTimeDiv >= _max) currentTimeDiv = _max - 1;
		if(currentTimeDiv >= 1) {
			primed = true;
			return "ready "+currentTimeDiv;
		}
		return "ready "+currentTimeDiv;
	}
}


class Loop implements FreelinerConfig{
	ArrayList<TimedCommand> commands;
	ArrayList<TimedCommand> queue;

	int timeDivider;
	float timeOffset;
	float lastUnit;

	public Loop(int _t, float _f){
		timeDivider = _t;
		timeOffset = _f;
		commands = new ArrayList<TimedCommand>();
		queue = new ArrayList<TimedCommand>();

		println("new Loop "+this);
	}

	public void addCMD(String _cmd, float _t){
		commands.add(new TimedCommand(_cmd, _t));
		println("adding "+_cmd);
	}

	public ArrayList<String> update(float _time){
		if(_time < lastUnit) reload();
		lastUnit = _time;
		ArrayList<String> _out = new ArrayList<String>();
		for(TimedCommand _cmd : commands){
			if(queue.contains(_cmd) && _cmd.getStamp() < _time){
				_out.add(_cmd.getCMD());
				queue.remove(_cmd);
			}
		}
		return _out;
	}

	private void reload(){
		if(commands.size() > 0){
			queue.addAll(commands);
		}
	}
	public int getDiv(){
		return timeDivider;
	}
	public float getOffset(){
		return timeOffset;
	}
}

// for now essentialy a time tagged cmd string
class TimedCommand implements FreelinerConfig{
	float timeStamp;
	String commandString;
	public TimedCommand(String _cmd, float _t){
		timeStamp = _t;
		commandString = _cmd;
	}
	public String getCMD(){
		return commandString;
	}
	public float getStamp(){
		return timeStamp;
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



/**
 * Mode is a abstract class for colorModes, renderModes...
 * Added to facilitate auto documentation.
 *
 */

abstract class Mode implements FreelinerConfig{
  int modeIndex;
  String name = "mode";
  String description = "abstract";
  char relatedKey = '_';

  public Mode(){
  }


  public void setName(String _name){
    name = _name;
  }

  public void setDescrition(String _d){
    description = _d;
  }

  public void setRelateKey(char _k){
    relatedKey = _k;
  }

  public int getIndex(){
    return modeIndex;
  }

  public String getName(){
    return name;
  }

  public String getDescription(){
    return description;
  }

  public char getRelatedKey(){
    return relatedKey;
  }
}
//
// class ModeSelector {
//   char thekey;
// }
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// subclass for dedicated mouse hacks from architext?

/**
 * Manages the mouse input, the cursor movement and the clicks
 * <p>
 *
 *
 */
class Mouse implements FreelinerConfig{
  // other mouse buttons than LEFT and RIGHT
  final int MIDDLE = 3;
  final int FOURTH_BUTTON = 0;

  // dependecy injection
  GroupManager groupManager;
  Keyboard keyboard;

  boolean mouseEnabled;
  boolean snapping;
  boolean snapped;
  boolean useFixedAngle;
  boolean useFixedLength;
  boolean invertMouse;
  boolean grid;
  boolean hasMoved;
  int lineLenght = DEFAULT_LINE_LENGTH;
  int lineAngle = DEFAULT_LINE_ANGLE;
  int gridSize = DEFAULT_GRID_SIZE;
  int debounceTimer = 0;
  //mouse crosshair stuff
  PVector position;
  PVector mousePos;
  PVector previousPosition;
  PVector mouseOrigin;

  /**
   * Constructor, receives references to the groupManager and keyboard instances. This is for operational logic.
   * inits default values
   * @param GroupManager dependency injection
   * @param Keyboard dependency injection
   */

  public Mouse(){

    // init vectors
  	position = new PVector(0, 0);
    mousePos = new PVector(0, 0);
    previousPosition = new PVector(0, 0);
    mouseOrigin = new PVector(0,0);

    // init booleans
    mouseEnabled = true;
    snapping = true;
    snapped = false;
    useFixedLength = false;
    useFixedAngle = false;
    invertMouse = false;
  }

  public void inject(GroupManager _gm, Keyboard _kb){
    groupManager = _gm;
    keyboard = _kb;
  }

  /**
   * Handles mouse button press. Buttons are
   * @param int mouseButton
   */
  public void press(int mb) { // perhaps move to GroupManager
    if(debounceTimer > millis()-MOUSE_DEBOUNCE) {
      println("Mouse Bounce!");
      return;
    }
    debounceTimer = millis();
    if (groupManager.isFocused()) {
      if(!(mb == LEFT && snapped && keyboard.isCtrled())) groupManager.getSelectedGroup().mouseInput(mb, position);

      if (mb == LEFT || mb == MIDDLE) previousPosition = position.get();
      else if (mb == RIGHT && !snapped) previousPosition = groupManager.getPreviousPosition();

      if(mb == LEFT && useFixedLength) previousPosition = groupManager.getPreviousPosition();
        //if (mb == MIDDLE && useFixedLength) previousPosition = mousePos.get();
    }
    else if (mb == FOURTH_BUTTON) groupManager.newGroup();
    //println(previousPosition);
  }

  /**
   * Simulate mouse actions!
   * @param int mouseButton
   * @param PVector position
   */
  public void fakeMouse(int mb, PVector p) {
    position = p.get();
    //mousePress(mb);
  }

  /**
   * Handles mouse movements
   * @param int X axis (mouseX)
   * @param int Y axis (mouseY)
   */
  public void move(int _x, int _y) {
    hasMoved = true;
    mousePos.set(_x, _y);
    if (mouseEnabled) {
      if(invertMouse) mousePos.set(abs(width - _x), mousePos.y);
      if (grid) position = gridMouse(mousePos, gridSize);
      else if (useFixedLength || useFixedAngle) position = constrainMouse(mousePos, previousPosition, lineLenght);
      else if (keyboard.isCtrled()) position = featherMouse(mousePos, mouseOrigin, 0.2f);
      else if (snapping) position = snapMouse(mousePos);
      else position = mousePos.get();
    }
    //gui.resetTimeOut();
  }

  /**
   * Handles mouse dragging, currently works with the useFixedLength mode to draw curve approximations.
   * @param int mouseButton
   * @param int X axis (mouseX)
   * @param int Y axis (mouseY)
   */
  public void drag(int _b, int _x, int _y) {
    if (useFixedLength) {
      move(_x, _y);
      if (previousPosition.dist(position) < previousPosition.dist(mousePos)) press(_b);
    }
    else if(snapped && _b == LEFT) {
      move(_x, _y);
      groupManager.drag(position);
    }
  }

  /**
   * Scroll wheel input, currently unused, oooooh possibilities :)
   *
   * @param int positive or negative value depending on direction
   */
  public void wheeled(int _n) {
    if(SCROLLWHEEL_SELECTOR){
      if(_n == -1) keyboard.keyPressed(45, PApplet.parseChar(45));
      else keyboard.keyPressed(61, PApplet.parseChar(61));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Methods to modify the mouse movement
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Snaps to the nearest intersection of a grid
   *
   * @param PVector of mouse position
   * @param int size of grid
   * @return PVector of nearest intersection to position provided
   */
  public PVector gridMouse(PVector _pos, int _grid){
    _pos.x -= width/2;
    _pos.y -= height/2;
    _pos.set(round(_pos.x/_grid)*_grid, round(_pos.y/_grid)*_grid);
    _pos.x += width/2;
    _pos.y += height/2;
    return _pos.get();
    //return new PVector(round(_pos.x/_grid)*_grid, round(_pos.y/_grid)*_grid);
  }

  /**
   * constrain mouse to fixed length and optionaly at an angle of 60deg
   * <p>
   * This is usefull when aproximating curves, all segments will be of same length.
   * Constraining angle allows to create fun geometry, for VJ like visuals
   *
   * @param PVector of mouse position
   * @param PVector of the previous place clicked
   * @return PVector constrained to length and possibly angle
   */
  public PVector constrainMouse(PVector _pos, PVector _prev, int _len){

    float ang = PVector.sub(_prev, _pos).heading()+PI;
    if (useFixedAngle) ang = radians(PApplet.parseInt(degrees(ang)/lineAngle)*lineAngle);
    if(useFixedLength) return new PVector((cos(ang)*_len)+_prev.x, (sin(ang)*_len)+_prev.y, 0);
    else {
      _len = PApplet.parseInt(_pos.dist(_prev));
      return new PVector((cos(ang)*_len)+_prev.x, (sin(ang)*_len)+_prev.y, 0);
    }
  }

  /**
   * Feather mouse for added accuracy, happens when ctrl is held
   *
   * @param PVector of mouse position
   * @param PVector of where the mouse when ctrl was pressed.
   * @return PVector feathered from origin
   */
  public PVector featherMouse(PVector _pos, PVector _origin, float _sensitivity){
    PVector fthr = PVector.mult(PVector.sub(_pos, _origin), _sensitivity);
    return PVector.add(_origin, fthr);
  }


  /**
   * Snap to other vertices! Toggles the snapped boolean
   *
   * @param PVector of mouse position
   * @return PVector of snapped location, or if it did not snap, the position provided
   */
  public PVector snapMouse(PVector _pos){
    PVector snap_ = groupManager.snap(_pos);
    if(snap_ == _pos) snapped = false;
    else snapped = true;
    return snap_;
  }


  /**
   * Move the cursor around with arrow keys, to a greater amount if shift is pressed.
   *
   */
  private void positionUp() {
    if (keyboard.isShifted()) position.y -= 10;
    else position.y--;
    position.y=position.y%width;
  }

  private void positionDown() {
    if (keyboard.isShifted()) position.y += 10;
    else position.y++;
    if (position.y<0) position.y=height;
  }

  private void positionLeft() {
    if (keyboard.isShifted()) position.x -= 10;
    else position.x--;
    if (position.x<0) position.x=width;
  }

  private void positionRight() {
    if (keyboard.isShifted()) position.x += 10;
    else position.x++;
    position.x=position.x%height;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void setOrigin(){
    mouseOrigin = mousePos.get();
  }

  public boolean toggleInvertMouse(){
    invertMouse = !invertMouse;
    return invertMouse;
  }

  public boolean toggleFixedLength(){
    useFixedLength = !useFixedLength;
    return useFixedLength;
  }

  public boolean toggleFixedAngle(){
    useFixedAngle = !useFixedAngle;
    return useFixedAngle;
  }

  public int setLineLenght(int _v) {
    lineLenght = numTweaker(_v, lineLenght);
    if(lineLenght <= 0) lineLenght = 1;
    return lineLenght;
  }

  public int setLineAngle(int _v){
    lineAngle = numTweaker(_v, lineAngle);
    if(lineAngle<=0) lineAngle = 1;
    return lineAngle;
  }


  public boolean toggleSnapping(){
    snapping = !snapping;
    if(!snapping) groupManager.unSnap();
    return snapping;
  }

  //Set the size of grid and generate a PImage of the grid.
  public int setGridSize(int _v) {
    if(_v >= 10 || _v==-1 || _v==-2){
      gridSize = numTweaker(_v, gridSize);
      if(gridSize < 10) gridSize = 10;
    }
    return gridSize;
  }

  private boolean toggleGrid() {
    grid = !grid;
    return grid;
  }

  public void setGrid(boolean _b){
    grid = _b;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public int getGridSize(){
    return gridSize;
  }

  public boolean useGrid(){
    return grid;
  }

  public PVector getPosition(){
    return position;
  }

  public boolean isSnapped(){
    if(!snapping) return false;
    return snapped;
  }


  public boolean hasMoved(){
    if(!hasMoved) return false;
    hasMoved = false;
    return true;
  }

}
 	/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



// Anything that has to do with rendering things with one segment
// basic painter dosent know what to paint but knows what color

// extract colorizers?
// gets a reference to one.

class Painter extends Mode{

	// Since we paint we need colors
	// arraySizes int Config.pde
	Colorizer[] colorizers;
	Interpolator[] posGetters;

  PGraphics canvas;
	RenderableTemplate event;
	int interpolatorCount;
	int colorizerCount;

	public Painter(){
		name = "Painter";
		description = "Paints stuff";

		initColorizers();
		interpolatorCount = 10;
		posGetters = new Interpolator[interpolatorCount];
		posGetters[0] = new Interpolator(0);
		posGetters[1] = new CenterSender(1);
		posGetters[2] = new CenterSender(2);
		posGetters[3] = new HalfWayInterpolator(3);
		posGetters[4] = new RandomExpandingInterpolator(4);
		posGetters[5] = new RandomInterpolator(5);
		posGetters[6] = new DiameterInterpolator(6);
		posGetters[7] = new RadiusInterpolator(7);
		posGetters[8] = new SegmentOffsetInterpolator(8);
		posGetters[9] = new OppositInterpolator(9);

		if(MAKE_DOCUMENTATION) documenter.documentModes( (Mode[])posGetters, 'e', this, "Enterpolator");
	}

  public void paint(RenderableTemplate _rt){
    event = _rt;
    canvas = event.getCanvas();
		applyStyle(canvas);
  }

	public Interpolator getInterpolator(int _index){
		if(_index >= interpolatorCount) _index = interpolatorCount - 1;
		return posGetters[_index];
	}

	public PVector getPosition(Segment _seg){
		return getInterpolator(event.getInterpolateMode()).getPosition(_seg, event, this);
	}

	public float getAngle(Segment _seg, RenderableTemplate _event){
		float ang = getInterpolator(_event.getInterpolateMode()).getAngle(_seg, _event, this);
		if(_event.getDirection()) ang += PI;
		if(_seg.isClockWise()) return ang + _event.getAngleMod();
		else return ang + (-_event.getAngleMod());
	}

	// color stuffs
	public void initColorizers(){
		colorizerCount = 32;
		colorizers = new Colorizer[colorizerCount];
		// basic colors
		colorizers[0] = new SimpleColor(color(0), 0);
		colorizers[0].setDescrition("None");
    colorizers[1] = new SimpleColor(color(255), 1);
		colorizers[1].setDescrition("white");
    colorizers[2] = new SimpleColor(color(255, 0, 0), 2);
		colorizers[2].setDescrition("red");
    colorizers[3] = new SimpleColor(color(0, 255, 0), 3);
		colorizers[3].setDescrition("green");
    colorizers[4] = new SimpleColor(color(0, 0, 255), 4);
		colorizers[4].setDescrition("blue");
    colorizers[5] = new SimpleColor(color(0), 5);
		colorizers[5].setDescrition("black");
		// userPallet colors
    colorizers[6] = new PalletteColor(0, 6);
    colorizers[7] = new PalletteColor(1, 7);
    colorizers[8] = new PalletteColor(2, 8);
    colorizers[9] = new PalletteColor(3, 9);
    colorizers[10] = new PalletteColor(4, 10);
		colorizers[11] = new PalletteColor(5, 11);
		colorizers[12] = new PalletteColor(6, 12);
		colorizers[13] = new PalletteColor(7, 13);
		colorizers[14] = new PalletteColor(8, 14);
		colorizers[15] = new PalletteColor(9, 15);
		colorizers[16] = new PalletteColor(10, 16);
		colorizers[17] = new PalletteColor(11, 17);
		// changing color modes
		colorizers[18] = new RepetitionColor(18);
		colorizers[19] = new RandomPrimaryColor(19);
    colorizers[20] = new PrimaryBeatColor(20);
		colorizers[21] = new HSBFade(21);
    colorizers[22] = new FlashyPrimaryColor(22);
    colorizers[23] = new FlashyGray(23);
    colorizers[24] = new RandomRGB(24);
    colorizers[25] = new Strobe(25);
		colorizers[26] = new Flash(26);
		colorizers[27] = new JahColor(27);
    colorizers[28] = new CustomStrokeColor(28);
		colorizers[29] = new CustomFillColor(29);

		colorizers[30] = new MillisFade(30);
		colorizers[31] = new HSBLerp(31);
		if(MAKE_DOCUMENTATION) documenter.documentModes( (Mode[])colorizers, 'q', this, "Colorizers");
	}

  public Colorizer getColorizer(int _index){
    if(_index >= colorizerCount) _index = colorizerCount - 1;
    return colorizers[_index];
  }

	// apply colors to shape
  public void applyStyle(PShape _s){
		applyWeight(_s);
		applyColor(_s);
  }

	public void applyWeight(PShape _s){
		int strokeWidth = event.getStrokeWeight();
		int strokeMode = event.getStrokeMode();

    if(strokeMode != 0) {
			_s.setStrokeWeight(strokeWidth);
    }
	}

	public void applyColor(PShape _s){
		int fillMode = event.getFillMode();
		int strokeMode = event.getStrokeMode();
		int strokeAlpha = event.getStrokeAlpha();
		int fillAlpha = event.getFillAlpha();

		if (fillMode != 0){
			_s.setFill(true);
			_s.setFill(getFillColor());//getColorizer(fillMode).get(event, fillAlpha));
		}
		else _s.setFill(false);

		if(strokeMode != 0 && strokeAlpha != 0) {
			_s.setStroke(true);
			_s.setStroke(getStrokeColor());//getColorizer(strokeMode).get(event, strokeAlpha)); // _s.getStyle().stroke = getColorizer(strokeMode).get(event);//
		}
	}

  //apply settings to a canvas
  public void applyStyle(PGraphics _g){
		applyColor(_g);
		applyWeight(_g);
	}

	public void applyColor(PGraphics _g){
    int fillMode = event.getFillMode();
  	int strokeMode = event.getStrokeMode();
		int strokeAlpha = event.getStrokeAlpha();
		int fillAlpha = event.getFillAlpha();

    if(fillMode != 0){
      _g.fill(getFillColor());//getColorizer(fillMode).get(event, fillAlpha));
    }
    else _g.noFill();

    if(strokeMode != 0 && strokeAlpha != 0) {
      _g.stroke(getStrokeColor());//getColorizer(strokeMode).get(event, strokeAlpha));
    }
    else _g.noStroke();
  }


	public void applyWeight(PGraphics _g){
  	int strokeMode = event.getStrokeMode();
  	int strokeWidth = event.getStrokeWeight();
    if(strokeMode != 0) {
      _g.strokeWeight(strokeWidth);
    }
  }



	public int getStrokeColor(){
		return getColorizer(event.getStrokeMode()).get(event, event.getStrokeAlpha());
	}
	public int getFillColor(){
		return getColorizer(event.getFillMode()).get(event, event.getFillAlpha());
	}

  public String getName(){
  	return name;
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Misc painters
///////
////////////////////////////////////////////////////////////////////////////////////

class LineToLine extends Painter{
	String name = "lineToLine";

  public LineToLine(int _ind){
		modeIndex = _ind;
		name = "LineToLine";
		description = "Draws a line from a point interpolated on a segment to a point interpolated on a different segment, `d` key sets the different segment.";
  }
  public void paint(ArrayList<Segment> _segs, RenderableTemplate _rt){
    super.paint(_rt);
		applyStyle(canvas);
    PVector pos = new PVector(-10,-10);
		PVector prev = new PVector(-10,-10);
		if(_segs == null) return;
    for(Segment seg : _segs){
			prev = pos.get();
			pos = seg.getStrokePos(event.getLerp()).get();
			if(prev.x != -10 && pos.x != -10) vecLine(canvas, pos, prev);
    }
  }
}


/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode extends Mode{

	public RenderMode(){

	}

	public void doRender(RenderableTemplate _rt){}
}

/**
 * Parent class for all rendering that happens per segment.
 */
class PerSegment extends RenderMode{
	// selectorModeCount in Config.pde
	SegmentSelector[] segmentSelectors;

	SegmentPainter[] segmentPainters;
	int painterCount = 1;
	int segmentModeCount = 8;

	public PerSegment(){
		name = "PersegmentRender";
		description = "Things that render per each segment";
		segmentSelectors = new SegmentSelector[segmentModeCount];
		segmentSelectors[0] = new AllSegments(0);
		segmentSelectors[1] = new SequentialSegments(1);
		segmentSelectors[2] = new RunThroughSegments(2);
		segmentSelectors[3] = new RandomSegment(3);
		segmentSelectors[4] = new FastRandomSegment(4);
		segmentSelectors[5] = new SegmentBranch(5);
		segmentSelectors[6] = new RunThroughBranches(6);
		segmentSelectors[7] = new ConstantSpeed(7);


		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentSelectors, 'v', this, "SegmentSelector");
		// place holder for painter
		segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new SimpleBrusher(0);
	}

	public void doRender(RenderableTemplate _event){
		ArrayList<Segment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
    int index = 0;
    if(segList == null) return;
    for(Segment seg : segList){
    	_event.setSegmentIndex(index);
    	index++;
      if(seg != null && !seg.isHidden()) {
				_event.setLerp(seg.getLerp());
				getPainter(_event.getAnimationMode()).paintSegment(seg, _event);
			}
    }
	}

	public SegmentSelector getSelector(int _index){
		if(_index >= segmentModeCount) _index = segmentModeCount - 1;
		return segmentSelectors[_index];
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}



// Place brushes on segments
class BrushSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
  int painterCount = 1;

  public BrushSegment(int _ind){
		super();
		modeIndex = _ind;
  	segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new SimpleBrusher(0);
		// segmentPainters[1] = new FadedBrusher(1);


		name = "BrushSegment";
		description = "Render mode for drawing with brushes";
		//if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "None?");
    // segmentPainters[6] = new CircularBrusher();
  }
	// public SegmentPainter getPainter(int _index){
	// 	if(_index >= painterCount) _index = painterCount - 1;
	// 	return segmentPainters[_index];
	// }
}

// Make lines on segments
class LineSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 7;

	public LineSegment(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new FunLine(0);
    segmentPainters[1] = new FullLine(1);
    segmentPainters[2] = new MiddleLine(2);
		segmentPainters[3]  = new TrainLine(3);
    segmentPainters[4] = new Maypole(4);
    segmentPainters[5] = new SegToSeg(5);
		segmentPainters[6] = new AlphaLine(6);

		name = "LineSegment";
		description = "Draw lines related to segments";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "LineModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}

// Make circles on segments
class CircularSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 1;

	public CircularSegment(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentPainters[0] = new Elliptic(0);
    // segmentPainters[1] = new RadarPainter();
		name = "CircularSegment";
		description = "Circles and stuff";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "CicularModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}

// text rendering
class TextRenderMode extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 3;

	public TextRenderMode(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentPainters[0] = new TextWritter(0);
		segmentPainters[1] = new ScrollingText(1);
		segmentPainters[2] = new NiceText(2);


		name = "TextRenderMode";
		description = "Stuff that draws text";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "TextModes");
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}


class WrapLine extends PerSegment{
	LineToLine painter;

	public WrapLine(int _ind){
		super();
		modeIndex = _ind;
		painter = new LineToLine(0);
	}
	public void doRender(RenderableTemplate _rt) {
		//super.doRender(_rt);
		ArrayList<Segment> segList;
		SegmentSelector selector = getSelector(_rt.getSegmentMode()); //constrain(_rt.getSegmentMode(), 4, 5);
		// need to constrain to a few segmentSelectors...
		if(selector instanceof SegmentBranch){
			segList = selector.getSegments(_rt);
			painter.paint(segList, _rt);
		}
		else if(selector instanceof RunThroughBranches){
			segList = selector.getSegments(_rt);
			painter.paint(segList, _rt);
		}
		else {
			ArrayList<ArrayList<Segment>> trees = _rt.getSegmentGroup().getBranches();
			for(ArrayList<Segment> branch : trees){
				painter.paint(branch, _rt);
			}
		//println("=============================");
		}
	}
}

// Make lines on segments
class MetaFreelining extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 5;
	SegmentCommandParser segmentCommandParser;
	StrokeColorPicker strokeColorPicker;
	FillColorPicker fillColorPicker;


	public MetaFreelining(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentCommandParser = new SegmentCommandParser(0);
    segmentPainters[0] = segmentCommandParser;
		strokeColorPicker = new StrokeColorPicker(1);
    segmentPainters[1] = strokeColorPicker;
		fillColorPicker = new FillColorPicker(2);
		segmentPainters[2] = fillColorPicker;
		// new faded brush test;
		segmentPainters[3] = new FadedPointBrusher(3);
		segmentPainters[4] = new FadedLineBrusher(4);

		name = "MetaFreelining";
		description = "Use freeliner to automate itself.";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "MetaModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
	public void setCommandSegments(ArrayList<Segment> _segs){
		segmentCommandParser.setCommandSegments(_segs);
	}
	public void setCommandProcessor(CommandProcessor _cp){
		segmentCommandParser.setCommandProcessor(_cp);
		strokeColorPicker.setCommandProcessor(_cp);
		fillColorPicker.setCommandProcessor(_cp);

	}
	public void setColorMap(PImage _im){
		_im.loadPixels();
		strokeColorPicker.setColorMap(_im);
		fillColorPicker.setColorMap(_im);
	}
}



////////////////////////////////////////////////////////////////////////////////////
///////
///////    fill etc
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * Parent class for all rendering that happens with all segments.
 */
class Geometry extends RenderMode{
	GroupPainter[] groupPainters;
	int painterCount = 2;

	public Geometry(int _ind){
		modeIndex = _ind;
		name = "GeometryRender";
		description = "RenderModes that involve all segments.";
		groupPainters = new GroupPainter[painterCount];
		groupPainters[0] = new InterpolatorShape(0);
		groupPainters[1] = new InterpolatorShape(1);
		if(MAKE_DOCUMENTATION) documenter.documentModes(groupPainters, 'a', this, "FillModes");
		//groupPainters[2] = new FlashFiller();
	}

	public void doRender(RenderableTemplate _event){

		getPainter(_event.getAnimationMode()).paintGroup(_event);
	}

	public GroupPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return groupPainters[_index];
	}
}


//
// /**
//  * Parent class for all rendering that happens per segment.
//  */
// class PerSegmentOffset extends PerSegment{
//
//
//
// 	public PerSegmentOffset(){
//
// 	}
//
// 	public void doRender(RenderableTemplate _event){
// 		ArrayList<Segment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
//     int index = 0;
//     if(segList == null) return;
//     for(Segment seg : segList){
//     	_event.setSegmentIndex(index);
//     	index++;
//       if(seg != null) getPainter(_event.getAnimationMode()).paintSegment(seg, _event);
//     }
// 	}
//
// 	public SegmentSelector getSelector(int _index){
// 		if(_index >= SEGMENT_MODE_COUNT) _index = SEGMENT_MODE_COUNT - 1;
// 		return segmentSelectors[_index];
// 	}
//
// 	public SegmentPainter getPainter(int _index){
// 		if(_index >= painterCount) _index = PAINTER_COUNT - 1;
// 		return segmentPainters[_index];
// 	}
// }
//
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// the data structure shared between a SegmentGroup and Renderer
class RenderableTemplate extends TweakableTemplate{
	//
	TweakableTemplate sourceTemplate;

	SegmentGroup segmentGroup;

	// reference to what to draw on, layer system relies on this
	PGraphics canvas;

/*
 * Second tier, data that can change per beat.
 */
 	// Which beat we are on
	int beatCount;
	int rawBeatCount;
	int launchCount;
	int randomValue;
	int largeRandom;
	boolean direction;

/*
 * Third tier, data that changes every render
 */
 	// unitInterval of animation, aka lerper
	protected float unitInterval;
	float lerp;

/*
 * Fourth Tier, data can change multiple times per render
 */
	// Which iteration we are on
	int repetition;
	int segmentIndex;
	float angleMod;
	float scaledBrushSize;
	int colorCount;
	float hue;
	PShape brushShape;
	boolean updateBrush;
	/*
	 * Variable for internal use.
	 */
  float timeStamp;

	// for meta freelining
	ArrayList<Segment> executedSegments;

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Constructors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public RenderableTemplate(){
		super();
	}

	public RenderableTemplate(char _id){
		super(_id);
	}


/*
 * Constructor
 * @param SegmentGroup in question
 */
	public RenderableTemplate(TweakableTemplate _te, SegmentGroup _sg){
		super(_te.getTemplateID());
		//println(_te.getStrokeMode());
		sourceTemplate = _te;
		copy(_te);
		segmentGroup = _sg;
		beatCount = -1;
		brushShape = null;
		updateBrush = true;
		executedSegments = new ArrayList();
	}

/*
 * Start a render event
 * @param float unitInterval reference
 */
	public void init(float _ts){
		timeStamp = _ts;
		setrandomValue((int)random(100));
    setLargeRan((int)random(10000));
	}

	public void setCanvas(PGraphics _pg){
		canvas = _pg;
	}

	public void setBeatCount(int _beat){
		if(beatCount != _beat){
			beatCount = _beat;
			setrandomValue((int)random(100));
	    setLargeRan((int)random(10000));
			clearExecutedSegments();
		}
		colorCount = 0;
		// this updates according to source template...
		copy(sourceTemplate);
		// find the scaled size, the brushSize of the source template may have changed
		scaledBrushSize = brushSize * (BRUSH_SCALING ? segmentGroup.getBrushScaler() : 1.0f);
	}

	public void setRawBeatCount(int _raw){
		rawBeatCount = _raw;
	}

	public void setUnitInterval(float _u){
		unitInterval = _u;
	}

	public void forceScaledBrushSize(float _s){
		scaledBrushSize = _s;
	}

	public float conditionLerp(float _lrp){
		if(_lrp > timeStamp) return _lrp - timeStamp;
		else return (_lrp+1) - timeStamp; // _lrp < timestamp
	}

	public void setLastPosition(PVector _pv){
		sourceTemplate.setLastPosition(_pv);
	}

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Mutators
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void setLerp(float _lrp){
		lerp = _lrp;
	}

	public void setrandomValue(int _rn){
 		randomValue = _rn;
 	}

 	public void setRepetition(int _c){
 		repetition = _c;
 	}

 	public void setSegmentIndex(int _i){
 		segmentIndex = _i;
 	}

 	public void setLargeRan(int _lr){
 		largeRandom = _lr;
 	}

 	public void setAngleMod(float _ang){
 		angleMod = _ang;
 	}

 	public void setDirection(boolean _dir){
 		direction = _dir;
 	}

 	public void setHue(float _h){
 		hue = _h;
 	}

	public void setBrushShape(PShape _brush){
		updateBrush = false;
		brushShape = _brush;
	}

	public int setBrushSize(int _s){
		updateBrush = true;
		return super.setBrushSize(_s, 5000);
	}



	// public int setBrushMode(int _m){
	// 	updateBrush = true;
	// 	return super.setBrushMode(_m);
	// }
	public void executeSegment(Segment _seg){
		executedSegments.add(_seg);
	}
	public void clearExecutedSegments(){
		executedSegments.clear();
	}
	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Accessors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public boolean doUpdateBrush(){
		return updateBrush;
	}

	public final int getGroupId(){
		return segmentGroup.getID();
	}

	public final SegmentGroup getSegmentGroup(){
		return segmentGroup;
	}

	public final PGraphics getCanvas(){
		return canvas;
	}

/*
 * Second tier accessors
 */
 	public int getBeatCount(){
 		return beatCount;
 	}

 	public final int getRawBeatCount(){
 		return rawBeatCount;
 	}

 	public final int getRandomValue(){
 		return randomValue;
 	}

 	public final int getLargeRandomValue(){
 		return largeRandom;
 	}

 	public final boolean getDirection(){
 		return direction;
 	}

	/*
	 * Third tier accessors
	 */
 	public float getUnitInterval(){
 		return unitInterval;
 	}

 	public final float getLerp(){
 		return lerp;
 	}

 	// add with potential
  public float getAngleMod(){
		return angleMod;
  }

/*
 * Fourth Tier accessors
 */
	public final int getRepetition(){
		return repetition;
	}

	public final int getSegmentIndex(){
		return segmentIndex;
	}

	public final float getScaledBrushSize(){
		return scaledBrushSize;
	}

	public final int getColorCount(){
		return colorCount++;
	}

	public final float getHue(){
		return hue;
	}

	public final PShape getBrushShape(){
		return brushShape;
	}

	public ArrayList<Segment> getExecutedSegments(){
		return executedSegments;
	}


	// // ask if the brush needs updating
	// public final boolean updateBrush(){
	// 	if(updateBrush || brush == null){
	// 		updateBrush = false;
	// 		return true;
	// 	}
	// 	return false;
	// }
}



// this is for triggering system
class KillableTemplate extends RenderableTemplate{

	float unitIntervalOffset;
	boolean toKill;

	/*
	 * Constructor
	 * @param SegmentGroup in question
	 */
	public KillableTemplate(TweakableTemplate _te, SegmentGroup _sg){
		super(_te.getTemplateID());
		sourceTemplate = _te;
		copy(_te);
		// force enable?
		if(enablerMode != 0) enablerMode = 1;
		segmentGroup = _sg;
		beatCount = -1;
		toKill = false;
	}


	public void copy(TweakableTemplate _te){
		super.copy(_te);
		launchCount = _te.getLaunchCount();
	}

	public void setOffset(float _o){
		unitIntervalOffset = _o;
	}

	public void setUnitInterval(float _u){
		float ha =   _u - unitIntervalOffset;
		if(ha < 0.0f) ha += 1.0f;
		if(ha < unitInterval) toKill = true;
		unitInterval = ha;
	}

	// does not update...
	public void setBeatCount(int _beat){
		if(beatCount != _beat){
			beatCount = _beat;
			setrandomValue((int)random(100));
	    setLargeRan((int)random(10000));
		}
		colorCount = 0;
		// this updates according to source template...
		//copy(sourceTemplate);
		// find the scaled size, the brushSize of the source template may have changed
		float sb = brushSize;// * segmentGroup.getBrushScaler();
		//scaledBrushSize = brushSize;
		if(sb != scaledBrushSize) {
			updateBrush = true;
			scaledBrushSize = sb;
		}
	}

	public boolean isDone(){
		return toKill;
	}

	public int getBeatCount(){
 		return launchCount;
 	}

}

// Repetition was iterator
// returns different unit intervals in relation to
// unit intervals that are negative means reverse.
class Repetition extends Mode {


	public Repetition(){
		name = "repetition";
	}

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList _flts = new FloatList();
		_flts.append(_unit);
		return _flts;
	}
}


/**
 * One single unit interval
 */
class Single extends Repetition {

	public Single(int _ind){
		super();
		modeIndex = _ind;
		name = "single";
		description = "only draw template once";
	}

	// public FloatList getFloats(RenderableTemplate _rt){
	// 	FloatList flts = new FloatList();
	// 	rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
	// 	float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
	// 	flts.append(lrp*rev);
	// 	return flts;
	// }
}

/**
 * Evenly spaced
 */
class EvenlySpaced extends Repetition{
	public EvenlySpaced(){}

	public EvenlySpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "EvenlySpaced";
		description = "Render things evenly spaced";
	}

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		int _count = _rt.getRepetitionCount();
		return getEvenlySpaced(_unit, _count);
	}

	public FloatList getEvenlySpaced(float _lrp, int _count){
		FloatList flts = new FloatList();
		float amount = abs(_lrp)/_count;
		float increments = 1.0f/_count;
		for (int i = 0; i < _count; i++)
			flts.append((increments * i) + amount);
		return flts;
	}
}

class EvenlySpacedWithZero extends EvenlySpaced{
	public EvenlySpacedWithZero(int _ind){
		super();
		modeIndex = _ind;
		name = "EvenlySpacedWithZero";
		description = "Render things evenly spaced with a fixed one at the begining and end";
	}
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = super.getFloats(_rt, _unit);
		flts.append(0);
		flts.append(0.999f);
		return flts;
	}
}

class ExpoSpaced extends EvenlySpaced{
	public ExpoSpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "ExpoSpaced";
		description = "RenderMultiples but make em go faster";
	}
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt, _unit))  flts.append(pow(_f,2));
		return flts;
	}
}

/**
 * TwoFull
 */
class TwoFull extends Repetition{
	public TwoFull(int _ind){
		super();
		modeIndex = _ind;
		name = "TwoFull";
		description = "Render twice in opposite directions";
	}

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		flts.append(_unit);
		flts.append(_unit*-1.0f);
		return flts;
	}
}

class TwoSpaced extends EvenlySpaced{
	public TwoSpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "TwoFull";
		description = "Render twice in opposite directions";
	}
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt, _unit)){
			flts.append(_f);
			flts.append(_f*-1.0f);
		}
		return flts;
	}
}


class Reverse extends Mode {

  public Reverse(){}
  public Reverse(int _ind){
    modeIndex = _ind;
    name = "Reverse";
    description = "Goes reverse";
  }

  public float getDirection(RenderableTemplate _event){
    return -1.0f;
  }
}

class NotReverse extends Reverse{

  public NotReverse(int _ind){
    modeIndex = _ind;
    name = "NotReverse";
    description = "Goes forward";
  }

  public float getDirection(RenderableTemplate _event){
    return 1.0f;
  }
}


class BackForth extends Reverse{
	public BackForth(int _ind){
  modeIndex = _ind;}

	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 2 == 0) return 1.0f;
		else return -1.0f;
	}
}


class TwoTwoReverse extends Reverse{
	public TwoTwoReverse(int _ind){
    modeIndex = _ind;
    name = "TwoTwoReverse";
    description = "Goes twice forward then twice in reverse";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 4 > 1) return 1.0f;
		else return -1.0f;
	}
}

class RandomReverse extends Reverse{
	public RandomReverse(int _ind){
    modeIndex = _ind;
    name = "RandomReverse";
    description = "Might go forward, might go backwards";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getRandomValue() % 2 == 1) return 1.0f;
	   else return -1.0f;
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * A segment consist of two vertices with special other data as a offset line.
 */
class Segment {
  // these are the main coordinates of the start and end of a segment
  PVector pointA;
  PVector pointB;
  // these are the coordinates of the offset of the brush size
  PVector brushOffsetA;
  PVector brushOffsetB;
  PVector strokeOffsetA;
  PVector strokeOffsetB;

  // these are alternative positions for pointA and pointB
  PVector ranA;
  PVector ranB;

  // previous and or next segments, needed to create offset line
  Segment neighbA;
  Segment neighbB;

  // center position of the segment
  PVector center;

  float scaledSize;
  float strokeWidth;

  float angle;
  //float anglePI;
  boolean centered;
  boolean clockWise;
  float ranFloat;
  int id;
  float length;
  float lerp;

  String segmentText;

  boolean hiddenSegment;

  public Segment(PVector pA, PVector pB) {

    pointA = pA.get();
    pointB = pB.get();
    center = new PVector(0, 0, 0);
    newRan();
    brushOffsetA = new PVector(0,0,0);
    brushOffsetB = new PVector(0,0,0);
    strokeOffsetA = new PVector(0,0,0);
    strokeOffsetB = new PVector(0,0,0);
    scaledSize = 10;
    strokeWidth  = 3;
    centered = false;
    lerp = 0;
    length = 0;
    updateAngle();
    segmentText = "freeliner!";
    hiddenSegment = false;
  }

  public void updateAngle(){
    angle = atan2(pointA.y-pointB.y, pointA.x-pointB.x);
    //anglePI = angle + PI;
    if(pointA.x > pointB.x){
      if(pointA.y > pointB.y) clockWise = false;
      else clockWise = true;
    }
    else if(pointA.y > pointB.y) clockWise = true;
    else clockWise = false;
    length = dist(pointA.x, pointA.y, pointB.x, pointB.y);
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void newRan(){
    ranA = new PVector(pointA.x+random(-100, 100), pointA.y+random(-100, 100), 0);
    ranB = new PVector(pointB.x+random(-100, 100), pointB.y+random(-100, 100), 0);
    ranFloat = 1+random(50)/100.0f;
  }

  public void setNeighbors(Segment a, Segment b){
    neighbA = a;
    neighbB = b;
    findOffset();
  }

  private void findOffset() {
    if(neighbA == null || neighbB == null) return;
    brushOffsetA = inset(pointA, neighbA.getPointA(), pointB, center, scaledSize + strokeWidth, neighbA.getPointB());
    brushOffsetB = inset(pointB, pointA, neighbB.getPointB(), center, scaledSize + strokeWidth, neighbB.getPointA());
    strokeOffsetA = inset(pointA, neighbA.getPointA(), pointB, center, strokeWidth, neighbA.getPointB());
    strokeOffsetB = inset(pointB, pointA, neighbB.getPointB(), center, strokeWidth, neighbB.getPointA());
  }

  public void setPointA(PVector p){
    pointA = p.get();
    updateAngle();
  }

  public void setPointB(PVector p){
    pointB = p.get();
    updateAngle();
  }

  public void setCenter(PVector c) {
    centered = true;
    //scaledSize = 0;
    center = c.get();
    findOffset();
  }

  public void unCenter(){
    centered = false;
  }

  public void setSize(float _s){
    if(_s != scaledSize && centered){
      scaledSize = _s;
      findOffset();
    }
  }

  public void setStrokeWidth(float _w){
    if(_w != scaledSize && centered){
      strokeWidth = _w;
      findOffset();
    }
  }

  public void setText(String w){
    segmentText = w;
  }

  public void setID(int _id){
    id =_id;
  }

  public void toggleHidden(){
    hiddenSegment = !hiddenSegment;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Offset by brush size
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * This is to generate new vertices in relation to brush size.
   * @param PVector vertex to offset
   * @param PVector previous neighboring vertex
   * @param PVector following neighboring vertex
   * @param PVector center of shape
   * @param float distance to offset
   * @param PVector an other to point to check if the offset should be perpendicular
   * @return PVector offseted vertex
   */
  public PVector inset(PVector p, PVector pA, PVector pB, PVector c, float d, PVector ot) {
    float angleA = (atan2(p.y-pA.y, p.x-pA.x));
    float angleB = (atan2(p.y-pB.y, p.x-pB.x));
    float A = radianAbs(angleA);
    float B = radianAbs(angleB);
    float ang = abs(A-B)/2; //the shortest angle
    d = (d/2);
    if(p.dist(ot) > 3.0f) ang = HALF_PI + angle;
    else {
      d = d/sin(ang);
      if (A<B) ang = (ang+angleA);
      else ang = (ang+angleB);
    }

    PVector outA = new PVector(cos(ang)*d, sin(ang)*d, 0);
    PVector outB = new PVector(cos(ang+PI)*d, sin(ang+PI)*d, 0);
    outA.add(p);
    outB.add(p);

    PVector offset;
    if (c.dist(outA) < c.dist(outB)) return outA;
    else  return outB;
  }

  public float radianAbs(float a) {
    while (a<0) {
      a+=TWO_PI;
    }
    while (a>TWO_PI) {
      a-=TWO_PI;
    }
    return a;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void setLerp(float _lrp){
    lerp = _lrp;
  }

  /**
   * POINT POSITIONS
   */

  /**
   * Get the first vertex
   * @return PVector pointA
   */
  public final PVector getPointA(){
    return pointA;
  }

  /**
   * Get the second vertex
   * @return PVector pointB
   */
  public final PVector getPointB(){
    return pointB;
  }

  /**
   * Get pointA's strokeWidth offset
   * @return PVector offset of stroke width
   */
  public final PVector getStrokeOffsetA(){
    if(!centered) return pointA;
    return strokeOffsetA;
  }

  /**
   * Get pointB's strokeWidth offset
   * @return PVector offset of stroke width
   */
  public final PVector getStrokeOffsetB(){
    if(!centered) return pointB;
    return strokeOffsetB;
  }

  /**
   * Get pointA's brushSize offset
   * @return PVector offset of brushSize
   */
  public final PVector getBrushOffsetA(){
    if(!centered) return pointA;
    return brushOffsetA;
  }

  /**
   * Get pointB's brushSize offset
   * @return PVector offset of brushSize
   */
  public final PVector getBrushOffsetB(){
    if(!centered) return pointB;
    return brushOffsetB;
  }

  /**
   * INTERPOLATED POSTIONS
   */

  /**
   * Interpolate between pointA and pointB, offset by brush if centered
   * @param float unit interval (lerp)
   * @return PVector interpolated position
   */
  public final PVector getBrushPos(float _l) {
    if (centered) return vecLerp(brushOffsetA, brushOffsetB, _l);
    else return vecLerp(pointA, pointB, _l);
  }

  /**
   * Interpolate between pointA and pointB, offset by strokeWidth if centered
   * @param float unit interval (lerp)
   * @return PVector interpolated position
   */
  public final PVector getStrokePos(float _l) {
    if (centered) return vecLerp(strokeOffsetA, strokeOffsetB, _l);
    else return vecLerp(pointA, pointB, _l);
  }

  //random pos
  public final PVector getRanA() {
    return ranA;
  }

  public final PVector getRanB() {
    return ranB;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }

  public final boolean isClockWise(){
    return clockWise;
  }

  public final boolean isHidden(){
    return hiddenSegment;
  }

  public final float getAngle(boolean inv) {
    if(inv) return angle+PI;
    return angle;
  }

  public final float getRanFloat(){
    return ranFloat;
  }

  public final float getLength() {
    return length;
  }

  public final float getLerp(){
    return lerp;
  }

  public final PVector getCenter() {
    return center;
  }

  public final PVector getMidPoint() {
    return vecLerp(pointA, pointB, 0.5f);
  }

  public final String getText(){
    return segmentText;
  }

  public final Segment getNext(){
    return neighbB;
  }

  public final Segment getPrev(){
    return neighbA;
  }
  public final int getID(){
    return id;
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * SegmentGroup is an arrayList of Segment with one center point
 * <p>
 * A group of segments that can have a center, renderer tags, a brush size scalar and a random number.
 * </p>
 *
 * @see Renderer
 */

class SegmentGroup implements FreelinerConfig{
  final int ID;
  float brushScaler = 1.0f;
  int sizer = 10;
  int priority = 0;
  PShape itemShape;

  ArrayList<Segment> segments;
  int segCount = 0;
  ArrayList<Segment> sortedSegments;
  int sortedSegCount = 0;
  ArrayList<ArrayList<Segment>> treeBranches;

  TemplateList templateList;
  PVector center;
  PVector segmentStart;
  boolean firstPoint;
  boolean seperated;

  boolean centered;
  boolean centerPutting;

  boolean launchit = false;
  boolean incremented = false;

  //for roations
  boolean clockwise = false;

  // new string
  String groupText = "";

  /**
   * Create an new SegmentGroup
   * @param  identification interger
   */
  public SegmentGroup(int _id) {
    ID = _id;
    init();
  }

  /**
   * Initialises variables, can be used to reset a group.
   */
  public void init(){
    segments = new ArrayList();
    sortedSegments = new ArrayList();
    treeBranches = new ArrayList();
    templateList = new TemplateList();
    segmentStart = new PVector(-10, -10, -10);
    center = new PVector(-10, -10, -10);
    firstPoint = true;
    centered = false;
    centerPutting = false;
    seperated = false;
    generateShape();
    groupText = "hi, im geometry "+ID;
  }

  public void updateGeometry(){
    findRealNeighbors();
    sortSegments();
    setNeighbors();
    updateAngles();
    clockwise = findDirection();
    if(centered) placeCenter(center);
    generateShape();
    if(segments.size() == 0) sortedSegments.clear();
  }


  private void updateAngles(){
    for(Segment seg : segments) seg.updateAngle();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Management, Segment creation and such
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Start a new segment from a coordinate
   * @param PVector starting coordinate
   */
  private void startSegment(PVector p) {
    if(firstPoint) center = p.get();
    segmentStart = p.get();
    firstPoint = false;
  }

  /**
   * Make a segment by placing the second point.
   * A few things are updated such as the neighbors and shape.
   * @param PVector ending coordinate
   */
  private void endSegment(PVector p) {
    addSegment(segmentStart, p);
    segmentStart = p.get();
    seperated = false;
    updateGeometry();
  }

  /**
   * Make a segment by giving a start and a end
   * @param PVector starting coordinate
   * @param PVector ending coordinate
   */
  public void addSegment(PVector _a, PVector _b){
    segments.add(new Segment(_a, _b));
    segCount++;
    updateGeometry();
  }

  /**
   * Make a segment by giving a start and a end
   * @param Segment to add
   */
  public void addSegment(Segment _seg){
    segments.add(_seg);
    segCount++;
    updateGeometry();
  }

  /**
   * Remove a specific segment.
   * @param Segment to remove
   */
  public void deleteSegment(Segment _seg){
    if(segments.remove(_seg)){
      segCount--;
      updateGeometry();
    }
  }

  /**
   * Start a new segment somewhere else than the current segmentStart
   * A few things are updated such as the neighbors and shape.
   * @param PVector ending coordinate
   */
  private void breakSegment(PVector p) {
    seperated = true;
    segmentStart = p.get();
  }

  /**
   * Nudge the segmentStart or the center.
   * @param PVector ending coordinate
   */
  private void nudgeSegmentStart(PVector p) {
    PVector np = segmentStart.get();
    // nudge the last point.
    if (!centerPutting) {
      np.add(p);
      if (segCount == 0 || seperated) breakSegment(np);
      else {
        undoSegment();
        endSegment(np);
      }
    }
    // nudge the center
    else {
      np = center.get();
      np.add(p);
      placeCenter(np);
      centerPutting = true;
      updateGeometry();
    }
  }

  /**
   * Nudge the segmentStart.
   * @param PVector ending coordinate
   */
  private void undoSegment() {
    if (segCount > 0) {
      float dst = segmentStart.dist(segments.get(segCount-1).pointB.get());
      if(dst > 0.001f){
        segmentStart = segments.get(segCount-1).pointB.get();
      }
      else {
        segmentStart = segments.get(segCount-1).pointA.get();
        segments.remove(segCount-1);
        segCount--;
      }
      updateGeometry();
    }
  }

  /**
   * Set the center point
   * @param PVector center coordinate
   */
  private void placeCenter(PVector c) {
    center = c.get();
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        segments.get(i).setCenter(center);
      }
      centered = true;
      generateShape();
    }
    centerPutting = false;
  }

  /**
   * Uncenter
   * @param PVector center coordinate
   */
  private void unCenter() {
    centered = false;
    for(Segment seg : segments)
      seg.unCenter();
    centerPutting = false;
  }


  /**
   * Make a PShape of the geometry
   */
  private void generateShape() {
    itemShape = createShape();
    itemShape.textureMode(NORMAL);
    itemShape.beginShape();
    itemShape.strokeJoin(STROKE_JOIN);
    itemShape.strokeCap(STROKE_CAP);
    float _x = 0;
    float _y = 0;
    if(segCount!=0){
      for (Segment seg : sortedSegments){
        _x = seg.getPointA().x;
        _y = seg.getPointA().y;
        itemShape.vertex(_x, _y, _x/width, _y/height);
      }
      _x = sortedSegments.get(0).getPointA().x;
      _y = sortedSegments.get(0).getPointA().y;
      itemShape.vertex(_x, _y, _x/width, _y/height);
    }
    else {
      itemShape.vertex(0,0);
      itemShape.vertex(0,0);
    }

    itemShape.endShape(CLOSE);//CLOSE dosent work...
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment classification
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Generate a 2D segment ArrayList starting from the first segment
   */
  private void findRealNeighbors(){
    if(segments.size() < 1) return;
    treeBranches = new ArrayList();
    ArrayList<Segment> roots = new ArrayList();
    // find first segments, layer 1
    boolean root = true;
    for(Segment toCheck : segments){
      root = true;
      for(Segment seg : segments){
        if(toCheck.getPointA().dist(seg.getPointB()) < 0.1f){
          root = false;
        }
      }
      if(toCheck == segments.get(0)) root = true; // added to force segment 0 as a root
      if(root) roots.add(toCheck);
    }
    if(roots.size() == 0) roots.add(segments.get(0));
    treeBranches.add(roots);

    boolean keepSearching = true;
    int ind = 0;
    while(keepSearching){
      ArrayList<Segment> next = getNext(treeBranches.get(ind++));
      if(next.size() > 0) treeBranches.add(next);
      else keepSearching = false;
    }
  }

  /**
   * Looks for segments not sorted.
   */
  private ArrayList<Segment> getNext(ArrayList<Segment> _segs){
    ArrayList<Segment> nextSegs = new ArrayList();
    boolean duplicate = false;
    for(Segment seg : _segs){
      for(Segment next : segments){
        if(seg.getPointB().dist(next.getPointA()) < 0.001f){
          // check duplicates
          duplicate = false;
          for(ArrayList<Segment> br : treeBranches){
            for(Segment se : br){
              if(next == se) duplicate = true;
            }
          }
          if(!duplicate) nextSegs.add(next);
        }
      }
    }
    return nextSegs;
  }

  /**
   * segments need to be sorted if a segments gets deleted and remplaced by 2 or more new segments.
   */
  private void sortSegments(){
    sortedSegments.clear();
    int _index = 0;
    for(ArrayList<Segment> brnch : treeBranches){
      for(Segment seg : brnch){
        sortedSegments.add(seg);
        seg.setID(_index);
      }
      _index++;
    }
    sortedSegCount = sortedSegments.size();
    if(sortedSegCount != segCount){
      sortedSegments.clear();
      for(Segment seg : segments)
        sortedSegments.add(seg);
      sortedSegCount = sortedSegments.size();
    }
  }

  /**
   * Set each segments direct neighbors
   */
  private void setNeighbors() {
    int v1 = 0;
    int v2 = 0;
    if (segCount>0) {
      for (int i = 0; i < sortedSegCount; i++) {
        v1 = i-1;
        v2 = i+1;
        if (i==0) v1 = sortedSegCount-1; // maybe wrong
        if (i >= sortedSegCount-1) v2 = 0;
        Segment s1 = getSegment(v1);
        Segment s2 = getSegment(v2);
        if(s1 != null && s2 != null)
          getSegment(i).setNeighbors(s1, s2);
        //segments.get(i).setNeighbors(segments.get(v1), segments.get(v2));
      }
    }
  }

  private boolean findDirection(){
    for(Segment seg : sortedSegments){
      if(seg != null) return seg.isClockWise();
      // int ax = int(seg.getPointA().x);
      // int bx = int(seg.getPointB().x);
      // if( ax > bx) return true;
      // else if (ax < bx) return false;
    }
    return false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment access
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // deprecate
  public final ArrayList<Segment> getSegments() {
    return sortedSegments;
  }

  // Segment accessors
  public Segment getSegment(int _index){
    //if(_index >= segments.size()) return null;
    if(_index >= 0 && _index < sortedSegCount) return sortedSegments.get(_index);
    return null;
  }

  // Segment accessors
  public Segment getSegmentSequence(int _index){
    //if(_index >= segments.size()) return null;
    if(_index >= 0) return sortedSegments.get(_index%sortedSegCount);
    return null;
  }

  public Segment getSegmentByTotalLength(float _lerp){
    // _lerp
    float _totalLength = 0;
    for(Segment _seg : segments) _totalLength += _seg.getLength();
    float _target = _totalLength*_lerp;
    float _tracker = 0;
    for(Segment _seg : segments){
      _tracker += _seg.getLength();
      if(_tracker >= _target){
        float _dst = _tracker - _target;
        _seg.setLerp((_seg.getLength()-_dst)/_seg.getLength());
        return _seg;
      }
    }
    return null;
  }

  public ArrayList<ArrayList<Segment>> getBranches(){
    return treeBranches;
  }

  public ArrayList<Segment> getBranch(int _i){
    if(treeBranches.size() == 0 || _i < 0) return null;
    return treeBranches.get(_i%treeBranches.size());
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void mouseInput(int mb, PVector c) {
    if (mb == 37 && centerPutting) placeCenter(c);
    else if (mb == 39 && centerPutting) unCenter();
    else if (mb == 37 && firstPoint) startSegment(c);
    else if (mb == 37 && !firstPoint) endSegment(c);
    else if (mb == 39) undoSegment();
    else if (mb == 3) breakSegment(c);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void toggleTemplate(TweakableTemplate _te) {
    templateList.toggle(_te);
  }
  // check_this
  public void setText(String w, int v) {
    if (segCount >= 1 && v == -1) segments.get(segCount-1).setText(w);
    else if (v<segCount) segments.get(v).setText(w);
  }
  // set text gor group
  public void setText(String _txt){
    groupText = _txt;
    distributeText(groupText);
  }

  private void distributeText(String _txt){
    // split text up to fit segments?
  }


  public void newRan(){
    for (int i = 0; i < segCount; i++) {
      segments.get(i).newRan();
    }
  }

  public boolean toggleCenterPutting(){
    centerPutting = !centerPutting;
    return centerPutting;
  }

  public int setBrushScaler(int s){
    sizer = numTweaker(s, sizer);
    brushScaler = sizer/10.0f;
    return sizer;
  }

  public void setTemplateList(TemplateList _tl){
    templateList.copy(_tl);
  }

  public int tweakPriority(int _v){
      priority = numTweaker(_v, priority);
      return priority;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final int getPriority(){
      return priority;
  }

  public final int getID(){
    return ID;
  }

  public int getCount(){
    return segCount;
  }

  public final PShape getShape(){
    return itemShape;
  }

  public final PVector getCenter(){
    return center;
    //if(centered) return center;
    //else return segmentStart;
  }

  public final PVector getTagPosition(){
    if(centered) return center;
    else return segmentStart;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }

  public final boolean isEmpty(){
    return segments.isEmpty();
  }

  public final boolean isClockWise(){
    return clockwise;
  }

  public final PVector getSegmentStart(){
    return segmentStart;
  }

  public final TemplateList getTemplateList() {
    return templateList;
  }

  public final PVector getLastPoint() {
    return segmentStart.get();
  }

  public final float getBrushScaler(){
    return brushScaler;
  }

  public final String getText(){
    return groupText;
  }

}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


// base class
class SegmentPainter extends Painter{

	// reference to the _event being rendered
	// RenderableTemplate _event;
	public SegmentPainter(){}
	public SegmentPainter(int _ind){
		modeIndex = _ind;
		name = "segmentPainter";
		description = "paints segments";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paint(_event);
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Line Painters
///////
////////////////////////////////////////////////////////////////////////////////////

// base class for line painter
class LinePainter extends SegmentPainter{
	public LinePainter(){}
	public LinePainter(int _ind){
		modeIndex = _ind;
		name = "LinePainter";
		description = "base class for making lines";
	}

	// paint the segment in question
	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setStrokeWidth(_event.getStrokeWeight());
		applyStyle(event.getCanvas());
	}
}

class FunLine extends LinePainter {

	public FunLine(int _ind){
		modeIndex = _ind;
		name = "FunLine";
		description = "Makes a line between pointA and a position.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), getPosition(_seg));//_seg.getStrokePos(event.getLerp()));
	}
}

class FullLine extends LinePainter {

	public FullLine(int _ind){
		modeIndex = _ind;
		name = "FullLine";
		description = "Draws a line on a segment, not animated.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}

class AlphaLine extends LinePainter{
	public AlphaLine(int _ind){
		modeIndex = _ind;
		name = "AlphaLine";
		description = "modulates alpha channel, made for LEDs";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		int _col = getColorizer(event.getStrokeMode()).get(event,PApplet.parseInt(event.getLerp()*event.getStrokeAlpha()));
		if(PApplet.parseInt(event.getLerp()*event.getStrokeAlpha())==0) return;//event.getCanvas().noStroke();
		else event.getCanvas().stroke(_col);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}


class TrainLine extends LinePainter {

	public TrainLine(int _ind){
		modeIndex = _ind;
		name = "TrainLine";
		description = "Line that comes out of point A and exits through pointB";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float lrp = event.getLerp();
		if(lrp < 0.5f) vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokePos(lrp*2));
		else vecLine(event.getCanvas(), _seg.getStrokePos(2*(lrp-0.5f)), _seg.getStrokeOffsetB());

		// test with enterpolator...
		// if(lrp < 0.5){
		// 	_event.setLerp(lrp*2.0);
		// 	vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), getPosition(_seg));
		// 	_event.setLerp(lrp);
		// }
		// else {
		// 	_event.setLerp(2*(lrp-0.5));
		// 	vecLine(event.getCanvas(), getPosition(_seg), _seg.getCenter());
		// 	_event.setLerp(lrp);
		// }
	}
}


class MiddleLine extends LinePainter {

	public MiddleLine(int _ind){
		modeIndex = _ind;
		name = "MiddleLine";
		description = "line that expands from the middle of a segment.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float aa = (event.getLerp()/2)+0.5f;
		float bb = -(event.getLerp()/2)+0.5f;
		vecLine(event.getCanvas(), _seg.getStrokePos(aa), _seg.getStrokePos(bb));
	}
}

class Maypole extends LinePainter {
	public Maypole(int _ind){
		modeIndex = _ind;
		name = "Maypole";
		description = "Draw a line from center to position.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getCenter(), getPosition(_seg));
	}
}


class Elliptic extends LinePainter {
	public Elliptic(int _ind){
		modeIndex = _ind;
		name = "Elliptic";
		description = "Makes a expanding circle with segment as final radius.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = _seg.getPointA();
		float sz = pos.dist(_seg.getStrokePos(event.getLerp()))*2;
		event.getCanvas().ellipse(pos.x, pos.y, sz, sz);
	}
}

class SegToSeg extends LinePainter{
	public SegToSeg(int _ind){
		modeIndex = _ind;
		name = "SegToSeg";
		description = "Draws a line from a point on a segment to a point on a different segment. Affected by `e`";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		Segment secondSeg = getNextSegment(_seg, _event.getMiscValue());
		vecLine(event.getCanvas(), getPosition(_seg), getPosition(secondSeg));
		//vecLine(event.getCanvas(), _seg.getStrokePos(_event.getLerp()), secondSeg.getStrokePos(_event.getLerp()));
	}

	public Segment getNextSegment(Segment _seg, int _iter){
		Segment next = _seg.getNext();
		if(_iter == 0) return next;
		else return getNextSegment(next, _iter - 1);
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Brush System
///////
////////////////////////////////////////////////////////////////////////////////////

// base brush putter
class BrushPutter extends SegmentPainter{
	final int BRUSH_COUNT = 10;
	Brush[] brushes;
	// brush count in Config.pde

	public BrushPutter(){
		loadBrushes();
		name = "BrushPainter";
		description = "Place brush onto segment. Affected by `e`.";
	}

	public void loadBrushes(){
		brushes = new Brush[BRUSH_COUNT];
		brushes[0] = new PointBrush(0);
		brushes[1] = new LineBrush(1);
		brushes[2] = new CircleBrush(2);
		brushes[3] = new ChevronBrush(3);
		brushes[4] = new SquareBrush(4);
		brushes[5] = new XBrush(5);
		brushes[6] = new TriangleBrush(6);
		brushes[7] = new SprinkleBrush(7);
		brushes[8] = new LeafBrush(8);
		brushes[9] = new CustomBrush(9);
		if(MAKE_DOCUMENTATION) documenter.documentModes(brushes,'a', this, "Brushes");
	}

	public Brush getBrush(int _index){
		if(_index >= BRUSH_COUNT) _index = BRUSH_COUNT - 1;
		return brushes[_index];
	}


	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setSize(_event.getScaledBrushSize()+_event.getStrokeWeight());
	}

	// regular putShape
	public void putShape(PVector _p, float _a){
		PShape shape_;
    shape_ = getBrush(event.getAnimationMode()).getShape(event);
		if(shape_ == null) return;
    // applyStyle(shape_);
		applyColor(shape_);
		float scale = event.getBrushSize() / 20.0f; // devided by base brush size
		shape_.setStrokeWeight(event.getStrokeWeight()/scale);
		canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a+ HALF_PI);
		canvas.scale(scale);
		canvas.shape(shape_);
		canvas.popMatrix();
	}
}

class SimpleBrusher extends BrushPutter{

	public SimpleBrusher(int _ind){
		modeIndex = _ind;
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		putShape(getPosition(_seg), getAngle(_seg, _event));
	}
}

class FadedPointBrusher extends BrushPutter{
	public FadedPointBrusher(int _ind){
		modeIndex = _ind;
		name = "FadedBrusher";
		description = "same as brush but adds a faded edge";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//putShape(_seg.getBrushPos(_event.getLerp()), _seg.getAngle(_event.getDirection()) + _event.getAngleMod());
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		putShape(getPosition(_seg), getAngle(_seg, _event));
	}

	// make a strokeWeight gradient
	public void putShape(PVector _p, float _a){
		int _col = getStrokeColor();
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a+ HALF_PI);
		float stepSize = event.getScaledBrushSize()/16.0f;
		int weight = event.getStrokeWeight();
		float steps = 16;
		for(float i = 0; i < steps; i++){
			canvas.stroke(red(_col), green(_col), blue(_col), pow((steps-i)/steps, 4) * event.getStrokeAlpha());
			canvas.strokeWeight(weight+(stepSize*i));
			int _sz = 500;
			canvas.point(0,0);
		}

		canvas.popMatrix();
	}
}


class FadedLineBrusher extends BrushPutter{
	public FadedLineBrusher(int _ind){
		modeIndex = _ind;
		name = "FadedBrusher";
		description = "same as brush but adds a faded edge";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//putShape(_seg.getBrushPos(_event.getLerp()), _seg.getAngle(_event.getDirection()) + _event.getAngleMod());
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		putShape(getPosition(_seg), getAngle(_seg, _event));
	}

	// make a strokeWeight gradient
	public void putShape(PVector _p, float _a){
		int _col = getStrokeColor();
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a+ HALF_PI);
		float stepSize = event.getScaledBrushSize()/16.0f;
		int weight = event.getStrokeWeight();
		float steps = 16;
		for(float i = 0; i < steps; i++){
			canvas.stroke(red(_col), green(_col), blue(_col), pow((steps-i)/steps, 4) * event.getStrokeAlpha());
			canvas.strokeWeight(weight+(stepSize*i));

			int _sz = 500;
			canvas.line(500,0,-500,0);
		}

		canvas.popMatrix();
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Text displaying
///////
////////////////////////////////////////////////////////////////////////////////////

class BasicText extends SegmentPainter{

	public BasicText(){}
  public BasicText(int _ind){
		modeIndex = _ind;
    name = "BasicText";
    description = "Extendable object fo text displaying";
  }

  public void putChar(char _chr, PVector _p, float _a){
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a);
		canvas.text(_chr, 0, event.getScaledBrushSize()/3.0f);
		canvas.popMatrix();
	}
}


class TextWritter extends BasicText{

	public TextWritter(int _ind){
		modeIndex = _ind;
		name = "TextWritter";
		description = "Fit a bunch of text on a segment";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
		canvas.textFont(font);
		canvas.textSize(_event.getScaledBrushSize());
		char[] carr = _txt.toCharArray();
		int l = _txt.length();
		for(int i = 0; i < l; i++){
      _event.setLerp(-((float)i/(l+1) + 1.0f/(l+1))+1);
			putChar(carr[i], getPosition(_seg), getAngle(_seg, _event));
		}
	}
}

class ScrollingText extends BasicText{
  public ScrollingText(int _ind){
		modeIndex = _ind;
    name = "ScrollingText";
    description = "Scrolls text, acording to enterpolator";
  }

  public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
    canvas.textFont(font);
    canvas.textSize(_event.getScaledBrushSize());
    char[] _chars = _txt.toCharArray();

    float _textWidth = _chars.length * _event.getScaledBrushSize();//canvas.textWidth(_txt);
    float _distance = _textWidth+_seg.getLength();


    float  _covered = 0;
    float _lrp = _event.getLerp();
    for(int i = 0; i < _chars.length; i++){
      _covered += _event.getScaledBrushSize()*0.666f;//canvas.textWidth(_chars[i]);
      float place = ((_distance*_lrp)-_covered)/_seg.getLength();
      if(place > 0.0f && place < 1.0f) {
        _event.setLerp(place);
        putChar(_chars[i], getPosition(_seg), getAngle(_seg, _event));
      }
    }
    _event.setLerp(_lrp);

	}
}

class NiceText extends BasicText{
  public NiceText(int _ind){
		modeIndex = _ind;
    name = "NiceText";
    description = "Displays with correct kerning";
  }

  public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
    canvas.textFont(font);
    canvas.textSize(_event.getScaledBrushSize());
		putString(_txt, _seg.getPointA(), _seg.getAngle(true));

	}

	public void putString(String _str, PVector _p, float _a){
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a);
		canvas.text(_str, 0, event.getScaledBrushSize()/3.0f);
		canvas.popMatrix();
	}
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Meta Freelining
///////
////////////////////////////////////////////////////////////////////////////////////

class MetaPoint extends SegmentPainter{
	CommandProcessor commandProcessor;
	public MetaPoint(int _mi){
		modeIndex = _mi;
		name = "MetaPoint";
		description = "A simple dot that is used to do stuff!";
	}
	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		putShape(getPosition(_seg), 0);
	}
	// regular putShape
	public void putShape(PVector _p, float _a){
		canvas.point(_p.x, _p.y);
	}
	public void setCommandProcessor(CommandProcessor _cp){
		commandProcessor = _cp;
	}
}

// base brush putter
class SegmentCommandParser extends MetaPoint{
	ArrayList<Segment> commandSegments;
	public SegmentCommandParser(int _mi){
		super(_mi);
		name = "SegmentCommand";
		description = "MetaFreelining, execute commands of commandSegments";
		commandSegments = null;
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = getPosition(_seg);
		putShape(pos, 0);
		if(commandSegments != null){
			for(Segment _s : commandSegments){
				if(_s.getPointA().dist(_seg.getPointA()) < 0.0001f){
					if(!_event.getExecutedSegments().contains(_seg)){
						_event.executeSegment(_seg);
						commandProcessor.queueCMD(_s.getText());
					}
				}
			}
		}
	}

	public void setCommandSegments(ArrayList<Segment> _cmdSegs){
		commandSegments = _cmdSegs;
	}
}


// base brush putter
class StrokeColorPicker extends MetaPoint{
	PImage colorMap;

	public StrokeColorPicker(int _mi){
		super(_mi);
		name = "StrokeColorPicker";
		description = "MetaFreelining, pick a stroke color from colorMap, load one with colormap colorMap.png";
		colorMap = null;
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = getPosition(_seg);
		putShape(pos, getAngle(_seg, _event));
		if(colorMap != null){
			int _x = (int)pos.x;
			int _y = (int)pos.y;
			if(_x < colorMap.width && _y < colorMap.height && _x >= 0 && _y >= 0){
				setColor(colorMap.pixels[_y*colorMap.width+_x]);
			}
			else setColor(color(0,0,0,0));
			putShape(pos,0);
		}
	}
	public void setColor(int _c){
		commandProcessor.queueCMD("tp stroke "+event.getLinkID()+" "+hex(_c));
	}
	public void setColorMap(PImage _im){
		colorMap = _im;
	}
}

class FillColorPicker extends StrokeColorPicker{
	public FillColorPicker(int _mi){
		super(_mi);
		name = "FillColorPicker";
		description = "MetaFreelining, pick a fill color from colorMap, load one with colormap colorMap.png";
	}
	public void setColor(int _c){
		commandProcessor.queueCMD("tp fill "+event.getLinkID()+" "+hex(_c));
	}
}


// Segment Selector take a segmentGroup and returns segments to render

class SegmentSelector extends Mode {
	public SegmentSelector(){}
	public SegmentSelector(int _ind){
		modeIndex = _ind;
		name = "SegmentSelector";
		description = "Selects segments to render";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		return null;
	}
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////
/**
 * Get all the segments of an _event
 */
class AllSegments extends SegmentSelector {
	public AllSegments(int _ind){
		modeIndex = _ind;
		name = "AllSegments";
		description = "Renders all segments";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = _event.getSegmentGroup().getSegments();
		for(Segment _seg : _segs) _seg.setLerp(_event.getLerp());
		return _segs;
	}
}

/**
 * Get the segments in order of creation
 */
class SequentialSegments extends SegmentSelector{
	public SequentialSegments(int _ind){
		modeIndex = _ind;
		name = "SequentialSegments";
		description = "Renders one segment per beat in order.";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = new ArrayList();
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999);
		Segment _seg = _event.segmentGroup.getSegmentSequence(index);
		if(_seg == null) return null;
		_seg.setLerp(_event.getLerp());
		_segs.add(_seg);
		return _segs;
	}
}

/**
 * Get the segments in order of creation
 */
class RunThroughSegments extends SegmentSelector{
	public RunThroughSegments(int _ind){
		modeIndex = _ind;
		name = "RunThroughSegments";
		description = "Render all segments in order in one beat.";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = new ArrayList();
		float _segCount = _event.segmentGroup.getCount();
		float _unit = _event.getLerp();// getUnitInterval();
		int _index = PApplet.parseInt(_unit * _segCount);
		float _inc = 1.0f/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;
		// this right here is important
		Segment _seg = _event.segmentGroup.getSegment(_index);
		if(_seg != null) _seg.setLerp(_lrp);
		_segs.add(_seg);
		return _segs;
	}
}

/**
 * Get the segments in order of creation
 */
class ConstantSpeed extends SegmentSelector{
	public ConstantSpeed(int _ind){
		modeIndex = _ind;
		name = "ConstantSpeed";
		description = "Runs through segments at a consistant speed.";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = new ArrayList();
		float _segCount = _event.segmentGroup.getCount();
		float _unit = _event.getLerp();
		Segment _seg = _event.segmentGroup.getSegmentByTotalLength(_unit);
		_segs.add(_seg);
		return _segs;
	}
}



/**
 * Get a random segment
 */
class RandomSegment extends SegmentSelector{
	public RandomSegment(int _ind){
		modeIndex = _ind;
		name = "RandomSegment";
		description = "Render a random segment per beat.";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = new ArrayList();
		int index = _event.getLargeRandomValue() % _event.segmentGroup.getCount();
		Segment _seg = _event.segmentGroup.getSegment(index);
		_seg.setLerp(_event.getLerp());
		_segs.add(_seg);
		// could get R's worth of random segments?
		// then setLerp...
		return _segs;
	}
}

/**
 * Get a random segment
 */
class FastRandomSegment extends SegmentSelector{
	public FastRandomSegment(int _ind){
		modeIndex = _ind;
		name = "FastRandomSegment";
		description = "Render a different segment per frame";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = new ArrayList();
		int index = (int)random(_event.segmentGroup.getCount());
		Segment _seg = _event.segmentGroup.getSegment(index);
		_seg.setLerp(_event.getLerp());
		_segs.add(_seg);
		return _segs;
	}
}

/**
 * Render at a branch level
 */
class SegmentBranch extends SegmentSelector{
	public SegmentBranch(int _ind){
		modeIndex = _ind;
		name = "SegmentBranch";
		description = "Renders segment in branch level augmenting every beat";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999); // dosent seem to work...
		ArrayList<Segment> _segs = _event.segmentGroup.getBranch(index);
		if(_segs == null) return null;
		for(Segment _seg : _segs) _seg.setLerp(_event.getLerp());
		return _segs;
	}
}

/**
 * Run through branches over lerp
 */
class RunThroughBranches extends SegmentSelector{
	public RunThroughBranches(int _ind){
		modeIndex = _ind;
		name = "RunThroughBranches";
		description = "Render throught all the branch levels in one beat.";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		float _segCount = _event.segmentGroup.treeBranches.size();
		float _unit = _event.getLerp();//UnitInterval();
		int _index = PApplet.parseInt(_unit * _segCount);
		float _inc = 1.0f/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;
		ArrayList<Segment> _segs = _event.segmentGroup.getBranch(_index);
		for(Segment _seg : _segs) _seg.setLerp(_lrp);
		return _segs;
	}
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


 /**
  * A sequencer inspired by electronic music instruments, particularly after hands on experience with korg volca beats and bass.
  */
class Sequencer implements FreelinerConfig{

  TemplateList[] lists; // should have an array of lists
  TemplateList selectedList;
  boolean doStep = false;
  final int SEQ_STEP_COUNT = 16;
  // current step for playback
  int step = 0;
  int periodCount;
  // step being edited
  int editStep = 0;
  boolean playing = true;
  boolean recording = false; // implement this
  boolean stepChanged = false;

  public Sequencer(){
    lists = new TemplateList[SEQ_STEP_COUNT];
    for(int i = 0; i < SEQ_STEP_COUNT; i++){
      lists[i] = new TemplateList();
    }
    selectedList = lists[0];
  }

  // update the step according to synchroniser
  public void update(int _periodCount){
    if(periodCount != _periodCount){
      doStep = true;
      step++;
      step %= SEQ_STEP_COUNT;
      periodCount = _periodCount;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Toggle template for selectedlist
   */
  public void toggle(TweakableTemplate _tw){
    selectedList.toggle(_tw);
  }

  /**
   * Clear everything
   */
  public void clear(){
    for(TemplateList _tl : lists) _tl.clear();
  }

  /**
   * Clear specific step
   * @param int step index
   */
  public void clear(int _s){
    if(_s < SEQ_STEP_COUNT) lists[_s].clear();
  }

  /**
   * Clear a specific Template
   * @param TweakableTemplate template to clear
   */
  public void clear(TweakableTemplate _tw){
    for(TemplateList _tl : lists) _tl.remove(_tw);
  }

  /**
   * Set step to edit
   * @param int step index
   */
  public int setEditStep(int _n){
    editStep = numTweaker(_n, editStep);
    if(editStep >= SEQ_STEP_COUNT) editStep = SEQ_STEP_COUNT-1;
    selectedList = lists[editStep];
    stepChanged = true;
    return editStep;
  }

  /**
   * Jump to specific step and trigger it
   * @param int step index
   */
  public void forceStep(int _step){
   step = _step % SEQ_STEP_COUNT;
   doStep = true; // might need a time delay
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean play(boolean _b){
    playing = _b;
    return playing;
  }

  public boolean play(){
    playing = !playing;
    return playing;
  }

  public boolean record(boolean _b){
    recording = _b;
    return recording;
  }

  public boolean record(){
    recording = !recording;
    return recording;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public TemplateList getStepToEdit(){
    return selectedList;
  }

  // check for things to trigger
  public TemplateList getStepList(){
    if(doStep && playing){
      doStep = false;
      return lists[step];
    }
    else return null;
  }

  public String getStatusString(){
    String _buff = "";
    for(TemplateList _tl : lists){
      _buff += "/"+_tl.getTags();
    }
    return _buff;
  }

  public TemplateList[] getStepLists(){
    return lists;
  }

  public int getStep(){
    return step;
  }

  public boolean isPlaying(){
    return playing;
  }

  public boolean isRecording(){
    return recording;
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-08-23
 */

/**
 * Syphon output!
 * To enable you must remove all the double slashes //
 */

// import spout.*;

class SpoutLayer extends Layer{
  //  Spout spout;

  public SpoutLayer(PApplet _pa){
    enabled = false;
    //  spout = new Spout(_pa);
    //  enabled = true;
    name = "SpoutLayer";
    id = name;
    description = "Output layer to other software, only on win, requires SpoutLibrary, and uncoment code in SpoutLayer.pde";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled || _pg == null) return _pg;
    //    spout.sendTexture(_pg);
    return _pg;
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-12-01
 */


/*
 * The synchroniser is in charge of the timing. Tap tempo with compensation for render time.
 */

class Synchroniser implements FreelinerConfig{

    // millis to render one frame
    int renderTime = 0;
    int lastRender = 0;

    // tapTempo
    int lastTap = 0;
    int lastTime = 0;
    FloatSmoother tapTimer;
    int tempo = DEFAULT_TEMPO;

    boolean steadyFrameRate;

    FloatSmoother intervalTimer;
    float renderIncrement = 0.1f;
    float lerper = 0;
    float unit = 0;
    int periodCount = 0;

    // new time scaler!
    float timeScaler = 1.0f;

    public Synchroniser(){
        tapTimer = new FloatSmoother(5, 350);
        intervalTimer = new FloatSmoother(5, 34);
        steadyFrameRate = false;
    }

    public void update() {
        // calculate how much to increment
        if(!steadyFrameRate){
            renderIncrement = intervalTimer.addF(PApplet.parseFloat(millis()-lastRender))/tempo;
            lastRender = millis();
        }
        lerper += renderIncrement*timeScaler;
        unit += renderIncrement*timeScaler;
        if(lerper > 1.0f){
            lerper = 0.0000001f;
            periodCount++;
            freeliner.oscTick();
        }
        else if(lerper < 0.0f){
            lerper = 0.99999999f;
            periodCount--;
            if(periodCount < 1) periodCount = 9999;
            freeliner.oscTick();
        }
    }

    //tap the tempo
    public void tap() {
        int elapsed = millis()-lastTap;
        lastTap = millis();
        if (elapsed> 100 && elapsed < 3000) {
          tempo = PApplet.parseInt(tapTimer.addF(elapsed));///2;
        }
    }

    //adjust tempo by +- 100 millis
    public void nudgeTime(int t){
        // println(lastTime);
        if(t==-2) lastTime -= 100;
        else if(t==-1) lastTime += 100;
    }

  // for frame capture to loc rendertime
    public void setSteady(boolean _r) {
        steadyFrameRate = _r;
    }

    public void setTimeScaler(float _f){
        timeScaler = _f;
    }

    public float getLerp(int _div){
        if(_div < 1) _div = 1;
        int cyc_ = (periodCount%_div);
        float lrp_ = (1.0f/_div)*cyc_;
        return (lerper/_div) + lrp_;
    }

    public float getUnit(){
        return unit;
    }

    public int getPeriod(int _div){
        if(_div < 1) _div = 1;
        return PApplet.parseInt(periodCount/_div);
    }

    public int getPeriodCount(){
        return periodCount;
    }

    public float getTime(){
        return periodCount + unit;
    }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-08-23
 */

/**
 * Syphon output!
 * To enable you must remove all the double slashes //
 */

//import codeanticode.syphon.*;

class SyphonLayer extends Layer{
  //  SyphonServer syphonServer;

  public SyphonLayer(PApplet _pa){
    enabled = false;
    //  syphonServer = new SyphonServer(_pa, "alcFreeliner");
    //  enabled = true;
    name = "SyphonLayer";
    id = name;
    description = "Output layer to other software, only on osx, requires SyphonLibrary, and uncoment code in SyphonLayer.pde";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled || _pg == null) return _pg;
    //  syphonServer.sendImage(_pg);
    return _pg;
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


 /**
  * Templates hold all the parameters for the renderer.
  *
  */
class Template implements FreelinerConfig{
/*
 * First tier, data that dosent change unless told to
 */
	// Which type of rendering: per segment, all the segments...
	int renderMode;
	// how we pic which segments to paint
	int segmentMode;
	// different "animations" of a rendering style
	int animationMode;
	// how to extract position from a segment
	int interpolateMode;
	// Colorizer mode for stroke, 0 is noStroke()
	int strokeMode;
	// Colorizer mode for fill, 0 is noFill()
	int fillMode;
	// alpha channel
	int strokeAlpha;
	int fillAlpha;
	// Add rotation to elements such as brushes
	int rotationMode;
	// how we manipulate unitIntervals
	int easingMode;
	// Reversing diretction of unitInterval
	int reverseMode;
	// Mode to render more than once while changing the unitInterval
	int repetitionMode;
	// was polka
	int repetitionCount;
	// Defines speed
	int beatDivider;
	// Width of stroke
	int strokeWidth;
	// Size of brush
	int brushSize;
	// a general purpose value
  int miscValue;
	// enablers decide if render or not
	int enablerMode;
	// which layer to render to
	int renderLayer;

	// custom shape
  PShape customShape;
	PVector translation;

  // custom color
  int customStrokeColor;
	int customFillColor;

	char templateID;
	char linkedTemplateID = '.';

	// for stats
	float fixLerp;

	public Template(){
		reset();
	}

	public Template(char _id){
		templateID = _id;
		reset();
	}
	//
	// public Template(Template _source){
	// 	templateID = 'z';
	// 	reset();
	// 	copy(_source);
	// }

	/**
	 * Copy a Template
	 * @parma RenderEvent to copy
	 */
 	public void copy(Template _tp){
 		// copy the first tier of variables
 		templateID = _tp.getTemplateID();
 		copyParameters(_tp);
 	}

	/**
	 * Copy Template parameters
	 * @parma RenderEvent to copy
	 */
 	public void copyParameters(Template _tp){
 		strokeAlpha = _tp.getStrokeAlpha();
		fillAlpha = _tp.getFillAlpha();
		renderMode = _tp.getRenderMode();
		segmentMode = _tp.getSegmentMode();
		animationMode = _tp.getAnimationMode();
		interpolateMode = _tp.getInterpolateMode();
		strokeMode = _tp.getStrokeMode();
		fillMode = _tp.getFillMode();
		rotationMode = _tp.getRotationMode();
		reverseMode = _tp.getReverseMode();
		repetitionMode = _tp.getRepetitionMode();
		repetitionCount = _tp.getRepetitionCount();
		easingMode = _tp.getEasingMode();
		beatDivider = _tp.getBeatDivider();
		strokeWidth = _tp.getStrokeWeight();
		brushSize = _tp.getBrushSize();
		miscValue = _tp.getMiscValue();
		customShape = _tp.getCustomShape();
		enablerMode = _tp.getEnablerMode();
		customStrokeColor = _tp.getCustomStrokeColor();
		customFillColor = _tp.getCustomFillColor();

		renderLayer = _tp.getRenderLayer();
		linkedTemplateID = _tp.getLinkID();
		fixLerp = _tp.getFixLerp();
		translation = _tp.getTranslation();
 	}

	/**
	 * Reset to default values
	 * Defaults from Config.pde?
	 */
 	public void reset(){
 		fillAlpha = 255;
		strokeAlpha = 255;
		renderMode = 0;
		animationMode = 0;
		segmentMode  = 0;
		interpolateMode = 0;
		strokeMode = 1;
		fillMode = 1;
		rotationMode = 0;
		reverseMode = 0;
		repetitionMode = 0;
		repetitionCount = 5;
		easingMode = 0;
		beatDivider = 1;
		strokeWidth = 3;
		brushSize = 20;
		enablerMode = 1;
		renderLayer = 1;
		customStrokeColor = color(0,0,50,255);
		customFillColor = color(50,50,50,255);
		translation = new PVector(0,0,0);
 	}

	public void setCustomShape(PShape _shp){
    customShape = _shp;
  }
	public void setLinkTemplate(char _id){
		linkedTemplateID = _id;
	}
	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Debug
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void print(){
		println("++++++++++++++++++++++++");
		println("Template : "+templateID);
		println("renderMode "+renderMode);
		println("animationMode "+animationMode);
		println("strokeMode "+strokeMode);
		println("fillMode "+fillMode);
		println("rotationMode "+rotationMode);
		println("reverseMode "+reverseMode);
		println("repetitionMode "+repetitionMode);
		println("repetitionCount "+repetitionCount);
		println("beatDivider "+beatDivider);
		println("strokeWidth "+strokeWidth);
		println("brushSize "+brushSize );
		println("renderLayer "+renderLayer);
		println("++++++++++++++++++++++++");
	}



	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Accessors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	// public boolean equals(Object _obj){
	// 	println(templateID+" "+((Template)_obj).getTemplateID());
	// 	return (templateID == ((Template)_obj).getTemplateID());
	// }

  public PShape getCustomShape(){
    return customShape;
  }

	public final char getTemplateID(){
		return templateID;
	}

	/**
	 * First tier accessors
	 */
	public final int getRenderMode(){
		return renderMode;
	}

	public final int getSegmentMode(){
		return segmentMode;
	}

	public final int getAnimationMode(){
		return animationMode;
	}

	public final int getInterpolateMode(){
		return interpolateMode;
	}

	public final int getEasingMode(){
		return easingMode;
	}

	public final int getFillMode(){
		return fillMode;
	}

	public final int getStrokeMode(){
		return strokeMode;
	}

	public final int getStrokeAlpha(){
		return strokeAlpha;
	}

	public final int getFillAlpha(){
		return fillAlpha;
	}

	public final int getStrokeWeight(){
		return strokeWidth;
	}

	public final int getMiscValue(){
		return miscValue;
	}

	public final int getBrushSize(){
		return brushSize;
	}

	public final int getRotationMode(){
		return rotationMode;
	}

	public final int getReverseMode(){
		return reverseMode;
	}

	public final int getRepetitionMode(){
		return repetitionMode;
	}

	public final int getRepetitionCount(){
		return repetitionCount;
	}

	public final int getBeatDivider(){
		return beatDivider;
	}

	public final int getEnablerMode(){
		return enablerMode;
	}

	public final int getRenderLayer(){
		return renderLayer;
	}

	public final int getCustomStrokeColor(){
		return customStrokeColor;
	}
	public final int getCustomFillColor(){
		return customFillColor;
	}
	public final char getLinkID(){
		return linkedTemplateID;
	}
	public float getFixLerp(){
		return fixLerp;
	}
	public PVector getTranslation(){
		return translation;
	}
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * TemplateList is a class that contains TweakableTemplate references
 * <p>
 * Add and remove TweakableTemplates
 * </p>
 *
 * @see TweakableTemplate
 */
class TemplateList {
  // TweakableTemplate references
  ArrayList<TweakableTemplate> templates;
  String tags = "";

  public TemplateList(){
    templates = new ArrayList();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Copy and other TemplateList
   */
  public void copy(TemplateList _tl){
    if(_tl == this) return;
    clear();
    if(_tl == null) return;
    if(_tl.getAll() == null) return;
    if(!_tl.getAll().isEmpty())
      for(TweakableTemplate tt : _tl.getAll())
        toggle(tt);
    updateString();
  }

  /**
   * Clear the whole thing
   */
  public void clear(){
    if(!templates.isEmpty()){
      templates.clear();
      tags = "";
    }
    updateString();
  }

  /**
   * Toggle a Template
   * @param TweakableTemplate template to toggle
   */
  public void toggle(TweakableTemplate _te) {
    if(_te == null) return;
    if(!templates.remove(_te)) templates.add(_te);
    updateString();
  }

  /**
   * Add a template
   * @param TweakableTemplate template to toggle
   */
  public void add(TweakableTemplate _te){
    if(_te == null) return;
    if(contains(_te)) return;
    else templates.add(_te);
    updateString();
  }

  /**
   * Remove a specific template
   * @param TweakableTemplate template to toggle
   */
  public void remove(TweakableTemplate _te){
    if(_te == null) return;
    if(contains(_te)) templates.remove(_te);
    updateString();
  }

  /**
   * Makes the string of tags
   */
  public void updateString(){
    tags = "";
    for(TweakableTemplate _ten : templates){
      tags += _ten.getTemplateID();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean contains(TweakableTemplate _te){
    return templates.contains(_te);
  }

  public ArrayList<TweakableTemplate> getAll(){
    if(templates.size() == 0) return null;
    else return templates;
  }

  public TweakableTemplate getIndex(int _index){
    if(_index < templates.size()) return templates.get(_index);
    else return null;
  }

  public String getTags(){
    return tags;
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * Manage all the templates
 *
 */
class TemplateManager implements FreelinerConfig{
    //selects templates to control
    TemplateList templateList;

    //templates all the basic templates
    ArrayList<TweakableTemplate> templates;
    TweakableTemplate copyedTemplate;
    final int N_TEMPLATES = 26;

    // events to render
    ArrayList<RenderableTemplate> eventList;
    ArrayList<RenderableTemplate> loops;
    // synchronise things
    Synchroniser sync;
    Sequencer sequencer;
    GroupManager groupManager;

    public TemplateManager() {
        sync = new Synchroniser();
        sequencer = new Sequencer();
        templateList = new TemplateList();
        loops = new ArrayList();
        eventList = new ArrayList();
        copyedTemplate = null;
        init();
        groupManager = null;
    }

    public void inject(GroupManager _gm) {
        groupManager = _gm;
    }

    private void init() {
        templates = new ArrayList();
        for (int i = 0; i < N_TEMPLATES; i++) {
            TweakableTemplate te = new TweakableTemplate(PApplet.parseChar(65+i));
            templates.add(te);
        }
    }

    // update the render events
    public void update() {
        sync.update();
        sequencer.update(sync.getPeriodCount());
        trigger(sequencer.getStepList());
        //println("tags "+sequencer.getStepList().getTags());
        // check for events?
        // set the unitinterval/beat for all templates
        syncTemplates(loops);
        syncTemplates(eventList);
        ArrayList<RenderableTemplate> toKill = new ArrayList();
        synchronized(eventList) {
            ArrayList<RenderableTemplate> _safe = new ArrayList(eventList);
            for(RenderableTemplate _tp : _safe) {
                if(_tp == null) return;
                if(((KillableTemplate) _tp).isDone()) toKill.add(_tp);
            }
            if(toKill.size()>0) {
                for(RenderableTemplate _rt : toKill) {
                    eventList.remove(_rt);
                }
            }
        }
    }

    // synchronise renderable templates lists
    private void syncTemplates(ArrayList<RenderableTemplate> _tp) {
        ArrayList<RenderableTemplate> lst = new ArrayList<RenderableTemplate>(_tp);
        int beatDv = 1;
        if(_tp.size() > 0) {
            for (RenderableTemplate rt : lst) {
                // had a null pointer here...
                if(rt == null) continue; // does this fix?
                beatDv = rt.getBeatDivider();
                rt.setUnitInterval(sync.getLerp(beatDv));
                rt.setBeatCount(sync.getPeriod(beatDv));
                rt.setRawBeatCount(sync.getPeriod(0));
            }
        }
    }

    /**
     * Makes sure there is a renderable template for all the segmentGroup / Template pairs.
     * @param ArrayList<SegmentGroup>
     */
    public void launchLoops() {
        ArrayList<SegmentGroup> _groups = groupManager.getSortedGroups();
        if(_groups.size() == 0) return;
        ArrayList<RenderableTemplate> toKeep = new ArrayList();

        //check to add new loops
        for(SegmentGroup sg : _groups) {
            ArrayList<TweakableTemplate> tmps = sg.getTemplateList().getAll();
            if(tmps != null) {
                for(TweakableTemplate te : tmps) {
                    RenderableTemplate rt = getByIDandGroup(loops, te.getTemplateID(), sg);
                    if(rt != null) toKeep.add(rt);
                    else toKeep.add(loopFactory(te, sg));
                }
            }
        }
        loops = toKeep;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Event Factory
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // set size as per scalar
    public RenderableTemplate loopFactory(TweakableTemplate _te, SegmentGroup _sg) {
        return new RenderableTemplate(_te, _sg);
    }

    // set size as per scalar
    public RenderableTemplate eventFactory(TweakableTemplate _te, SegmentGroup _sg) {
        RenderableTemplate _rt = new KillableTemplate(_te, _sg);
        ((KillableTemplate) _rt).setOffset(sync.getLerp(_rt.getBeatDivider()));
        return _rt;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Playing functions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    // trigger but catch with synchroniser
    public void trigger(char _c) {
        TweakableTemplate _tp = getTemplate(_c);
        if(_tp == null) return;
        trigger(_tp);
        // sync.templateInput(_tp);
    }

    public void trigger(TweakableTemplate _tp) {
        if(_tp == null) return;
        _tp.launch(); // increments the launchCount
        // get groups with template
        ArrayList<SegmentGroup> _groups = groupManager.getGroups(_tp);
        if(_groups.size() > 0) {
            for(SegmentGroup _sg : _groups) {
                eventList.add(eventFactory(_tp, _sg));
            }
        }
    }

    // trigger a letter + group
    public void trigger(char _c, int _id) {
        SegmentGroup _sg = groupManager.getGroup(_id);
        if(_sg == null) return;
        TweakableTemplate _tp = getTemplate(_c);
        if(_tp == null) return;
        eventList.add(eventFactory(_tp, _sg));
    }

    // trigger a templateList, in this case via the
    public void trigger(TemplateList _tl) {
        if(_tl == null) return;
        ArrayList<TweakableTemplate> _tp = _tl.getAll();
        if(_tp == null) return;
        if(_tp.size() > 0) {
            for(TweakableTemplate tw : _tp) {
                if(tw.getEnablerMode() != 3) trigger(tw); // check if is in the right enabler mode
            }
        }
    }

    // osc trigger many things and gps
    public void oscTrigger(String _tags, int _gp) {
        for(int i = 0; i < _tags.length(); i++) {
            if(_gp != -1) trigger(_tags.charAt(i), _gp);
            else trigger(_tags.charAt(i));
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Select all the templates in order to tweak them all. Triggered by ctrl-a
     */
    public void focusAll() {
        templateList.clear();
        for (TweakableTemplate r_ : templates) {
            templateList.toggle(r_);
        }
    }

    /**
     * unSelect templates
     */
    public void unSelect() {
        templateList.clear();
    }

    /**
     * toggle template selection
     */
    public void toggle(char _c) {
        templateList.toggle(getTemplate(_c));
    }


    /**
     * Copy one template into an other. Triggered by ctrl-c with 2 templates selected.
     */
    // public void copyPaste(){
    //   Template a = templateList.getIndex(0);
    //   Template b = templateList.getIndex(1);
    //   if(a != null && b !=null) b.copyParameters(a);
    // }

    /**
     * Copy a template and maybe paste it automaticaly. Triggered by ctrl-c with 2 templates selected.
     */
    public void copyTemplate() {
        TweakableTemplate toCopy = templateList.getIndex(0);
        TweakableTemplate pasteInto = templateList.getIndex(1);
        copyTemplate(toCopy, pasteInto);
    }

    // for ABCD (A->BCD)
    public void copyTemplate(String _tags) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() == 1) copyTemplate(_tmps.get(0), null);
        else
            for(int i = 1; i < _tmps.size(); i++)
                copyTemplate(_tmps.get(0), _tmps.get(i));
    }

    public void copyTemplate(TweakableTemplate _toCopy, TweakableTemplate _toPaste) {
        copyedTemplate = _toCopy;
        if(copyedTemplate != null && _toPaste != null) _toPaste.copyParameters(copyedTemplate);
    }

    /**
     * Paste a previously copyed template into an other
     */
    public void pasteTemplate() {
        pasteTemplate(templateList.getTags());
    }

    public void pasteTemplate(String _tags) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() == 1) pasteTemplate(_tmps.get(0));
        else
            for(int i = 0; i < _tmps.size(); i++)
                pasteTemplate(_tmps.get(i));
    }

    public void pasteTemplate(TweakableTemplate _pasteInto) {
        if(copyedTemplate != null && _pasteInto != null) _pasteInto.copyParameters(copyedTemplate);
    }

    /**
     * Toggle a template for groups matching first template
     */
    public void groupAddTemplate() {
        groupAddTemplate(templateList.getTags());
    }

    public void groupAddTemplate(String _tags) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() < 2) return;
        else
            // for(int i = 1; i < ; i++)
            groupAddTemplate(_tmps.get(0), _tmps.get(1));
    }

    public void groupAddTemplate(TweakableTemplate _a, TweakableTemplate _b) {
        if(_a != null && _b !=null) groupManager.groupAddTemplate(_a, _b);
    }

    /**
     * Swap Templates (AB), swaps their related geometry also
     */
    public void swapTemplates(String _tags) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() < 2) return;
        else swapTemplates(_tmps.get(0), _tmps.get(1));
    }

    // might remove the copy? not sure.
    public void swapTemplates(TweakableTemplate _a, TweakableTemplate _b) {
        TweakableTemplate _c = new TweakableTemplate();
        _c.copyParameters(_a);
        _a.copyParameters(_b);
        _b.copyParameters(_c);
        groupSwapTemplate(_a, _b);
    }

    public void groupSwapTemplate(TweakableTemplate _a, TweakableTemplate _b) {
        if(_a != null && _b !=null) groupManager.groupSwapTemplate(_a, _b);
    }

    /**
     * ResetTemplate
     */
    public void resetTemplate() {
        resetTemplate(templateList.getTags());
    }

    public void resetTemplate(String _tags) {
        if(_tags == null) return;
        else if(_tags.length() > 0) {
            ArrayList<TweakableTemplate> _tps = getTemplates(_tags);
            if(_tps != null) for(TweakableTemplate _tp : _tps) _tp.reset();
        }
    }
    /**
     * Set a template's custom color, this is done with OSC.
     */
    public void setCustomStrokeColor(String _tags, int _c) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        for(TweakableTemplate _tp : _tmps) {
            if(_tp != null) _tp.setCustomStrokeColor(_c);
        }
    }

    public void setCustomFillColor(String _tags, int _c) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        for(TweakableTemplate _tp : _tmps) {
            if(_tp != null) _tp.setCustomFillColor(_c);
        }
    }

    /**
     * Link Templates (AB)
     */
    public void linkTemplates(String _tags) {
        ArrayList<TweakableTemplate> _tmps = getTemplates(_tags);
        if(_tmps.size() < 2) return;
        else linkTemplates(_tmps.get(0), _tmps.get(1));
    }

    public void linkTemplates(TweakableTemplate _tp, TweakableTemplate _link) {
        if(_tp != null && _link != null) {
            _tp.setLinkTemplate(_link.getTemplateID());
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Saving and loading with XML
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void saveTemplates() {
        saveTemplates("templates.xml");
    }

    /**
     * Simple save templates to xml file.
     */
    public void saveTemplates(String _fn) {
        XML _templates = new XML("templates");
        for(Template _tp : templates) {
            XML _tmp = _templates.addChild("template");
            _tmp.setString("ID", str(_tp.getTemplateID()));
            _tmp.setInt("renderMode", _tp.getRenderMode());
            _tmp.setInt("segmentMode", _tp.getSegmentMode());
            _tmp.setInt("animationMode", _tp.getAnimationMode());
            _tmp.setInt("interpolateMode", _tp.getInterpolateMode());
            _tmp.setInt("strokeMode", _tp.getStrokeMode());
            _tmp.setInt("fillMode", _tp.getFillMode());
            _tmp.setInt("strokeAlpha", _tp.getStrokeAlpha());
            _tmp.setInt("fillAlpha", _tp.getFillAlpha());
            _tmp.setInt("rotationMode", _tp.getRotationMode());
            _tmp.setInt("easingMode", _tp.getEasingMode());
            _tmp.setInt("reverseMode", _tp.getReverseMode());
            _tmp.setInt("repetitionMode", _tp.getRepetitionMode());
            _tmp.setInt("repetitionCount", _tp.getRepetitionCount());
            _tmp.setInt("beatDivider", _tp.getBeatDivider());
            _tmp.setInt("strokeWidth", _tp.getStrokeWeight());
            _tmp.setInt("brushSize", _tp.getBrushSize());
            _tmp.setInt("miscValue", _tp.getMiscValue());
            _tmp.setInt("enablerMode", _tp.getEnablerMode());
            _tmp.setInt("renderLayer", _tp.getRenderLayer());
        }
        saveXML(_templates, dataPath(PATH_TO_TEMPLATES)+"/"+_fn);
    }

    public void loadTemplates() {
        loadTemplates("templates.xml");
    }

    public void loadTemplates(String _fn) {
        XML file;
        try {
            file = loadXML(dataPath(PATH_TO_TEMPLATES)+"/"+_fn);
        } catch (Exception e) {
            println(_fn+" cant be loaded");
            return;
        }
        XML[] _templateData = file.getChildren("template");
        TweakableTemplate _tmp;
        for(XML _tp : _templateData) {
            _tmp = getTemplate(_tp.getString("ID").charAt(0));
            if(_tmp == null) continue;
            _tmp.setRenderMode(_tp.getInt("renderMode"), 50000);
            _tmp.setSegmentMode(_tp.getInt("segmentMode"), 50000);
            _tmp.setAnimationMode(_tp.getInt("animationMode"), 50000);
            _tmp.setInterpolateMode(_tp.getInt("interpolateMode"), 50000);
            _tmp.setStrokeMode(_tp.getInt("strokeMode"), 50000);
            _tmp.setFillMode(_tp.getInt("fillMode"), 50000);
            _tmp.setStrokeAlpha(_tp.getInt("strokeAlpha"), 50000);
            _tmp.setFillAlpha(_tp.getInt("fillAlpha"), 50000);
            _tmp.setRotationMode(_tp.getInt("rotationMode"), 50000);
            _tmp.setEasingMode(_tp.getInt("easingMode"), 50000);
            _tmp.setReverseMode(_tp.getInt("reverseMode"), 50000);
            _tmp.setRepetitionMode(_tp.getInt("repetitionMode"), 50000);
            _tmp.setRepetitionCount(_tp.getInt("repetitionCount"), 50000);
            _tmp.setBeatDivider(_tp.getInt("beatDivider"), 50000);
            _tmp.setStrokeWidth(_tp.getInt("strokeWidth"), 50000);
            _tmp.setBrushSize(_tp.getInt("brushSize"), 50000);
            _tmp.setMiscValue(_tp.getInt("miscValue"), 50000);
            _tmp.setEnablerMode(_tp.getInt("enablerMode"), 50000);
            _tmp.setRenderLayer(_tp.getInt("renderLayer"), 50000);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Setting custom shapes
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // set a decorator's shape
    private void setCustomShape(SegmentGroup _sg) {
        if(_sg == null) return;
        ArrayList<TweakableTemplate> temps = _sg.getTemplateList().getAll();

        if(_sg.getShape() == null) return;

        PShape sourceShape = cloneShape(_sg.getShape(), 1.0f, _sg.getCenter());
        //println("Setting customShape of "+temp.getTemplateID()+" with a shape of "+sourceShape.getVertexCount()+" vertices");

        int vertexCount = sourceShape.getVertexCount();
        if(vertexCount > 0) {
            // store the widest x coordinate
            float maxX = 0.0001f;
            float minX = -0.0001f;
            float mx = 0;
            float mn = 0;
            // check how wide the shape is to scale it to the BASE_SIZE
            for(int i = 0; i < vertexCount; i++) {
                mx = sourceShape.getVertex(i).x;
                mn = sourceShape.getVertex(i).y;
                if(mx > maxX) maxX = mx;
                if(mn < minX) minX = mn;
            }
            // return a brush scaled to the BASE_SIZE
            float baseSize = (float)new PointBrush(0).BASE_BRUSH_SIZE;
            PShape cust = cloneShape(sourceShape, baseSize/(maxX+abs(minX)), new PVector(0,0));
            if(temps != null)
                for(TweakableTemplate temp : temps)
                    if(temp != null)
                        temp.setCustomShape(cust);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Mutators
    ///////
    ////////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public Synchroniser getSynchroniser() {
        return sync;
    }

    public Sequencer getSequencer() {
        return sequencer;
    }

    public ArrayList<RenderableTemplate> getLoops() {
        return loops;
    }

    public ArrayList<RenderableTemplate> getEvents() {
        return eventList;
    }

    public boolean isFocused() {
        return templateList.getIndex(0) != null;
    }

    public TweakableTemplate getTemplate(char _c) {
        if(_c >= 'A' && _c <= 'Z') return templates.get(PApplet.parseInt(_c)-'A');
        else return null;
    }

    public RenderableTemplate getByIDandGroup(ArrayList<RenderableTemplate> _tps, char _id, SegmentGroup _sg) {
        for(RenderableTemplate tp : _tps) {
            if(tp.getTemplateID() == _id && tp.getSegmentGroup() == _sg) return tp;
        }
        return null;
    }

    public TemplateList getTemplateList() {
        return templateList;
    }

    public ArrayList<TweakableTemplate> getTemplates() {
        return templates;
    }

    public ArrayList<TweakableTemplate> getSelected() {
        ArrayList<TweakableTemplate> _tmps = new ArrayList();
        if(templateList.getAll() == null) return null;
        if(templateList.getAll().size() == 0) return null;
        for(TweakableTemplate _tw : templateList.getAll()) {
            if(_tw != null) _tmps.add(_tw);
        }
        return _tmps;
    }

    public ArrayList<TweakableTemplate> getGroupTemplates() {
        TemplateList _tl = groupManager.getTemplateList();
        if(_tl == null) return null;
        return _tl.getAll();
    }


    // a fancier accessor, supports "ANCD" "*" "$" "$$"
    public ArrayList<TweakableTemplate> getTemplates(String _tags) {
        if(_tags.length() < 1) return null;
        ArrayList<TweakableTemplate> _tmps = new ArrayList();
        if(_tags.length() == 0) return null;
        else if(_tags.charAt(0) == '$') {
            if(_tags.length() > 1) return getGroupTemplates();
            else return getSelected();
        } else if(_tags.charAt(0) == '*') return getTemplates();
        else {
            for(int i = 0; i < _tags.length(); i++) {
                TweakableTemplate _tw = getTemplate(_tags.charAt(i));
                // println(_tw);
                if( _tw != null) _tmps.add(_tw);
            }
        }
        return _tmps;
    }

}
 /**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * View part
 * The template renderer is where the rendering process begins.
 */

class TemplateRenderer extends Mode{
    // rendering modes and repetition
    // arraySizes in config.pde
    RenderMode[] renderModes;
    Repetition[] repeaters;
    Enabler[] enablers;
    Easing[] easers;
    Reverse[] reversers;

    // PVector[] translations;

    // easer and reversers count in Config.pde
    int easingModeCount = 12;
    int reverseModeCount = 5;
    int renderModeCount = 7;
    int repetitionModeCount = 6;
    int enablerModeCount = 8;

    MetaFreelining metaFreeliner;
    GroupManager groupManager;
    /**
     * Constructor
     */
	public TemplateRenderer(){
    name="TemplateRenderer";
    description="regular template renderer";
    // add renderModes
    renderModes = new RenderMode[renderModeCount];
    renderModes[0] = new BrushSegment(0);
    renderModes[1] = new LineSegment(1);
    renderModes[2] = new WrapLine(2);
    renderModes[3] = new Geometry(3);
    renderModes[4] = new TextRenderMode(4);
    renderModes[5] = new CircularSegment(5);
    renderModes[6] = new MetaFreelining(6);
    metaFreeliner = (MetaFreelining)renderModes[6];

    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])renderModes, 'b', this, "RenderModes");
    // add repetitionModes
    repeaters = new Repetition[repetitionModeCount];
    repeaters[0] = new Single(0);
    repeaters[1] = new EvenlySpaced(1);
    repeaters[2] = new EvenlySpacedWithZero(2);
    repeaters[3] = new ExpoSpaced(3);
    repeaters[4] = new TwoFull(4);
    repeaters[5] = new TwoSpaced(5);
    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])repeaters, 'i', this, "RepetitionModes");

    // add enablers
    enablers = new Enabler[enablerModeCount];
    enablers[0] = new Disabler(0);
    enablers[1] = new Enabler(1);
    enablers[2] = new Triggerable(2);
    enablers[3] = new Triggerable(3);
    enablers[4] = new SweepingEnabler(4);
    enablers[5] = new SwoopingEnabler(5);
    enablers[6] = new RandomEnabler(6);
    enablers[7] = new StrobeEnabler(7);

    if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])enablers, 'u', this, "Enablers");

    description = "how to darw multiples of one template";
	easers = new Easing[easingModeCount];
	easers[0] = new NoEasing(0);
	easers[1] = new Square(1);
	easers[2] = new Sine(2);
	easers[3] = new Cosine(3);
	easers[4] = new Boost(4);
	easers[5] = new RandomUnit(5);
	easers[6] = new TargetNoise(6);
	easers[7] = new Fixed(1.0f, 7);
	easers[8] = new Fixed(0.5f, 8);
	easers[9] = new Fixed(0.0f, 9);
	easers[10] = new EaseInOut(10);
    easers[11] = new FixLerp(11);

	if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])easers, 'h', this, "EasingModes");

	reversers = new Reverse[reverseModeCount];
	reversers[0] = new NotReverse(0);
	reversers[1] = new Reverse(1);
	reversers[2] = new BackForth(2);
	reversers[3] = new TwoTwoReverse(3);
	reversers[4] = new RandomReverse(4);
	if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])reversers, 'j', this, "ReverseModes");

    // translations = new PVector[26];
    // for(int i = 0; i < 26; i++) translations[i] = new PVector(0,0,0);
	}

  /**
   * Render a renderable template.
   * @param RenderableTemplate to render.
   */
   public void render(RenderableTemplate _rt, PGraphics _pg){
        if(_rt == null) return;
        if(_rt.getSegmentGroup() == null) return;
        if(_rt.getSegmentGroup().isEmpty()) return;
        _rt.setCanvas(_pg);

        metaFreeliner.setCommandSegments(groupManager.getCommandSegments());


        // check the enabler, it may modify the unitInterval
        if(!enablers[_rt.getEnablerMode()%enablerModeCount].enable(_rt)) return;

        // translate, beta...
        _pg.pushMatrix(); // new
        PVector _trans = _rt.getTranslation();
        _pg.translate(_trans.x*width, _trans.y*height);

        // get multiple unit intervals to use
        float _eased = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
        FloatList flts = getRepeater(_rt.getRepetitionMode()).getFloats(_rt, _eased);
        float _rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
        int repetitionCount = 0;

        for(float flt : flts){
            flt *= _rev;
            // Repition object return arrayList of unit intervals.
            // negative values indicates going in reverse
            if(flt < 0){
                _rt.setLerp(flt+1);
                _rt.setDirection(true);
            }
            else {
                _rt.setLerp(flt);
                _rt.setDirection(false);
            }
            // push the repetition count to template
            _rt.setRepetition(repetitionCount);
            repetitionCount++;
            // modify angle modifier
            tweakAngle(_rt);
            // pass template to renderer
            getRenderer(_rt.getRenderMode()).doRender(_rt);
        }
        _pg.popMatrix();
  }

  //needs work
  /**
   * One of the last few things to expand into
   * @param RenderableTemplate to render.
   */
  // yes a mess!
    public void tweakAngle(RenderableTemplate _rt){
        int rotMode = _rt.getRotationMode();
        float _ang = 0;
        if(rotMode == 0) _rt.setAngleMod(0);
        else {
            if(rotMode < 4){
                if(_rt.getSegmentGroup().isClockWise()) _ang = _rt.getLerp()*PI*-rotMode;
                else _ang = _rt.getLerp()*PI*rotMode;
            }
            else if(rotMode == 4) _ang = -_rt.getLerp()*PI;
            else if(rotMode == 5) _ang = _rt.getLerp()*PI;

            if(_rt.getDirection()) _ang -= PI;
                _rt.setAngleMod(_ang);
            }
    }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

    public void inject(CommandProcessor _cp){
        metaFreeliner.setCommandProcessor(_cp);
    }

    public void inject(GroupManager _gp){
        groupManager = _gp;
    }

    public void setColorMap(PImage _cm){
        metaFreeliner.setColorMap(_cm);
    }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

    public RenderMode getRenderer(int _index){
        if(_index >= renderModeCount) _index = renderModeCount - 1;
        return renderModes[_index];
    }

    public Repetition getRepeater(int _index){
        if(_index >= repetitionModeCount) _index = repetitionModeCount - 1;
        return repeaters[_index];
    }

    public Easing getEaser(int _index){
        if(_index >= easingModeCount) _index = easingModeCount - 1;
        return easers[_index];
    }

    public Reverse getReverser(int _index){
        if(_index >= reverseModeCount) _index = reverseModeCount - 1;
        return reversers[_index];
    }
}

/*
 * Subclass of RenderEvent that is tweakable
 */
class TweakableTemplate extends Template {
  // store presets!
  int bankIndex;
  ArrayList<Template> bank;

  // track launches, will replace the beat count in killable templates
  int launchCount;

  /*
   * data that can be read post render
   */
  PVector lastPosition;


	public TweakableTemplate(char _id){
		super(_id);
    bank = new ArrayList();
    bankIndex = 0;
    launchCount = 0;
    lastPosition = new PVector(0,0);
	}

  public TweakableTemplate(){
    super();
  }

  public void setLastPosition(PVector _pv){
		lastPosition = _pv.get();
	}

  public final PVector getLastPosition(){
		return lastPosition.get();
	}

  public void launch(){
    launchCount++;
  }
  public int getLaunchCount(){
    return launchCount;
  }
  public String getStatusString(){
    String _stat = str(templateID);
    _stat += " a-"+animationMode;
    _stat += " b-"+renderMode;
    _stat += " j-"+reverseMode;
    _stat += " e-"+interpolateMode;
    _stat += " f-"+fillMode;
    _stat += " h-"+easingMode;
    _stat += " i-"+repetitionMode;
    _stat += " j-"+reverseMode;
    _stat += " k-"+strokeAlpha;
    _stat += " l-"+fillAlpha;
    _stat += " m-"+miscValue;
    _stat += " j-"+reverseMode;
    _stat += " j-"+reverseMode;
    _stat += " j-"+reverseMode;
    _stat += " o-"+rotationMode;
    _stat += " p-"+renderLayer;
    _stat += " q-"+strokeMode;
    _stat += " r-"+repetitionCount;
    _stat += " s-"+brushSize;
    _stat += " u-"+enablerMode;
    _stat += " v-"+segmentMode;
    _stat += " w-"+strokeWidth;
    _stat += " x-"+beatDivider;
    return _stat;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Bank management
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public int saveToBank(){
    Template _tp = new Template();
    _tp.copy(this);
    bank.add(_tp);
    return bank.size()-1;
  }

  public void loadFromBank(int _index){
    if(_index < bank.size()){
      copy(bank.get(_index));
    }
  }

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Tweakable mutators
	///////
	////////////////////////////////////////////////////////////////////////////////////


  public void setCustomStrokeColor(int _c){
    customStrokeColor = _c;
  }

  public void setCustomFillColor(int _c){
    customFillColor = _c;
  }

  /*
   * Tweakables, all these more or less work the same.
   * @param int value, -1 increment, -2 decrement, >= 0 set, -3 return current value
   * @return int value given to parameter
   */

   public int setBankIndex(int _v, int _max){
     bankIndex = numTweaker(_v, bankIndex);
     if(bankIndex >= bank.size()) bankIndex = bank.size()-1;
     loadFromBank(bankIndex);
     return bankIndex;
   }

  public int setReverseMode(int _v, int _max){
    reverseMode = numTweaker(_v, reverseMode);
    if(reverseMode >= _max) reverseMode = _max - 1;
    return reverseMode;
  }

  public int setAnimationMode(int _v, int _max) {
    animationMode = numTweaker(_v, animationMode);
    if(animationMode >= _max) animationMode = _max - 1;
    return animationMode;
  }

  public int setInterpolateMode(int _v, int _max) {
    interpolateMode = numTweaker(_v, interpolateMode);
    if(interpolateMode >= _max) interpolateMode = _max - 1;
    return interpolateMode;
  }

  public int setRenderMode(int _v, int _max) {
    renderMode = numTweaker(_v, renderMode);
    if(renderMode >= _max) renderMode = _max - 1;
    return renderMode;
  }

  public int setSegmentMode(int _v, int _max){
    segmentMode = numTweaker(_v, segmentMode);
    if(segmentMode >= _max) segmentMode = _max - 1;
    return segmentMode;
  }

  public int setEasingMode(int _v, int _max){
    easingMode = numTweaker(_v, easingMode);
    if(easingMode >= _max) easingMode = _max - 1;
    return easingMode;
  }

  public int setRepetitionMode(int _v, int _max){
    repetitionMode = numTweaker(_v, repetitionMode);
    if(repetitionMode >= _max) repetitionMode = _max - 1;
    return repetitionMode;
  }

  public int setRepetitionCount(int _v, int _max) {
    repetitionCount = numTweaker(_v, repetitionCount);
    if(repetitionCount >= _max) repetitionCount = _max - 1;
    return repetitionCount;
  }

  public int setBeatDivider(int _v, int _max) {
    beatDivider = numTweaker(_v, beatDivider);
    if(beatDivider >= _max) beatDivider = _max - 1;
    return beatDivider;
  }

  public int setRotationMode(int _v, int _max){
    rotationMode = numTweaker(_v, rotationMode);
    if(rotationMode >= _max) rotationMode = _max - 1;
    return rotationMode;
  }

	public int setStrokeMode(int _v, int _max) {
    strokeMode = numTweaker(_v, strokeMode);
    if(strokeMode >= _max) strokeMode = _max - 1;
    return strokeMode;
  }

  public int setFillMode(int _v, int _max) {
    fillMode = numTweaker(_v, fillMode);
    if(fillMode >= _max) fillMode = _max - 1;
    return fillMode;
  }

  public int setStrokeWidth(int _v, int _max) {
    strokeWidth = numTweaker(_v, strokeWidth);
    if(strokeWidth >= _max) strokeWidth = _max - 1;
    if(strokeWidth <= 0) strokeWidth = 1;
    return strokeWidth;
  }

  public int setStrokeAlpha(int _v, int _max){
    strokeAlpha = numTweaker(_v, strokeAlpha);
    if(strokeAlpha >= _max) strokeAlpha = _max - 1;
    return strokeAlpha;
  }

  public int setFillAlpha(int _v, int _max){
    fillAlpha = numTweaker(_v, fillAlpha);
    if(strokeAlpha >= _max) strokeAlpha = _max - 1;
    return fillAlpha;
  }

  public int setBrushSize(int _v, int _max) {
    brushSize = numTweaker(_v, brushSize);
    if(brushSize >= _max) brushSize = _max - 1;
    if(brushSize <= 0) brushSize = 1;
    return brushSize;
  }

  public int setMiscValue(int _v, int _max) {
    miscValue = numTweaker(_v, miscValue);
    if(miscValue >= _max) miscValue = _max - 1;
    return miscValue;
  }

  public int setEnablerMode(int _v, int _max) {
    enablerMode = numTweaker(_v, enablerMode);
    if(enablerMode >= _max) enablerMode = _max - 1;
    return enablerMode;
  }

  public int setRenderLayer(int _v, int _max) {
    renderLayer = numTweaker(_v, renderLayer);
    if(renderLayer >= _max) renderLayer = _max - 1;
    return renderLayer;
  }

  public void setFixLerp(float _lrp){
    fixLerp = _lrp;
  }

  public void setTranslation(PVector _pv){
    translation.set(_pv);
  }
}


class GUIWebServer implements FreelinerConfig {

  SimpleHTTPServer server;

  public GUIWebServer(PApplet _parent){
    // // create a server
    if(SERVE_HTTP){
      SimpleHTTPServer.useIndexHtml = false;
      server = new SimpleHTTPServer(_parent, HTTPSERVER_PORT);
      // serveAppropriateFiles();
      server.serveAll("",sketchPath()+"/data/webgui");
    }
    else println("HTTP Webserver disabled!");
  }

  public void refreshFiles(){
    if(SERVE_HTTP){
      server.serveAll("",sketchPath()+"/data/webgui");
    }
  }
  // dosent work
  public void serveAppropriateFiles(){
    File _folder = new File(sketchPath()+"/data");
    File[] _files = _folder.listFiles();
    for (int i = 0; i < _files.length; i++) {
      String[] _file = split(_files[i].getName(), ".");
      if(_file.length > 1){
        // println(_files[i].getPath());
        if(_file[1].equals("html")) server.serve(_files[i].getPath());
        else if(_file[1].equals("css")) server.serve(_files[i].getPath());
        else if(_file[1].equals("json")) server.serve(_files[i].getPath());
        else if(_file[1].equals("js")) server.serve(_files[i].getPath());
        else if(_file[1].equals("jpg")) server.serve(_files[i].getPath());
      }
    }
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


/**
 * Widgets! from scratch!
 * could of used a library but this is fun too.
 */

/**
 * Basic widget class
 *
 *
 */
public class Widget implements FreelinerConfig{
  // position and size
  PVector pos;
  PVector size;
  // mouse position relative to widget 0,0
  PVector mouseDelta;
  // mouse XY 0.0 to 1.0
  PVector mouseFloat;
  // if the mouse is over the widget
  boolean selected;
  // enable disable widget
  boolean active;
  // basic colors
  int bgColor = color(100);
  int hoverColor = color(150);
  int frontColor = color(200,0,0);
  // label
  String label = "";
  int inset = 2;

  String command = "";
  String cmdBuffer = null;

  // callback
  // Method callback;

  /**
   * Constructor
   * @param PVector position of top left corner of widget
   * @param PVector widget dimentions
   */
  public Widget(PVector _pos, PVector _sz){
    pos = _pos.get();
    size = _sz.get();
    mouseDelta = new PVector(0,0);
    mouseFloat = new PVector(0,0);
    active = true;
  }

  /**
   * Render the widget, draws the basic background and changes its color if widget selected.
   * @param PGraphics canvas to draw on
   */
  public void show(PGraphics _pg){
    if(!active) return;
    _pg.noStroke();
    if(selected) _pg.fill(hoverColor);
    else _pg.fill(bgColor);
    _pg.rect(pos.x, pos.y, size.x, size.y);
    showLabel(_pg);
  }

  public void showLabel(PGraphics _pg){
    _pg.fill(255);
    _pg.textSize(14);
    if(label.length()>0) _pg.text(label, pos.x+size.x+2, pos.y + size.y - inset);
  }

  /**
   * Update the widget
   * @param PVector cursor position
   * @return boolean cursor is over widget
   */
  public boolean update(PVector _cursor){
    setCursor(_cursor);
    if(!active) selected = false;
    else selected = isOver();
    return selected;
  }

  /**
   * Update the cursor position, determin the mouseDelta and unit interval
   * @param PVector cursor position
   */
  public void setCursor(PVector _cursor){
    mouseDelta = _cursor.get().sub(pos);
    mouseFloat.set(mouseDelta.x/size.x, mouseDelta.y/size.y);
  }

  /**
   * Is mouse over widget
   * @return boolean
   */
  public boolean isOver(){
    return (mouseDelta.x > 0 && mouseDelta.y > 0) && (mouseDelta.x < size.x && mouseDelta.y < size.y);
  }

  /**
   * receive mouse press
   * @param int mouse button
   */
  public void click(int _mb){
    if(selected) action(_mb);
  }

  /**
   * receive mouse drag,
   * @param int mouse button
   */
  public void drag(int _mb){
    if(selected) action(_mb);
  }

  /**
   * where the action of the widget happens
   * @param int mouse button
   * @return boolean
   */
  public void action(int _button){
    // you can use mouseFloat for info
    //cmdBuffer = command+" "+1;
  }

  public String getCmd(){
    if(cmdBuffer == null) return null;
    else {
      String _out = cmdBuffer;
      cmdBuffer = null;
      return _out;
    }
  }

  public void setPos(PVector _pos){
    pos = _pos.get();
  }

  public void setBackgroundColor(int _col){
    bgColor = _col;
  }
  public void setHoverColor(int _col){
    hoverColor = _col;
  }
  public void setFrontColor(int _col){
    frontColor = _col;
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     Real Widgets!
///////
////////////////////////////////////////////////////////////////////////////////////
/**
 * Basic button widget, subclass and inject things to control.
 */
class Button extends Widget {
  int counter;
  public Button(PVector _pos, PVector _sz, String _cmd){
    super(_pos, _sz);
    counter = 0;
    label = _cmd;
    command = _cmd;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active && counter > 0){
      counter--;
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, size.x-(2*inset), size.y-(2*inset));
    }
  }

  public void action(int _button){
    cmdBuffer = command;
  }

  public void click(int _mb){
    super.click(_mb);
    counter = 4;
  }

  // do nothing on drag
  public void drag(int _mb){

  }
}

/**
 * Basic toggle widget, subclass and inject things to control.
 */
class Toggle extends Widget {
  boolean value;
  int toggleCol = color(255,0,0);

  public Toggle(PVector _pos, PVector _sz){
    super(_pos, _sz);
    value = false;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active && value){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, size.x-(2*inset), size.y-(2*inset));
    }
  }

  public void action(int _button){
    value = !value;
  }
}

/**
 * Basic horizontal fader widget, subclass and inject things to control.
 */
class Fader extends Widget {
  float value;

  public Fader(PVector _pos, PVector _sz, String _cmd){
    super(_pos, _sz);
    value = 0.5f;
    label = _cmd;
    command = _cmd;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, (size.x-(2*inset)) * value, size.y-(2*inset));
    }
  }

  public void action(int _button){
    value = constrain(mouseFloat.x, 0.0f, 1.0f);
    cmdBuffer = command+" "+value;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Actual widgets
///////
////////////////////////////////////////////////////////////////////////////////////


/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
class InfoLine extends Widget {
  Gui flGui;
  int txtSize;
  public InfoLine(PVector _pos, PVector _sz, Gui _g){
    super(_pos, _sz);
    txtSize = PApplet.parseInt(_sz.y);
    flGui = _g;
    active = true;
  }

  public void show(PGraphics _canvas){
    if(!active) return;
    _canvas.textSize(txtSize);
    String[] _info = reverse(flGui.getAllInfo());
    String _txt = "";
    for(String str : _info) _txt += str+"  ";
    _canvas.fill(255);
    _canvas.text(_txt, pos.x, pos.y+txtSize);
  }
}

/**
 * Widget to control the sequencer
 */
class SequenceGUI extends Widget {
  int txtSize = 20;
  int inset = 2;
  Sequencer sequencer;
  TemplateList managerList;

  public SequenceGUI(PVector _pos, PVector _sz, Sequencer _seq, TemplateList _tl){
    super(_pos, _sz);
    //txtSize = int(_sz.y);
    sequencer = _seq;
    managerList = _tl;
    active = true;
  }

  public void action(int _mb){
    int _clickedStep = PApplet.parseInt(mouseFloat.x * SEQ_STEP_COUNT);
    if(_mb == LEFT) sequencer.forceStep(_clickedStep);
    else if(_mb == RIGHT){
      ArrayList<TweakableTemplate> _tmps = managerList.getAll();
      if(_tmps == null) return;
      sequencer.setEditStep(_clickedStep);
      for(TweakableTemplate _tw : _tmps){
        sequencer.getStepToEdit().toggle(_tw);
      }
    }
  }


  public void show(PGraphics _canvas){
    if(!active) return;
    int _index = 0;
    int _stepSize = PApplet.parseInt(size.x/ 16.0f);
    _canvas.textSize(txtSize);
    for(TemplateList _tl : sequencer.getStepLists()){
      _canvas.pushMatrix();
      _canvas.translate(_stepSize * _index, pos.y);
      if(_index == sequencer.getStep()) _canvas.fill(hoverColor);
      else _canvas.fill(bgColor);
      _canvas.stroke(0);
      _canvas.strokeWeight(1);
      _canvas.rect(0, 0, _stepSize, size.y);
      _canvas.noStroke();
      if(_tl == sequencer.getStepToEdit()){
        _canvas.fill(frontColor);
        _canvas.rect(inset, inset, _stepSize-(2*inset), size.y-(2*inset));
      }
      _canvas.rotate(HALF_PI);
      _canvas.fill(255);
      _canvas.text(_tl.getTags(),inset*4,-inset*4);
      _canvas.popMatrix();
      _index++;
    }
  }
}
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class XMLTemplate extends Template{
  public XMLTemplate(){

  }

  public XML getXML(){
    XML _tpXML = new XML("template");
    _tpXML.setInt("renderMode", renderMode);
    _tpXML.setInt("segmentMode", segmentMode);
    _tpXML.setInt("animationMode", animationMode);
    _tpXML.setInt("strokeMode", strokeMode);
    _tpXML.setInt("fillMode", fillMode);
    _tpXML.setInt("strokeAlpha", strokeAlpha);
    _tpXML.setInt("fillAlpha", fillAlpha);
    _tpXML.setInt("rotationMode", rotationMode);
    _tpXML.setInt("easingMode", easingMode);
    _tpXML.setInt("reverseMode", reverseMode);
    _tpXML.setInt("repetitionMode", repetitionMode);
    _tpXML.setInt("repetitionCount", repetitionCount);
    _tpXML.setInt("beatDivider", beatDivider);
    _tpXML.setInt("strokeWidth", strokeWidth);
    _tpXML.setInt("brushSize", brushSize);
    _tpXML.setInt("miscValue", miscValue);
    _tpXML.setInt("enablerMode", enablerMode);
    //String _name = str(renderMode)+str(segmentMode)+str(animationMode)+str(strokeMode)+str(fillMode)
    //_tpXML.setString("name", _name);
    return _tpXML;
  }

  public void loadXML(XML _tpXML){
    renderMode = _tpXML.getInt("renderMode");
    segmentMode = _tpXML.getInt("segmentMode");
    animationMode = _tpXML.getInt("animationMode");
    strokeMode = _tpXML.getInt("strokeMode");
    fillMode = _tpXML.getInt("fillMode");
    strokeAlpha = _tpXML.getInt("strokeAlpha");
    fillAlpha = _tpXML.getInt("fillAlpha");
    rotationMode = _tpXML.getInt("rotationMode");
    easingMode = _tpXML.getInt("easingMode");
    reverseMode = _tpXML.getInt("reverseMode");
    repetitionMode = _tpXML.getInt("repetitionMode");
    repetitionCount = _tpXML.getInt("repetitionCount");
    beatDivider = _tpXML.getInt("beatDivider");
    strokeWidth = _tpXML.getInt("strokeWidth");
    brushSize = _tpXML.getInt("brushSize");
    miscValue = _tpXML.getInt("miscValue");
    enablerMode = _tpXML.getInt("enablerMode");
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */


public int stringInt(String _str){
  try {
    return Integer.parseInt(_str);
  }
  catch (Exception e){
    //println("Bad number string");
    return -42;
  }
}

public float stringFloat(String _str){
  try {
    return Float.parseFloat(_str);
  }
  catch (Exception e){
    //println("Bad number float");
    return -42.0f;
  }
}

/**
 * Class to collect and average data
 */
class FloatSmoother {
  boolean firstValue;
  FloatList flts;
  int smoothSize;

  public FloatSmoother(int s, float f){
    firstValue = true;
    smoothSize = s;
    flts = new FloatList();
    fillArray(f);
  }

  public float addF(float s){
    if(firstValue){
      firstValue = false;
      fillArray(s);
    }
    flts.append(s);
    flts.remove(0);
    return arrayAverager();
  }

  private void fillArray(float f) {
    flts.clear();
    for(int i = 0; i < smoothSize; i++){
      flts.append(f);
    }
  }

  private float arrayAverager() {
    float sum = 0;
    for(int i = 0; i < smoothSize; i++){
      sum += flts.get(i);
    }
    return sum / smoothSize;
  }
}

/**
 * Method to manipulate values by increment or asbolute
 * if the new value is >= 0 it will simply return this.
 * otherwise if its -1 or -2 it will increment or decrement the original value
 * @param int new value
 * @param int value to modify
 * @return int modified value
 */
public int numTweaker(int v, int n){
  if(v >= 0) return v;
  else if (v == -1) return n+1;
  else if (v == -2 && n-1>=0) return n-1;
  else return n;
}


/**
 * linear interpolation between two PVectors
 * @param PVector first vector
 * @param PVector second vector
 * @param float unit interval
 * @return PVector interpolated
 */
public PVector vecLerp(PVector a, PVector b, float l){
  return new PVector(lerp(a.x, b.x, l), lerp(a.y, b.y, l), 0);
}

/**
 * linear interpolation between two PVectors
 * @param PGraphics to draw on
 * @param PVector first coordinate
 * @param PVector second coordinate
 */
public void vecLine(PGraphics p, PVector a, PVector b){
  p.line(a.x,a.y,b.x,b.y);
}

/**
 * Polar to euclidean conversion
 * @param PVector center point
 * @param float angle
 * @param float distance
 * @return PVector euclidean of polar
 */
public PVector angleMove(PVector p, float a, float s){
  PVector out = new PVector(cos(a)*s, sin(a)*s, 0);
  out.add(p);
  return out;
}

/**
 * Mirror PVector from the center
 * @param PVector position to mirror along the X axis
 * @return PVector mirrored position
 */
public PVector vectorMirror(PVector p){
  float newX = 0;
  if(p.x < width/2) newX = width-p.x;
  else newX = -(p.x-width/2)+width/2;
  return new PVector(newX, p.y, p.z);
}


public float fltMod(float f) {
  if (f>1) f-=1;
  else if (f<0) f+=1;
  return f;
}

//wrap around
public static int wrap(int v, int n) {
  if (v<0) v = n;
  if (v>n) v = 0;
  return v;
}

public boolean maybe(int _p){
  return random(100) < _p;
}

/**
 * PShape clone/resize/center, the centerPosition will translate everything making it 0,0
 * @param  source PShape
 * @param  scalar float
 * @param  centerPoint PVector
 * @return new PShape
 */

public PShape cloneShape(PShape _source, float _scale, PVector _center){
  if(_source == null) return null;
  PShape shp = createShape();
  shp.beginShape(_source.getKind());
  shp.strokeJoin(FreelinerConfig.STROKE_JOIN);
  shp.strokeCap(FreelinerConfig.STROKE_CAP);
  PVector tmp = new PVector(0,0);
  PVector frst = new PVector(0,0);
  PVector last = new PVector(0,0);
  for(int i = 0; i < _source.getVertexCount(); i++){
    tmp = _source.getVertex(i);
    tmp.sub(_center);
    tmp.mult(_scale);
    if(i == 0) frst = tmp;
    else last = tmp;
    shp.vertex(tmp.x, tmp.y);
  }
  if(abs(frst.dist(last)) < 0.1f) shp.endShape(CLOSE);
  else shp.endShape();
  //_source = null; // cleanup?
  return shp;
}

public PShape cloneShape(PShape _source, float _scale){
  return cloneShape(_source, _scale, new PVector(0,0));
}

/**
 * PShape clone/resize/center, the centerPosition will translate everything making it 0,0
 * @param  String directory
 * @param String file extention
 * @return String[] fileNames
 */
// String[] parseDirectory(String _dir, String _ext){
//
// }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "freeliner_sketch" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
