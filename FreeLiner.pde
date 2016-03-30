/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

 import oscP5.*;
 import netP5.*;

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

  // int trailmix = -1;
  Gui gui;

  // control
  Mouse mouse;
  Keyboard keyboard;
  OSClistener osc;
  // new part
  CommandProcessor commandProcessor;
  // misc
  boolean windowFocus;
  PApplet applet;

  OscP5 oscP5;
  // where to send a sync message
  NetAddress toPDpatch;
  OscMessage tickmsg = new OscMessage("/freeliner/tick");

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
    if(RENDERING_PIPELINE == 0) canvasManager = new ClassicCanvasManager();
    else if(RENDERING_PIPELINE == 1) canvasManager = new LayeredCanvasManager();

    // control
    mouse = new Mouse();
    keyboard = new Keyboard();
    //osc
    osc = new OSClistener();
    oscP5 = new OscP5(applet, OSC_IN_PORT);
    toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);
    oscP5.addListener(osc);

    commandProcessor = new CommandProcessor();
    // inject dependence
    mouse.inject(groupManager, keyboard);
    keyboard.inject(this);
    gui.inject(groupManager, mouse);
    templateManager.inject(groupManager);
    groupManager.inject(templateManager);
    commandProcessor.inject(this);
    canvasManager.inject(templateRenderer);
    osc.inject(commandProcessor);
    windowFocus = true;
  }

  /**
   * It all starts here...
   */
  public void update() {
    autoSave();
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
      resetShader();
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
  ///////    OSC feedback
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // sync message to other software
  void oscTick(){
    oscP5.send(tickmsg, toPDpatch);
  }

  void oscInfoLine(){
    oscP5.send(new OscMessage("/freeliner/infoline").add(gui.getInfo()), toPDpatch);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

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

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void printStatus() {
    //merp
  }
}
