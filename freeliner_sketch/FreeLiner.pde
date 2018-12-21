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
        if(OSC_USE_TCP) oscComs = new TCPOSCCommunicator(applet, commandProcessor);
        else oscComs = new UDPOSCCommunicator(applet, commandProcessor);
        webComs = new WebSocketCommunicator(applet, commandProcessor);

        keyMap = new KeyMap();

        // inject dependence
        mouse.inject(groupManager, keyboard);
        keyboard.inject(this);
        gui.inject(groupManager, mouse);
        templateManager.inject(groupManager);
        groupManager.inject(templateManager, commandProcessor);
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
            fisheye = loadShader(dataDirectory(PATH_TO_SHADERS)+"/"+"fisheye.glsl");
            fisheye.set("aperture", 180.0);
            shader(fisheye);
        }
        // commandProcessor.queueCMD("colormap colorMap.png");

        // up commands
        String _file = dataDirectory("userdata/startup");
        String[] _lines = loadStrings(_file);
        if(_lines!=null){
            println("Startup commands:");
            if(_lines.length > 0){
                for (String _s : _lines) {
                    if(_s.charAt(0) != '#'){
                        println(_s);
                        commandProcessor.queueCMD(_s);
                    }
                }
            }
        }

    }

    // sync message to other software
    void oscTick() {
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
            groupManager.unSnap();
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


    public String randomAction() {
        ArrayList<TweakableTemplate> active = templateManager.getActive();
        if(active.size() == 0 ) return "";
        char _tp = active.get((int)random(active.size())).getTemplateID();
        char[] options = {'a', 'q', 'f', 'e', 'v', 'o', 'w', 's', 'r', 'y', 'i', 'p', 'h', 'h', 'j', 'k', 'l', 'x', 'b'};
        char ran = options[(int)random(options.length)];
        int val = 0;
        if(ran == 's') val = (int)random(300);
        else if(ran == 'w') val = (int)random(42);
        else if(ran == 'x') val = (int)random(12);
        else if(ran == 'r') val = (int)random(200);
        else if(ran == 'h') val = (int)random(9);

        else val = (int)random(keyMap.getMax(ran)-1);
        String _cmd = "tw "+_tp+" "+ran+" "+val;
        commandProcessor.queueCMD(_cmd);
        return _cmd;
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
        File _directory = new File(dataDirectory(_dir));
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
