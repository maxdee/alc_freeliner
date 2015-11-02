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

// thx to @codingjoe for leading me to this!
public class ExternalGUI extends PApplet {

  // reference to the freeliner instance to control
  FreeLiner freeliner;

  // canvas to draw to, is needed to be passed to objects that need to draw.
  PGraphics canvas;
  // mouse cursor
  PVector cursor;
  // gui behavioral variables
  boolean relayKeys = true;

  // gui Items
  ArrayList<Widget> widgets;

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
    widgets.add(new InfoLine(new PVector(0,0), new PVector(width, 20), freeliner.getGui()));
    widgets.add(new Widget(new PVector(100,100), new PVector(20,20)));
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     PApplet Basics
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // your traditional sketch setup function
  public void settings(){
    size(1000, 400, P2D);
    smooth(0);
  }

  // your traditional sketch setup function
  public void setup() {
    canvas = createGraphics(width, height, P2D);
    surface.setResizable(false); // keep it pretty
    textMode(CORNER);
    hint(ENABLE_KEY_REPEAT); // usefull for performance
    //frameRate(10); // keep it fast?
  }

  public void draw(){
    background(0);
    // update the widgets with the mouse position
    for(Widget wdgt : widgets) wdgt.update(cursor);

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

  public void keyPressed(){
    println("in ext : "+(keyCode==SHIFT));
    if(relayKeys) freeliner.getKeyboard().processKey(key, keyCode);
    if (key == 27) key = 0;       // dont let escape key, we need it :)
  }
  public void keyReleased(){
    if(relayKeys) freeliner.getKeyboard().processRelease(key, keyCode);
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Gui items, like template selector, colorPicker, gui text! toggleable keyboard sender
///////
////////////////////////////////////////////////////////////////////////////////////

// basic class to make clickable object
class Widget {
  PVector pos;
  PVector size;
  // mouse position relative to widget 0,0
  PVector mouseDelta;
  // mouse XY 0.0 to 1.0
  PVector mouseFloat;
  boolean selected;
  boolean active;
  color bgcol = color(100);
  color selcol = color(200);

  public Widget(PVector _pos, PVector _sz){
    pos = _pos.get();
    size = _sz.get();
    mouseDelta = new PVector(0,0);
    mouseFloat = new PVector(0,0);
    active = true;
  }

  // the update function should be called at first to give the mouse position.
  public void update(PVector _cursor){
    mouseDelta = _cursor.get().sub(pos);
    mouseFloat.set(mouseDelta.x/size.x, mouseDelta.y/size.y);
    if(!active) selected = false;
    else selected = isOver();
  }

  // draw stuff here
  public void show(PGraphics _pg){
    if(!active) return;
    _pg.noStroke();
    if(selected) _pg.fill(selcol);
    else _pg.fill(bgcol);
    _pg.rect(pos.x, pos.y, size.x, size.y);
  }

  public boolean isOver(){
    return (mouseDelta.x > 0 && mouseDelta.y > 0) && (mouseDelta.x < size.x && mouseDelta.y < size.y);
  }

  public void click(int _mb){
    if(selected) action();
  }

  // here is where we process actions
  public void action(){
    // you can use mouseFloat for info
  }
  // public void setPos(PVector _pos){
  //   pos = _pos.get();
  // }
}


// display GUI info compiled by the regular Freeliner GUI
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
    _canvas.textSize(txtSize);
    String[] _info = reverse(flGui.getAllInfo());
    String _txt = "";
    for(String str : _info) _txt += str+"  ";
    _canvas.fill(255);
    _canvas.text(_txt, pos.x, pos.y+txtSize);
  }
}











///
