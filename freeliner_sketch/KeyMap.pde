
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
    final int KEYTYPE_MACRO = 7;



    public KeyMap() {
        keymap = new ParameterKey[255];
        // animationMode
        loadKeys();
        loadMacros();
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
        keymap['f'].setCMD("tw $ f");

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
        // deprecated, use webgui
        // keymap['M'] = new ParameterKey('M');
        // keymap['M'].setType(0);
        // keymap['M'].setName("mask");
        // keymap['M'].setDescription("Generate mask for maskLayer, or set mask.");
        // keymap['M'].setCMD("layer mask make"); //
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

        keymap['1'] = new ParameterKey('1');
        keymap['1'].setType(KEYTYPE_MACRO);
        keymap['1'].setName("macro1");
        keymap['1'].setDescription("macro 1: ");
        keymap['1'].setCMD("");

        keymap['2'] = new ParameterKey('2');
        keymap['2'].setType(KEYTYPE_MACRO);
        keymap['2'].setName("macro2");
        keymap['2'].setDescription("macro 2: ");
        keymap['2'].setCMD("");

        keymap['3'] = new ParameterKey('3');
        keymap['3'].setType(KEYTYPE_MACRO);
        keymap['3'].setName("macro3");
        keymap['3'].setDescription("macro 3: ");
        keymap['3'].setCMD("");

        keymap['4'] = new ParameterKey('4');
        keymap['4'].setType(KEYTYPE_MACRO);
        keymap['4'].setName("macro4");
        keymap['4'].setDescription("macro 4: ");
        keymap['4'].setCMD("");

        keymap['5'] = new ParameterKey('5');
        keymap['5'].setType(KEYTYPE_MACRO);
        keymap['5'].setName("macro5");
        keymap['5'].setDescription("macro 5: ");
        keymap['5'].setCMD("");

        keymap['6'] = new ParameterKey('6');
        keymap['6'].setType(KEYTYPE_MACRO);
        keymap['6'].setName("macro6");
        keymap['6'].setDescription("macro 6: ");
        keymap['6'].setCMD("");

        keymap['7'] = new ParameterKey('7');
        keymap['7'].setType(KEYTYPE_MACRO);
        keymap['7'].setName("macro7");
        keymap['7'].setDescription("macro 7: ");
        keymap['7'].setCMD("");

        keymap['8'] = new ParameterKey('8');
        keymap['8'].setType(KEYTYPE_MACRO);
        keymap['8'].setName("macro8");
        keymap['8'].setDescription("macro 8: ");
        keymap['8'].setCMD("");

        keymap['9'] = new ParameterKey('9');
        keymap['9'].setType(KEYTYPE_MACRO);
        keymap['9'].setName("macro9");
        keymap['9'].setDescription("macro 9: ");
        keymap['9'].setCMD("");

        keymap['0'] = new ParameterKey('0');
        keymap['0'].setType(KEYTYPE_MACRO);
        keymap['0'].setName("macro0");
        keymap['0'].setDescription("macro 0: ");
        keymap['0'].setCMD("");
    }

    public void loadMacros() {
        // startup commands
        String[] _lines = loadStrings("data/userdata/"+"macros");
        println("------ Loading macros ----------------------------------");
        if(_lines!=null){
            println("macros :");
            if(_lines.length > 0){
                for (String _s : _lines) {
                    if(_s.charAt(0) != '#'){
                        String[] _split = split(_s, '=');
                        if(_split.length > 1){
                            setMacro(_split[0].charAt(0), _split[1]);
                        }
                    }
                }
            }
        }
        println("-------------------------------------------------------");
    }

    public void setMacro(char _key, String _str) {
        if(_key >= 48 && _key <= 57) {
            keymap[_key].setDescription(keymap[_key].getName()+" "+_str);
            keymap[_key].setCMD(_str);
            println(keymap[_key].getDescription());
        }
    }

    public ParameterKey getKey(int _ascii) {
        // fix a
        if(_ascii > keymap.length || _ascii < 0) return null;
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
