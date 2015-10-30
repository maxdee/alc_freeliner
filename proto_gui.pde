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
public class FLgui extends PApplet {
  FreeLiner freeliner;

  // gui Items
  ArrayList<GuiItem> guiItems;
  // gui variables
  boolean relayKeys;
  public FLgui(FreeLiner _fl){
    super();
    freeliner = _fl;
  }

  public void settings(){
    size(1000, 400, P2D);
  }

  public void setup() {
    surface.setResizable(false); // keep it pretty
    smooth(0);
    //frameRate(10); // keep it fast?
    guiItems = new ArrayList();
    //guiItems.add();
  }

  public void draw(){
    background(0);

    displayInfo();
  }

  public void displayInfo(){
    String[] _info = freeliner.getGui().getAllInfo();
    String _txt = "";
    for(String str : _info) _txt += str;
    fill(255);
    text(_txt, 500, 200);
  }


  public void mouseMoved(){ }

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
///////     Gui items, like template selector, colorPicker, gui text! toggleable keyboard sender
///////
////////////////////////////////////////////////////////////////////////////////////

// basic class to make clickable object
class Clickable {
  PVector pos;
  PVector dimention;

  public Clickable(PVector _pos, PVector _sz){
    pos = _pos.get();
    dimention = _sz.get();
  }

  public void draw(){

  }

  public void setPos(PVector _pos){
    pos = _pos.get();
  }

  public boolean isOver(PVector _cursor){
    // if(pos.sub(_cursor))
    // if()
    return false;
  }
}



// a basic class to create Items in the gui
class GuiItem extends Clickable {
  public GuiItem(PVector _pos){
    super(_pos, new PVector(10,10));
  }

  public void draw(){}
  public void click(PVector _loc){}
}












///
