
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

  public KeyMap(){
    keymap = new ParameterKey[255];
    // animationMode
    loadKeys();
  }

  public ParameterKey[] getKeyMap(){
    return keymap;
  }

  public void setLimits(IntDict _limits){
    for(String _s : _limits.keys()){
      keymap[_s.charAt(0)].setMax(_limits.get(_s));
    }
    keymap['f'].setMax(keymap['q'].getMax());
    for(ParameterKey _pk : keymap) if(_pk != null) println(_pk.getKey()+" "+_pk.getMax());
  }




  public void loadKeys(){
    keymap['a'] = new ParameterKey('a');
    keymap['a'].setType(5);
    keymap['a'].setName("animation");
    keymap['a'].setDescription("animate stuff");
    keymap['a'].setCMD("tw $ a");

    // renderMode
    keymap['b'] = new ParameterKey('b');
    keymap['b'].setType(5);
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
    keymap['e'].setType(5);
    keymap['e'].setName("enterpolator");
    keymap['e'].setDescription("Enterpolator picks a position along a segment");
    keymap['e'].setCMD("tw $ e"); //

    // fillColor
    keymap['f'] = new ParameterKey('f');
    keymap['f'].setType(5);
    keymap['f'].setName("fill");
    keymap['f'].setDescription("Pick fill color");
    keymap['f'].setCMD("tw $ f"); //

    // the grid
    keymap['g'] = new ParameterKey('g');
    keymap['g'].setType(2);
    keymap['g'].setName("grid");
    keymap['g'].setDescription("use snappable grid");
    keymap['g'].setCMD("tools grid"); // argument
    keymap['g'].setMax(255);

    // easing
    keymap['h'] = new ParameterKey('h');
    keymap['h'].setType(5);
    keymap['h'].setName("easing");
    keymap['h'].setDescription("Set the easing mode.");
    keymap['h'].setCMD("tw $ h");

    // iteration
    keymap['i'] = new ParameterKey('i');
    keymap['i'].setType(5);
    keymap['i'].setName("iteration");
    keymap['i'].setDescription("Iterate animation in different ways, `r` sets the amount.");
    keymap['i'].setCMD("tw $ i");

    // reverseMode
    keymap['j'] = new ParameterKey('j');
    keymap['j'].setType(5);
    keymap['j'].setName("reverse");
    keymap['j'].setDescription("Pick different reverse modes");
    keymap['j'].setCMD("tw $ j"); //

    // strokeAlpha
    keymap['k'] = new ParameterKey('k');
    keymap['k'].setType(4);
    keymap['k'].setName("strokeAlpha");
    keymap['k'].setDescription("Alpha value of stroke.");
    keymap['k'].setCMD("tw $ k"); //
    keymap['k'].setMax(256); //


    // fillAlpha
    keymap['l'] = new ParameterKey('l');
    keymap['l'].setType(4);
    keymap['l'].setName("fillAlpha");
    keymap['l'].setDescription("Alpha value of fill.");
    keymap['l'].setCMD("tw $ l"); //
    keymap['l'].setMax(256); //


    // miscValue
    keymap['m'] = new ParameterKey('m');
    keymap['m'].setType(3);
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
    keymap['o'].setType(5);
    keymap['o'].setName("rotation");
    keymap['o'].setDescription("Rotate stuff.");
    keymap['o'].setCMD("tw $ o"); //
    keymap['o'].setMax(12);

    // layer
    keymap['p'] = new ParameterKey('p');
    keymap['p'].setType(3);
    keymap['p'].setName("layer");
    keymap['p'].setDescription("Pick which layer to render on.");
    keymap['p'].setCMD("tw $ p");
    keymap['p'].setMax(3); // need to fix this

    // strokeColor
    keymap['q'] = new ParameterKey('q');
    keymap['q'].setType(5);
    keymap['q'].setName("strokeColor");
    keymap['q'].setDescription("Pick the stroke Color.");
    keymap['q'].setCMD("tw $ q"); //

    // polka
    keymap['r'] = new ParameterKey('r');
    keymap['r'].setType(3);
    keymap['r'].setName("polka");
    keymap['r'].setDescription("Number of iterations for the iterator, related to `i`.");
    keymap['r'].setCMD("tw $ r"); //
    keymap['r'].setMax(10000000); //


    // Size
    keymap['s'] = new ParameterKey('s');
    keymap['s'].setType(3);
    keymap['s'].setName("size");
    keymap['s'].setDescription("Sets the brush size for `b-0`");
    keymap['s'].setCMD("tw $ s"); //
    keymap['s'].setMax(5000);


    // tapTempo
    keymap['t'] = new ParameterKey('t');
    keymap['t'].setType(0);
    keymap['t'].setName("tap");
    keymap['t'].setDescription("Tap tempo, tweaking nudges time.");
    keymap['t'].setCMD("seq tap");
    keymap['t'].setMax(1000);

    // enabler
    keymap['u'] = new ParameterKey('u');
    keymap['u'].setType(5);
    keymap['u'].setName("enabler");
    keymap['u'].setDescription("Enablers decide if a render happens or not.");
    keymap['u'].setCMD("tw $ u"); //

    // segmentSelcetor
    keymap['v'] = new ParameterKey('v');
    keymap['v'].setType(5);
    keymap['v'].setName("segSelect");
    keymap['v'].setDescription("Picks which segments get rendered.");
    keymap['v'].setCMD("tw $ v"); //

    // strokeWeight
    keymap['w'] = new ParameterKey('w');
    keymap['w'].setType(3);
    keymap['w'].setName("strokeWeight");
    keymap['w'].setDescription("Stroke weight.");
    keymap['w'].setCMD("tw $ w"); //
    keymap['w'].setMax(420);


    // beatDivider
    keymap['x'] = new ParameterKey('x');
    keymap['x'].setType(3);
    keymap['x'].setName("beatMultiplier");
    keymap['x'].setDescription("Set how many beats the animation will take.");
    keymap['x'].setCMD("tw $ x"); //
    keymap['x'].setMax(5000);

    // tracers
    keymap['y'] = new ParameterKey('y');
    keymap['y'].setType(4);
    keymap['y'].setName("tracers");
    keymap['y'].setDescription("Set tracer level for tracer layer.");
    keymap['y'].setCMD("post tracers"); //
    keymap['y'].setMax(256);


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
    keymap['A'].setCMD("??set*??"); //
    // share
    keymap['B'] = new ParameterKey('B');
    keymap['B'].setType(0);
    keymap['B'].setName("add");
    keymap['B'].setDescription("Toggle second template on all geometry with first template.");
    keymap['B'].setCMD("tp add $"); //
    // copy
    keymap['C'] = new ParameterKey('C');
    keymap['C'].setType(0);
    keymap['C'].setName("copy");
    keymap['C'].setDescription("Copy first selected template into second selected.");
    keymap['C'].setCMD("tp copy $"); //
    // customShape
    keymap['D'] = new ParameterKey('D');
    keymap['D'].setType(3);
    keymap['D'].setName("customShape");
    keymap['D'].setDescription("Set a template's customShape.");
    keymap['D'].setCMD("tp shape $"); //
    keymap['D'].setMax(1000);

    // reverseMouse
    keymap['I'] = new ParameterKey('I');
    keymap['I'].setType(1);
    keymap['I'].setName("revMouseX");
    keymap['I'].setDescription("Reverse the X axis of mouse, trust me its handy.");
    keymap['I'].setCMD("tools revx"); //
    // enterpolator
    keymap['O'] = new ParameterKey('O');
    keymap['O'].setType(6);
    keymap['O'].setName("open");
    keymap['O'].setDescription("Open stuff");
    keymap['O'].setCMD("fl open"); //
    // enterpolator
    keymap['M'] = new ParameterKey('M');
    keymap['M'].setType(0);
    keymap['M'].setName("mask");
    keymap['M'].setDescription("Generate mask for maskLayer, or set mask.");
    keymap['M'].setCMD("layer mask make"); //
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
    keymap['.'].setType(2);
    keymap['.'].setName("snapping");
    keymap['.'].setDescription("enable/disable snapping or set the snapping distance");
    keymap['.'].setCMD("tools snap"); // then check for selected segment, or execute cmd
    keymap['.'].setMax(255);
    // fixed angle
    keymap['['] = new ParameterKey('[');
    keymap['['].setType(2);
    keymap['['].setName("fixedAngle");
    keymap['['].setDescription("enable/disable fixed angles for the mouse");
    keymap['['].setCMD("tools angle"); // then check for selected segment, or execute cmd
    keymap['['].setMax(360);
    // fixed length
    keymap[']'] = new ParameterKey(']');
    keymap[']'].setType(2);
    keymap[']'].setName("fixedLength");
    keymap[']'].setDescription("enable/disable fixed length for the mouse");
    keymap[']'].setCMD("tools ruler"); // then check for selected segment, or execute cmd
    keymap[']'].setMax(5000);
    // showLines
    keymap['/'] = new ParameterKey('/');
    keymap['/'].setType(1);
    keymap['/'].setName("showLines");
    keymap['/'].setDescription("Showlines of all geometry.");
    keymap['/'].setCMD("tools lines");
    // showTags
    keymap[','] = new ParameterKey(',');
    keymap[','].setType(1);
    keymap[','].setName("showTags");
    keymap[','].setDescription("showTags of all groups");
    keymap[','].setCMD("tools tags");


    // text entry
    keymap['|'] = new ParameterKey('|');
    keymap['|'].setType(1);
    keymap['|'].setName("enterText");
    keymap['|'].setDescription("enable text entry, type text and press return");
    keymap['|'].setCMD("text"); // then check for selected segment, or execute cmd

    // sequencer
    keymap['<'] = new ParameterKey('<');
    keymap['<'].setType(3);
    keymap['<'].setName("sequencer");
    keymap['<'].setDescription("select sequencer steps to add or remove templates");
    keymap['<'].setCMD("seq select"); // tweak value select step
    keymap['<'].setMax(16);
    // play pause
    keymap['>'] = new ParameterKey('>');
    keymap['>'].setType(1);
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
  }

  public ParameterKey getKey(int _ascii){
    // fix a
    if(_ascii > keymap.length) return null;
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
  // type of control
  // 0 button
  // 1 toggle
  // 2 toogle+value
  // 3 Number
  // 4 slider
  // 5 menu
  // 6 file
  int type = 0;

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
  public final void setType(int _t){
    type =_t;
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
  public final int getType(){
    return type;
  }
}
