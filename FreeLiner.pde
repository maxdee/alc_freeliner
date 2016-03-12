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

  public FreeLiner(PApplet _pa) {
    applet = _pa;
    // instantiate
    // model
    groupManager = new GroupManager();
    templateManager =  new TemplateManager();
    // view
    templateRenderer = new TemplateRenderer();
    gui = new Gui();
    canvasManager = new CanvasManager();
    // control
    mouse = new Mouse();
    keyboard = new Keyboard();
    osc = new OSClistener(applet, this);

    commandProcessor = new CommandProcessor();
    // inject dependence
    mouse.inject(groupManager, keyboard);
    keyboard.inject(this);
    gui.inject(groupManager, mouse);
    templateManager.inject(groupManager);
    groupManager.inject(templateManager);
    commandProcessor.inject(this);
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

    // render animations
    canvasManager.beginRender();
    templateRenderer.setCanvas(canvasManager.getRenderLayer(1));
    templateRenderer.render(templateManager.getLoops());
    templateRenderer.render(templateManager.getEvents());
    canvasManager.endRender();

    image(canvasManager.getCanvas(),0,0);
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
