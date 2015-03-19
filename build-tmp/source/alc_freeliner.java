import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.net.InetAddress; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class alc_freeliner extends PApplet {


/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */






FreeLiner fl;
PFont font;
PFont introFont;

boolean ballPit = false;//true;
//boolean fullscreen = true;
boolean fullscreen = false;
int xres = 1024;
int yres = 768;

public void setup() {

  if(!fullscreen) size(xres, yres, P2D);
  else size(displayWidth, displayHeight, P2D);
  //frame.setBackground(new java.awt.Color(0, 0, 0));
  
  frameRate(30); //is this helpfull?
  textureMode(NORMAL);
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  
  noCursor();
  splash();
  fl = new FreeLiner();
  delay(1000);
  //loadTest();
}


// lets processing know if we want it fullscreen
public boolean sketchFullScreen() {
  return fullscreen;
}

public void splash(){
  background(0);
  stroke(100);
  fill(150);
  textMode(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
}

public void draw() {
  fl.update();
}
  


//relay the inputs to the mapper
public void keyPressed() {
  fl.keyboard.processKey(key, keyCode);
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

public void keyReleased() {
  fl.keyboard.processRelease(key, keyCode);
}

public void mousePressed(MouseEvent event) {
  fl.mouse.press(mouseButton);
}

public void mouseDragged() {
  if(ballPit && mouseX < width/2) fl.mouse.drag(mouseButton, 
                                              -(PApplet.parseInt((mouseY/(float)height)*(width/2.0f)))+width/2,
                                              (PApplet.parseInt((mouseX/(width/2.0f))*height)));
  else fl.mouse.drag(mouseButton, mouseX, mouseY);
}

public void mouseMoved() {
  if(ballPit && mouseX < width/2) fl.mouse.move(-(PApplet.parseInt((mouseY/(float)height)*(width/2.0f)))+width/2,
                                              (PApplet.parseInt((mouseX/(width/2.0f))*height))); 
  else fl.mouse.move(mouseX, mouseY);
}

public void mouseWheel(MouseEvent event) {
  fl.mouse.wheeled(event.getCount());
}



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     weird testing tool, sorry for the wtf
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


public void loadTest(){
  execute(":1000x :100y . :800x:100y . :600x:100y . :400x:100y .");
  execute("n, :200x:200y . :800x:200y . :800x:600y . :200x:600y . :200x:200y .");
  execute("A, B,");
  execute("c, :500x :500y .");
  execute("+ A, q, 2, > + B, b, 4, >");
}

public void execute(String cmd){
  boolean makeNum = false;
  boolean sendKey = false;
  String num = "";
  char chr = '_';
  int xpos = 0;
  int ypos = 0;

  for(int i = 0; i<cmd.length(); i++){
    if(cmd.charAt(i) == ' ');
    else if(cmd.charAt(i) == ':'){
      makeNum = true;
    }
    else if(cmd.charAt(i) == ','){
      fl.keyboard.processKey(chr, keyCode);
    }
    else if(cmd.charAt(i) == '>'){
      fl.keyboard.processKey('_', 10);
    }
    else if(cmd.charAt(i) == '+'){
      fl.keyboard.processKey('_', 27);
    }
    else if(cmd.charAt(i) == '.'){
      fl.mouse.move(xpos, ypos);
      fl.mouse.press(37);
    }
    else {
      if(makeNum){
        if(cmd.charAt(i) == 'x') { xpos = Integer.parseInt(num); num =""; makeNum = false;} 
        else if(cmd.charAt(i) == 'y') { ypos = Integer.parseInt(num); num =""; makeNum = false;}
        else num += cmd.charAt(i);
      }
      else chr = cmd.charAt(i);
    }
  }
}

/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */



class Clock {
 
  boolean ticker = true; //goes true for one cycle when on
  int tempo = 1000; //in millis
  int lastTime = 0;
  int cycles = 0;



  int division;
  int increment = 0;
  float lerper = 0;
  float lerpIncrement = 0;
  FloatSmoother fs;

  public Clock(int d) {
    division = d;
    fs = new FloatSmoother(8, 0.1f);
  }

  public void update(int inc) {
    cycles++;
    lerper += lerpIncrement;

    if(lerper > 1){
      lerper = 0;
      increment++;
    }

    if(inc % division == 0 && !ticker){
      ticker = true;
      lerpIncrement = fs.addF(1.0f/cycles);
      cycles = 0;
    }
    if(inc % division == 1) ticker = false; 
  }


  public void reset(){
    lerper = 0;
    lastTime = millis();
    increment++;
  }

    //dosentreally work....
  public void internal(){
    if (millis()-lastTime > tempo) {
      increment++;
      lastTime = millis();
    }
    update(increment);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public void setTempo(int s){
    tempo = s * division;
  }

  public void setDiv(int d){
    if(d > 0) division = d;
  }
  public void setLerper(float _l){
    lerper = _l;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final boolean getTicker() {
    return ticker;
  }

  public final int getTempo(){
    return tempo;
  }

  public final float getLerper() {
    return lerper;
  }

  public final int getIncrement() {
    return increment;
  }
}

/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */





///*** Todo ***///
// deco pgraphics as a texture to be shaded?
// loop mode = clock, non loop = trigger mode. (rendering speed stored in rederer?)
// yahoo!!

//bumper

// autoPilot for renderers b:1,3 q:2,3
//add middle to vertix


// the PGraphics deco should maybe be a P2D?


class  FreeLiner {

  OscP5 oscP5;
  //"graphical interface"
  Gui gui;
  // input
  Mouse mouse;
  Keyboard keyboard;
  // managers
  GroupManager groupManager;
  RendererManager rendererManager;

  public FreeLiner() {

    //network
    //oscP5 = new OscP5(this, 3333);
    rendererManager =  new RendererManager();
    groupManager = new GroupManager();
    mouse = new Mouse();
    keyboard = new Keyboard();
    gui = new Gui();

    mouse.inject(groupManager, keyboard);
    keyboard.inject(groupManager, rendererManager, gui, mouse);
    gui.inject(groupManager, mouse);
  }

  public void update() {
    background(0);
    rendererManager.update(groupManager.getGroups());
    image(rendererManager.getCanvas(), 0, 0);
    
    if(gui.doDraw()){
      gui.update();
      image(gui.getCanvas(), 0, 0);
    }
    keyboard.resetInputFlag();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Playing functions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Mouse Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     OSC
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // public void oscEvent(OscMessage mess) {
  //   println(mess);
  //   if (mess.checkAddrPattern("/freeliner/decorator")) {
  //     char dec = mess.get(0).stringValue().charAt(0);
  //     char edit = mess.get(1).stringValue().charAt(0);
  //     int value = mess.get(2).intValue();
  //     //renderers.get(charIndex(dec)).numberDispatch(edit, value);
  //     //println(dec+" "+edit+" "+value);
  //   }
  // }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Keyboard Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  private void printStatus() {
    //println("selectedGroupIndex : "+groupManager.getSelectedGroup()+" editKey : "+editKey+" grid "+viewGrid+" gridSize "+gridSize);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Manage segmentGroups!
 *
 */
class GroupManager{

  //selects groups to control, -1 for not selected
  int selectedIndex;
  int lastSelectedIndex;
  int snappedIndex;
  // list of PVectors that are snapped
  ArrayList<PVector> snappedList;

  //manages groups of points
  ArrayList<SegmentGroup> groups;
  int groupCount = 0;

/**
 * Constructor, inits default values
 */
  public GroupManager(){
  	groups = new ArrayList();
    snappedList = new ArrayList();
  	groupCount = 0;
    selectedIndex = -1;
    lastSelectedIndex = -1;
    snappedIndex = -1;
    newItem();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // create a new item.
  public void newItem() {
    //if (groupCount == 0) groups.add(new SegmentGroup(groupCount));
    //else 
    groups.add(new SegmentGroup(groupCount));
    selectedIndex = groupCount;
    groupCount++;
  }

  // tab and shift-tab through groups
  public void tabThrough(boolean _shift) {
    if(!isFocused()) selectedIndex = lastSelectedIndex;
    else if (_shift)selectedIndex--;
    else selectedIndex++;
    selectedIndex = wrap(selectedIndex, groupCount-1);
  }

  //add an other renderer to all groups who have the first renderer.
  public void groupAddRenderer(String _nr, char _rn){
    if(groupCount > 0){
      for (int i = groupCount-1; i>=0; i--) {
        if(groups.get(i).getRenderList().has(_rn)){
          char k = _nr.charAt(0);
          if(k >= 65 && k <= 90) groups.get(i).toggleRender(k);
        }
      }
    }
  }


  public PVector snap(PVector _pos){
    PVector snap = new PVector(0, 0);
    snappedList.clear();
    snappedIndex = -1;
    for (int i = 0; i < groupCount; i++) {
      snap = groups.get(i).snapVerts(_pos); // snapVerts does not find anything it returns 0s
      if (snap.x != 0 && snap.y != 0){
        snappedIndex = i;
        snappedList.add(snap);
        if(!isFocused()) lastSelectedIndex = i;
        //break; 
      }
    }
    if (snappedIndex != -1) return snappedList.get(0);
    else return _pos;
  }

  public void nudger(Boolean axis, int dir, boolean _shift){
    PVector ndg = new PVector(0, 0);
    if (axis && _shift) ndg.set(10*dir, 0);
    else if (!axis && _shift) ndg.set(0, 10*dir);
    else if (axis && !_shift) ndg.set(1*dir, 0);
    else if (!axis && !_shift) ndg.set(0, 1*dir);

    if(snappedList.size()>0){
      //if(!isFocused()){
        for(PVector _vert : snappedList){
          println(_vert);
          _vert.add(ndg);
        }
      //}
    }
    else if(isFocused()) getSelectedGroup().nudgePoint(ndg);
    // else if (isFocused() && snappedIndex == selectedIndex) {
    //   getSelectedGroup().nudgeSnapped(ndg, _pos); 
    // } 
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void unSelect(){
    lastSelectedIndex = selectedIndex;
    selectedIndex = -1;
  }

  public int setSelectedGroupIndex(int _i) {
    selectedIndex = _i % groupCount;
    return selectedIndex;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean isFocused(){
    if(snappedIndex != -1 || selectedIndex != -1) return true;
    else return false;
  }

  public int getSelectedIndex(){
    return selectedIndex;
  }

  public SegmentGroup getSelectedGroup(){
    
    if(snappedIndex != -1 && selectedIndex == -1) return groups.get(snappedIndex);
    else if(selectedIndex != -1 && selectedIndex <= groupCount) return groups.get(selectedIndex);
    else return null;
  }

  public SegmentGroup getLastSelectedGroup(){
    if(lastSelectedIndex != -1 ) return groups.get(lastSelectedIndex);
    else return null;
  }

  public SegmentGroup getIndex(int _i){
    if(_i >= 0 && _i < groupCount) return groups.get(_i);
    else return null;
  }

  public ArrayList<SegmentGroup> getGroups(){
    return groups;
  }

  public PVector getPreviousPosition() {
    if (isFocused()) return getSelectedGroup().getLastPoint();
    else return new PVector(width/2, height/2, 0);
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Gui class handles anything on the PGraphics gui
 * <p>
 * All drawing happens here.
 * </p>
 *
 * @see SegmentGroup
 */
 class Gui{

  // depends on a group manager
  GroupManager groupManager;
  Mouse mouse;
  PGraphics grid;
  PGraphics canvas;
  PShape crosshair;

  //gui and line placing
  boolean showGui;
  boolean viewLines;
  boolean viewTags;
  boolean viewPosition;

  int gridSize = 30;
  int guiTimeout = 1000;
  int guiTimer = 1000;
  //display elapsed time!
  int[] timeStarted = new int[3];

  //ui strings
  String keyString = "derp";
  String valueGiven = "__";
  String renderString = "_";

  boolean updateFlag = false;


/**
 * Constructor
 * @param GroupManager dependency injection
 */
  public Gui(){

    canvas = createGraphics(width, height);
    canvas.smooth(0);
    canvas.textFont(font);
    
    grid = createGraphics(width, height);
    grid.smooth(0);

    makecrosshair();

    showGui = true;
    viewLines = false;
    viewTags = false;
    viewPosition = true;
    timeStarted[0] = hour();
    timeStarted[1] = minute();
    timeStarted[2] = second();
  }

  public void inject(GroupManager _gm, Mouse _m){
    groupManager = _gm;
    mouse = _m;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     GUI
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //gui bits
  private void update() {
    canvas.beginDraw();
    canvas.clear();
    canvas.textFont(font);
    canvas.textSize(15);
    canvas.textMode(CENTER);
    if (mouse.useGrid()){
      if(mouse.getGridSize() != gridSize) generateGrid(mouse.getGridSize());
      canvas.image(grid,0,0); // was without canvas before
    }
    if(viewPosition) putcrosshair(mouse.getPosition(), mouse.isSnapped());
    if(viewLines || viewTags){
      for (SegmentGroup sg : groupManager.getGroups()) {
        canvas.fill(200);
        sg.showLines(canvas); 
        sg.showTag(canvas);
      }
    }
    SegmentGroup sg = groupManager.getSelectedGroup();
    if(sg != null){
      canvas.fill(255);
      sg.showLines(canvas); 
      sg.showTag(canvas);
      if (viewPosition) sg.previewLine(canvas, mouse.getPosition());
    }
    infoWritter(canvas);
    canvas.endDraw();
  }



  private void infoWritter(PGraphics pg) {
    //if(updateFlag){
      String rn = " ";
      if (groupManager.isFocused()) rn += groupManager.getSelectedGroup().getRenderList().getString();
      else rn += renderString; //renderList.getString();
      if(rn.length()>20) rn = "*ALL*";

      groupManager.getIndex(0).setWord("[Item: "+groupManager.getSelectedIndex()+"]", 0);
      groupManager.getIndex(0).setWord("[Rndr: "+rn+"]", 1);
      groupManager.getIndex(0).setWord("["+keyString+": "+valueGiven+"]", 2);
      groupManager.getIndex(0).setWord("[FPS "+frameRate+"]", 3);
      groupManager.getIndex(0).setWord("[Run "+getTimeRunning()+"]", 4);
      updateFlag = false;
    //}
    groupManager.getIndex(0).showText(pg);

  }

  private String getTimeRunning(){
    return str(hour()-timeStarted[0])+':'+str(minute()-timeStarted[1])+':'+str(second()-timeStarted[2]); 
  }

  // makes a screenshot with all lines and itemNumbers/renderers.
  private void updateReference() {
    boolean tgs = viewTags;
    boolean lns = viewLines;
    viewLines = true;
    viewTags = true;
    update();
    canvas.save("reference.jpg");
    viewTags = tgs;
    viewLines = lns;
  }


  private void generateGrid(int _sz){
    gridSize = _sz;
    PShape grd;
    grd = createShape();
    grd.beginShape(LINES);
    for (int x = 0; x < width; x+=gridSize) {
      for (int y = 0; y < height; y+=gridSize) {
        grd.vertex(x, 0);
        grd.vertex(x, height);
        grd.vertex(0, y);
        grd.vertex(width, y);
      }
    }
    grd.endShape();
    grd.setStroke(color(100, 100, 100, 10));
    grd.setStrokeWeight(1);
    grid.beginDraw();
    grid.clear();
    grid.shape(grd);
    grid.endDraw();
  }
  


  private void putcrosshair(PVector _pos, boolean _snap){
    if(_snap) crosshair.setStroke(color(0,200,0));
    else crosshair.setStroke(color(255));
    crosshair.setStrokeWeight(3);
    canvas.pushMatrix();
    canvas.translate(_pos.x, _pos.y);
    if(width > 1026 && _pos.x > width/2) canvas.rotate(QUARTER_PI);
    canvas.shape(crosshair);
    canvas.popMatrix();
  }

  private void makecrosshair(){
    int out = 20;
    int in = 3;
    crosshair = createShape();
    crosshair.beginShape(LINES);
    crosshair.vertex(-out, -out);
    crosshair.vertex(-in, -in);

    crosshair.vertex(out, out);
    crosshair.vertex(in, in);
    
    crosshair.vertex(out, -out);
    crosshair.vertex(in, -in);
    
    crosshair.vertex(-out, out);
    crosshair.vertex(-in, in);
    crosshair.endShape();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public void hide(){
    guiTimer = -1;
  }
  public void resetTimeOut(){
    guiTimer = guiTimeout;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean doDraw(){
    if (guiTimer > 0 || mouse.useGrid()) {
      guiTimer--;
      return true;
    }
    else return false;
  }

  public PGraphics getCanvas(){
    return canvas;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////



  public void setKeyString(String _s){
    keyString = _s;
    updateFlag = true;
  }

  public void setValueGiven(String _s){
    valueGiven = _s;
    updateFlag = true;
  }  

  public void setRenderString(String _s){
    renderString = _s;
    updateFlag = true;
  }


  public boolean toggleViewPosition(){
    viewPosition = !viewPosition;
    return viewPosition;
  }

    public boolean toggleViewTags(){
    viewTags = !viewTags;
    return viewTags;
  }

  public boolean toggleViewLines(){
    viewLines = !viewLines;
    return viewLines;
  }
}

/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Manage a keyboard
 * <p>
 * KEYCODES MAPPING
 * ESC unselect
 * CTRL feather mouse + (ctrl)...
 * UP DOWN LEFT RIGHT move snapped or previous point, SHIFT for faster
 * TAB tab through segmentGroups, SHIFT to reverse
 * <p>
 * CTRL + KEYS MAPPING
 * ctrl-a   selectAll
 * ctrl-i   revers mouseX
 * ctrl-r   reset decorator
 * ctrl-d   customShape
 */
class Keyboard{
  //provides strings to show what is happening.
  final String keyMap[] = {
    "a    animationMode", 
    "b    renderMode", 
    "c    placeCenter", 
    "d    setShape", 
    "f    setFill",
    "g    grid/size", 
    "h    lerpMode",
    "i    iterations", 
    "j    reverseMode",
    "k    internalClock",
    "l    loop mode",
    "n    newItem", 
    "o    rotation",
    "p    probability",
    "q    setStroke", 
    "r    polka", 
    "s    setSize", 
    "t    tap", 
    "u    setSpeed",
    "v    vertMode",
    "x    setDiv", 
    "y    trails", 
    "w    strkWeigth",   
    ",    showTags", 
    "/    showLines",
    ";    showCrosshair",
    ".    snapping",
    "|    enterText",
    "m    breakLine",
    "]    fixedLenght",
    "[    fixedAngle",
    "-    decreaseValue",
    "=    increaseValue",
    "@    save", 
    "#    load",
    "!    loopAll"
  };


  // dependecy injection
  GroupManager groupManager;
  RendererManager rendererManager;
  Gui gui;
  Mouse mouse;

  //key pressed
  boolean shifted;
  boolean ctrled;
  boolean alted;

  // more keycodes
  final int CAPS_LOCK = 20;
  // flags
  boolean enterText;
  boolean gotInputFlag;

  //setting selector
  char editKey = ' '; // dispatches number maker to various things such as size color
  char editKeyCopy = ' ';

  //user input int and string
  String numberMaker = " ";
  String wordMaker = " ";


/**
 * Constructor inits default values
 */
  public Keyboard(){
    shifted = false;
    ctrled = false;
    alted = false;
    enterText = false;
    gotInputFlag = false;
  }

/**
 * Dependency injection
 * Receives references to the groupManager, rendererManager, GUI and mouse.
 *
 * @param GroupManager reference
 * @param RenderManager reference
 * @param Gui reference
 * @param Mouse reference
 */
  public void inject(GroupManager _gm, RendererManager _rm, Gui _gui, Mouse _m){
    groupManager = _gm;
    rendererManager = _rm;
    gui = _gui;
    mouse = _m;
  }

/**
 * receive and key and keycode from papplet.keyPressed();
 *
 * @param char key that was press
 * @param int the keyCode
 */
  public void processKey(char k, int kc) {
    gotInputFlag = true;
    gui.resetTimeOut(); // was in update, but cant rely on got input due to ordering
    processKeyCodes(kc); // TAB SHIFT and friends
    if (enterText) {
      if (k==ENTER) returnWord();
      else if (k!=65535) wordMaker(k);
      println(wordMaker);
      gui.setValueGiven(wordMaker);
    }
    else {
      if (k >= 48 && k <= 57) numMaker(k);
      else if (k>=65 && k <= 90) processCAPS(k);
      else if (k==ENTER) returnNumber();
      else if (ctrled || alted) modCommands(PApplet.parseInt(k));
      else{
        setEditKey(k);
        distributor(k, -3, true);
      }
    }
  }


/**
 * Process keycode for keys like ENTER or ESC
 *
 * @param int the keyCode
 */
  public void processKeyCodes(int kc) {
    if (kc==SHIFT) shifted = true;
    else if (kc == ESC) unSelectThings();
    else if (kc==CONTROL) setCtrled(true);
    else if (kc==ALT) alted = true;
    else if (kc==UP) groupManager.nudger(false, -1, shifted);//, mouse.getPosition()); //positionUp();
    else if (kc==DOWN) groupManager.nudger(false, 1, shifted);//, mouse.getPosition());//positionDown();
    else if (kc==LEFT) groupManager.nudger(true, -1, shifted);//, mouse.getPosition());//positionLeft();
    else if (kc==RIGHT) groupManager.nudger(true, 1, shifted);//, mouse.getPosition());//positionRight();
    //tab and shift tab throug groups
    else if (kc==TAB) groupManager.tabThrough(shifted);
  }

/**
 * Process key release, mostly affcting coded keys
 *
 * @param char the key
 * @param int the keyCode
 */
  public void processRelease(char k, int kc) {
    if (kc==16) shifted = false;
    else if (kc==17) ctrled = false;
    else if (kc==18) alted = false;
  }


/**
 * Process capital letters. A trick is applied here, different actions happen if caps-lock is on or shift is pressed.
 * <p>
 * When shift is used it will toggle the renderer from a segment group or from the list.
 * When caps lock is used, it triggers the renderer. This way you can mash your keyboard with capslock on to perform.
 *
 * @param char the capital key to process
 */
  public void processCAPS(char c) {
    if(shifted){
      if (groupManager.isFocused()) groupManager.getSelectedGroup().toggleRender(c);
      else {
        rendererManager.getList().toggle(c);
        gui.setRenderString(rendererManager.renderList.getString());
      }
    }
    else {
      rendererManager.trigger(c);
    }
  }


/**
 * The ESC key triggers this, it unselects segment groups / renderers, a second press will hid the gui.
 */
  private void unSelectThings(){
    if(!groupManager.isFocused() && !rendererManager.isFocused()) gui.hide();
    else {
      rendererManager.unSelect();
      groupManager.unSelect();
      gui.setRenderString(" ");//rendererManager.renderList.getString());
    }
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Interpretation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //for some reason if you are holding ctrl or alt you get other keycodes
/**
 * Process a key differently if ctrl or alt is pressed.
 *
 * @param int ascii value of the key
 */
  public void modCommands(int k){
    if(ctrled || alted) println(k);
    if (ctrled && k == 1) focusAll(); // a
    else if(ctrled && k == 9) gui.setValueGiven( str(mouse.toggleInvertMouse()) );
    else if(ctrled && k == 18) distributor(PApplet.parseChar(518), -3, false); // re init()
    else if(ctrled && k == 4) distributor(PApplet.parseChar(504), -3, false);  // set custom shape
  }

/**
 * Checks if the key is mapped by checking the keyMap to see if is defined there.
 *
 * @param char the key
 */
  public boolean keyIsMapped(char k) {
    for (int i = 0; i < keyMap.length; i++) {
      if (keyMap[i].charAt(0)==k) return true;
    }
    return false;
  }

/**
 * Gets the string associated to the key from the keyMap
 *
 * @param char the key
 */
  public String getKeyString(char k) {
    for (int i = 0; i < keyMap.length; i++) {
      if (keyMap[i].charAt(0)==k) return keyMap[i];
    }
    return "not mapped?";
  }

/**
 * CTRL-a selects all renderers as always. 
 */
  private void focusAll(){
    groupManager.unSelect();
    rendererManager.focusAll();
    gui.setRenderString("*all*");
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Distribution of input to things
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //distribute input!
  //check if its mapped to general things
  //then if an item has focus
  //check if it is mapped to an item thing
  //if not then pass it to the first decorator of the item.
  //if no item has focus, pass it to the slected renderers.

  public void distributor(char _k, int _n, boolean _vg){
    if (!localDispatch(_k, _n, _vg)){
      if (groupManager.isFocused()){
        if(!segmentGroupDispatch(groupManager.getSelectedGroup(), _k, _n, _vg)){ // check if mapped to a segmentGroup
          char d = groupManager.getSelectedGroup().getRenderList().getFirst();
          //println(d+"  "+getSelectedGroup());
          decoratorDispatch(rendererManager.getRenderer(d), _k, _n, _vg);
        }
      }
      else { 
        ArrayList<Renderer> selected_ = rendererManager.getSelected();
        for (int i = 0; i < selected_.size(); i++) {
          //if(renderList.has(renderers.get(i).getID())){
            decoratorDispatch(selected_.get(i), _k, _n, _vg);
          //}
        }
      }    
    } 
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Dispatches
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // PERHAPS MOVE
  // for the signature ***, char k, int n, boolean vg
  // char K is the editKey
  // int n, -3 is no number, -2 is decrease one, -1 is increase one and > 0 is value to set.
  // boolean vg is weather or not to update the value given. (osc?)

  public boolean localDispatch(char _k, int _n, boolean _vg) {
    boolean used_ = true;
    String valueGiven_ = null;
    if(_n == -3){
      if (_k == 'n'){
        groupManager.newItem(); 
        gui.updateReference();
      }
      //more ergonomic?
      // else if (_k == 'a') nudger(true, -1); //right
      // else if (_k == 'd') nudger(true, 1); //left
      // else if (_k == 's') nudger(false, 1); //down 
      // else if (_k == 'w') nudger(false, -1); //up

      else if (_k == 't') rendererManager.sync.tap(); 
      else if (_k == 'g') valueGiven_ = str(mouse.toggleGrid());  
      else if (_k == 'y') valueGiven_ = str(rendererManager.toggleTrails());
      else if (_k == ',') valueGiven_ = str(gui.toggleViewTags());
      else if (_k == '.') valueGiven_ = str(mouse.toggleSnapping());
      else if (_k == '/') valueGiven_ = str(gui.toggleViewLines()); 
      else if (_k == ';') valueGiven_ = str(gui.toggleViewPosition());
      else if (_k == '|') valueGiven_ = str(toggleEnterText()); 
      else if (_k == '-') distributor(editKey, -2, _vg); //decrease value
      else if (_k == '=') distributor(editKey, -1, _vg); //increase value
      else if (_k == ']') valueGiven_ = str(mouse.toggleFixedLength());
      else if (_k == '[') valueGiven_ = str(mouse.toggleFixedAngle());
      else if (_k == '!') valueGiven_ = str(rendererManager.toggleLooping());
      else if (_k == 'm') mouse.press(3);  // 
      else used_ = false;
    }
    else {
      if (editKey == 'g') valueGiven_ = str(mouse.setGridSize(_n));
      else if (editKey == 't') rendererManager.sync.nudgeTime(_n);
      else if (editKey == 'y') valueGiven_ = str(rendererManager.setTrails(_n));
      else if (editKey == ']') valueGiven_ = str(mouse.setLineLenght(_n));
      else used_ = false;
    }
    
    if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    return used_;
  }

  public boolean segmentGroupDispatch(SegmentGroup _sg, char _k, int _n, boolean _vg) {
    boolean used_ = true;
    String valueGiven_ = null;
    if(_k == 'c') valueGiven_ = str(_sg.toggleCenterPutting());
    else if(_k == 's') valueGiven_ = str(_sg.setScaler(_n));
    else if(_k == '.') valueGiven_ = str(_sg.setSnapVal(_n));
    else used_ = false;
    if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    return used_;
  }

  public boolean decoratorDispatch(Renderer _renderer, char _k, int _n, boolean _vg) {
    //println(_renderer.getID()+" "+_k+" ("+int(_k)+") "+n);
    boolean used_ = true;
    
    if(_renderer != null){
      String valueGiven_ = null;
      if(_n == -3){
        if (_k == 'l') valueGiven_ = str(_renderer.toggleLoop());
        else if (_k == 'k') valueGiven_ = str(_renderer.toggleInternal());
        else if (PApplet.parseInt(_k) == 518) _renderer.init();
        else if (PApplet.parseInt(_k) == 504) rendererManager.setCustomShape(groupManager.getLastSelectedGroup());
        else used_ = false;
      }
      else {
        if (_k == 'a') valueGiven_ = str(_renderer.setAniMode(_n));
        else if (_k == 'f') valueGiven_ = str(_renderer.setFillMode(_n));
        else if (_k == 'r') valueGiven_ = str(_renderer.setPolka(_n));
        else if (_k == 'x') valueGiven_ = str(_renderer.setdivider(_n));
        else if (_k == 'i') valueGiven_ = str(_renderer.setIterationMode(_n));
        else if (_k == 'j') valueGiven_ = str(_renderer.setReverseMode(_n));
        else if (_k == 'b') valueGiven_ = str(_renderer.setRenderMode(_n));
        else if (_k == 'p') valueGiven_ = str(_renderer.setProbability(_n));
        else if (_k == 'h') valueGiven_ = str(_renderer.setLerpMode(_n)); 
        else if (_k == 'u') valueGiven_ = str(_renderer.setTempo(_n));
        else if (_k == 's') valueGiven_ = str(_renderer.setSize(_n));   
        else if (_k == 'q') valueGiven_ = str(_renderer.setStrokeMode(_n));
        else if (_k == 'w') valueGiven_ = str(_renderer.setStrokeWeight(_n)); 
        else if (_k == 'd') valueGiven_ = str(_renderer.setShapeMode(_n));
        else if (_k == 'v') valueGiven_ = str(_renderer.setSegmentMode(_n));
        else if (_k == 'o') valueGiven_ = str(_renderer.setRotation(_n));  
        else used_ = false;
      }
      
      if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    }
    return used_;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Typing in stuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  private void wordMaker(char _k) {
    if(wordMaker.charAt(0) == ' ') wordMaker = str(_k);
    else wordMaker = wordMaker + _k;
  }

  private void returnWord() {
    SegmentGroup _sg = groupManager.getSelectedGroup();
    if (_sg != null) _sg.setWord(wordMaker, -1);
    else groupManager.groupAddRenderer(wordMaker, rendererManager.getList().getFirst());
    wordMaker = " ";
    enterText = false;
  }


  // type in values of stuff
  private void numMaker(char _k) {
    if(numberMaker.charAt(0)==' ') numberMaker = str(_k);
    else numberMaker = numberMaker + _k;
    gui.setValueGiven(numberMaker);
  }

  private void returnNumber() {
    try {
      distributor(editKey, Integer.parseInt(numberMaker), true);
    }
    catch (Exception e){
      println("Bad number string");
    }
    numberMaker = " ";
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void resetInputFlag(){
    gotInputFlag = false;
  }

  public void setEditKey(char _k) {
    if (keyIsMapped(_k) && _k != '-' && _k != '=') {
      gui.setKeyString(getKeyString(_k));
      editKey = _k;
      numberMaker = "0";
      gui.setValueGiven("_");
    }
  }

  public void setCtrled(boolean _b){
    if(_b){
      ctrled = true;
      mouse.setOrigin();
    }
    else ctrled = false;
  }

  public boolean toggleEnterText(){
    enterText = !enterText;
    return enterText;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public boolean isCtrled(){
    return ctrled;
  }
  public boolean isShifted(){
    return shifted;
  }

  public boolean gotInput(){
    return gotInputFlag;
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */

// subclass for dedicated mouse hacks from architext?

/**
 * Manages the mouse input, the cursor movement and the clicks
 * <p>
 * 
 *
 */
class Mouse{
  // other mouse buttons than LEFT and RIGHT
  final int MIDDLE = 3;
  final int FOURTH_BUTTON = 0;

  // dependecy injection
  GroupManager groupManager;
  Keyboard keyboard;

  boolean mouseEnabled;
  boolean snapping;
  boolean snapped;  
  boolean fixedAngle;
  boolean fixedLength;
  boolean invertMouse;
  boolean grid;
  int lineLenght = 50;
  int gridSize = 64;

  //mouse crosshair stuff
  PVector position;
  PVector mousePos;
  PVector previousPosition;
  PVector mouseOrigin;

/**
 * Constructor, receives references to the groupManager and keyboard instances. This is for operational logic.
 * inits default values
 * @param GroupManager dependency injection
 * @param Keyboard dependency injection
 */

  public Mouse(){

    // init vectors
  	position = new PVector(0, 0);
    mousePos = new PVector(0, 0);
    previousPosition = new PVector(0, 0);
    mouseOrigin = new PVector(0,0);

    // init booleans
    mouseEnabled = true;
    snapping = true;
    snapped = false;
    fixedLength = false;
    fixedAngle = false;
    invertMouse = false;
  }

  public void inject(GroupManager _gm, Keyboard _kb){
    groupManager = _gm;
    keyboard = _kb;
  }

/**
 * Handles mouse button press. Buttons are
 *
 * @param int mouseButton
 */
  public void press(int mb) { // perhaps move to GroupManager
    if (groupManager.isFocused()) {
      if (mb == LEFT || mb == MIDDLE) previousPosition = position.get();
      else if (mb == RIGHT) previousPosition = groupManager.getPreviousPosition();
      groupManager.getSelectedGroup().mouseInput(mb, position);
      if (mb == MIDDLE && fixedLength) previousPosition = mousePos.get();
    }
    else if (mb == FOURTH_BUTTON) groupManager.newItem();
  }

/**
 * Simulate mouse actions!
 *
 * @param int mouseButton
 * @param PVector position
 */
  public void fakeMouse(int mb, PVector p) { 
    position = p.get();
    //mousePress(mb);
  }

/**
 * Handles mouse movements
 *
 * @param int X axis (mouseX)
 * @param int Y axis (mouseY)
 */
  public void move(int _x, int _y) {  
    mousePos.set(_x, _y);
    if (mouseEnabled) { 
      if(invertMouse) _x = abs(width - _x); 
      if (grid) position = gridMouse(mousePos, gridSize);
      else if (fixedLength) position = constrainMouse(mousePos, previousPosition, lineLenght);
      else if (keyboard.isCtrled()) position = featherMouse(mousePos, mouseOrigin, 0.2f);

      else if (snapping) position = snapMouse(mousePos);
      else position = mousePos.get();
    }
    //gui.resetTimeOut();
  }

/**
 * Handles mouse dragging, currently works with the fixedLength mode to draw curve approximations.
 *
 * @param int mouseButton
 * @param int X axis (mouseX)
 * @param int Y axis (mouseY)
 */
  public void drag(int b, int x, int y) {
    if (fixedLength) {
      move(x, y);
      if (previousPosition.dist(position) < previousPosition.dist(mousePos)) press(b);
    }
  }


/**
 * Scroll wheel input, currently unused, oooooh possibilities :)
 * 
 * @param int positive or negative value depending on direction
 */
  public void wheeled(int n) {
    //println(n);
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Methods to modify the mouse movement
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Snaps to the nearest intersection of a grid
 *
 * @param PVector of mouse position
 * @param int size of grid
 * @return PVector of nearest intersection to position provided
 */  
  public PVector gridMouse(PVector _pos, int _grid){
    return new PVector(round(_pos.x/_grid)*_grid, round(_pos.y/_grid)*_grid);
  }

/**
 * constrain mouse to fixed length and optionaly at an angle of 60deg
 * <p>
 * This is usefull when aproximating curves, all segments will be of same length. 
 * Constraining angle allows to create fun geometry, for VJ like visuals
 *
 * @param PVector of mouse position
 * @param PVector of the previous place clicked
 * @return PVector constrained to length and possibly angle
 */  
  public PVector constrainMouse(PVector _pos, PVector _prev, int _len){
    
    float ang = PVector.sub(_prev, _pos).heading()+PI;
    if (fixedAngle) ang = radians(PApplet.parseInt(degrees(ang)/30)*30);
    return new PVector((cos(ang)*_len)+_prev.x, (sin(ang)*_len)+_prev.y, 0);
  }

/**
 * Feather mouse for added accuracy, happens when ctrl is held
 *
 * @param PVector of mouse position
 * @param PVector of where the mouse when ctrl was pressed.
 * @return PVector feathered from origin
 */  
  public PVector featherMouse(PVector _pos, PVector _origin, float _sensitivity){
    PVector fthr = PVector.mult(PVector.sub(_pos, _origin), _sensitivity);
    return PVector.add(_origin, fthr);
  }


/**
 * Snap to other vertices! Toggles the snapped boolean
 *
 * @param PVector of mouse position
 * @return PVector of snapped location, or if it did not snap, the position provided
 */  
  public PVector snapMouse(PVector _pos){
    PVector snap_ = groupManager.snap(_pos);
    if(snap_ == _pos) snapped = false;
    else snapped = true;
    return snap_;
  }


/**
 * Move the cursor around with arrow keys, to a greater amount if shift is pressed.
 *
 */  
  private void positionUp() {
    if (keyboard.isShifted()) position.y -= 10;
    else position.y--;
    position.y=position.y%width;
  }

  private void positionDown() {
    if (keyboard.isShifted()) position.y += 10;
    else position.y++;
    if (position.y<0) position.y=height;
  }

  private void positionLeft() {
    if (keyboard.isShifted()) position.x -= 10;
    else position.x--;
    if (position.x<0) position.x=width;
  }

  private void positionRight() {
    if (keyboard.isShifted()) position.x += 10;
    else position.x++;
    position.x=position.x%height;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void setOrigin(){
    mouseOrigin = mousePos.get();
  }

  public boolean toggleInvertMouse(){
    invertMouse = !invertMouse;
    return invertMouse;
  }

  public boolean toggleFixedLength(){
    fixedLength = !fixedLength;
    return fixedLength;
  }

  public int setLineLenght(int v) {
    lineLenght = numTweaker(v, lineLenght);
    return lineLenght;
  }

  public boolean toggleSnapping(){
    snapping = !snapping;
    return snapping;
  }

  public boolean toggleFixedAngle(){
    fixedAngle = !fixedAngle;
    return fixedAngle;
  }
  //Set the size of grid and generate a PImage of the grid.
  public int setGridSize(int _v) {
    if(_v >= 10 || _v==-1 || _v==-2){
      gridSize = numTweaker(_v, gridSize);
    }
    return gridSize;
  }
  private boolean toggleGrid() {
    grid = !grid;   
    return grid;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public int getGridSize(){
    return gridSize;
  }

  public boolean useGrid(){
    return grid;
  }

  public PVector getPosition(){
    return position;
  }

  public boolean isSnapped(){
    return snapped;
  }

}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * RenderList is a class that contains renderer tags (capital chars)
 * <p>
 * Add and remove renderers
 * </p>
 *
 * @see Renderer
 */

class RenderList{
  ArrayList<CharObject> tags;
  int tagsCount = 0;

/**
 * Create an new RenderList
 */
	public RenderList(){
		tags = new ArrayList();
	}


/**
 * Toggle a renderer tag from the list
 * @param  renderer tag char (capital letter)
 */
  public void toggle(char _tag) {
    if(has(_tag)){
      for(int i = 0; i < tagsCount; i++){
        if(tags.get(i).get() == _tag){
          tags.remove(i);
          tagsCount--;
        }
      }
    }
    else {
      tags.add(new CharObject(_tag));
      tagsCount++;
    }
  }


/**
 * Check if list has tag
 * @param  renderer tag char (capital letter)
 */
  public boolean has(char c){
  	if(tagsCount > 0){
      for(int i = 0; i < tagsCount; i++){
        if(tags.get(i).get() == c){
          return true;
        }
      }
    }
    return false;
  }

/**
 * Clear the list
 */
  public void clear(){
  	tags.clear();
    tagsCount = 0;
  }

/**
 * Returns a string of the list
 * @return string
 */
  public final String getString(){
  	String s = " ";
  	if(tagsCount > 0){
      for(int i = 0; i < tagsCount; i++){
        s+= tags.get(i).get();
      }
    }
    return s;
  }
  
/**
 * Returns first tag
 * @return char
 */
  public final char getFirst(){
    if(tagsCount > 0) return tags.get(0).get();
    else return '_';
  }
}



/**
 * A char class to use chars in arrayLists
 * @see RenderList
 */
class CharObject{
	char chr;

	public CharObject(char _c){
		chr = _c;
	}

  public void set(char _c){
    chr = _c;
  }

	public char get(){
		return chr;
	}
}


/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Renderer is a processing class that renders animation to a SegmentGroup.
 * <p>
 * All drawing happens here.
 * </p>
 *
 * @see SegmentGroup
 */

class Renderer {
	
  // a capital letter to represent the decorator
  final char ID;
  Stylist style;
  Brush brush;

  Clock clk;
  SegmentGroup group;
  ArrayList<Segment> segments;
  int segCount;
  
  boolean enableDeco;
  boolean looper;
  boolean launchit;
  boolean internalClock;
  boolean invertLerp;
  boolean updateGroupFlag;
  boolean fillit;

  float lerper;
  float vertAngle;

  int aniMode;
  int renderMode;
  int segmentMode;
  int lerpMode;
  int iterationMode;
  int shpMode;
  int rotationMode;
  int reverseMode;

  int polka;
  int probability;

  int divider;
  int increment;
  int randomer; // should be in verts? or group
  int largeRan;

  PGraphics canvas; // do image effects such as tint and shit.
  PVector center;
  boolean centered;

  //mul all the angles 
  float rotater;
  float modulator; // use for rotation speed and other.

  char letter;

/**
 * Create an new Renderer
 * @param  identification char
 */
  public Renderer(char _id){
  	ID = _id;
    init();
  }

/**
 * Initialises variables and childs
 */
  public void init(){
    style = new Stylist();
    brush = new Brush();
    segments = new ArrayList();
    clk = new Clock(2);
    letter = ID;
    
    center = new PVector(0,0);

    enableDeco = true;
    looper = true;
    launchit = false;
    internalClock = false;
    invertLerp = false;
    updateGroupFlag = false;
    fillit = false;

    segCount = 0;
    aniMode = 0;
    renderMode = 0;
    segmentMode = 0;
    lerpMode = 0;
    iterationMode = 0;
    shpMode = 0;
    rotationMode = 0;
    reverseMode = 0;

    polka = 5;
    probability = 100;

    divider = 2;
    increment = 0;
    randomer = 0;
    largeRan = 0;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Synchronising
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Pass the data needed to draw animations.
 * @param  PGraphics instance
 * @param  SegmentGroup
 */
  public void passData(PGraphics pg, SegmentGroup m) { // bro, do we even update now?
    canvas = pg; 
    group = m;
    segments = group.getSegments();
    segCount = segments.size();
    setScale(group.getScaler());

    if(updateGroupFlag) group.newRan();

    largeRan = PApplet.parseInt(group.getRan()*((PApplet.parseFloat(ID)/200)+1));
    randomer = largeRan%100; // was 20
    brush.setRandomer(randomer);
    style.setRandomer(randomer);
    //println("group : "+group.getID()+"  Decor : "+ID+ "  randomer : "+randomer);
  }
 
  private void clockWorks(float lrp, int inc){
    if(internalClock){
      clk.internal();
      inc = clk.getIncrement();
      lrp = clk.getLerper();
    }

    lerper = lerpStyle(lrp); 
    updateGroupFlag = false;
    if(inc != increment) {
      increment = inc;
      incrementThings();
      updateGroupFlag = true;
    }
  }

  private void incrementThings(){
    //println("group : "+group.getID()+"  Decor : "+ID+ "  randomer : "+randomer);
 
    if(!looper && launchit){
      enableDeco = true;
      launchit = false;
    }
    else if(!looper) enableDeco = false;
    else enableDeco = true;

    style.setIncrement(increment);
    brush.setIncrement(increment);
    reverseThings();
  }

  private void reverseThings(){
    switch(reverseMode){
      case 0:
        invertLerp = false;
        break;
      case 1:
        invertLerp = true;
        break;
      default :
        invertLerp = maybe(reverseMode);
        break;  
    }
  }

  // public void launch() {
  //   launchit = true;
  //   if(internalClock){
  //     clk.reset();
  //   }
  // }
  public void trigger(){
    
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     lerpStuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private float lerpStyle(float lrp){
    if(lrp > 1) lrp = 1;
    if(invertLerp) lrp = -lrp+1;
    switch (lerpMode){
      case 0:
        return lrp;
      case 1:
        return backAndForth(lrp);
      case 2:
        return pow(lrp, 2);
      case 3:
        return sin(lrp*PI);
      case 4:
        return random(2000)/2000;
    }
    return PApplet.parseFloat(lerpMode - 5)/10;
  }

  //there is a slight glitch here
  private float backAndForth(float l){
    if(increment % 2 == 0) return -l+1;
    else return l;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     iterations
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void iterator(){
    float origLerp = lerper;
    if( segCount > 0 && enableDeco && randomer < probability){
      switch (iterationMode){
        case 0:
          doDeco();  
          break;
        case 1:  
          manyThings();
          break;
        case 2:
          middler();
          break;
        case 3:
          twoFull();
          break;
      }
    }
    lerper = origLerp;
  }

  private void manyThings() {
    float ll = 0;
    float lerpol = lerper/polka;
    float pold = 1.0f/polka;
    for (int i = 0; i < polka; i++) {
      lerper = (pold*i)+lerpol;
      style.setIteration(i);
      doDeco();
    }
  }

  private void middler() {
    float oldLerp = lerper;
    lerper = (oldLerp/-2)+0.5f;
    doDeco(); 
    lerper = (oldLerp/2)+0.5f;
    doDeco();
    lerper = oldLerp;
  }

  private void twoFull(){
    doDeco();
    invertLerp = !invertLerp;
    doDeco();
    invertLerp = !invertLerp;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     rendermodes
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  private void doDeco() {
    style.apply(canvas);
    if(rotationMode != 0) rotater = lerper*TWO_PI*rotationMode;
    else rotater = 0;
    if (lerper <= 1 && lerper >= 0){// && segCount > 0 && enableDeco && randomer < probability){
      if(segments.get(0).isCentered()){
        center = segments.get(0).getCenter().get();
        centered = true;
      }
      else centered = false;
      if(renderMode < 4) vertPicker();
      else decorategroup();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Select and decorates segments
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 

  private void vertPicker(){
    switch (segmentMode){
      case 0:
        allSegments();
        break;
      case 1:
        sequentialSegments();
        break;
      case 2:
        alternateLerp();
        break;
      case 3:
        //vertChase();
        break;
      case 4:
        randomSegment();
        break;
    }
  }

  //Segment render style
  public void allSegments() {
    for (int i = 0; i < segCount; i++) {
      renderSegment(segments.get(i));
    }
  }

  public void randomSegment() {
    int i = largeRan % segCount;
    if (lerper <= 1) renderSegment(segments.get(i));
  }

  //one vert at a time
  private void sequentialSegments() {
    int v = increment%segCount;
    renderSegment(segments.get(v));
  }


  // private void vertChase(){
  //   int v = increment%segCount;
  //   renderSegment(segments.get(v));
  //   if(millis() % 200 == 1) increment++;
  //   println(increment);
  // }

  private void alternateLerp() {
    boolean bkp = invertLerp;
    for (int i = 0; i < segCount; i++) {
      renderSegment(segments.get(i));
      invertLerp = !invertLerp;
    }
    invertLerp = bkp;
  }

  // then go back to render modes to distribute further
  private void renderSegment(Segment _v){
    if(centered) _v.setSize(brush.getScaledSize());
    vertAngle = _v.getAngle(invertLerp);
    switch (renderMode){
      case 0:
        applyBrush(_v);
        break;
      case 1:
        edgeLight(_v);
        break;
      case 2:
        miscDec(_v);
        break;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Applying brush
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  


  public void applyBrush(Segment _v) {
    switch (aniMode) {
      case 0:
        putShape( _v.getPos(lerper), vertAngle);    
        break;
      case 1:
        spiralesk(_v);
        break;
      // case 2:
      //   wavy(_v);
      //   break;
    }
  }

  private void putShape(PVector _p, float _a){  
    PShape shape_; 
    if(brush.getShapeMode() < 5) {
      shape_ = brush.getShape();
      style.apply(shape_);
    }
    else shape_ = specialShapes(brush.getShapeMode());
    
    canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a + HALF_PI + rotater); 
    canvas.shape(shape_);
    canvas.popMatrix();
  }
  
  private void spiralesk(Segment _v){
    PVector pv = _v.getPos(lerper).get();
    pv = vecLerp(pv, _v.getCenter(), lerper).get();
    putShape(pv, vertAngle);
  }

  // special shapes that need to handle style differently
  private PShape specialShapes(int _s){
    switch(_s){
      case 5:
        return sprinkles();
    }
    return brush.getShape();
  }

  private PShape sprinkles(){
    PShape shape_;
    shape_ = createShape();
    shape_.beginShape(POINTS);
    
    PVector pos = new PVector(0,0);
    int sz = brush.getHalfSize();
    int ran = 0;
    int tenpol = polka * 10;
    style.apply(shape_);

    for(int i = 0; i < tenpol; i++){
      // pos = v.getPos(i/tenpol);
      // ran = int(random(100));
      // pos = vecLerp(pos, v.getCenter(), ran/100);
      pos.set(random(-sz, sz), random(-sz, sz));
      shape_.stroke(style.getStroke());
      shape_.vertex(pos.x, pos.y);
    }
    shape_.endShape();
    return shape_;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Applying lines
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  
  private void edgeLight(Segment _v){
    switch (aniMode){
      case 0:
        grow(_v);
        break;
      case 1:
        autoMap(_v);
        break;
      case 2:
        flashLine(_v);
        break;
      case 3:
        strobeLine(_v);
        break;
    }
  }

  private void liner(PVector _a, PVector _b){
    canvas.line(_a.x, _a.y, _b.x, _b.y);
  }

  private void autoMap(Segment v) {
    float l = lerper;// * v.getRanFLoat();
    if(l>1) l = 1;
    PVector a = vecLerp(v.getRanA(), v.getRegA(), l);
    PVector b = vecLerp(v.getRanB(), v.getRegB(), l);
    liner(a, b);
  }

  private void highLighter(Segment v) {
    if(invertLerp) liner(v.getRegB(), v.getRegPos(-lerper+1));
    else liner(v.getRegA(), v.getRegPos(lerper));
  }

  private void grow(Segment v){
    if(invertLerp) liner(v.getRegB(), v.getRegPos((lerper*-1)+1));
    else liner(v.getRegA(), v.getRegPos(lerper));
  }

  private void flashLine(Segment _v){
    if(random(polka) < 1) liner(_v.getRegA(), _v.getRegB());
    else {
      canvas.pushStyle();
      canvas.stroke(0);
      liner(_v.getRegA(), _v.getRegB());
      canvas.popStyle();
    }
  }

  private void strobeLine(Segment _v){
    if(maybe(polka)) liner(_v.getRegA(), _v.getRegB());
  }


  //BETA
  private void worms(Segment _v) {
    // if( lerper <= 1){
    //   canvas.stroke(colorizer(strokeMode));
    //   canvas.strokeWeight(strokeW);
    //   //vert to vert lines...
    //   PVector tmpA = new PVector(0,0,0);
    //   PVector tmpB = new PVector(0,0,0);
    //   for (int i = 0; i<segCount; i++) {
    //     tmpA = segments.get(i).getRegPos(lerper);
    //     if(lerper < 0.5){
    //       tmpB = segments.get(i).getRegA(); 
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //     else if(lerper >= 0.25 && lerper < 0.75){
    //       tmpB = segments.get(i).getRegPos(lerper - 0.25);
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //     else if(lerper >= 0.75){
    //       tmpB = segments.get(i).getRegB(); 
    //       vecLine(canvas, tmpA, tmpB);
    //     }
    //   }
    // }
  }





  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Other Vert decorations
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 


  public void miscDec(Segment vert) {
    switch (aniMode){
      case 0:
        writer(vert);  
        break;
      case 1:  
        elipser(vert);
        break;
    //else if (m == 11) sprinkles(vert);
    }
  }

  public void writer(Segment vert) {
    String werd = vert.getWord();
    int l = werd.length();
    PVector pos = new PVector(0,0,0);
    //setBrushes();
    canvas.textFont(font);
    canvas.textSize(brush.getScaledSize());
    char[] carr = vert.getWord().toCharArray();
    for(int i = 0; i < l; i++){
      pos = vert.getRegPos(-((float)i/(l+1) + 1.0f/(l+1))+1); //optimise!!
      canvas.pushMatrix();
      canvas.translate(pos.x, pos.y);
      canvas.rotate(vert.getAngle(invertLerp));
      canvas.translate(0,5);
      canvas.text(carr[i], 0, 0);
      canvas.popMatrix();
    }
  }

  public void elipser(Segment _v){
    PVector pA = _v.getA();
    PVector pos = _v.getRegPos(lerper);
    float diam = 2*pos.dist(pA);
    canvas.ellipse(pA.x, pA.y, diam, diam);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     All vert renderers
  ///////
  ///////
  ///////     All vert renderers
  ///////
  //////////////////////////////////////////////////////////////////////////////////// 

  public void decorategroup() {
    switch (renderMode){
      case 5:
        doFill();
        break;
      case 6:
        stringArt();
        break;
      case 7:
        //worms();
        break;
      }
  }

  private void doFill() {
    canvas.pushMatrix();
    
    PShape shpe = group.getShape();
    float lorp = 1-lerper;
    lorp*=lorp;
    PVector fp = segments.get(0).getRegA();
    PVector p = vecLerp(fp, center, -lorp+1);

    style.apply(shpe);

    //if(strokeMode != 0) shpe.setStrokeWeight(strokeW*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));

    canvas.translate(p.x, p.y);
    canvas.rotate(rotater);
    canvas.scale(lorp);
    canvas.translate(-fp.x, -fp.y);
    canvas.shapeMode(CORNER);
    
    canvas.shape(shpe);
    canvas.popMatrix();
  }

  // automatic string art
  // draws lines between points on segments
  private void stringArt() {
    int other = 0;
    float xA = 0;
    float yA = 0;
    float xB = 0;
    float yB = 0;
    for (int i = 0; i<segCount; i++) {
      other = (i + shpMode) % segCount;
      xA = segments.get(i).getRegPos(lerper).x;
      yA = segments.get(i).getRegPos(lerper).y;
      xB = segments.get(other).getRegPos(lerper).x;
      yB = segments.get(other).getRegPos(lerper).y;
      canvas.line(xA, yA, xB, yB);
    }  
  }

  // private void doFill() {
  //   canvas.pushMatrix();
    
  //   PShape shpe = group.getShape();
  //   float lorp = lerper*lerper;
  //   PVector fp = segments.get(0).getRegA();
  //   PVector p = vecLerp(fp, center, -lorp+1);

  //   shpBrush(shpe);
  //   if(strokeMode != 0) shpe.setStrokeWeight(strokeW*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));

  //   canvas.translate(p.x, p.y);
  //   canvas.scale(lorp);
  //   canvas.translate(-fp.x, -fp.y);
  //   canvas.shapeMode(CORNER);
  //   canvas.shape(shpe);
  //   canvas.popMatrix();
  // }





  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public final int getDivider() {
    return divider;
  }

  public final char getID(){
  	return ID;
  }

  public final PGraphics getCanvas(){
    return canvas;
  }
  // public final int getSize() {
  //   return sizer;
  // }

  // public final int getStrokeWeight() {
  //   return strokeW;
  // }

  // public final int getshpMode() {
  //   return shpMode;
  // }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////
  // decorator settings
  //////////////////////////////////////////
  public int setProbability(int v){
    probability = numTweaker(v, probability);
    if(probability > 100) probability = 100;
    return probability;
  }

  public int setIncrement(int i){
    increment = i;
    return increment;
  }

  public void setLerp(float f) {
    lerper = f;
  }

  public boolean enableDeco(boolean b) {
    enableDeco = b;
    return enableDeco;
  }

  public int setReverseMode(int _v){
    reverseMode = numTweaker(_v, reverseMode);
    return reverseMode;
  }

  public boolean toggleInternal(){
    internalClock = !internalClock;
    return internalClock;
  }

  public boolean toggleLoop(){
    looper = !looper;
    return looper;
  }

  public void setInternal(boolean _b){
    internalClock = _b;
  }

  public void setLooper(boolean _b){
    looper = _b;
  }
  public int setAniMode(int _v) {
    aniMode = numTweaker(_v, aniMode);
    return aniMode;
  }

  public int setRenderMode(int _v) {
    renderMode = numTweaker(_v, renderMode);
    return renderMode;
  }

  public int setSegmentMode(int _v){
    segmentMode = numTweaker(_v, segmentMode);
    return segmentMode;
  }

  public int setLerpMode(int v){
    lerpMode = numTweaker(v, lerpMode);
    return lerpMode;
  }

  public int setIterationMode(int _v){
    println(iterationMode);
    iterationMode = numTweaker(_v, iterationMode);
    return iterationMode;
  }

  public int setPolka(int _v) {
    polka = numTweaker(_v, polka);
    return polka;
  }

  public int setdivider(int _v) {
    divider = numTweaker(_v, divider);
    divider %= 17;
    clk.setDiv(divider);
    return divider;
  }

  public int setTempo(int n){
    clk.setTempo(numTweaker(n, clk.getTempo()));
    return clk.getTempo();
  }

  public int setRotation(int _v){
    rotationMode = numTweaker(_v, rotationMode);
    return rotationMode;
  }
  //////////////////////////////////////////
  // pass style settings to stylist
  //////////////////////////////////////////
  public int setStrokeMode(int _v) {
    return style.setStrokeMode(_v);
  }

  public int setFillMode(int _v) {
    return style.setFillMode(_v);
  }

  public int setStrokeWeight(int _v) {
    return style.setStrokeWeight(_v); 
  }

  public int setAlpha(int _v){
    return style.setAlpha(_v);
  }

  //////////////////////////////////////////
  // pass shape settings
  //////////////////////////////////////////
  public int setSize(int _v) {
    return brush.setSize(_v);
  }

  public void setScale(float _s){
    brush.setScale(_s);
  }

  public int setShapeMode(int _v) {
    shpMode = brush.setShapeMode(_v);
    return shpMode;
  }

  public void setCustomShape(PShape _p){
    println("derp");
    brush.setCustomShape(_p);
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * Manage all the renderers
 *
 */
class RendererManager{
	//selects renderers to control
  RenderList renderList;

  Synchroniser sync;

  //enable or disable all the renderers
  boolean allLoop = true;

  //renderers
  ArrayList<Renderer> renderers;
  int rendererCount = 24;

  //graphics buffers
  PGraphics canvas;

  //draw a solid or transparent 
  boolean trails;
  int trailmix = 20;


  public RendererManager(){
    sync = new Synchroniser();
  	renderList = new RenderList();
    canvas = createGraphics(width, height);
    canvas.smooth(0);

    ellipseMode(CENTER);

    trails = false;
  	init();
  }

  private void init() {
    renderers = new ArrayList();
    for (int i = 0; i < rendererCount; i++) {
      renderers.add(new Renderer(PApplet.parseChar(65+i)));
    }
  }

  private void alphaBG(PGraphics _pg) {
    _pg.fill(0, 0, 0, trailmix);
    _pg.stroke(0, 0, 0, trailmix);
    _pg.rect(0, 0, width, height);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  
  public void trigger(char _c){
    renderers.get(charIndex(_c)).trigger();
  }

  public void focusAll() {
    renderList.clear();
    for (int i = 0; i < rendererCount; i++) {
      renderList.toggle(renderers.get(i).getID());
    }
  }

  public int charIndex(char c){
    int ind = 0;
    if(c >= 65) ind = PApplet.parseInt(c)-65;
    return ind % rendererCount;
  }

  // new effects here for nuance!
  // such as one groups renderer
  // X number of groups
  // left to right things
  public void update(ArrayList<SegmentGroup> _sgarray) {
    float lrp = 0;
    int rndr = 0;
    int dv = 0;
    int inc = 0;
    RenderList fl;
    sync.update();
    canvas.beginDraw();
    if(trails) alphaBG(canvas);
    else canvas.clear();   

    for (int j = 0; j < rendererCount; j++) {
      dv = renderers.get(j).getDivider();
      lrp = sync.clocks.get(dv).getLerper();
      inc = sync.clocks.get(dv).getIncrement();
      renderers.get(j).clockWorks(lrp, inc);
    }
    for(SegmentGroup sg : _sgarray){
      renderGroup(sg);
    }
    
    canvas.endDraw();
  }


  public void renderGroup(SegmentGroup _sg){
    RenderList rList = _sg.getRenderList();
    for (int j = 0; j < rendererCount; j++) {
      if (rList.has(renderers.get(j).getID())) {
        renderers.get(j).passData(canvas, _sg);
        renderers.get(j).iterator();
      }
    }
  }
  //add some auto modes!

  private void triggerGroups(char k) {

  }
  
  // set a decorator's shape 
  private void setCustomShape(SegmentGroup _sg){
      //println("CustomShape with item : "+ n);
    char c_ = renderList.getFirst();
    if(c_ != '_'){
      renderers.get(charIndex(c_)).setCustomShape(cloneShape(_sg.getShape(), 1.0f, _sg.getCenter()));
    }
  }

  private int getRendererIndex(char c) {
    int i = PApplet.parseInt(c)-'A';
    if (i>=rendererCount) {
      println("Not a decorator");
      return 0;
    } else return i;
  }


  public final boolean isAdeco(char c){
    boolean ha = false;
    for (int i = 0; i < rendererCount; i++) {
      if(renderers.get(i).getID() == c) ha =true;
    }
    return ha;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public boolean toggleLooping() {
    allLoop = !allLoop;
    for (int i = 0; i<rendererCount; i++) {
      renderers.get(i).setLooper(allLoop);
    }
    return allLoop;
  }

  public boolean toggleTrails(){
    trails = !trails;
    return trails;
  }

  public int setTrails(int v){
    trailmix = numTweaker(v, trailmix);
    return trailmix;
  }

  public void unSelect(){
    renderList.clear();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean isFocused(){
    return renderList.getFirst() != '_';
  }

  public Renderer getRenderer(char _c){
    if(isAdeco(_c)) return renderers.get(charIndex(_c));
    else return null;
  }

  public ArrayList<Renderer> getSelected(){
    ArrayList<Renderer> selected_ = new ArrayList();
    for (int i = 0; i < rendererCount; i++) {
      if(renderList.has(renderers.get(i).getID())){
      selected_.add(renderers.get(i));
      }
    }
    return selected_;
  }
  
  public RenderList getList(){
    return renderList;
  }

  public PGraphics getCanvas(){
    return canvas;
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */



// a group of two points.

class Segment {
  PVector pointA;
  PVector pointB;

  PVector ranA;
  PVector ranB;
  
  PVector offA;
  PVector offB;
  
  Segment neighbA;
  Segment neighbB;

  PVector center;
  
  int sizer;
  
  float angle;
  float anglePI;
  boolean centered;

  float ranFloat;
  float growFloat;

  String werd;

  public Segment(PVector pA, PVector pB) {
    pointA = pA.get();
    pointB = pB.get();
    center = new PVector(0, 0, 0);
    newRan();
    offA = new PVector(0,0,0);
    offB = new PVector(0,0,0);
    sizer = 1;
    centered = false;
    updateAngle();
    werd = "haha!";
  }

  public void updateAngle(){
    angle = atan2(pointA.y-pointB.y, pointA.x-pointB.x);
    anglePI = angle + PI;
  }

  //for teh gui
  public void drawLine(PGraphics g) {
    g.stroke(170);
    g.strokeWeight(1);
    vecLine(g, pointA, pointB);
    if(centered) vecLine(g, offA, offB);
    g.stroke(200);
    g.strokeWeight(3);
    g.point(pointA.x, pointA.y);
    g.point(pointB.x, pointB.y);
  }

  public void simpleText(PGraphics pg, int s){
    int l = werd.length();
    PVector pos = new PVector(0,0,0);
    pg.pushStyle();
    pg.fill(255);
    pg.noStroke();
    pg.textFont(font);
    pg.textSize(s);
    char[] carr = werd.toCharArray();
    for(int i = 0; i < l; i++){
      pos = getRegPos(-((float)i/(l+1) + 1.0f/(l+1))+1);
      pg.pushMatrix();
      pg.translate(pos.x, pos.y);
      pg.rotate(angle);
      pg.translate(0,5);
      pg.text(carr[i], 0, 0);
      pg.popMatrix();
    }
    pg.popStyle();
  }




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void newRan(){
    ranA = new PVector(pointA.x+random(-100, 100), pointA.y+random(-100, 100), 0);
    ranB = new PVector(pointB.x+random(-100, 100), pointB.y+random(-100, 100), 0);
    ranFloat = 1+random(50)/100.0f;
  }

  public void setNeighbors(Segment a, Segment b){
    neighbA = a;
    neighbB = b;
  }

  private void findOffset() {
    offA = inset(pointA, neighbA.getRegA(), pointB, center, sizer);
    offB = inset(pointB, pointA, neighbB.getRegB(), center, sizer);
  }

  public void setPointA(PVector p){
    pointA = p.get();
    
  }

  public void setPointB(PVector p){
    pointB = p.get();
    updateAngle();
  }

  public void setCenter(PVector c) {
    centered = true;
    sizer = 0;
    center = c.get();
  }

  public void unCenter(){
    centered = false;
  }

  public void setSize(int s){
    if(s != sizer){ 
      sizer = s;
      findOffset();
    }
  }

  public void setWord(String w){
    werd = w;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final PVector getPos(float l) {
    if (centered) return getOffPos(l);
    else return getRegPos(l);
  }

  public final PVector getOffPos(float l){
    return vecLerp(offA, offB, l);
  }

  public final PVector getRegPos(float l){
    return vecLerp(pointA, pointB, l);
  }

  // return centered if centered  
  public final PVector getA() {
    if(centered) return offA;
    else return pointA;
  }

  public final PVector getB() {
    if(centered) return offB;
    else return pointB;
  }

  //get offset pos from predetermined angle
  //add a recentOffA with a recent sizer
  public final PVector getOffA() {
    return offA;
  }

  public final PVector getOffB() {
    return offB;
  }
  //original points
  public final PVector getRegA(){
    return pointA;
  }

  public final PVector getRegB(){
    return pointB;
  }

  //random pos
  public final PVector getRanA() {
    return ranA;
  }
  
  public final PVector getRanB() {
    return ranB;
  }

  // other stuff
  public final boolean isCentered(){
    return centered;
  }

  public final float getAngle(boolean inv) {
    if(inv) return anglePI;
    return angle;
  }

  public final float getRanFloat(){
    return ranFloat;
  }

  public final float getLength() {
    return dist(pointA.x, pointA.y, pointB.x, pointB.y);
  }

  public final PVector getCenter() {
    return center;
  }

  public final String getWord(){
    return werd;
  }
}

/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */



/**
 * SegmentGroup is an arrayList of Segment with one center point
 * <p>
 * A group of segments that can have a center, renderer tags, a brush size scalar and a random number.
 * </p>
 *
 * @see Renderer
 */

class SegmentGroup {
  final int ID;
  float sizeScaler = 1.0f;
  int sizer = 10;
  int randomNum = 0;
  PShape itemShape;

  ArrayList<Segment> segments;
  int segCount = 0;
  RenderList renderList;
  PVector center;
  PVector placeA;
  boolean firstPoint;
  boolean seperated;

  boolean centered;
  boolean centerPutting;

  boolean launchit = false;
  boolean incremented = false;

  int snapVal = 10;

/**
 * Create an new SegmentGroup
 * @param  identification interger
 */
  public SegmentGroup(int _id) {
    ID = _id;
    init();
  }


/**
 * Initialises variables, can be used to reset a group.
 */
  public void init(){
    segments = new ArrayList();
    renderList = new RenderList();
    placeA = new PVector(-10, -10, -10);
    center = new PVector(-10, -10, -10);
    firstPoint = true;
    centered = false;
    centerPutting = false;
    seperated = false;
    generateShape();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Management, Segment creation and such
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void startSegment(PVector p) {
    if(firstPoint) center = p.get();
    placeA = p.get();
    firstPoint = false;
  }

  private void endSegment(PVector p) {
    segments.add(new Segment(placeA, p));
    segCount++;
    placeA = p.get();
    seperated = false;
    setNeighbors();
    generateShape();
  }

  private void breakSegment(PVector p) {
    seperated = true;
    placeA = p.get();
  }

  private void nudgePoint(PVector p) {
    PVector np = placeA.get();
    if (!centerPutting) {
      np.add(p);
      if (segCount == 0 || seperated) breakSegment(np);
      else {
        undoSegment();
        endSegment(np);
      }
    } 
    else {
      np = center.get();
      np.add(p);
      placeCenter(np);
      centerPutting = true;
    }
    setNeighbors();
  }

  // needs to deal better with two points that are close together
  public void nudgeSnapped(PVector p, PVector m) {
    boolean nud = false;
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        if (m.dist(segments.get(i).getRegA()) < 0.001f ) segments.get(i).getRegA().add(p);
        if (m.dist(segments.get(i).getRegB()) < 0.001f ) segments.get(i).getRegB().add(p);
      }
      if (checkProx(m, center)) {
        center.add(p);
        placeCenter(center);
      }
      generateShape();
      setNeighbors();
    }
  }

  private void undoSegment() {
    if (segCount > 0) {
      float dst = placeA.dist(segments.get(segCount-1).pointB.get());
      if(dst > 0.001f){
        placeA = segments.get(segCount-1).pointB.get();
      }
      else {
        placeA = segments.get(segCount-1).pointA.get();
        segments.remove(segCount-1);
        segCount--;
      }
      setNeighbors();
    }
  }

  private void placeCenter(PVector c) {
    center = c.get();
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        segments.get(i).setCenter(center);
      }
      centered = true;
    }
    centerPutting = false;
  }

  private void unCenter() {
    centered = false;
    for (int i = 0; i< segCount; i++) {
      segments.get(i).unCenter();
    }
    centerPutting = false;
  }


  public PVector snapVerts(PVector m) {
    if (segCount>0) {
      if (checkProx(m, center)) return center;
      for (int i = 0; i<segCount; i++) {
        if (checkProx(m, segments.get(i).getRegA())) return segments.get(i).getRegA();
        if (checkProx(m, segments.get(i).getRegB())) return segments.get(i).getRegB();
      }
    }
    return new PVector(0, 0, 0);
  }

  public boolean checkProx(PVector g, PVector f) {
    //abs(g.x-f.x) < snapVal && abs(g.y-f.y) < snapVal
    if (g.dist(f) < snapVal) return true;
    else return false;
  } 


  private void setNeighbors() {
    int v1 = 0;
    int v2 = 0;
    if (segCount>0) {
      for (int i = 0; i<segCount; i++) {
        v1 = i-1;
        v2 = i+1;
        if (i==0) v1 = segCount-1; // maybe wrong
        if (i==segCount-1) v2 = 0;
        segments.get(i).setNeighbors(segments.get(v1), segments.get(v2));
      }
    }
  }

  private void generateShape() {
    itemShape = createShape();
    itemShape.beginShape();
    itemShape.textureMode(NORMAL);
    itemShape.strokeCap(ROUND); //strokeCap(SQUARE);
    itemShape.strokeJoin(ROUND);
    float _x = 0;
    float _y = 0;
    if(segCount!=0){
      for (int i = 0; i < segCount; i++) {
        _x = segments.get(i).getRegA().x;
        _y = segments.get(i).getRegA().y;
        itemShape.vertex(_x, _y, _x/width, _y/height);
      }
      _x = segments.get(0).getRegA().x;
      _y = segments.get(0).getRegA().y;
      itemShape.vertex(_x, _y, _x/width, _y/height);
    }
    else {
      itemShape.vertex(0,0);
      itemShape.vertex(0,0);
    }

    itemShape.endShape(CLOSE);//CLOSE dosent work...
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void mouseInput(int mb, PVector c) {
    if (mb == 37 && centerPutting) placeCenter(c);
    else if (mb == 39 && centerPutting) unCenter();
    else if (mb == 37 && firstPoint) startSegment(c); 
    else if (mb == 37 && !firstPoint) endSegment(c);
    else if (mb == 39) undoSegment();
    else if (mb == 3) breakSegment(c);
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     GUI
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void showLines(PGraphics g) {
    for (int i = 0; i<segCount; i++) {
      segments.get(i).drawLine(g);
    }
    // if(segCount!=0){
    //   itemShape.setFill(false);
    //   itemShape.setStroke(100);
    //   //itemShape.set
    //   g.shape(itemShape);
    // }
  }

  private void previewLine(PGraphics g, PVector c) {
    if (!firstPoint) {
      g.stroke(255);
      g.strokeWeight(3);
      g.line(placeA.x, placeA.y, c.x, c.y);
    }
  }

  public void showTag(PGraphics g) {
    PVector pos = centered ? center : placeA; 
    g.noStroke();
    g.fill(255);
    g.text(str(ID), pos.x - (16+PApplet.parseInt(ID>9)*6), pos.y+6);
    g.text(renderList.getString(), pos.x + 6, pos.y+6);
    g.noFill();
    g.stroke(255);
    g.strokeWeight(1);
    g.ellipse(pos.x, pos.y, 10, 10);
  }

  private void showText(PGraphics pg){
    for (int i = 0; i<segCount; i++) {
      segments.get(i).simpleText(g, PApplet.parseInt(sizeScaler*10));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void toggleRender(char c) {
    renderList.toggle(c);
  }

  public void setWord(String w, int v) {
    if (segCount >= 1 && v == -1) segments.get(segCount-1).setWord(w);
    else if (v<segCount) segments.get(v).setWord(w);
  } 

  public void newRan(){
    randomNum = (int)random(1000);
    for (int i = 0; i < segCount; i++) {
      segments.get(i).newRan();
    }
  }

  public boolean toggleCenterPutting(){
    centerPutting = !centerPutting;
    return centerPutting;
  }

  public int setScaler(int s){
    sizer = numTweaker(s, sizer); 
    sizeScaler = sizer/10.0f;
    return sizer;
  }

  public int setSnapVal(int s){
    snapVal = numTweaker(s, snapVal); 
    return snapVal;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final int getID(){
    return ID;
  }

  public final int getRan(){
    return randomNum;
  }
  public final PShape getShape(){
    return itemShape;
  }

  public final PVector getCenter(){
    return center;
  }

  public final RenderList getRenderList() {
    return renderList;
  }

  public final PVector getLastPoint() {
    if (segCount>0)  return segments.get(segCount-1).getRegA();
    else return new PVector(0, 0, 0);
  }

  public final float getScaler(){
    return sizeScaler;
  }

  // Segment accessors
  public Segment getSegment(int _index){
    return segments.get(_index % segCount);
  }
  
  // deprecate
  public final ArrayList getSegments() {
    return segments;
  }



}


/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


class Synchroniser{
	Clock clk;
  ArrayList<Clock> clocks;
  int clocksCnt = 17;



  // millis to render one frame
  int renderTime = 0;
  int lastRender = 0;
  
  // tapTempo
  int lastTap = 0;
  int lastTime = 0;
  FloatSmoother tapTimer;
  int tempo = 1500;

  FloatSmoother intervalTimer;
  float increment = 0.1f;
  float lerper = 0;
  // every time we fold over
  int cycleCount = 0;

	public Synchroniser(){
		initClocks();
    tapTimer = new FloatSmoother(5, 350);
    intervalTimer = new FloatSmoother(5, 34);
	}

	private void initClocks() {
    clocks =  new ArrayList();
    for (int i = 0; i < clocksCnt; i++) {
      clocks.add(new Clock(i+2));
    }
  }



  public void update() {
    // increment = intervalTimer.addF(float(millis()-lastRender))/tempo;
    // lastRender = millis();
    // lerper += increment;
    // if(lerper > 1.0){
    //   lerper = 0;
    //   cycleCount++;
    //   println("bomp " + renderTime);
    // }


    if (millis()-lastTime > tempo) {
      cycleCount++;
      lastTime = millis();
    }
    for (int i = 0; i < clocksCnt; i++) {
      clocks.get(i).update(cycleCount);
      //clocks.get(i).setLerper(lerper);
    }
  }

  //tap the tempo
  public void tap() {
    int elapsed = millis()-lastTap;
    lastTap = millis();
    if (elapsed> 100 && elapsed < 3000) {
      tempo = PApplet.parseInt(tapTimer.addF(elapsed));///2;
    }
  }

  public void setAllClockSpeeds(int s) {
    for (int i = 0; i < clocksCnt; i++) {
      clocks.get(i).setTempo(s);
    }
  }

  //adjust tempo by +- 100 millis
  public void nudgeTime(int t){
    println(lastTime);
    if(t==-2) lastTime -= 100;
    else if(t==-1) lastTime += 100;
  }
}
/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */



class FloatSmoother {
  boolean firstValue;
  FloatList flts;
  int smoothSize;

  public FloatSmoother(int s, float f){
    firstValue = true;
    smoothSize = s;
    flts = new FloatList();
    fillArray(f);
  }

  public float addF(float s){
    if(firstValue){
      firstValue = false;
      fillArray(s);
    } 
    flts.append(s);
    flts.remove(0);
    return arrayAverager();
  }

  private void fillArray(float f) {
    flts.clear();
    for(int i = 0; i < smoothSize; i++){
      flts.append(f);
    }
  }

  private float arrayAverager() {
    float sum = 0;
    for(int i = 0; i < smoothSize; i++){
      sum += flts.get(i);
    }
    return sum / smoothSize;
  }
}




public PVector vecLerp(PVector a, PVector b, float l){
  return new PVector(lerp(a.x, b.x, l), lerp(a.y, b.y, l), 0);
}

public PVector angleMove(PVector p, float a, float s){
  PVector out = new PVector(cos(a)*s, sin(a)*s, 0);
  out.add(p);
  return out; 
}

public PVector vectorMirror(PVector p){
  float newX = 0;
  if(p.x<width/2) newX = width-p.x;
  else newX = -(p.x-width/2)+width/2;
  return new PVector(newX, p.y, p.z);
}

public void vecLine(PGraphics p, PVector a, PVector b){
  p.line(a.x,a.y,b.x,b.y);
}

//4 am victory
// find angle with generic size? then offer offset by andgle and size?
public PVector inset(PVector p, PVector pA, PVector pB, PVector c, float d) {
  float angleA = (atan2(p.y-pA.y, p.x-pA.x));
  float angleB = (atan2(p.y-pB.y, p.x-pB.x));  
  float A = radianAbs(angleA); 
  float B = radianAbs(angleB); 
  float ang = abs(A-B)/2; //the shortest angle

  d = (d/2)/sin(ang);
  if (A<B) ang = (ang+angleA);
  else ang = (ang+angleB);

  PVector outA = new PVector(cos(ang)*d, sin(ang)*d, 0);
  PVector outB = new PVector(cos(ang+PI)*d, sin(ang+PI)*d, 0);
  outA.add(p);
  outB.add(p);

  PVector offset;
  if (c.dist(outA) < c.dist(outB)) return outA;
  else  return outB;  
}

public float radianAbs(float a) {
  while (a<0) {
    a+=TWO_PI;
  }
  while (a>TWO_PI) {
    a-=TWO_PI;
  } 
  return a;
}

public float fltMod(float f) {
  if (f>1) f-=1;
  else if (f<0) f+=1; 
  return f;
}

//wrap around
public static int wrap(int v, int n) {
  if (v<0) v = n;
  if (v>n) v = 0;
  return v;
}

public int numTweaker(int v, int n){
  if(v >= 0) return v;
  else if (v == -1) return n+1;
  else if (v == -2 && n-1>=0) return n-1;
  else return n;
}

public boolean maybe(int _p){
  return random(100) < _p;
}

/**
 * PShape clone/resize/center, the centerPosition will translate everything making it 0,0
 * @param  source PShape
 * @param  scalar float
 * @param  centerPoint PVector
 * @return new PShape
 */

public PShape cloneShape(PShape _source, float _scale, PVector _center){
  PShape shp = createShape();
  shp.beginShape();
  PVector tmp = new PVector(0,0);
  for(int i = 0; i < _source.getVertexCount(); i++){
    tmp = _source.getVertex(i);
    tmp.sub(_center);
    tmp.mult(_scale);
    shp.vertex(tmp.x, tmp.y);
  }
  shp.endShape();
  return shp;
}
// Abstraction for the decorator


// Colors, stroke weight and such
// have a global one to overide all!!
class Stylist {

  int strokeMode; // for stroke() 0 is noStroke()
  int fillMode; // for fill() 0 is noFill()
  int strokeWidth;
  int alphaValue; // maybe get implemented.
  int increment;
  int iteration;
  int randomer;
  float fluct; // fluctuating value

  //custom colors?
  int[] pallet = {
                    color(255,0,0),
                    color(0,255,0),
                    color(0,0,255),
                    color(0,255,255),
                    color(255,255,0),
                    color(255,22,255),
                    color(100,3,255),
                    color(255,0,255),
                  };

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Constructors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public Stylist(){
    strokeMode = 1;
    fillMode = 1;
    strokeWidth = 3;
    fluct = 0.0f;
    //alphaValue = 255;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Apply style to
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //apply settings to a shape
  public void apply(PShape _s){
    if (fillMode != 0){
      _s.setFill(true);
      _s.setFill(colorizer(fillMode));
    }
    else _s.setFill(false);
    if(strokeMode != 0) {
      _s.setStroke(colorizer(strokeMode));
      _s.setStrokeWeight(strokeWidth);//*(2*(-(lorp*lorp)+2)));   //(-lorp*lorp+1.3));
    }
    else _s.noStroke();
  }

  //apply settings to a canvas
  public void apply(PGraphics _g){
    
    if(fillMode != 0){
      _g.fill(colorizer(fillMode));
    }
    else _g.noFill();

    if(strokeMode != 0) {
      _g.stroke(colorizer(strokeMode));
      _g.strokeWeight(strokeWidth);
    }
    else _g.noStroke();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Color Selection
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  private int colorizer(int c) {
    switch (c){
      case 0:
        return color(0);
      case 1:
        return color(255, 255, 255);//, alphaValue);
      case 2:
        return color(255, 0, 0);//, alphaValue);
      case 3:
        return color(0, 255, 0);//, alphaValue);
      case 4:
        return color(0, 0, 255);//, alphaValue);
      case 5:
        return color(random(255));
      case 6:
        return color(random(255), random(255), random(255));//, alphaValue);
      case 7:
        return colorShift();
      case 8:
        return color(100);//lerpColor(colA, colB, lerper);
      case 9:
        return colorizer((increment%4)+1);
      case 10:
        return colorizer((randomer%4)+1);
      case 11:
        return shiftedColor();
      case 12:
        return color(0xffFFE203);//pallet[increment%7];
      case 13:
        return color(0);//pallet[c-20];
      case 14:
        return color(0);
      case 15:
        return colorizer(2+(iteration+increment)%4);
    }
    return color(255,0,255);
  }

  public int colorShift() {
    fluct += 0.0002f;
    fluct =  fltMod(fluct);
    return java.awt.Color.HSBtoRGB(fluct, 1.0f, 1.0f);//abs(sin(colFloat)), 1.0, 1.0);
  }

  // this would take a snapshot of the color
  public int shiftedColor() {
    return java.awt.Color.HSBtoRGB(fluct, 1.0f, 1.0f);//abs(sin(colFloat)), 1.0, 1.0);
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public int getStroke(){
    return colorizer(strokeMode);
  }

  public int getFill(){
    return colorizer(fillMode);
  }

  public int getStrokeWidth(){
    return strokeWidth;
  }
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  public void setIncrement(int _i){
    increment = _i;
  }

  public void setIteration(int _i){
    iteration = _i;
  }

  public void setRandomer(int _i){
    randomer = _i;
  }

  public int setStrokeMode(int _v) {
    strokeMode = numTweaker(_v, strokeMode);
    return strokeMode;
  }

  public int setFillMode(int _v) {
    fillMode = numTweaker(_v, fillMode);
    return fillMode;
  }

  public int setStrokeWeight(int _v) {
    strokeWidth = numTweaker(_v, strokeWidth);
    return strokeWidth; 
  }

  public int setAlpha(int _v){
    alphaValue = numTweaker(_v, alphaValue);
    return alphaValue;
  }
}



// Basic class to make shape subclasses
class Brush {

  // idealy would be static...
  int sizer;
  int scaledSize;
  int halfSize;
  int increment;
  int randomer;

  float scalar;
  int shpMode;

  PShape shp;
  PShape customShape;
  
  Brush(){
    sizer = 20;
    setScale(1.0f);
    //halfSize = sizer/2;
    scalar = 1.0f;
    shpMode = 0;
    updateShape();
    customShape = shp;
  }

  public void updateShape(){
    switch (shpMode) {
      case 0:
        pnt();
        break;
      case 1:
        perpLine();
        break;
      case 2:
        chevron();
        break;
      case 3:
        square();
        break;
      case 4:
        otherShape();
        break;
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Shape makers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  public void perpLine() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(halfSize, 0);
    shp.endShape();
  }

  public void chevron() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(0, halfSize);
    shp.vertex(halfSize, 0);
    shp.endShape();
  }

  public void square() {
    shp = createShape();
    shp.beginShape();
    shp.vertex(-halfSize, 0);
    shp.vertex(0, halfSize);
    shp.vertex(halfSize, 0);
    shp.vertex(0, -halfSize);
    shp.vertex(-halfSize, 0);
    shp.endShape(CLOSE);
  }

  public void pnt() {
    shp = createShape();
    shp.beginShape(POINTS);
    shp.vertex(0, 0);
    shp.endShape();
  }

  public void otherShape(){ //how to grab a mapitem??
    shp = cloneShape(customShape, PApplet.parseFloat(scaledSize)/100, new PVector(0,0));
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  

  public PShape getShape(){
    if(shpMode == 4) updateShape();
    return shp;
  }

  public int getShapeMode(){
    return shpMode;
  }

  public int getScaledSize(){
    return scaledSize;
  }

  public int getHalfSize(){
    return halfSize;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////  
  
  public void setIncrement(int _i){
    increment = _i;
  }

  public void setRandomer(int _i){
    randomer = _i;
  }

  public int setSize(int v) {
    sizer = numTweaker(v, sizer);
    halfSize = sizer/2;  
    updateShape(); //or scale shape
    return sizer;
  }

  // set the scale according to item's scalar
  public void setScale(float _s){
    scaledSize = PApplet.parseInt(sizer*_s);
    halfSize = scaledSize/2;
    updateShape(); //or scale shape
  }

  public int setShapeMode(int _v) {
    shpMode = numTweaker(_v, shpMode);
    updateShape();
    return shpMode;
  }

  public void setCustomShape(PShape _p){
    customShape = _p;
    updateShape();
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#000000", "--hide-stop", "alc_freeliner" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
