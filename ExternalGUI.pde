/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */

import processing.core.PApplet;
import processing.core.PSurface;

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

  /**
   * Constructor,
   * @param Freeliner to control
   */
  public ExternalGUI(FreeLiner _fl){
    super();
    freeliner = _fl;
    cursor = new PVector(0,0);
    widgets = new ArrayList();
    // InfoLine is the same info the regular GUI shows
    widgets.add(new InfoLine(new PVector(0,0), new PVector(WIDTH, 20), freeliner.getGui()));
    widgets.add(new Toggle(new PVector(100,100), new PVector(20,20)));
    widgets.add(new Fader(new PVector(100,125), new PVector(100,20)));
    widgets.add(new SequenceGUI(new PVector(0, HEIGHT - 150),
                                new PVector(WIDTH, 150),
                                freeliner.getTemplateManager().getSynchroniser(),
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
    size(1000, 400, P2D);
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
  }

  public void draw(){
    background(0);
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
      selectedWidget.click(mouseButton);
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

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Widgets! from scratch.
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * Basic widget class
 */
class Widget implements FreelinerConfig{
  // position and size
  PVector pos;
  PVector size;
  // mouse position relative to widget 0,0
  PVector mouseDelta;
  // mouse XY 0.0 to 1.0
  PVector mouseFloat;
  // if the mouse is over the widget
  boolean selected;
  // enable disable widget
  boolean active;
  // basic colors
  color bgColor = color(100);
  color hoverColor = color(150);
  color frontColor = color(200,0,0);

  /**
   * Constructor
   * @param PVector position of top left corner of widget
   * @param PVector widget dimentions
   */
  public Widget(PVector _pos, PVector _sz){
    pos = _pos.get();
    size = _sz.get();
    mouseDelta = new PVector(0,0);
    mouseFloat = new PVector(0,0);
    active = true;
  }

  /**
   * Render the widget, draws the basic background and changes its color if widget selected.
   * @param PGraphics canvas to draw on
   */
  public void show(PGraphics _pg){
    if(!active) return;
    _pg.noStroke();
    if(selected) _pg.fill(hoverColor);
    else _pg.fill(bgColor);
    _pg.rect(pos.x, pos.y, size.x, size.y);
  }

  /**
   * Update the widget
   * @param PVector cursor position
   * @return boolean cursor is over widget
   */
  public boolean update(PVector _cursor){
    setCursor(_cursor);
    if(!active) selected = false;
    else selected = isOver();
    return selected;
  }

  /**
   * Update the cursor position, determin the mouseDelta and unit interval
   * @param PVector cursor position
   */
  public void setCursor(PVector _cursor){
    mouseDelta = _cursor.get().sub(pos);
    mouseFloat.set(mouseDelta.x/size.x, mouseDelta.y/size.y);
  }

  /**
   * Is mouse over widget
   * @return boolean
   */
  public boolean isOver(){
    return (mouseDelta.x > 0 && mouseDelta.y > 0) && (mouseDelta.x < size.x && mouseDelta.y < size.y);
  }

  /**
   * receive mouse press
   * @param int mouse button
   * @return boolean
   */
  public void click(int _mb){
    if(selected) action(_mb);
  }

  /**
   * where the action of the widget happens
   * @param int mouse button
   * @return boolean
   */
  public void action(int _button){
    // you can use mouseFloat for info
  }

  public void setPos(PVector _pos){
    pos = _pos.get();
  }

  public void setBackgroundColor(color _col){
    bgColor = _col;
  }
  public void setHoverColor(color _col){
    hoverColor = _col;
  }
  public void setFrontColor(color _col){
    frontColor = _col;
  }
}



/**
 * Basic toggle widget, subclass and inject things to control.
 */
class Toggle extends Widget {
  boolean value;
  color toggleCol = color(255,0,0);
  int inset = 2;

  public Toggle(PVector _pos, PVector _sz){
    super(_pos, _sz);
    value = false;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active && value){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, size.x-(2*inset), size.y-(2*inset));
    }
  }

  public void action(int _button){
    value = !value;
  }
}

/**
 * Basic horizontal fader widget, subclass and inject things to control.
 */
class Fader extends Widget {
  float value;
  int inset = 2;
  public Fader(PVector _pos, PVector _sz){
    super(_pos, _sz);
    value = 0.5;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, (size.x-(2*inset)) * value, size.y-(2*inset));
    }
  }

  public void action(int _button){
    value = constrain(mouseFloat.x, 0.0, 1.0);
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Actual widgets
///////
////////////////////////////////////////////////////////////////////////////////////


/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
class InfoLine extends Widget {
  Gui flGui;
  int txtSize;
  public InfoLine(PVector _pos, PVector _sz, Gui _g){
    super(_pos, _sz);
    txtSize = int(_sz.y);
    flGui = _g;
    active = true;
  }

  public void show(PGraphics _canvas){
    if(!active) return;
    _canvas.textSize(txtSize);
    String[] _info = reverse(flGui.getAllInfo());
    String _txt = "";
    for(String str : _info) _txt += str+"  ";
    _canvas.fill(255);
    _canvas.text(_txt, pos.x, pos.y+txtSize);
  }
}

/**
 * Widget to control the sequencer
 */
class SequenceGUI extends Widget {
  int txtSize = 20;
  int inset = 2;
  SequenceSync sequencer;
  TemplateList managerList;

  public SequenceGUI(PVector _pos, PVector _sz, SequenceSync _seq, TemplateList _tl){
    super(_pos, _sz);
    //txtSize = int(_sz.y);
    sequencer = _seq;
    managerList = _tl;
    active = true;
  }

  public void action(int _mb){
    int _clickedStep = int(mouseFloat.x * SEQ_STEP_COUNT);
    if(_mb == LEFT) sequencer.setStep(_clickedStep);
    else if(_mb == RIGHT){
      ArrayList<TweakableTemplate> _tmps = managerList.getAll();
      if(_tmps == null) return;
      sequencer.setEditStep(_clickedStep);
      for(TweakableTemplate _tw : _tmps){
        sequencer.getStepToEdit().toggle(_tw);
      }
    }
  }


  public void show(PGraphics _canvas){
    if(!active) return;
    int _index = 0;
    int _stepSize = int(size.x/ 16.0);
    _canvas.textSize(txtSize);
    for(TemplateList _tl : sequencer.getStepLists()){
      _canvas.pushMatrix();
      _canvas.translate(_stepSize * _index, pos.y);
      if(_index == sequencer.getStep()) _canvas.fill(hoverColor);
      else _canvas.fill(bgColor);
      _canvas.stroke(0);
      _canvas.strokeWeight(1);
      _canvas.rect(0, 0, _stepSize, size.y);
      _canvas.noStroke();
      if(_tl == sequencer.getStepToEdit()){
        _canvas.fill(frontColor);
        _canvas.rect(inset, inset, _stepSize-(2*inset), size.y-(2*inset));
      }
      _canvas.rotate(HALF_PI);
      _canvas.fill(255);
      _canvas.text(_tl.getTags(),inset*4,-inset*4);
      _canvas.popMatrix();
      _index++;
    }
  }
}
