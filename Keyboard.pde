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
    "e    setAlpha",
    "f    setFill",
    "g    grid/size", 
    "h    easingMode",
    "i    repetitonMode", 
    "j    reverseMode",
    "k    internalClock",
    "l    loop mode",
    "n    newItem", 
    "o    rotation",
    "p    probability",
    "q    setStroke", 
    "r    repetitionCount", 
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
    ".    snap/Dist",
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
  EventManager eventManager;
  EventRenderer eventRenderer;
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
 * Receives references to the groupManager, eventManager, GUI and mouse.
 *
 * @param GroupManager reference
 * @param EventManager reference
 * @param EventRenderer reference
 * @param Gui reference
 * @param Mouse reference
 */
  public void inject(GroupManager _gm, EventManager _em, EventRenderer _er, Gui _gui, Mouse _m){
    groupManager = _gm;
    eventManager = _em;
    eventRenderer = _er;
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
      else if (ctrled || alted) modCommands(int(k));
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
  public void processCAPS(char _c) {
    if(shifted){
      TemplateList tl = groupManager.getTemplateList();
      if(tl == null) tl = eventManager.getTemplateList();
      tl.toggle(eventManager.getTemplate(_c));
      gui.setTemplateString(tl.getTags());
    }
    else {
      eventManager.trigger(_c);
    }
  }


/**
 * The ESC key triggers this, it unselects segment groups / renderers, a second press will hid the gui.
 */
  private void unSelectThings(){
    if(!groupManager.isFocused() && !eventManager.isFocused()) gui.hide();
    else {
      eventManager.unSelect();
      groupManager.unSelect();
      gui.setTemplateString(" ");//eventManager.renderList.getString());
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
    else if(ctrled && k == 18) distributor(char(518), -3, false); // re init()
    else if(ctrled && k == 4) distributor(char(504), -3, false);  // set custom shape
  }

/**
 * Checks if the key is mapped by checking the keyMap to see if is defined there.
 *
 * @param char the key
 */
  boolean keyIsMapped(char k) {
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
  String getKeyString(char k) {
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
    eventManager.focusAll();
    gui.setTemplateString("*all*");
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
      SegmentGroup sg = groupManager.getSelectedGroup();
      TemplateList tl = null;
      if(sg != null){
        if(!segmentGroupDispatch(sg, _k, _n, _vg)) tl = sg.getTemplateList();
      }
      else tl = eventManager.getTemplateList();
      if(tl != null){
        ArrayList<TemplateEvent> templates = tl.getAll();
        if(templates != null)
          for(TemplateEvent te : templates)
            rendererDispatch(te, _k, _n, _vg);
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
        groupManager.newGroup(); 
        gui.updateReference();
      }
      //more ergonomic?
      // else if (_k == 'a') nudger(true, -1); //right
      // else if (_k == 'd') nudger(true, 1); //left
      // else if (_k == 's') nudger(false, 1); //down 
      // else if (_k == 'w') nudger(false, -1); //up

      else if (_k == 't') eventManager.sync.tap(); 
      else if (_k == 'g') valueGiven_ = str(mouse.toggleGrid());  
      else if (_k == 'y') valueGiven_ = str(eventRenderer.toggleTrails());
      else if (_k == ',') valueGiven_ = str(gui.toggleViewTags());
      else if (_k == '.') valueGiven_ = str(mouse.toggleSnapping());
      else if (_k == '/') valueGiven_ = str(gui.toggleViewLines()); 
      else if (_k == ';') valueGiven_ = str(gui.toggleViewPosition());
      else if (_k == '|') valueGiven_ = str(toggleEnterText()); 
      else if (_k == '-') distributor(editKey, -2, _vg); //decrease value
      else if (_k == '=') distributor(editKey, -1, _vg); //increase value
      else if (_k == ']') valueGiven_ = str(mouse.toggleFixedLength());
      else if (_k == '[') valueGiven_ = str(mouse.toggleFixedAngle());
      else if (_k == '!') valueGiven_ = str(eventManager.toggleLooping());
      else if (_k == 'm') mouse.press(3);  // 
      else if (_k == '@') groupManager.saveVertices();
      else if (_k == '#') groupManager.loadVertices();
      else used_ = false;
    }
    else {
      if (editKey == 'g') valueGiven_ = str(mouse.setGridSize(_n));
      else if (editKey == 't') eventManager.sync.nudgeTime(_n);
      else if (editKey == 'y') valueGiven_ = str(eventRenderer.setTrails(_n));
      else if (editKey == ']') valueGiven_ = str(mouse.setLineLenght(_n));
      else if (editKey == '.') valueGiven_ = str(groupManager.setSnapDist(_n));
      else used_ = false;
    }
    
    if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    return used_;
  }

  public boolean segmentGroupDispatch(SegmentGroup _sg, char _k, int _n, boolean _vg) {
    boolean used_ = true;
    String valueGiven_ = null;
    if(_k == 'c') valueGiven_ = str(_sg.toggleCenterPutting());
    else if(_k == 's') valueGiven_ = str(_sg.setBrushScaler(_n));
    else if(_k == '.') valueGiven_ = str(_sg.setSnapVal(_n));
    else used_ = false;
    if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
    return used_;
  }

  public boolean rendererDispatch(TemplateEvent _template, char _k, int _n, boolean _vg) {
    //println(_template.getID()+" "+_k+" ("+int(_k)+") "+n);
    boolean used_ = true;
    
    if(_template != null){
      String valueGiven_ = null;
      if(_n == -3){
        if (_k == 'l') return false;//valueGiven_ = str(_template.toggleLoop());
        else if (_k == 'k') return false;//valueGiven_ = str(_template.toggleInternal());
        else if (int(_k) == 518) _template.reset();
        else if (int(_k) == 504) eventManager.setCustomShape(groupManager.getLastSelectedGroup());
        else used_ = false;
      }
      else {
        if (_k == 'a') valueGiven_ = str(_template.setAnimationMode(_n));
        else if (_k == 'f') valueGiven_ = str(_template.setFillMode(_n));
        else if (_k == 'e') valueGiven_ = str(_template.setAlpha(_n));
        else if (_k == 'r') valueGiven_ = str(_template.setRepetitionCount(_n));
        else if (_k == 'x') valueGiven_ = str(_template.setBeatDivider(_n));
        else if (_k == 'i') valueGiven_ = str(_template.setRepetitionMode(_n));
        else if (_k == 'j') valueGiven_ = str(_template.setReverseMode(_n));
        else if (_k == 'b') valueGiven_ = str(_template.setRenderMode(_n));
        else if (_k == 'p') valueGiven_ = str(_template.setProbability(_n));
        else if (_k == 'h') valueGiven_ = str(_template.setEasingMode(_n)); 
        else if (_k == 's') valueGiven_ = str(_template.setBrushSize(_n));   
        else if (_k == 'q') valueGiven_ = str(_template.setStrokeMode(_n));
        else if (_k == 'w') valueGiven_ = str(_template.setStrokeWidth(_n)); 
        else if (_k == 'd') valueGiven_ = str(_template.setBrushMode(_n));
        else if (_k == 'v') valueGiven_ = str(_template.setSegmentMode(_n));
        else if (_k == 'o') valueGiven_ = str(_template.setRotation(_n));  
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
    else if(wordMaker.length() > 0) {
      TemplateEvent _toadd = eventManager.getTemplate(wordMaker.charAt(0));
      TemplateEvent _tomatch = eventManager.getTemplateList().getIndex(0);
      groupManager.groupAddTemplateEvent(_toadd, _tomatch);
    }
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