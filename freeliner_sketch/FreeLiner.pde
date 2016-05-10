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
    if(_pipeline == 0) canvasManager = new ClassicCanvasManager();
    else if(_pipeline == 1) canvasManager = new LayeredCanvasManager();
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
    windowFocus = true;

    keyMap.setLimits(documenter.modeLimits);
    documenter.doDocumentation(keyMap);
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

    commandProcessor.processQueue();

    // update template models
    templateManager.update();
    templateManager.launchLoops();//groupManager.getGroups());

    // get templates to render
    ArrayList<RenderableTemplate> _toRender = new ArrayList(templateManager.getLoops());
    _toRender.addAll(templateManager.getEvents());

    canvasManager.render(_toRender);
  // image(canvasManager.getCanvas(),0,0);
  //  if(canvasManager instanceof EffectsCanvasManager) image((EffectsCanvasManager)canvasManager.getTopCanvas());

    gui.update();
    if(gui.doDraw()){
      // resetShader();
      image(gui.getCanvas(), 0, 0);
    }

  }

  // its a dummy for FreelinerLED
  public void reParse(){ }
  // its a dummy for others
  public void toggleExtraGraphics(){}

  // need to make this better.
  private void autoSave(){
    if(frameCount % 1000 == 1){
      // commandProcessor.processCMD("geom"+" "+"save"+" "+"userdata/autoSaveGeometry.xml");
      // commandProcessor.processCMD("tp"+" "+"save"+" "+"userdata/autoSaveTemplates.xml");
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
      _file = loadXML("../userdata/configuration.xml");
    }
    catch(Exception e) {
      _file = new XML("freelinerConfiguration");
    }
    _file.setInt(_param, _v);
    saveXML(_file, "../userdata/configuration.xml");
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

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
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void printStatus() {
    //merp
  }
}
