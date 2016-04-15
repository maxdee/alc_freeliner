/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

import processing.core.PApplet;
import processing.core.PSurface;

/**
 * ExternalGUI is a seperate PApplet launched by freeliner
 * aka the old gui, but we are keping it around because why not.
 */
public class ExternalGUI extends PApplet {

  // reference to the freeliner instance to control
  FreeLiner freeliner;
  CommandProcessor commandProcessor;
  // canvas to draw to, is needed to be passed to objects that need to draw.
  PGraphics canvas;
  // mouse cursor
  PVector cursor;
  // send keys from externalGUI to freeliner keyboard input
  boolean relayKeys = true;
  // externalGUI size, make sure you also change them in the settings() method
  final int GUI_WIDTH = 800;
  final int GUI_HEIGHT = 320;
  // ArrayList of widgets
  ArrayList<Widget> widgets;
  // the selected widget, aka the one that the cursor hovers
  Widget selectedWidget;

  boolean windowFocus;

  /**
   * Constructor,
   * @param Freeliner to control
   */
  public ExternalGUI(FreeLiner _fl){
    super();
    freeliner = _fl;
    commandProcessor = freeliner.getCommandProcessor();
    cursor = new PVector(0,0);
    windowFocus = true;
    widgets = new ArrayList();
    // InfoLine is the same info the regular GUI shows
    widgets.add(new InfoLine(new PVector(0,0), new PVector(GUI_WIDTH, 22), freeliner.getGui()));
    widgets.add(new SequenceGUI(new PVector(0, GUI_HEIGHT - 100),
                                new PVector(GUI_WIDTH, 100),
                                freeliner.getTemplateManager().getSequencer(),
                                freeliner.getTemplateManager().getTemplateList()));
    int _lp = 10;
    int _sz = 16;
    widgets.add(new Fader(new PVector(_lp,24+20), new PVector(128,_sz), "post shader 0"));
    widgets.add(new Fader(new PVector(_lp,48+20), new PVector(128,_sz), "post shader 1"));
    widgets.add(new Fader(new PVector(_lp,72+20), new PVector(128,_sz), "post shader 2"));
    widgets.add(new Fader(new PVector(_lp,96+20), new PVector(128,_sz), "post shader 3"));

    widgets.add(new Button(new PVector(256,24+20), new PVector(_sz,_sz), "post shader 0"));
    widgets.add(new Button(new PVector(256,48+20), new PVector(_sz,_sz), "post shader 1"));
    widgets.add(new Button(new PVector(256,72+20), new PVector(_sz,_sz), "post shader 2"));
    widgets.add(new Button(new PVector(256,96+20), new PVector(_sz,_sz), "post shader 3"));


    selectedWidget = null;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     PApplet Basics
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // your traditional sketch settings function
  public void settings(){
    size(GUI_WIDTH, GUI_HEIGHT, P2D);
    noSmooth();
  }

  // your traditional sketch setup function
  public void setup() {
    canvas = createGraphics(GUI_WIDTH, GUI_HEIGHT, P2D);
    canvas.textFont(font);
    surface.setResizable(false); // keep it pretty
    textMode(CORNER);
    hint(ENABLE_KEY_REPEAT); // usefull for performance
  }

  public void draw(){
    if(windowFocus != focused){
      freeliner.getKeyboard().forceRelease();
      windowFocus = focused;
    }
    if(freeliner instanceof FreelinerLED) background(50,0,0);
    else background(50,50,50);
    // update the widgets with the mouse position
    if(!mousePressed) selectedWidget = null;
    for(Widget _wdgt : widgets){
      if(!mousePressed && _wdgt.update(cursor)) selectedWidget = _wdgt;
    }
    for(Widget _wdgt : widgets)
      commandProcessor.queueCMD(_wdgt.getCmd());



    // draw stuff
    canvas.beginDraw();
    canvas.clear();

    // display all the widgets
    for(Widget wdgt : widgets) wdgt.show(canvas);
    canvas.endDraw();
    image(canvas, 0, 0);
  }


  public void mouseMoved(){
    cursor.set(mouseX, mouseY);
  }

  public void mousePressed(){
    if(selectedWidget != null) selectedWidget.click(mouseButton);
  }

  public void mouseDragged(){
    cursor.set(mouseX, mouseY);
    if(selectedWidget != null) {
      selectedWidget.setCursor(cursor);
      selectedWidget.drag(mouseButton);
    }
  }

  public void keyPressed(){
    if(relayKeys) freeliner.getKeyboard().keyPressed(keyCode);
    if (key == 27) key = 0;       // dont let escape key, we need it :)
  }

  public void keyReleased(){
    if(relayKeys) freeliner.getKeyboard().keyReleased(keyCode);
  }
}
