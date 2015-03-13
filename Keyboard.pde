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
    "j    invertLerp",
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
 * Constructor, receives references to the groupManager and rendererManager instances for operational logic
 * inits default values
 * @param GroupManager dependency injection
 * @param RenderManager dependency injection
 */
  public Keyboard(GroupManager _gm, RendererManager _rm, Gui _gui, Mouse _m){
  	groupManager = _gm;
    rendererManager = _rm;
    gui = _gui;
    mouse = _m;
    shifted = false;
    ctrled = false;
    alted = false;
    enterText = false;
    gotInputFlag = false;
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
      if (k==10) returnWord();
      else if (k!=65535) wordMaker(k);
      println(wordMaker);
      gui.setValueGiven(wordMaker);
    }
    else {
      if (k >= 48 && k <= 57) numMaker(k);
      else if (k>=65 && k <= 90) processCAPS(k);
      else if (k==10) returnNumber();
      else if (ctrled || alted) modCommands(int(k));
      else{
        if(k != '-' && k != '=') setEditKey(k);
        distributor(k, -3, true);
      }
      gui.setKeyString(getKeyString(k));
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

  public void processRelease(char k, int kc) {
    if (kc==16) shifted = false;
    if (kc==17) ctrled = false;
    if (kc==18) alted = false;
  }

  public void processCAPS(char c) {
    //renderers.get(charIndex(c)).launch();
    if (groupManager.isFocused()) groupManager.getSelectedGroup().toggleRender(c);
    else {
      rendererManager.getList().toggle(c);
      gui.setRenderString(rendererManager.renderList.getString());
    }
    //else triggerGroups(c);
  }

  private void unSelectThings(){
    if(!groupManager.isFocused() && rendererManager.renderList.getFirst() == '_') gui.hide();
    else {
      rendererManager.unSelect();
      groupManager.unSelect();
    }
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Interpretation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //for some reason if you are holding ctrl or alt you get other keycodes
  public void modCommands(int k){
    if(ctrled || alted) println(k);
    if (ctrled && k == 1) focusAll(); // a
    else if(ctrled && k == 9) gui.setValueGiven( str(mouse.toggleInvertMouse()) );
    else if(ctrled && k == 18) distributor(char(518), -3, false); // re init()
    else if(ctrled && k == 4) distributor(char(504), -3, false);  // set custom shape
  }

  boolean keyIsMapped(char k) {
    for (int i = 0; i < keyMap.length; i++) {
      if (keyMap[i].charAt(0)==k) return true;
    }
    return false;
  }

  String getKeyString(char k) {
    for (int i = 0; i <keyMap.length;i++) {
      if (keyMap[i].charAt(0)==k) return keyMap[i];
    }
    return "not mapped?";
  }

  private void focusAll(){
    groupManager.unSelect();
    rendererManager.focusAll();
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

  public void distributor(char k, int n, boolean vg){
    if (!localDispatch(k, n, vg)){
      if (groupManager.isFocused()){
        if(!segmentGroupDispatch(groupManager.getSelectedGroup(), k, n, vg)){ // check if mapped to a segmentGroup
          char d = groupManager.getSelectedGroup().getRenderList().getFirst();
          //println(d+"  "+getSelectedGroup());
          decoratorDispatch(rendererManager.getRenderer(d), k, n, vg);
        }
      }
      else { 
        ArrayList<Renderer> selected_ = rendererManager.getSelected();
        for (int i = 0; i < selected_.size(); i++) {
          //if(renderList.has(renderers.get(i).getID())){
            decoratorDispatch(selected_.get(i), k, n, vg);
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

  public boolean localDispatch(char k, int n, boolean vg) {
    boolean used = true;
    String valueGiven_ = "_";
    if(n == -3){
      if (k == 'n'){
        groupManager.newItem(); 
        gui.updateReference();
      }
      //more ergonomic?
      // else if (k == 'a') nudger(true, -1); //right
      // else if (k == 'd') nudger(true, 1); //left
      // else if (k == 's') nudger(false, 1); //down 
      // else if (k == 'w') nudger(false, -1); //up

      else if (k == 't') rendererManager.sync.tap(); 
      else if (k == 'g') valueGiven_ = str(mouse.toggleGrid());  
      else if (k == 'y') valueGiven_ = str(rendererManager.toggleTrails());
      else if (k == ',') valueGiven_ = str(gui.toggleViewTags());
      else if (k == '.') valueGiven_ = str(mouse.toggleSnapping());
      else if (k == '/') valueGiven_ = str(gui.toggleViewLines()); 
      else if (k == ';') valueGiven_ = str(gui.toggleViewPosition());
      else if (k == '|') valueGiven_ = str(toggleEnterText()); 
      else if (k == '-') distributor(editKey, -2, vg); //decrease value
      else if (k == '=') distributor(editKey, -1, vg); //increase value
      else if (k == ']') valueGiven_ = str(mouse.toggleFixedLength());
      else if (k == '[') valueGiven_ = str(mouse.toggleFixedAngle());
      else if (k == '!') valueGiven_ = str(rendererManager.toggleLooping());
      else if (k == 'm') mouse.press(3);  // 
      else used = false;
    }
    else {
      if (editKey == 'g') valueGiven_ = str(mouse.setGridSize(n));
      else if (editKey == 't') rendererManager.sync.nudgeTime(n);
      else if (editKey == 'y') valueGiven_ = str(rendererManager.setTrails(n));
      else if (editKey == ']') valueGiven_ = str(mouse.setLineLenght(n));
      else used = false;
    }
    
    if(vg) gui.setValueGiven(valueGiven_);
    return used;
  }

  public boolean segmentGroupDispatch(SegmentGroup _sg, char k, int n, boolean vg) {
    boolean used = true;
    String valueGiven_ = "_";
    if(k == 'c') valueGiven_ = str(_sg.toggleCenterPutting());
    else if(k == 's') valueGiven_ = str(_sg.setScaler(n));
    else if(k == '.') valueGiven_ = str(_sg.setSnapVal(n));
    else used = false;
    if(vg) gui.setValueGiven(valueGiven_);
    return used;
  }

  public boolean decoratorDispatch(Renderer _renderer, char k, int n, boolean vg) {
    //println(_renderer.getID()+" "+k+" ("+int(k)+") "+n);
    boolean used = true;
    
    if(_renderer != null){
      String valueGiven_ = "_";
      if(n == -3){
        if (k == 'l') valueGiven_ = str(_renderer.toggleLoop());
        else if (k == 'k') valueGiven_ = str(_renderer.toggleInternal());
        else if (k == 'j') valueGiven_ = str(_renderer.toggleInvertLerp());
        else if (int(k) == 518) _renderer.init();
        else if (int(k) == 504) rendererManager.setCustomShape(groupManager.getLastSelectedGroup());
        else used = false;
      }
      else {
        if (k == 'a') valueGiven_ = str(_renderer.setAniMode(n));
        else if (k == 'f') valueGiven_ = str(_renderer.setFillMode(n));
        else if (k == 'r') valueGiven_ = str(_renderer.setPolka(n));
        else if (k == 'x') valueGiven_ = str(_renderer.setdivider(n));
        else if (k == 'i') valueGiven_ = str(_renderer.setIterationMode(n));
        else if (k == 'b') valueGiven_ = str(_renderer.setRenderMode(n));
        else if (k == 'p') valueGiven_ = str(_renderer.setProbability(n));
        else if (k == 'h') valueGiven_ = str(_renderer.setLerpMode(n)); 
        else if (k == 'u') valueGiven_ = str(_renderer.setTempo(n));
        else if (k == 's') valueGiven_ = str(_renderer.setSize(n));   
        else if (k == 'q') valueGiven_ = str(_renderer.setStrokeMode(n));
        else if (k == 'w') valueGiven_ = str(_renderer.setStrokeWeight(n)); 
        else if (k == 'd') valueGiven_ = str(_renderer.setShapeMode(n));
        else if (k == 'v') valueGiven_ = str(_renderer.setSegmentMode(n));
        else if (k == 'o') valueGiven_ = str(_renderer.setRotation(n));  
        else used = false;
      }
      
      if(vg) gui.setValueGiven(valueGiven_);
    }
    return used;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Typing in stuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  private void wordMaker(char c) {
    if(wordMaker.charAt(0) == ' ') wordMaker = str(c);
    else wordMaker = wordMaker+c;
  }

  private void returnWord() {
    SegmentGroup _sg = groupManager.getSelectedGroup();
    if (_sg != null) _sg.setWord(wordMaker, -1);
    else groupManager.groupAddRenderer(wordMaker, rendererManager.getList().getFirst());
    wordMaker = " ";
    enterText = false;
  }


  // type in values of stuff
  private void numMaker(char num) {
    if(numberMaker.charAt(0)==' ') numberMaker = str(num);
    else numberMaker = numberMaker+num;
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

  public void setEditKey(char k) {
    if (keyIsMapped(k)) {
      gui.setKeyString(getKeyString(k));
      editKey = k;
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