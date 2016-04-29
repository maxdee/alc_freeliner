
interface FreelinerConfig {

  final int WINDOW_WIDTH = 1024;
  final int WINDOW_HEIGHT = 768;
  final boolean FULLSCREEN = false;

  // UDP Port for incomming messages
  final int OSC_IN_PORT = 6667;
  // UDP Port for outgoing sync message
  final int OSC_OUT_PORT = 6668;
  // IP address to send sync messages to
  final String OSC_OUT_IP = "127.0.0.1";
  // Websocket port
  final int WEBSOCKET_PORT = 8025;

  // GUI options
  final int CURSOR_SIZE = 18;
  final int CURSOR_GAP_SIZE = 6;
  final int CURSOR_STROKE_WIDTH = 3;
  final int GUI_TIMEOUT = 1000;
  // final int DEFAULT_GRID_SIZE = 32; // used by mouse too
  final int NODE_STROKE_WEIGTH = 5;
  final int NODE_COLOR = #FFFFFF;
  final int PREVIEW_LINE_STROKE_WIDTH = 1;
  final color PREVIEW_LINE_COLOR = #ffffff;
  final color CURSOR_COLOR = #FFFFFF;
  final color SNAPPED_CURSOR_COLOR = #00C800;
  final color TEXT_COLOR = #FFFFFF;
  final color GRID_COLOR = #969696;//9696;
  final color SEGMENT_COLOR = #BEBEBE;
  final color SEGMENT_COLOR_UNSELECTED = #6E6E6E;

  // If you are using a DLP with no colour wheel
  final boolean BW_BEAMER = false;
  // If you are using a dual head setup
  final boolean DUAL_HEAD = false;
  // invert colors
  final boolean INVERTED_COLOR = false;

  // Rendering options
  final color BACKGROUND_COLOR = #000000;
  final int STROKE_CAP = ROUND;
  final int STROKE_JOIN = MITER;
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

  // Mouse options
  final int DEFAULT_GRID_SIZE = 64;
  final int DEFAULT_LINE_ANGLE = 30;
  final int DEFAULT_LINE_LENGTH = 128;
  final int MOUSE_DEBOUNCE = 100;
  // use scrollwheel as - +
  final boolean SCROLLWHEEL_SELECTOR = true;

  // generate documentation on startup
  final boolean MAKE_DOCUMENTATION = true;
  /**
   * Your color pallette! customize it!
   * Use hex value or color(0,100,200);
   */
  final color[] userPallet = {
                    #ffff00,
                    #ffad10,
                    #ff0000,
                    #ff00ad,
                    #f700f7,
                    #ad00ff,
                    #0000ff,
                    #009cff,
                    #00c6ff,
                    #00deb5,
                    #a5ff00,
                    #f700f7,
                  };

  final int PALLETTE_COUNT = 12;

  // Freeliner LED options
  final String LED_SERIAL_PORT = "/dev/ttyACM0";
  final int LED_SYSTEM = 1; // FastLEDing 1, OctoLEDing 2
}



class KeyMap {
  ParameterKey[] keymap;

  public KeyMap(){
    keymap = new ParameterKey[255];
    // animationMode
    loadKeys();
  }

  public void setLimits(IntDict _limits){
    for(String _s : _limits.keys()){
      keymap[_s.charAt(0)].setMax(_limits.get(_s));
    }
    for(ParameterKey _pk : keymap) if(_pk != null) println(_pk.getKey()+" "+_pk.getMax());
  }

  public void loadKeys(){
    keymap['a'] = new ParameterKey('a');
    keymap['a'].setName("animation");
    keymap['a'].setDescription("animate stuff");
    keymap['a'].setCMD("tw $ a");

    // renderMode
    keymap['b'] = new ParameterKey('b');
    keymap['b'].setName("renderMode");
    keymap['b'].setDescription("picks the renderMode");
    keymap['b'].setCMD("tw $ b");

    // placeCenter
    keymap['c'] = new ParameterKey('c');
    keymap['c'].setName("placeCenter");
    keymap['c'].setDescription("Place the center of geometry on next left click, right click uncenters the geometry, middle click sets scene center.");
    keymap['c'].setCMD("geom center"); // -3 toggles other args for setting center?

    // breakline
    keymap['d'] = new ParameterKey('d');
    keymap['d'].setName("breakline");
    keymap['d'].setDescription("Detach line to new starting position.");
    keymap['d'].setCMD("geom breakline"); //

    // enterpolator
    keymap['e'] = new ParameterKey('e');
    keymap['e'].setName("enterpolator");
    keymap['e'].setDescription("Enterpolator picks a position along a segment");
    keymap['e'].setCMD("tw $ e"); //

    // fillColor
    keymap['f'] = new ParameterKey('f');
    keymap['f'].setName("fill");
    keymap['f'].setDescription("Pick fill color");
    keymap['f'].setCMD("tw $ f"); //

    // the grid
    keymap['g'] = new ParameterKey('g');
    keymap['g'].setName("grid");
    keymap['g'].setDescription("use snappable grid");
    keymap['g'].setCMD("tools grid"); // argument
    keymap['g'].setMax(255);

    // easing
    keymap['h'] = new ParameterKey('h');
    keymap['h'].setName("easing");
    keymap['h'].setDescription("Set the easing mode.");
    keymap['h'].setCMD("tw $ h");

    // iteration
    keymap['i'] = new ParameterKey('i');
    keymap['i'].setName("iteration");
    keymap['i'].setDescription("Iterate animation in different ways, `r` sets the amount.");
    keymap['i'].setCMD("tw $ i");

    // reverseMode
    keymap['j'] = new ParameterKey('j');
    keymap['j'].setName("reverse");
    keymap['j'].setDescription("Pick different reverse modes");
    keymap['j'].setCMD("tw $ j"); //

    // strokeAlpha
    keymap['k'] = new ParameterKey('k');
    keymap['k'].setName("strokeAlpha");
    keymap['k'].setDescription("Alpha value of stroke.");
    keymap['k'].setCMD("tw $ k"); //
    keymap['k'].setMax(256); //


    // fillAlpha
    keymap['l'] = new ParameterKey('l');
    keymap['l'].setName("fillAlpha");
    keymap['l'].setDescription("Alpha value of fill.");
    keymap['l'].setCMD("tw $ l"); //
    keymap['l'].setMax(256); //


    // miscValue
    keymap['m'] = new ParameterKey('m');
    getKey('m').setName("miscValue");
    getKey('m').setDescription("A extra value that can be used by modes.");
    getKey('m').setCMD("tw $ m"); //
    keymap['l'].setMax(1000); //


    // new geometry
    keymap['n'] = new ParameterKey('n');
    keymap['n'].setName("new");
    keymap['n'].setDescription("make a new geometry group");
    keymap['n'].setCMD("geom new");

    // rotationMode
    keymap['o'] = new ParameterKey('o');
    getKey('o').setName("rotation");
    getKey('o').setDescription("Rotate stuff.");
    getKey('o').setCMD("tw $ o"); //

    // layer
    keymap['p'] = new ParameterKey('p');
    getKey('p').setName("layer");
    getKey('p').setDescription("Pick which layer to render on.");
    getKey('p').setCMD("tw $ p");
    getKey('p').setMax(3); // need to fix this


    // strokeColor
    keymap['q'] = new ParameterKey('q');
    getKey('q').setName("strokeColor");
    getKey('q').setDescription("Pick the stroke Color.");
    getKey('q').setCMD("tw $ q"); //

    // polka
    keymap['r'] = new ParameterKey('r');
    getKey('r').setName("polka");
    getKey('r').setDescription("Number of iterations for the iterator, related to `i`.");
    getKey('r').setCMD("tw $ r"); //

    // Size
    keymap['s'] = new ParameterKey('s');
    getKey('s').setName("size");
    getKey('s').setDescription("Sets the brush size for `b-0`");
    getKey('s').setCMD("tw $ s"); //
    getKey('s').setMax(5000);


    // tapTempo
    keymap['t'] = new ParameterKey('t');
    getKey('t').setName("tap");
    getKey('t').setDescription("Tap tempo, tweaking nudges time.");
    getKey('t').setCMD("seq tap");
    getKey('t').setMax(1000);


    // enabler
    keymap['u'] = new ParameterKey('u');
    getKey('u').setName("enabler");
    getKey('u').setDescription("Enablers decide if a render happens or not.");
    getKey('u').setCMD("tw $ u"); //

    // segmentSelcetor
    keymap['v'] = new ParameterKey('v');
    getKey('v').setName("segSelect");
    getKey('v').setDescription("Picks which segments get rendered.");
    getKey('v').setCMD("tw $ v"); //

    // strokeWeight
    keymap['w'] = new ParameterKey('w');
    getKey('w').setName("strokeWeight");
    getKey('w').setDescription("Stroke weight.");
    getKey('w').setCMD("tw $ w"); //

    // beatDivider
    keymap['x'] = new ParameterKey('x');
    getKey('x').setName("beatMultiplier");
    getKey('x').setDescription("Set how many beats the animation will take.");
    getKey('x').setCMD("tw $ x"); //
    getKey('x').setMax(5000);

    // enterpolator
    keymap['y'] = new ParameterKey('y');
    getKey('y').setName("tracers");
    getKey('y').setDescription("Set tracer level for tracer layer.");
    getKey('y').setCMD("post tracers"); //
    getKey('y').setMax(256);


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    controlKeys (also capital letters, but they dont need to know this)
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // selectAll
    keymap['A'] = new ParameterKey('A');
    getKey('A').setName("selectAll");
    getKey('A').setDescription("Select ALL the templates.");
    getKey('A').setCMD("??set*??"); //
    // copy
    keymap['C'] = new ParameterKey('C');
    getKey('C').setName("copy");
    getKey('C').setDescription("Copy first selected template into second selected.");
    getKey('C').setCMD("tp copy $"); //
    // customShape
    keymap['D'] = new ParameterKey('D');
    getKey('D').setName("customShape");
    getKey('D').setDescription("Set a template's customShape.");
    getKey('D').setCMD("tp shape $"); //
    getKey('D').setMax(1000);

    // reverseMouse
    keymap['I'] = new ParameterKey('I');
    getKey('I').setName("revMouseX");
    getKey('I').setDescription("Reverse the X axis of mouse, trust me its handy.");
    getKey('I').setCMD("tools revx"); //
    // enterpolator
    keymap['O'] = new ParameterKey('O');
    getKey('O').setName("open");
    getKey('O').setDescription("Open stuff");
    getKey('O').setCMD("fl open"); //
    // enterpolator
    keymap['M'] = new ParameterKey('M');
    getKey('M').setName("mask");
    getKey('M').setDescription("Generate mask for maskLayer, or set mask.");
    getKey('M').setCMD("layer mask"); //
    // resetTamplate
    keymap['R'] = new ParameterKey('R');
    getKey('R').setName("reset");
    getKey('R').setDescription("Reset template.");
    getKey('R').setCMD("tp reset $"); //
    // saveStuff
    keymap['S'] = new ParameterKey('S');
    getKey('S').setName("save");
    getKey('S').setDescription("Save stuff.");
    getKey('S').setCMD("fl save");
    // swap
    keymap['X'] = new ParameterKey('X');
    getKey('X').setName("swap");
    getKey('X').setDescription("Completely swap template tag, with `AB` A becomes B and B becomes A.");
    getKey('X').setCMD("tp swap $");


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    other keys
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // increase
    keymap['='] = new ParameterKey('=');
    getKey('=').setName("increase");
    getKey('=').setDescription("Increase value of selectedKey.");
    // decrease
    keymap['-'] = new ParameterKey('-');
    getKey('-').setName("decrease");
    getKey('-').setDescription("Decrease value of selectedKey.");

    // snapping
    keymap['.'] = new ParameterKey('.');
    keymap['.'].setName("snapping");
    keymap['.'].setDescription("enable/disable snapping or set the snapping distance");
    keymap['.'].setCMD("tools snap"); // then check for selected segment, or execute cmd
    keymap['.'].setMax(255);
    // fixed angle
    keymap['['] = new ParameterKey('[');
    keymap['['].setName("fixedAngle");
    keymap['['].setDescription("enable/disable fixed angles for the mouse");
    keymap['['].setCMD("tools angle"); // then check for selected segment, or execute cmd
    keymap['['].setMax(360);
    // fixed length
    keymap[']'] = new ParameterKey(']');
    keymap[']'].setName("fixedLength");
    keymap[']'].setDescription("enable/disable fixed length for the mouse");
    keymap[']'].setCMD("tools ruler"); // then check for selected segment, or execute cmd
    keymap[']'].setMax(5000);
    // showLines
    keymap['/'] = new ParameterKey('/');
    getKey('/').setName("showLines");
    getKey('/').setDescription("Showlines of all geometry.");
    getKey('/').setCMD("tools lines");
    // showTags
    keymap[','] = new ParameterKey(',');
    getKey(',').setName("showTags");
    getKey(',').setDescription("showTags of all groups");
    getKey(',').setCMD("tools tags");


    // text entry
    keymap['|'] = new ParameterKey('|');
    keymap['|'].setName("enterText");
    keymap['|'].setDescription("enable text entry, type text and press return");
    keymap['|'].setCMD("text"); // then check for selected segment, or execute cmd

    // sequencer
    keymap['<'] = new ParameterKey('<');
    keymap['<'].setName("sequencer");
    keymap['<'].setDescription("select sequencer steps to add or remove templates");
    keymap['<'].setCMD("seq select"); // tweak value select step
    keymap['<'].setMax(16);
    // play pause
    keymap['>'] = new ParameterKey('>');
    keymap['>'].setName("play");
    keymap['>'].setDescription("toggle auto loops and sequencer"); // ?
    keymap['>'].setCMD("seq play"); // toggle sequencer playing or specify step to play from
    // seq clear
    keymap['^'] = new ParameterKey('^');
    keymap['^'].setName("clear");
    keymap['^'].setDescription("clear sequencer");
    keymap['^'].setCMD("seq clear $");

    // randomAction
    keymap['?'] = new ParameterKey('?');
    keymap['?'].setName("???");
    keymap['?'].setDescription("~:)"); // ?
    keymap['?'].setCMD("fl random"); // toggle sequencer playing or specify step to play from

  }

  public ParameterKey getKey(int _ascii){
    return keymap[_ascii];
  }

  // safe accessors
  public String getName(char _k){
    if(keymap[_k] == null) return "not_mapped";
    else return keymap[_k].getName();
  }
  public String getDescription(char _k){
    if(keymap[_k] == null) return "not_mapped";
    else return keymap[_k].getDescription();
  }
  public String getCMD(char _k){
    if(keymap[_k] == null) return "nope";
    else return keymap[_k].getCMD();
  }
  public int getMax(char _k){
    if(keymap[_k] == null) return -42;
    else return keymap[_k].getMax();
  }
}


class ParameterKey{
  char thekey;
  String name;
  String description;
  String cmd = "nope";
  int maxVal = -42; // for no max

  public ParameterKey(char _k){
    thekey = _k;
  }


  public final void setName(String _n){
    name = _n;
  }
  public final void setDescription(String _d){
    description = _d;
  }
  public final void setCMD(String _c){
    cmd = _c;
  }
  public final void setMax(int _i){
    maxVal = _i;
  }


  public final char getKey(){
    return thekey;
  }
  public final String getName(){
    return name;
  }
  public final String getDescription(){
    return description;
  }
  public final String getCMD(){
    return cmd;
  }
  public final int getMax(){
    return maxVal;
  }
}
