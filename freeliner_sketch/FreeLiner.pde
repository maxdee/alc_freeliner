/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */
 import java.util.Arrays;


/**
 * Main class for alc_freeliner
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */
class FreeLiner  {
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

    public FreeLiner(PApplet _pa) {
        applet = _pa;
        // instantiate
        // model
        groupManager = new GroupManager();
        templateManager =  new TemplateManager();
        // view
        templateRenderer = new TemplateRenderer();
        gui = new Gui();
        // pick a rendering system
        if(!projectConfig.layers) canvasManager = new ClassicCanvasManager(applet, gui.getCanvas());
        else if(projectConfig.layers) canvasManager = new LayeredCanvasManager(applet, gui.getCanvas());
        // control
        mouse = new Mouse();
        keyboard = new Keyboard();
        commandProcessor = new CommandProcessor();
        guiWebServer = new GUIWebServer(applet);
        // osc + webSocket
        if(projectConfig.oscUseTCP) oscComs = new TCPOSCCommunicator(applet, commandProcessor);
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

        // commandProcessor.queueCMD("colormap colorMap.png");

        // up commands
        String _file = projectConfig.fullPath+"/startup";
        String[] _lines = loadStrings(_file);
        if(_lines!=null){
            println("------ Startup Commands ----------------------------------");
            if(_lines.length > 0){
                for (String _s : _lines) {
                    if(_s.length() > 0){
                        if(_s.charAt(0) != '#'){
                            println(_s);
                            commandProcessor.queueCMD(_s);
                        }
                    }
                }
            }
            println("----------------------------------------------------------");
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
        if(projectConfig.checkMakeNewProjectFlag()) {
            commandProcessor.queueCMD("fl new");
            println("[config] caught make new project flag");
        }
        // windowFocus
        if(windowFocus != focused) {
            windowFocus = focused;
            keyboard.forceRelease();
            groupManager.unSnap();
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
        groupManager.updateLinkedSvgs();
    }

    // its a dummy for FreelinerLED
    public void reParse() { }
    // its a dummy for others
    public void toggleExtraGraphics() {}

    // need to make this better.
    private void autoSave() {
        if(frameCount % 1000 == 1) {
        }
    }

    public void processCMD(String _cmd) {
        commandProcessor.processCMD(_cmd);
    }

    public void queueCMD(String _cmd) {
        commandProcessor.queueCMD(_cmd);
    }


    public String randomAction() {
        ArrayList<Template> active = templateManager.getActive();
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
    ///////    save/load files
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    void saveProject(){
        saveConfig();
        saveGeometry();
        saveTemplates();
        saveLayers();
    }

    void saveConfig(){
        saveConfig("config.xml");
    }

    void saveConfig(String _fn){
        XML _session = new XML("freeliner-data");

        XML _cfg = projectConfig.makeXML();

        _session.addChild(_cfg);
        saveXML(_session, projectConfig.fullPath+"/"+_fn);

        String[] _dir = {projectConfig.fullPath};
        saveStrings(dataPath("last_project_path"), _dir);
    }

    void saveGeometry(){
        saveGeometry("geometry.xml");
    }

    void saveGeometry(String _fn){
        XML _obj = new XML("freeliner-data");
        XML _geom = groupManager.getXML();
        _obj.addChild(_geom);
        saveXML(_obj, projectConfig.fullPath+"/"+_fn);
    }

    void saveTemplates(){
        saveTemplates("templates.xml");
    }

    void saveTemplates(String _fn){
        XML _obj = new XML("freeliner-data");
        XML _tps = templateManager.getXML();
        _obj.addChild(_tps);
        saveXML(_obj, projectConfig.fullPath+"/"+_fn);
    }

    void saveLayers(){
        saveLayers("layers.xml");
    }

    void saveLayers(String _fn){
        XML _obj = new XML("freeliner-data");
        XML _tps = canvasManager.getLayersXML();
        _obj.addChild(_tps);
        saveXML(_obj, projectConfig.fullPath+"/"+_fn);
    }


    void loadBasics(){
        loadFile("geometry.xml");
        loadFile("templates.xml");
        loadFile("layers.xml");
    }
    //
    void loadFile(String _fn){
        XML _xml = null;
        try {
            _xml = loadXML(projectConfig.fullPath+"/"+_fn);
        }
        catch (Exception e) {
            println("[ERROR] could not load : " + _fn+"\n");
            return;
        }
        // _xml = _xml.getChild("freeliner-data");
        if(_xml == null) {
            println("[load file] no xml for file : \n"+_fn);
            return;
        }
        XML[] _config = _xml.getChildren("config");
        if(_config.length != 0) {
            projectConfig.loadConfigXML(_config[0]);
        }
        XML[] _geom = _xml.getChildren("geometry");
        if(_geom.length != 0) {
            groupManager.loadGeometryXML(_geom[0]);
        }
        XML[] _tp = _xml.getChildren("templates");
        if(_tp.length != 0) {
            templateManager.loadTemplatesXML(_tp[0]);
        }
        XML[] _layers = _xml.getChildren("layers");
        if(_layers.length != 0) {
            canvasManager.loadLayersXML(_layers[0]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // getFilesFrom("/shaders", ".glsl");
    public ArrayList<String> getFilesFrom(String _dir, String _type){
        println(_dir+" "+_type);

        ArrayList<String> _files = new ArrayList<String>();
        File _directory = new File(_dir);
        recursiveFind(_files, "", _directory, _type);
        ArrayList<String> subDirectoryFiles = new ArrayList<String>();
        ArrayList<String> regularFiles =  new ArrayList<String>();
        for(String _s : _files){
            if(_s.contains("/")) {
                subDirectoryFiles.add(_s);
            }
            else {
                regularFiles.add(_s);
            }
        }
        String[] _reg = regularFiles.toArray(new String[regularFiles.size()]);
        String[] _sub = subDirectoryFiles.toArray(new String[subDirectoryFiles.size()]);

        Arrays.sort(_reg);
        Arrays.sort(_sub);
        _files.clear();
        for(String _s : _sub) {
            _files.add(_s);
        }
        for(String _s : _reg) {
            _files.add(_s);
        }
        return _files;
    }

    public void recursiveFind(ArrayList<String> _files, String _root, File _directory, String _type){
        File[] _list = _directory.listFiles();
        if(_list != null){
            for (File _file : _list) {
                if (_file.isFile()) {
                    if(_file.getName().contains(_type)){
                        String _new = _root+_file.getName();
                        _files.add(_new);
                    }
                }
                else if(_file.isDirectory()) {
                    recursiveFind(_files, _root+_file.getName()+"/", _file, _type);
                }
            }
        }
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
