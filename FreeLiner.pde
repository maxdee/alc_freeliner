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
  Gui gui;
  // control
  Mouse mouse;
  Keyboard keyboard;

  // OSC not in use.
  //OscP5 oscP5;
  PImage imageBackground;

  public FreeLiner() {
    //network
    //oscP5 = new OscP5(this, 3333);

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

    
  }


  /**
   * It all starts here...
   */
  public void update() {
    //background(0);
    // update template models
    templateManager.update();
    templateManager.launchLoops(groupManager.getGroups());
    // render animations
    templateRenderer.render(templateManager.getEvents());
    image(templateRenderer.getCanvas(), 0, 0);
    // draw gui on top
    if(gui.doDraw()){
      gui.update();
      image(gui.getCanvas(), 0, 0);
    }
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
