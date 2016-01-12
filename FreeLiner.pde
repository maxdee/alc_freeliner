/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Main class for alc_freeliner
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */
class FreeLiner {
  // model
  GroupManager groupManager;
  TemplateManager templateManager;
  // view
  TemplateRenderer templateRenderer;
  int trailmix = -1;
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
  PShader shaderOne;

  // optional background image
  PImage backgroundImage;

  public FreeLiner(PApplet _pa) {
    applet = _pa;
    // instantiate
    // model
    groupManager = new GroupManager();
    templateManager =  new TemplateManager();
    // view
    templateRenderer = new TemplateRenderer();
    gui = new Gui();
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

    // experimental
    reloadShader();

    // check for background image, usefull for tracing paterns
    try { backgroundImage = loadImage("userdata/background.png");}
    catch(Exception _e) {backgroundImage = null;}
  }

  void reloadShader(){
    try{
      shaderOne = loadShader("shaders/shaderOne.glsl");
    }
    catch(Exception _e){
      println("Could not load shader... ");
      println(_e);
    }
  }
  /**
   * It all starts here...
   */
  public void update() {
    //background(0);
    if(backgroundImage != null) image(backgroundImage,0,0);
    if(windowFocus != focused){
      keyboard.forceRelease();
      windowFocus = focused;
    }
    // update template models
    templateManager.update();
    templateManager.launchLoops();//groupManager.getGroups());
    // render animations
    templateRenderer.beginRender();
    templateRenderer.render(templateManager.getLoops());
    templateRenderer.render(templateManager.getEvents());
    templateRenderer.endRender();
    //try{shader(shaderOne);}catch(RuntimeException _e){}
    image(templateRenderer.getCanvas(), 0, 0);
    // draw gui on top
    gui.update();
    if(gui.doDraw()){
      resetShader();
      image(gui.getCanvas(), 0, 0);
    }
    if(trailmix != -1){
      templateRenderer.setTrails(trailmix);
      trailmix = -1;
    }
  }

  public void oscSetTrails(int _t){
    trailmix = _t;
  }

  // its a dummy for FreelinerLED
  public void reParse(){ }
  // its a dummy for others
  public void toggleExtraGraphics(){}

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

  public PGraphics getCanvas(){
    return templateRenderer.getCanvas();
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
