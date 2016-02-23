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
import controlP5.*;
/**
 * ExternalGUI is a seperate PApplet launched by freeliner
 */
public class ExternalGUI extends PApplet {

  // reference to the freeliner instance to control
  FreeLiner freeliner;
  // canvas to draw to, is needed to be passed to objects that need to draw.
  PGraphics canvas;
  // mouse cursor
  PVector cursor;
  // send keys from externalGUI to freeliner keyboard input
  boolean relayKeys = true;
  // externalGUI size, make sure you also change them in the settings() method
  final int WIDTH = 1000;
  final int HEIGHT = 400;
  // ArrayList of widgets
  ArrayList<Widget> widgets;
  // the selected widget, aka the one that the cursor hovers
  Widget selectedWidget;

  boolean windowFocus;

  ControlP5 cp5;
  ControlP5Controler flcp5;

  /**
   * Constructor,
   * @param Freeliner to control
   */
  public ExternalGUI(FreeLiner _fl){
    super();
    freeliner = _fl;
    cursor = new PVector(0,0);
    windowFocus = true;
    widgets = new ArrayList();
    // InfoLine is the same info the regular GUI shows


    widgets.add(new InfoLine(new PVector(0,0), new PVector(WIDTH, 22), freeliner.getGui()));
    widgets.add(new SequenceGUI(new PVector(0, HEIGHT - 150),
                                new PVector(WIDTH, 150),
                                freeliner.getTemplateManager().getSequencer(),
                                freeliner.getTemplateManager().getTemplateList()));
    selectedWidget = null;

  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     PApplet Basics
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // your traditional sketch settings function
  public void settings(){
    size(1000, 700, P2D);
    smooth(0);
  }

  // your traditional sketch setup function
  public void setup() {
    canvas = createGraphics(width, height, P2D);
    canvas.textFont(font);
    surface.setResizable(false); // keep it pretty
    textMode(CORNER);
    hint(ENABLE_KEY_REPEAT); // usefull for performance
    //frameRate(10); // keep it fast?
    cp5 = new ControlP5(this);
    flcp5 = new ControlP5Controler(cp5, freeliner);
  }

  void controlEvent(ControlEvent _ev){
    flcp5.controlEvent(_ev);
  }

  public void draw(){
    if(windowFocus != focused){
      freeliner.getKeyboard().forceRelease();
      windowFocus = focused;
    }
    if(freeliner instanceof FreelinerLED) background(50,0,0);
    else background(0,0,50);
    // update the widgets with the mouse position
    if(!mousePressed) selectedWidget = null;
    for(Widget wdgt : widgets){
      if(!mousePressed && wdgt.update(cursor)) selectedWidget = wdgt;
    }

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
    if(relayKeys) freeliner.getKeyboard().processKey(key, keyCode);
    if (key == 27) key = 0;       // dont let escape key, we need it :)
  }

  public void keyReleased(){
    if(relayKeys) freeliner.getKeyboard().processRelease(key, keyCode);
  }
}
