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
class FreeLiner implements FreelinerConfig{
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
    // canvasManager.setGuiCanvas(gui.getCanvas());
    templateRenderer.inject(commandProcessor);
    templateRenderer.inject(groupManager);

    windowFocus = true;

    keyMap.setLimits(documenter.modeLimits);
    documenter.doDocumentation(keyMap);
    if(DOME_MODE){
      fisheye = loadShader(sketchPath()+"/data/userdata/fisheye.glsl");
      fisheye.set("aperture", 180.0);
      shader(fisheye);
    }
    commandProcessor.queueCMD("colormap colorMap.png");
  }

  // sync message to other software
  void oscTick(){
    oscComs.send("freeliner tick");
  }

  /**
   * It all starts here...
   */
  public void update() {
    //autoSave();

    // windowFocus
    if(windowFocus != focused){
      keyboard.forceRelease();
      windowFocus = focused;
    }
    gui.update();
    commandProcessor.processQueue();
    // update template models
    templateManager.update();
    templateManager.launchLoops();//groupManager.getGroups());

    // get templates to render
    ArrayList<RenderableTemplate> _toRender = new ArrayList(templateManager.getLoops());
    _toRender.addAll(templateManager.getEvents());

    canvasManager.render(_toRender);
  }

  // its a dummy for FreelinerLED
  public void reParse(){ }
  // its a dummy for others
  public void toggleExtraGraphics(){}

  // need to make this better.
  private void autoSave(){
    if(frameCount % 1000 == 1){
      // commandProcessor.processCMD("geom save userdata/autoSaveGeometry.xml");
      // commandProcessor.processCMD("tp save userdata/autoSaveTemplates.xml");
      // println("Autot saved");
    }
  }

  public void processCMD(String _cmd){
    commandProcessor.processCMD(_cmd);
  }

  public void queueCMD(String _cmd){
    commandProcessor.queueCMD(_cmd);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Configure stuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void configure(String _param, int _v){
    XML _file;
    try{
      _file = loadXML(sketchPath()+"/data/userdata/configuration.xml");
    }
    catch(Exception e) {
      _file = new XML("freelinerConfiguration");
    }
    _file.setInt(_param, _v);
    saveXML(_file, sketchPath()+"/data/userdata/configuration.xml");
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public String getFileNames(){
    File userData = new File(sketchPath()+"/data/userdata");
    File[] listOfFiles = userData.listFiles();
    String _out = "";
    for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile()) {
        _out +=  listOfFiles[i].getName()+" ";
        // System.out.println("File " + listOfFiles[i].getName());
      } else if (listOfFiles[i].isDirectory()) {
        // System.out.println("Directory " + listOfFiles[i].getName());
      }
    }
    return _out;
  }

  public KeyMap getKeyMap(){
    return keyMap;
  }

  public Mouse getMouse(){
    return mouse;
  }

  public Keyboard getKeyboard(){
    return keyboard;
  }

  public Gui getGui(){
    return gui;
  }

  public GroupManager getGroupManager(){
    return groupManager;
  }

  public TemplateManager getTemplateManager(){
    return templateManager;
  }

  public TemplateRenderer getTemplateRenderer(){
    return templateRenderer;
  }

  public CommandProcessor getCommandProcessor(){
    return commandProcessor;
  }

  public CanvasManager getCanvasManager(){
    return canvasManager;
  }

  public PGraphics getCanvas(){
    return canvasManager.getCanvas();
  }
  public OSCCommunicator getOscCommunicator(){
    return oscComs;
  }
  public WebSocketCommunicator getWebCommunicator(){
    return webComs;
  }
  public GUIWebServer getGUIWebServer(){
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
