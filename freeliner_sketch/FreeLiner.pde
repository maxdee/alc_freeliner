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
        String _file = dataDirectory("userdata/startup");
        String[] _lines = loadStrings(_file);
        if(_lines!=null){
            println("Startup commands:");
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
    ///////    save/load files
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    void saveProject(){
        saveConfig();
        saveGeometry();
        saveTemplates();
    }

    void saveConfig(){
        saveConfig("config.json");
    }

    void saveConfig(String _fn){
        JSONObject _session = new JSONObject();
        JSONObject _cfg = projectConfig.makeJSON();
        _session.setJSONObject("config", _cfg);
        saveJSONObject(_session, projectConfig.fullPath+"/"+_fn);

        String[] _dir = {projectConfig.fullPath};
        saveStrings(dataPath("last_project_path"), _dir);
    }

    void saveGeometry(){
        saveGeometry("geometry.json");
    }

    void saveGeometry(String _fn){
        JSONObject _obj = new JSONObject();
        JSONObject _geom = groupManager.getGroupsJSON();
        _obj.setJSONObject("geometry", _geom);
        saveJSONObject(_obj, projectConfig.fullPath+"/"+_fn);
    }

    void saveTemplates(){
        saveTemplates("templates.json");
    }

    void saveTemplates(String _fn){
        JSONObject _obj = new JSONObject();
        JSONObject _tps = templateManager.getTemplatesJSON();
        _obj.setJSONObject("templates", _tps);
        saveJSONObject(_obj, projectConfig.fullPath+"/"+_fn);
    }


    void loadBasics(){
        loadFile("geometry.json");
        loadFile("templates.json");
    }
    //
    void loadFile(String _fn){
        JSONObject _json = null;
        try {
            _json = loadJSONObject(projectConfig.fullPath+"/"+_fn);
        }
        catch (Exception e) {
            println("[ERROR] could not load : " + _fn+"\n");
            return;
        }
        JSONObject _config = _json.getJSONObject("config");
        if(_config != null) {
            projectConfig.loadJSON(_config);
        }
        JSONObject _geom = _json.getJSONObject("geometry");
        if(_geom != null) {
            groupManager.loadJSON(_geom);
        }
        JSONObject _tp = _json.getJSONObject("templates");
        if(_tp != null) {
            templateManager.loadJSON(_tp);
        }

        // loadJSON(_json);
    }

    void openProject(){
        selectFolder("load project or empty dir", "loadProjectPath");
        // canReset = true;
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
