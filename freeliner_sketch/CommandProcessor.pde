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
class CommandProcessor  {
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
        "info 1 text",
        // for adressing templates use ABCD, or * for all, or $ for selected
        "tw AB q 3",
        "tr AB (3 4 5)",
        "tp stroke AB (#ff0000, R G B)",
        "tp fill AB (#ff0000, R G B)",
        "tp copy (AB)",
        "tp paste (AB)",
        "tp groupadd (AB)",
        "tp reset (AB)",
        "tp save (cooleffects.xml)",
        "tp load (coolstuff.xml)",
        "tp free",
        "tp swap AB",
        "tp select AB*",
        "tp toggle A 3 4 5",
        "tp put A geom",
        "tp remove A geom",

        "tp lerp A 0.5",
        "tp rotate A 0.5",
        "tp translate AB 100 200",
        "tp scale AB 0.5 0.5",
        "tp random",

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
        "tools snap (dist)",
        "tools grid (size)",
        "tools ruler (length)",
        "tools angle (angle)",
        "tools revx",
        ///////////////////  Geometry
        "geom text (2 3) bunch of words",
        "geom save (coolMap.xml)",
        "geom load (coolMap.xml)",
        "geom link plainsvgfile.svg",

        // "geom toggle ABC (2 3 4)", // not implemented yet use tp toggle A 3
        "geom webref",
        "geom new",
        "geom center (3 40 40)",
        "geom addseg 3 40 40 20 20", //geom addseg shapeNumber x1 y1 x2 y2
        "geom priority (ABC|4) 3",
        "geom clear 4",
        "geom updatemap",
        "geom clone 2 A",
        "geom cloneseg 2 A",

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
        "colormap (file|0-1)",
        "colors set 1 (#ff0000, R G B)",
        // "fl directory",
        "fl new (path)",
        "fl save",
        "fl open (file)",
        "fl quit",
        "fl random",
        /////////////////// Scripting
        "oneliner 'tw A q '+beat%5"

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
        for(String _cmd : _q) {
            processCMD(_cmd);
            commandQueue.remove(_cmd);
        }
    }

    /**
     * First level of command parsing, redistributes according to first argument of command.
     * @param String command
     */
    public void processCMD(String _cmd) {
        if(_cmd == null) return;
        if(_cmd.contains(",")) {
            if(_cmd.contains("oneliner")){
                processCMD(_cmd);
            }
            else {
                String[] _split = split(_cmd, ',');
                for(String _str : _split){
                    processCMD(trim(_str));
                }
                return;
            }
        }
        valueGiven = "_";
        String[] _args = split(_cmd, ' ');
        boolean _used = false;
        if(_args.length == 0) return;
        // first the ones that get filtered out of the looper
        else if(_args[0].equals("seq")) _used = sequencerCMD(_args);

        else if(_args[0].equals("window")) _used = windowCMD(_args);
        else if(_args[0].equals("addlayer")) _used = canvasManager.layerCreator(_args);
        else if(_args[0].equals("setosc")) _used = setOsc(_args);
        else if(_args[0].equals("colormap")) _used = colorMapCMD(_args);
        else if(_args[0].equals("pallette")) _used = picturePalletteCMD(_args);
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

        else if(_args[0].equals("colors")) _used = colorsCMD(_args);
        else if(_args[0].equals("info")) _used = extraInfoCMD(_args);

        else if(_args[0].equals("oneliner")) _used = scriptingCMD(_args);

        if(!_used) println("CMD fail : "+join(_args, ' '));

    }

    // keyboard triggered commands go through here? might be able to hack a undo feature...
    public void processCmdStack(String _cmd) {
        // add to stack
        processCMD(_cmd);
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
            processCMD("layer fix testchan "+_ha+" 50");
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
            // PImage _map;
            try {
                freeliner.colorMapImage = loadImage(projectConfig.fullPath+"/images/"+_args[1]);
                gui.setColorMap(freeliner.colorMapImage);
                println("[meta] loaded colormap "+_args[1]);
                return true;
            } catch(Exception e) {
                println("[meta] Error : could not load colormap "+_args[1]);
            }
        }
        return false;
    }


    public boolean picturePalletteCMD(String[] _args){
        looper.receive(join(_args, " "));

        if(_args.length < 2) return false;
        int _v = stringInt(_args[1]);
        if(_v == -42) {
            PImage _image;
            try {
                _image = loadImage("userdata/images/"+_args[1]);
                _image.resize(64,64);
                _image.filter(POSTERIZE, PALLETTE_COUNT);
                _image.loadPixels();
                color[] _pal = new color[PALLETTE_COUNT];
                for(int i =0; i<PALLETTE_COUNT;i++) _pal[i] = color(0);
                int _idx = 0;
                boolean _pick = false;
                for(int i = 0 ; i < 64*64-1; i+=2){
                    _pick = true;
                    for(color c : _pal){
                        if(c == _image.pixels[i]){
                            _pick = false;
                        }
                    }
                    if(_pick){
                        _pal[_idx] = _image.pixels[i];
                        _idx++;
                        if(_idx>11) break;
                    }
                }
                userPallet = _pal;
                for(color c : userPallet) print(c+", ");
                println("[color] loaded pallette "+_args[1]+" "+userPallet);
                return true;
            } catch(Exception e) {
                println("[color] Error : could not load colormap "+_args[1]);
            }
        }
        return false;
    }


    public boolean colorsCMD(String[] _args){
        looper.receive(join(_args, " "));

        // "colors set 1 (#ff0000, R G B)",
        if(_args.length < 4) return false;
        else if(_args[1].equals("set")){
            int _index = stringInt(_args[2]);
            _index %= PALLETTE_COUNT;
            if(_index < 0) _index = 0;

            String _hex = _args[3];
            int _v = unhex(_hex.replaceAll("#","FF").toUpperCase());

            if(_args.length == 6) {
                color c = color(stringInt(_args[3]), stringInt(_args[4]), stringInt(_args[5]));
                _v = c;
            }

            userPallet[_index] = _v;
            return true;
        }

        return false;
    }
    // info 1 text
    public boolean extraInfoCMD(String[] _args) {
        if(_args.length < 3) return false;
        int _index = stringInt(_args[1]);
        gui.setInfo(_index, _args[2]);
        return true;
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
        else if(_args[1].equals("width")) projectConfig.windowWidth = _v;
        else if(_args[1].equals("height")) projectConfig.windowHeight = _v;
        else if(_args[1].equals("fullscreen")) projectConfig.fullscreen = (_v == 1);
        else if(_args[1].equals("display")) projectConfig.fullscreenDisplay = _v;
        else if(_args[1].equals("pipeline")) projectConfig.layers = (_v == 1);
        // else if(_args[1].equals("open")) openCMD(_args);
        else return false;
        return true;
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

    // fl new (path)
    // fl save
    // fl open
    // fl random
    // fl quit
    public boolean flCMD(String[] _args) {

        if(_args.length < 2) return false;
        else if(_args[1].equals("new")) newCMD(_args);
        else if(_args[1].equals("save")) saveCMD(_args);
        else if(_args[1].equals("open")) openCMD(_args);
        else if(_args[1].equals("random")) valueGiven = freeliner.randomAction();
        else if(_args[1].equals("quit")) quitCMD(); // via ctrl-q
        else return false;
        return true;
    }

    public void newCMD(String[] _args){
        if(_args.length == 2) {
            selectFolder("[project] pick directory for new project", "newWithDir");
        }
        else if(_args.length == 3) {
            File f = new File(_args[2]);
            f.mkdirs();
            newWithDir(f);
        }
    }

    public void saveCMD(String[] _args) {
        freeliner.saveProject();
        gui.updateReference(projectConfig.fullPath+"/reference.jpeg");
        valueGiven = "sure";
    }

    public void openCMD(String[] _args) {
        if(_args.length > 2) {
            freeliner.loadFile(_args[2]);
        }
        else {
            freeliner.loadBasics();
        }
        valueGiven = "sure";
    }
    public void quitCMD() {
        // do a backup save?
        println("Freeliner closing, goodbye!");
        exit();
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
        else if(_args[1].equals("tpcmd")) tpcmdCMD(_args);
        else if(_args[1].equals("tracker")) trackerCMD(_args);
        else if(_args[1].equals("seq")) seqStatCMD(_args);
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
        Template _tp = templateManager.getTemplate(_args[2].charAt(0));
        if(_tp == null) return;
        String _info = _tp.getStatusString();
        fetchSend(_args, "template "+_info);
    }

    public void tpcmdCMD(String[] _args) {
        if(_args.length < 3) return;
        char _tpchar = _args[2].charAt(0);
        Template _tp = templateManager.getTemplate(_tpchar);
        if(_tp == null) return;
        String[] _params = _tp.getStatusString().split(" ");
        String _output = "";
        boolean doit = false;
        for(String _s : _params) {
            if(doit) {
                _output += "tw "+_tpchar+" "+_s.replaceAll("-", " ")+", ";
            } else {
                doit = true;
            }
        }
        fetchSend(_args, "cmd "+_output);
    }


    public void trackerCMD(String[] _args) {
        if(_args.length < 3) return;
        Template _tp = templateManager.getTemplate(_args[2].charAt(0));
        if(_tp == null) return;
        PVector _pos = _tp.getLastPosition();
        fetchSend(_args, "tracker "+_tp.getTemplateID()+" "+_pos.x/width+" "+_pos.y/height);
    }

    void seqStatCMD(String[] _args) {
        String _stps = templateManager.getSequencer().getStatusString();
        fetchSend(_args, "seq "+_stps);
    }

    void layerInfoCMD(String[] _args) {
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
    // * tools snap (dist)
    // * tools grid (size)
    // * tools ruler (length)
    // * tools angle (angle)
    // * tools revx

    public boolean toolsCMD(String[] _args) {
        if(_args.length < 2) return false;
        if(_args[1].equals("lines")) valueGiven = str(gui.toggleViewLines());
        else if(_args[1].equals("tags")) valueGiven = str(gui.toggleViewLines());
        //else if(_args[1].equals("rec")) valueGiven = str(canvasManager.toggleRecording());
        else if(_args[1].equals("snap")) return snapCMD(_args);
        else if(_args[1].equals("grid")) return gridCMD(_args);
        else if(_args[1].equals("ruler")) return rulerCMD(_args);
        else if(_args[1].equals("angle")) return angleCMD(_args);
        else if(_args[1].equals("revx")) {
            valueGiven = str(gui.mouse.toggleInvertMouse());
            return true;
        }
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
        else if(_args[1].equals("center")) centerCMD(_args);
        else if(_args[1].equals("addseg")) addSegmentCMD(_args);
        else if(_args[1].equals("webref")) webrefCMD();
        else if(_args[1].equals("breakline")) mouse.press(3);
        else if(_args[1].equals("priority")) priorityGeometryCMD(_args);
        else if(_args[1].equals("clear")) geomClearCMD(_args);
        else if(_args[1].equals("updatemap")) canvasManager.passOutputMappingGeometry(groupManager.getOutputMappingGroup());
        else if(_args[1].equals("clone")) geomCloneCMD(_args);
        else if(_args[1].equals("cloneseg")) geomCloneSegmentCMD(_args);

        else if(_args[1].equals("link") && _args.length>2) groupManager.linkSvgFile(_args[2]);



        else return false;
        return true;
    }

    public void geomClearCMD(String[] _args){
        if(_args.length > 2){
            ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs( _args);
            for(SegmentGroup _sg : _groups){
                groupManager.clear(_sg.getID());
            }
        }
        else {
            groupManager.clear();
        }
    }


    public void geomCloneCMD(String[] _args){
        if(_args.length > 3){
            ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs( _args);
            ArrayList<Template> tps = templateManager.getTemplates(_args[3]);
            if(_groups.size() > 0 && tps.size() > 0) {
                groupManager.cloneGeometries(tps.get(0), _groups.get(0));
            }
        }
    }

    public void geomCloneSegmentCMD(String[] _args){
        if(_args.length > 3){
            ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs( _args);
            ArrayList<Template> tps = templateManager.getTemplates(_args[3]);
            if(_groups.size() > 0 && tps.size() > 0) {
                groupManager.cloneSegments(tps.get(0), _groups.get(0));
            }
        }
    }

    // geom center (3 x y)
    public void centerCMD(String[] _args){
        if(_args.length < 4){
            valueGiven = str(groupManager.toggleCenterPutting());
        }
        else if(_args.length > 4) {
            int _geom = stringInt(_args[2]);
            int _x = stringInt(_args[3]);
            int _y = stringInt(_args[4]);
            groupManager.setGeomCenter(_geom, _x, _y);
        }
    }
    // geom addseg 3 x y x y
    public void addSegmentCMD(String[] _args){
        if(_args.length < 7) return;
        else {
            int _geom = stringInt(_args[2]);
            int _x1 = stringInt(_args[3]);
            int _y1 = stringInt(_args[4]);
            int _x2 = stringInt(_args[5]);
            int _y2 = stringInt(_args[6]);
            groupManager.addSegment(_geom, _x1, _y1, _x2, _y2);
        }
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
        if(_args.length == 2) freeliner.saveGeometry();
        else if(_args.length == 3) freeliner.saveGeometry(_args[2]);
        else return false;
        return true;
    }

    public boolean loadGeometryCMD(String[] _args) {
        if(_args.length == 2) groupManager.loadGeometry();
        else if(_args.length == 3) groupManager.loadGeometry(_args[2]);
        else return false;
        return true;
    }

    // geom text (2 3) ahah yes
    // geom text yes no
    // #needstesting
    public boolean textCMD(String[] _args) {
        if(_args.length == 3) groupManager.setText(_args[2]);
        // else if(_args.length == 4) groupManager.setText(_args[2]+" "+_args[3]);
        else if(_args.length > 3) {
            ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs(_args[2]);
            int _seg = stringInt(_args[3]);
            println(_groups+"  "+_seg);
            boolean used = false;
            if(_groups != null) {
                if(_groups.size() > 0) {
                    used = true;
                    if(_seg != -42) {
                        groupManager.setText(_groups.get(0).getID(), _seg, remainingText(4, _args));
                    }
                    else{
                        groupManager.setText(_groups.get(0).getID(), remainingText(3, _args));
                    }
                }
            }
            if(!used) {
                String txt = remainingText(2, _args);
                println(txt);
                groupManager.setText(txt);
            }
        } else return false;
        return true;
    }

    String remainingText(int _start, String[] _args) {
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

    public boolean scriptingCMD(String[] _args){
        String a = join(_args, " ");
        a = a.replaceAll("oneliner ", "");
        println("[script] adding new expression : ");
        println(a);
        freeliner.scriptHandler = new ScriptHandler(a);
        return true;
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
        else {
            valueGiven = looper.setTimeDivider(-1, 0);
            return true;
        }
        // return false;
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
        else if(_args[1].equals("steady") && _args.length > 2) synchroniser.setSteady(boolean(stringInt(_args[2])));
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
            ArrayList<Template> _tps =  templateManager.getTemplates(_args[2]);
            if(_tps != null) {
                for(Template _tw : _tps)
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
            ArrayList<Template> _tp = templateManager.getTemplates(_args[2]);
            if(_tp == null) return;
            for(Template _tw : _tp)
                sequencer.toggle(_tw);
        }
        gui.setTemplateString(sequencer.getStepToEdit().getTags());
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Template commands
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

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
            else if(_args[1].equals("rotate")) tpRotateCMD(_args);
            else if(_args[1].equals("scale")) tpScaleCMD(_args);

            else if(_args[1].equals("toggle")) toggleCMD(_args);
            else if(_args[1].equals("add") || _args[1].equals("remove")) addRemoveCMD(_args);
            else if(_args[1].equals("lerp")) lerpCMD(_args);
            else if(_args[1].equals("free")) listFreeCMD();
        } else return false;
        return true;
    }

    public void listFreeCMD() {
        String _free = "";
        for(Template tp : templateManager.getInactive()) {
            _free += tp.getTemplateID();
        }
        valueGiven = _free;
    }

    public void lerpCMD(String[] _args) {
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
        float _lrp = stringFloat(_args[3]);
        for(Template _tp : _tmps) _tp.setFixLerp(_lrp);
    }

    // tp toggle
    public void toggleCMD(String[] _args) {
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
        ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs(remainingText(3, _args));
        for(SegmentGroup _sg : _groups){
             for(Template _tp : _tmps) {
                 groupManager.toggleTemplate(_tp, _sg.getID());
                 _tp.toggleGeometry(_sg.getID());
             }
        }
    }

    // tp toggle
    public void addRemoveCMD(String[] _args) {
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
        ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs(remainingText(3, _args));
        if(_args[1].equals("add")) {
            for(SegmentGroup _sg : _groups){
                for(Template _tp : _tmps) {
                    groupManager.addTemplate(_tp, _sg.getID());
                    _tp.addGeometry(_sg.getID());
                }
            }
        }
        else if(_args[1].equals("remove")) {
            for(SegmentGroup _sg : _groups){
                for(Template _tp : _tmps) {
                    groupManager.removeTemplate(_tp, _sg.getID());
                    _tp.removeGeometry(_sg.getID());
                }
            }
        }
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
        if(_args.length == 2) freeliner.saveTemplates();
        else if(_args.length == 3) freeliner.saveTemplates(_args[2]);
    }

    public void loadTemplateCMD(String[] _args) {
        if(_args.length == 2) freeliner.loadFile("templates.json");
        else if(_args.length == 3) freeliner.loadFile(_args[2]);
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

    // tp stroke DA (byte R G B | float R G B | #ffffff)
    public void strokeColorCMD(String[] _args) {
        looper.receive(join(_args, " "));

        if(_args.length < 4) return;
        if(_args.length < 5) {
            String _hex = _args[3];
            int _v = unhex(_hex.replaceAll("#","FF").toUpperCase());
            if(_v != -3) templateManager.setCustomStrokeColor(_args[2], _v);
        }
        else if(_args.length >= 6) {
            String _hex = _args[3];
            color c = color(stringInt(_args[3]), stringInt(_args[4]), stringInt(_args[5]));
            templateManager.setCustomStrokeColor(_args[2], c);
        }
    }

    public void fillColorCMD(String[] _args) {
        looper.receive(join(_args, " "));

        if(_args.length < 5) {
            String _hex = _args[3];
            int _v = unhex(_hex.replaceAll("#","FF").toUpperCase());
            if(_v != -3) templateManager.setCustomFillColor(_args[2], _v);
        }
        else if(_args.length == 6) {
            String _hex = _args[3];
            color c = color(stringInt(_args[3]), stringInt(_args[4]), stringInt(_args[5]));
            templateManager.setCustomFillColor(_args[2], c);
        }
    }

    // could be in tm
    public void triggerTemplates(String[] _args) {
        looper.receive(join(_args, " "));

        if(_args.length == 2) {
            for(int i = 0; i < _args[1].length(); i++) templateManager.trigger(_args[1].charAt(i));
        } else if(_args.length > 2) {
            ArrayList<SegmentGroup> _groups = groupManager.getGroupsFromArgs(_args);
            for(int i = 0; i < _args[1].length(); i++){
                for(SegmentGroup _sg : _groups){
                     templateManager.trigger(_args[1].charAt(i), _sg.getID());
                }
            }
        }
    }

// tp translate AB 100 100
    public boolean tpTranslateCMD(String[] _args) {
        looper.receive(join(_args, " "));
        if(_args.length == 3) {
            ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
            if(_tmps == null) return false;
            if(_tmps.size()<2) return false;
            for(int i = 0; i < _tmps.size()-1; i++){
                _tmps.get(i).setTranslationTemplate(_tmps.get(_tmps.size()-1));
            }
            return true;
        }
        else if(_args.length >= 5){
            float x = stringFloat(_args[3]);
            float y = stringFloat(_args[4]);
            PVector _translate = new PVector(x,y);
            ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
            if(_tmps == null) return false;
            for(Template _rt : _tmps) {
                _rt.setTranslation(_translate);
            }
            return true;
        }
        return false;
        // // scuff mixer info
        // String below = "";
        // String above = "";
        // for(Template _tp : templateManager.getTemplates()) {
        //     if(_tp.translation.x == 0) {
        //         above += _tp.getTemplateID();
        //     }
        //     else {
        //         below += _tp.getTemplateID();
        //     }
        // }
        // queueCMD("info 0 ["+above+"]");
        // queueCMD("info 1 ["+below+"]");
    }

    public void tpScaleCMD(String[] _args) {
        looper.receive(join(_args, " "));
        if(_args.length < 5) return;
        float x = stringFloat(_args[3]);
        float y = stringFloat(_args[4]);
        PVector _scale = new PVector(x,y);
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
        if(_tmps == null) return;
        for(Template _rt : _tmps) {
            _rt.setScale(_scale);
        }
    }

    // tp rotate AB 0.5
    public void tpRotateCMD(String[] _args) {
        looper.receive(join(_args, " "));
        if(_args.length < 4) return;
        float _angle = stringFloat(_args[3]);
        // if(_args.length > 5) z = stringFloat(_args[5]);
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[2]);
        if(_tmps == null) return;
        for(Template _rt : _tmps) {
            _rt.setRotation(_angle);
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
        ArrayList<Template> _tmps = templateManager.getTemplates(_args[1]); // does handle wildcard
        if(_tmps == null) return;
        if(_args[2].length() == 0) return;
        char _k = _args[2].charAt(0);
        int _v = stringInt(_args[3]);
        for(Template _tp : _tmps) templateDispatch(_tp, _k, _v);
    }

    /**
     * Change the parameters of a template.
     * @param Template template to modify
     * @param char editKey
     * @param int value
     * @return boolean value used
     */
    public void templateDispatch(Template _template, char _k, int _n) {
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
        if (int(_k) == 518) _template.reset();
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
