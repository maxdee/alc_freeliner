/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// imports for detecting capslock state
import java.awt.Toolkit;
import java.awt.event.KeyEvent;

/**
 * Manage a keyboard
 * <p>
 * KEYCODES MAPPING
 * ESC unselect
 * CTRL feather mouse + (ctrl)...
 * UP DOWN LEFT RIGHT move snapped or previous point, SHIFT for faster
 * TAB tab through segmentGroups, SHIFT to reverse
 * BACKSPACE remove selected segment
 */
class Keyboard implements FreelinerConfig{

  // dependecy injection
  GroupManager groupManager;
  TemplateManager templateManager;
  TemplateRenderer templateRenderer;
  CommandProcessor processor;
  Gui gui;
  Mouse mouse;
  FreeLiner freeliner;

  //key pressed
  boolean shifted;
  boolean ctrled;
  boolean alted;

  // more keycodes
  final int CAPS_LOCK = 20;

  // flags
  boolean enterText;

  //setting selector
  char editKey = ' '; // dispatches number maker to various things such as size color
  char editKeyCopy = ' ';

  //user input int and string
  String numberMaker = "";
  String wordMaker = "";

  KeyMap keyMap;
  /**
   * Constructor inits default values
   */
  public Keyboard(){
    shifted = false;
    ctrled = false;
    alted = false;
    enterText = false;
  }

/**
 * Dependency injection
 * Receives references to the groupManager, templateManager, GUI and mouse.
 * @param Freeliner reference
 */
  public void inject(FreeLiner _fl){
    freeliner = _fl;
    groupManager = freeliner.getGroupManager();
    templateManager = freeliner.getTemplateManager();
    templateRenderer = freeliner.getTemplateRenderer();
    gui = freeliner.getGui();
    mouse = freeliner.getMouse();
    processor = freeliner.getCommandProcessor();
    keyMap = freeliner.keyMap;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Starts Here
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * receive and key and keycode from papplet.keyPressed();
   * @param int the keyCode
   */
  public void keyPressed(int _kc, char _k) {
    gui.resetTimeOut(); // was in update, but cant rely on got input due to ordering

    // if in text entry mode
    if(processKeyCodes(_kc)) return; // TAB SHIFT and friends
    else if (enterText) textEntry(_k);
    else if (_kc >= 48 && _kc <= 57) numMaker(_k); // grab numbers into the numberMaker
    else if (isCapsLock()) processCapslocked(_k);
    else {
      // prevent caps here.
      if (ctrled || alted) modCommands(_kc); // alternate mappings related to ctrl and alt combos
      else if (_k == '-') commandMaker(editKey, -2); //decrease value
      else if (_k == '=') commandMaker(editKey, -1); //increase value
      else if (_k >= 65 && _k <=90) templateSelection(_k);

      else if (_k == '|') gui.setValueGiven(str(toggleEnterText())); // acts localy
      else{
        setEditKey(_k);
        commandMaker(editKey, -3);
      }
    }
  }

  public void commandMaker(char _k, int _n){
    ParameterKey _pk = keyMap.getKey(_k);
    if(_pk == null) return;
    makeCMD(keyMap.getCMD(_k)+" "+_n);
    gui.setValueGiven(processor.getValueGiven());
  }

  public void makeCMD(String _cmd){
    // println("making cmd : "+_cmd);
    if(groupManager.isFocused()) processor.processCMD(_cmd.replaceAll("\\$", "\\$\\$"));
    else processor.processCMD(_cmd);
  }

  public void setEditKey(char _k) {
    ParameterKey _pk = keyMap.getKey(_k);
    if(_pk == null) return;
    gui.setKeyString(_k+" "+_pk.getName());
    editKey = _k;
    numberMaker = "0";
    gui.setValueGiven("_");
  }

  /**
   * Process key release, mostly affecting coded keys.
   * @param char the key
   * @param int the keyCode
   */
  public void keyReleased(int _kc, char _k) {
    if (_kc == 16) shifted = false;
    else if (_kc == 17) ctrled = false;
    else if (_kc == 18) alted = false;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Interpretation
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Process key when capslock is on.
   * Basicaly just triggers templates
   * @param char the capital key to process
   */
  public void processCapslocked(char _k) {
    // for some reason OSX had inconsistent caps handling...
    if(OSX && _k >= 97 && _k <=122) _k -= 32;
    // if its a letter, trigger the template.
    if(_k >= 65 && _k <=90) {
      makeCMD("tr "+_k);
      // select it?
    }
  }

  /**
   * Do template selection.
   * Basicaly just triggers templates
   * @param char the template tag to select
   */
  public void templateSelection(char _k){
    if(editKey == '>' && shifted) makeCMD("seq toggle "+_k);
    else if(groupManager.isFocused()){ //makeCMD("geom toggle "_k+" $");
      TemplateList _tl = groupManager.getTemplateList();
      if(_tl != null){
        _tl.toggle(templateManager.getTemplate(_k));
        groupManager.setReferenceGroupTemplateList(_tl); // set ref
        gui.setTemplateString(_tl.getTags());
      }
    }
    else {
      templateManager.getTemplateList().toggle(templateManager.getTemplate(_k));
      gui.setTemplateString(templateManager.getTemplateList().getTags());
    }
  }

  /**
   * Process keycode for keys like ENTER or ESC
   * @param int the keyCode
   */
  public boolean processKeyCodes(int kc) {
    if (kc == SHIFT) shifted = true;
    else if (kc == ENTER && enterText) returnWord();
    else if (kc == ENTER && !enterText) returnNumber(); // grab enter
    else if (kc == ESC || kc == 27) unSelectThings();
    else if (kc == CONTROL) setCtrled(true);
    else if (kc == ALT) setAlted(true);
    else if (kc == UP) groupManager.nudger(false, -1, shifted);
    else if (kc == DOWN) groupManager.nudger(false, 1, shifted);
    else if (kc == LEFT) groupManager.nudger(true, -1, shifted);
    else if (kc == RIGHT) groupManager.nudger(true, 1, shifted);
    //tab and shift tab throug groups
    else if (kc == TAB) groupManager.tabThrough(shifted);
    else if (kc == BACKSPACE) backspaceAction();
    else return false;
    return true;
    //else if (kc==32 && OSX) mouse.press(3); // for OSX people with no 3 button mouse.
  }

/**
 * Process a key differently if ctrl or alt is pressed.
 * @param int ascii value of the key
 */
  public void modCommands(int _kc){
    // println("Mod : "+_kc);
    ParameterKey _pk = keyMap.getKey(_kc);
    if(_pk == null) return;
    makeCMD(_pk.getCMD());
    gui.setKeyString(_pk.getName());
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

  // public void distributor(char _k, int _n){
  //   if (localDispatch(_k, _n)) return;
  //   SegmentGroup sg = groupManager.getSelectedGroup();
  //   TemplateList tl = null;
  //   if(sg != null){
  //     if(!segmentGroupDispatch(sg, _k, _n, _vg)) tl = sg.getTemplateList();
  //   }
  //   else tl = templateManager.getTemplateList();
  //
  //   if(tl != null){
  //     makeCMD("tw"+" "+tl.getTags()+" "+_k+" "+_n);
  //     if(_vg) gui.setValueGiven(processor.getValueGiven());
  //   }
  // }



  // PERHAPS MOVE
  // for the signature ***, char k, int n, boolean vg
  // char K is the editKey
  // int n, -3 is no number, -2 is decrease one, -1 is increase one and > 0 is value to set.
  // boolean vg is weather or not to update the value given. (osc?)

  public boolean localDispatch(char _k, int _n) {
    ParameterKey _pk = keyMap.getKey(_k);
    if(_pk == null) return false;
    makeCMD(keyMap.getCMD(_k)+' '+_n);
    gui.setValueGiven(processor.getValueGiven());
    return true;
  }

  /**
   * Distribute parameters for segmentGroups, such as place center, set scalar, or grab as cutom shape
   * @param SegmentGroup segmentGroup to affect
   * @param char editKey (like q for color)
   * @param int value to set
   * @param boolean display the valueGiven in the gui.
   * @return boolean if the key was used.
   */
   // #needswork put to command processor...
  // public boolean segmentGroupDispatch(SegmentGroup _sg, char _k, int _n) {
  //   boolean used_ = true;
  //   String valueGiven_ = null;
  //   if(_k == 'c') valueGiven_ = str(_sg.toggleCenterPutting());
  //   // else if(_k == 's') valueGiven_ = str(_sg.setBrushScaler(_n));
  //   // else if (int(_k) == 504) templateManager.setCustomShape(_sg);
  //   // else used_ = false;
  //   if(_vg && valueGiven_ != null) gui.setValueGiven(valueGiven_);
  //   return used_;
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions?
  ///////
  ////////////////////////////////////////////////////////////////////////////////////



  public void forceRelease(){
    shifted = false;
    ctrled = false;
    alted = false;
  }

  private void backspaceAction(){
    if (!enterText) groupManager.deleteSegment();
  }

  /**
   * The ESC key triggers this, it unselects segment groups / renderers, a second press will hid the gui.
   */
  private void unSelectThings(){
    if(!groupManager.isFocused() && !templateManager.isFocused()) gui.hide();
    else {
      templateManager.unSelect();
      groupManager.unSelect();
      gui.setTemplateString(" ");//templateManager.renderList.getString());
      groupManager.setReferenceGroupTemplateList(null);
    }
    // This should fix some bugs.
    alted = false;
    ctrled = false;
    shifted = false;
    editKey = ' ';
    enterText = false;
    wordMaker = "";
    gui.setKeyString("unselect");
    gui.setValueGiven(" ");
    gui.hideStuff();
    mouse.setGrid(false);
  }

  /**
   * CTRL-a selects all renderers as always.
   */
  private void focusAll(){
    groupManager.unSelect();
    templateManager.focusAll();
    gui.setTemplateString("*all*");
    wordMaker = "";
    enterText = false;
  }

  // /**
  //  * Toggle the recording state.
  //  * @return boolean value given
  //  */
  // public boolean toggleRecording(){
  //   boolean record = templateRenderer.toggleRecording();
  //   templateManager.getSynchroniser().setRecording(record);
  //   return record;
  // }

  /**
   * Save geometry and templates to default file.
   */
  public void saveStuff(){
    makeCMD("geom save");
    makeCMD("tp save");
  }

  /**
   * Load geometry and templates from default file.
   */
  public void loadStuff(){
    makeCMD("geom load");
    makeCMD("tp load");
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Typing in stuff
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void textEntry(char _k){
    if (_k!=65535) wordMaker(_k);
    println("Making word:  "+wordMaker);
    gui.setValueGiven(wordMaker);
  }
    /**
     * Toggle text entry
     * @return boolean valueGiven
     */
    public boolean toggleEnterText(){
      enterText = !enterText;
      if(enterText) setEditKey('|');
      return enterText;
    }

  /**
   * Add a char to the text entry
   * @param char to add
   */
  private void wordMaker(char _k) {
    if(wordMaker.length() < 1) wordMaker = str(_k);
    else wordMaker = wordMaker + str(_k);
  }

  // failz
  private String removeLetter(String _s){
     if(_s.length() > 1){
       return _s.substring(0, _s.length()-1 );
     }
     return "";
  }

  /**
   * Use the word being typed. Mostly setting a segments text.
   * Perhaps write commands for the sequencer?
   */
  private void returnWord() {
    if(groupManager.getSnappedSegment() != null)
        makeCMD("geom text"+" "+wordMaker);
    else {
      makeCMD(wordMaker);
      gui.setKeyString("sure");
      gui.setValueGiven(wordMaker);
    }
    wordMaker = "";
    enterText = false;
  }

  /**
   * Compose numbers with 0-9
   * @param char character to add to the pending number
   */
  private void numMaker(char _k) {
    if(numberMaker.length() < 1) numberMaker = str(_k);
    else numberMaker = numberMaker + str(_k);
    if(numberMaker.charAt(0) == '0' && numberMaker.length()>1) numberMaker = numberMaker.substring(1);
    gui.setValueGiven(numberMaker);
  }

  /**
   * Use freshly typed number.
   */
  private void returnNumber() {
    try {
      commandMaker(editKey, Integer.parseInt(numberMaker));
    }
    catch (Exception e){
      println("Bad number string");
    }
    numberMaker = "";
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Set the editKey
   * The edit key is very important, it selects what parameter to modify.
   * This also verbose the parameter in the GUI.
   * @param char the edit Key
   */
  // public void setEditKey(char _k, String[] _map) {
  //   if (keyIsMapped(_k, _map) && _k != '-' && _k != '=') {
  //     gui.setKeyString(_k+" "+getKeyString(_k, _map));
  //     editKey = _k;
  //     numberMaker = "0";
  //     gui.setValueGiven("_");
  //   }
  // }

  /**
   * Set if the ctrl key is pressed. Also sets the mousePointer origin to feather the mouse movement for non OSX.
   * @param boolean ctrl key status
   */
  public void setCtrled(boolean _b){
    if(_b){
      ctrled = true;
      if(!OSX) mouse.setOrigin();
    }
    else ctrled = false;
  }

  /**
   * Set if the alt key is pressed. Also sets the mousePointer origin to feather the mouse movement for OSX.
   * @param boolean alt key status
   */
  public void setAlted(boolean _b){
    if(_b){
      alted = true;
      if(OSX) mouse.setOrigin();
    }
    else alted = false;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  /**
   * Checks if the key is mapped by checking the keyMap to see if is defined there.
   * @param char the key
   */
  boolean keyIsMapped(char _k, String[] _map) {
    for (int i = 0; i < _map.length; i++) {
      if (_map[i].charAt(0) == _k) return true;
    }
    return false;
  }

  /**
   * Gets the string associated to the key from the keyMap
   *
   * @param char the key
   */
  String getKeyString(char _k, String[] _map) {
    for (int i = 0; i < _map.length; i++) {
      if (_map[i].charAt(0) == _k) return _map[i];
    }
    return "not mapped?";
  }

  /**
   * Is the ctrl key pressed? In OSX the ctrl key behavior is given to the alt key...
   * @return boolean valueGiven
   */
  public boolean isCtrled(){
    if(OSX) return alted;
    return ctrled;
  }

  public boolean isAlted(){
    return alted;
  }

  public boolean isShifted(){
    return shifted;
  }

  public boolean isCapsLock(){
    return Toolkit.getDefaultToolkit().getLockingKeyState(KeyEvent.VK_CAPS_LOCK);
  }

}
