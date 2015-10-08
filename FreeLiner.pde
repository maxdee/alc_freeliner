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

  public FreeLiner() {

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
    // inject dependence
    mouse.inject(groupManager, keyboard);
    keyboard.inject(groupManager, templateManager, templateRenderer, gui, mouse);
    gui.inject(groupManager, mouse);
    templateManager.inject(groupManager);
  }

  /**
   * It all starts here...
   */
  public void update() {
    //background(0);
    if(!focused) keyboard.forceRelease();
    // update template models
    templateManager.update();
    templateManager.launchLoops();//groupManager.getGroups());
    // render animations
    templateRenderer.beginRender();
    templateRenderer.render(templateManager.getLoops());
    templateRenderer.render(templateManager.getEvents());
    templateRenderer.endRender();
    image(templateRenderer.getCanvas(), 0, 0);
    // draw gui on top
    gui.update();
    if(gui.doDraw()){
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


  public Mouse getMouse(){
    return mouse;
  }

  public Keyboard getKeyboard(){
    return keyboard;
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
