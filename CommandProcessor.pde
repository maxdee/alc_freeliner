/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/** LIST OF COMMMANDS !!! () means optional arguments
 * for adressing templates use ABCD, or * for all, or $ for selected
 * /////////////////// Playing
 * tw AB q 3
 * tr AB (3 4 5)
 * tp color AB color || r g b a
 * tp copy (AB)
 * tp paste (AB)
 * tp add (AB)
 * tp reset (AB)
 * tp save (cooleffects.xml)
 * tp load (coolstuff.xml)
 * /////////////////// Sequencer
 * seq tap (offset)
 * seq edit -1,-2,step ????
 * seq clear (step || AB)
 * seq share A step
 * seq toggle A (step)
 * seq play 0,1
 * seq stop // redundent play 0|1
 * cmd rec  // 0|1
 * cmd play // 0|1
 * ///////////////////  Tools
 * tools lines 0|1|-3
 * tools tags 0|1|-3
 * tools capture // should be in post????
 * tools snap (dist)
 * tools grid (size)
 * tools ruler (length)
 * tools angle (angle)
 * ///////////////////  Geometry
 * geom txt word (2 3)
 * geom save (coolMap.xml)
 * geom load (coolMap.xml)
 * ///////////////////  Post processing
 * post trails (alpha)
 * post shader (coolfrag.glsl)
 * post mask (mask.png)
 * /////////////////// Information Accessors
 * fetch infoline
 * ///////////////////
 * raw kbd 'keyCode'
 */

/**
 * This distributes events to templates and stuff.
 */
class CommandProcessor implements FreelinerConfig{
  TemplateManager templateManager;
  TemplateRenderer templateRenderer;
  CanvasManager canvasManager;
  GroupManager groupManager;
  Synchroniser synchroniser;
  Sequencer sequencer;
  Mouse mouse;
  Keyboard keyboard;
  Gui gui;

  FreeLiner freeliner;
  // this string gets set to whatever value was set
  String valueGiven = "";

  ArrayList<String> commandQueue;

  /**
   * Constructor
   */
  public CommandProcessor(){
    commandQueue = new ArrayList();
  }

  /**
   * Dependency injection
   * @param FreeLiner
   */
  public void inject(FreeLiner _fl){
    freeliner = _fl;

    templateManager = _fl.getTemplateManager();
    synchroniser = templateManager.getSynchroniser();
    sequencer = templateManager.getSequencer();
    templateRenderer = _fl.getTemplateRenderer();
    canvasManager = _fl.getCanvasManager();
    groupManager = _fl.getGroupManager();
    mouse = _fl.getMouse();
    keyboard = _fl.getKeyboard();
    gui = _fl.getGui();
  }

  /**
   * Add a command to the queue.
   * The external gui uses this to avoid concurent modification exceptions.
   * @param String command
   */
  public void queueCMD(String _cmd){
    // println("adding to queue : "+_cmd);
    commandQueue.add(_cmd);
  }

  /**
   * Process commands that are in the queue.
   */
  public void processQueue(){
    if(commandQueue.size() == 0) return;
    ArrayList<String> _q = new ArrayList(commandQueue);
    for(String _cmd : _q) processCMD(_cmd);
    commandQueue.clear();
    //gui.setValueGiven(getValueGiven());
  }

  /**
   * First level of command parsing, redistributes according to first argument of command.
   * @param String command
   */
  public void processCMD(String _cmd){
    // if(record)
    processCMD(split(_cmd, ' '));
  }

  public void processCMD(String[] _args){
    // println(_args);
    boolean _used = false;
    if(_args.length == 0) return;
    if(_args[0].equals("tw")) _used = templateCMD(_args); // good
    else if(_args[0].equals("tr")) _used = templateCMD(_args); // need to check trigger group
    else if(_args[0].equals("tp")) _used = templateCMD(_args);
    else if(_args[0].equals("seq")) _used = sequencerCMD(_args);
    else if(_args[0].equals("post")) _used = postCMD(_args);
    else if(_args[0].equals("tools")) _used = toolsCMD(_args);
    else if(_args[0].equals("geom")) _used = geometryCMD(_args);
    else if(_args[0].equals("fetch")) _used = fetchCMD(_args);
    else if(_args[0].equals("raw")) _used = rawCMD(_args);

    if(!_used) println("CMD fail : "+join(_args, ' '));

  }

  // keyboard triggered commands go through here? might be able to hack a undo feature...
  public void processCmdStack(String _cmd){
    // add to stack
    processCMD(_cmd);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     fetchCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // * tools fetch infoline

  public boolean fetchCMD(String[] _args){
    if(_args.length < 2) return false;
    if(_args[1].equals("infoline")) freeliner.oscInfoLine();
    else if(_args[1].equals("infoweb")) freeliner.webInfoLine();
    else return false;
    return true;
  }

  public boolean rawCMD(String[] _args){
    if(_args.length < 3) return false;
    if(_args[1].equals("press")) keyboard.processKeyCode(stringInt(_args[2]));
    else if(_args[1].equals("release")) keyboard.processKeyCodeRelease(stringInt(_args[2]));

    else return false;
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     toolsCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // * tools lines
  // * tools tags
  // * tools capture
  // * tools snap (dist)
  // * tools grid (size)
  // * tools ruler (length)
  // * tools angle (angle)

  public boolean toolsCMD(String[] _args){
    if(_args.length < 2) return false;
    if(_args[1].equals("lines")) valueGiven = str(gui.toggleViewLines());
    else if(_args[1].equals("tags")) valueGiven = str(gui.toggleViewLines());
    //else if(_args[1].equals("rec")) valueGiven = str(canvasManager.toggleRecording());
    else if(_args[1].equals("snap")) return snapCMD(_args);
    else if(_args[1].equals("grid")) return gridCMD(_args);
    else if(_args[1].equals("ruler")) return rulerCMD(_args);
    else if(_args[1].equals("angle")) return angleCMD(_args);
    else return false;
    return true;
  }

  public boolean snapCMD(String[] _args){
    if(_args.length > 2){
      int _v = stringInt(_args[2]);
      if(_v == -3) valueGiven = str(mouse.toggleSnapping());
      else if(_v != -42) valueGiven = str(groupManager.setSnapDist(_v));
      return true;
    }
    return false;
  }

  public boolean gridCMD(String[] _args){
    if(_args.length > 2){
      int _v = stringInt(_args[2]);
      if(_v == -3) valueGiven = str(mouse.toggleGrid());
      else if(_v != -42) valueGiven = str(mouse.setGridSize(_v));
      return true;
    }
    return false;
  }

  public boolean rulerCMD(String[] _args){
    if(_args.length > 2){
      int _v = stringInt(_args[2]);
      if(_v == -3) valueGiven = str(mouse.toggleFixedLength());
      else if(_v != -42) valueGiven = str(mouse.setLineLenght(_v));
      return true;
    }
    return false;
  }

  public boolean angleCMD(String[] _args){
    if(_args.length > 2){
      int _v = stringInt(_args[2]);
      if(_v == -3) valueGiven = str(mouse.toggleFixedAngle());
      else if(_v != -42) valueGiven = str(mouse.setLineAngle(_v));
      return true;
    }
    return false;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     geomCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // * geom txt word (2 3)
  // * geom save (coolMap.xml)
  // * geom load (coolMap.xml)

  public boolean geometryCMD(String[] _args){
    if(_args.length < 2) return false;
    if(_args[1].equals("save")) return saveGeometryCMD(_args);
    else if(_args[1].equals("load")) return loadGeometryCMD(_args);
    else if(_args[1].equals("text")) return textCMD(_args);
    else return false;
  }

  public boolean saveGeometryCMD(String[] _args){
    if(_args.length == 2) groupManager.saveGroups();
    else if(_args.length == 3) groupManager.saveGroups(_args[2]);
    else return false;
    return true;
  }

  public boolean loadGeometryCMD(String[] _args){
    if(_args.length == 2) groupManager.loadGroups();
    else if(_args.length == 3) groupManager.loadGroups(_args[2]);
    else return false;
    return true;
  }

  public boolean textCMD(String[] _args){
    if(_args.length == 3){
      if(groupManager.getSnappedSegment() != null)
        groupManager.getSnappedSegment().setText(_args[2]);
      return true;
    }
    else if(_args.length == 5){
      SegmentGroup _sg = groupManager.getGroup(stringInt(_args[3]));
      if(_sg != null){
        Segment _seg = _sg.getSegment(stringInt(_args[4]));
        if(_seg != null) _seg.setText(_args[2]);
      }
      return true;
    }
    return false;
  }

  ///////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     postCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean postCMD(String[] _args){
    if(_args.length < 2) return false;
    else if(_args[1].equals("trails")) trailsCMD(_args);
    else if(_args[1].equals("mask")) maskCMD(_args);
    else if(_args[1].equals("shader")) shaderCMD(_args);
    else return false;
    return true;
  }

  // needs to be tested with file argument
  public boolean maskCMD(String[] _args){
    //if(_args.length < 2) return;
    //else if(_args[1].equals("mask")){
    if(_args.length > 2){
      canvasManager.loadMask(_args[2]);
    }
    //else valueGiven = str(canvasManager.toggleMask());
    else {
      canvasManager.generateMask();
    }
    return true;
  }

  public boolean trailsCMD(String[] _args){
    //if(_args.length < 2) return;
    //else if(_args[1].equals("trails")){
      if(_args.length > 2){
        int _v = stringInt(_args[2]);
        //if(_v == -3) valueGiven = str(canvasManager.toggleTrails());
        //else valueGiven = str(canvasManager.setTrails(_v));
        valueGiven = str(canvasManager.setTrails(_v));
        return true;
      }
      return false;
    //}
  }

  // needs to be tested with file argument
  public boolean shaderCMD(String[]  _args){
    if(_args.length > 2){
      int _v = stringInt(_args[2]);
      if(_args.length > 3){
        float _f = stringFloat(_args[3]);
        canvasManager.setUniforms(_v, _f);
      }
      else canvasManager.loadShader(_v);
      return true;
    }
    return false;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     sequencerCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // * seq tap
  // * seq edit -1,-2,step
  // * seq clear (step || AB)
  // * seq toggle A (step)

  public boolean sequencerCMD(String[] _args){
    //if(_args.length < 3) return;
    if(_args.length < 2) return false;
    else if(_args[1].equals("tap")) synchroniser.tap();
    else if(_args[1].equals("edit")) editStep(_args); // up down or specific
    else if(_args[1].equals("clear")) clearSeq(_args); //
    else if(_args[1].equals("toggle")) toggleStep(_args);
    else return false;
    return true;
  }

  public void editStep(String[] _args){
    if(_args.length == 3) valueGiven = str(sequencer.setEditStep(stringInt(_args[2])));
    gui.setTemplateString(sequencer.getStepToEdit().getTags());
    // valueGiven = sequencer.getStepToEdit().getTags();
    println("tags   "+sequencer.getStepToEdit().getTags());
  }

  public void clearSeq(String[] _args){
    if(_args.length == 2) sequencer.clear();
    if(_args.length == 3){
      int _v = stringInt(_args[2]);
      if(_v != -42) sequencer.clear(_v);
      else {
        ArrayList<TweakableTemplate> _tps =  templateManager.getTemplates(_args[2]);
        if(_tps == null) return;
        for(TweakableTemplate _tw : _tps)
          sequencer.clear(_tw);
      }
    }
  }

  public void toggleStep(String[] _args){
    if(_args.length > 2){
      for(TweakableTemplate _tw : templateManager.getTemplates(_args[2]))
        sequencer.toggle(_tw);
    }
    gui.setTemplateString(sequencer.getStepToEdit().getTags());
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Template commands ********TESTED********
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // * tw AB q 3
  // * tr AB (geometry)
  // * tp copy (AB)
  // * tp paste (AB)
  // * tp share (AB)
  // * tp reset (AB)
  // * tp save (cooleffects.xml)
  // * tp load (coolstuff.xml)
  // * tp color AB r g b a

  public boolean templateCMD(String[] _args){
    if(_args[0].equals("tw")) tweakTemplates(_args);
    else if(_args[0].equals("tr")) triggerTemplates(_args);
    else if(_args[0].equals("tp")){
      if(_args.length < 2) return false;
      else if(_args[1].equals("copy")) copyCMD(_args);
      else if(_args[1].equals("paste")) pasteCMD(_args);
      else if(_args[1].equals("reset")) resetCMD(_args);
      else if(_args[1].equals("share")) addCMD(_args);
      else if(_args[1].equals("save")) saveTemplateCMD(_args);
      else if(_args[1].equals("load")) loadTemplateCMD(_args);
      else if(_args[1].equals("color")) colorCMD(_args);
    }
    else return false;
    return true;
  }

  public void saveTemplateCMD(String[] _args){
    if(_args.length == 2) templateManager.saveTemplates();
    else if(_args.length == 3) templateManager.saveTemplates(_args[2]);
  }

  public void loadTemplateCMD(String[] _args){
    if(_args.length == 2) templateManager.loadTemplates();
    else if(_args.length == 3) templateManager.loadTemplates(_args[2]);
  }

  public void copyCMD(String[] _args){
    if(_args.length == 3) templateManager.copyTemplate(_args[2]);
    else templateManager.copyTemplate();
  }

  public void pasteCMD(String[] _args){
    if(_args.length == 3) templateManager.pasteTemplate(_args[2]);
    else templateManager.pasteTemplate();
  }

  public void resetCMD(String[] _args){
    if(_args.length == 3) templateManager.resetTemplate(_args[2]);
    else templateManager.resetTemplate();
  }

  public void addCMD(String[] _args){
    if(_args.length == 3) templateManager.groupAddTemplate(_args[2]);
    else templateManager.groupAddTemplate();
  }

  public void colorCMD(String[] _args){
    if(_args.length < 4) return;
    int _v = stringInt(_args[3]);
    if(_v != -3) templateManager.setCustomColor(_args[2], _v);
  }

  // could be in tm
  public void triggerTemplates(String[] _args){
    if(_args.length == 2){
      for(int i = 0; i < _args[1].length(); i++) templateManager.trigger(_args[1].charAt(i));
    }
    else if(_args.length > 2){
      for(int i = 0; i < _args[1].length(); i++)
        for(int j = 2; j < _args.length; j++) templateManager.trigger(_args[1].charAt(i), stringInt(_args[j]));
    }
  }

  /**
   * Template tweaking, any "tw" cmds.
   * Commands like "tw A q 3"
   * @param String command
   * @return boolean was used
   */
  public void tweakTemplates(String[] _args){
    if(_args.length < 4) return;
    //if(_args[3] == "-3") return;
    ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[1]); // does handle wildcard
    if(_tmps == null) return;
    if(_args[2].length() == 0) return;
    char _k = _args[2].charAt(0);
    int _v = stringInt(_args[3]);
    for(TweakableTemplate _tp : _tmps) templateDispatch(_tp, _k, _v);
  }

  /**
   * Change the parameters of a template.
   * @param TweakableTemplate template to modify
   * @param char editKey
   * @param int value
   * @return boolean value used
   */
  public void templateDispatch(TweakableTemplate _template, char _k, int _n) {
    //println(_template.getID()+" "+_k+" ("+int(_k)+") "+n);
    if(_template == null) return;

    if (_k == 'a') valueGiven = str(_template.setAnimationMode(_n));
    else if (_k == 'b') valueGiven = str(_template.setRenderMode(_n));
    else if (_k == 'd') valueGiven = str(_template.setBrushMode(_n));
    else if (_k == 'f') valueGiven = str(_template.setFillMode(_n));
    else if (_k == 'h') valueGiven = str(_template.setEasingMode(_n));
    else if (_k == 'i') valueGiven = str(_template.setRepetitionMode(_n));
    else if (_k == 'j') valueGiven = str(_template.setReverseMode(_n));
    else if (_k == 'k') valueGiven = str(_template.setStrokeAlpha(_n));
    else if (_k == 'l') valueGiven = str(_template.setFillAlpha(_n));
    else if (_k == 'o') valueGiven = str(_template.setRotationMode(_n));
    else if (_k == 'e') valueGiven = str(_template.setInterpolateMode(_n));
    else if (_k == 'p') valueGiven = str(_template.setRenderLayer(_n));
    else if (_k == 'q') valueGiven = str(_template.setStrokeMode(_n));
    else if (_k == 'r') valueGiven = str(_template.setRepetitionCount(_n));
    else if (_k == 's') valueGiven = str(_template.setBrushSize(_n));
    else if (_k == 'u') valueGiven = str(_template.setEnablerMode(_n));
    else if (_k == 'v') valueGiven = str(_template.setSegmentMode(_n));
    else if (_k == 'w') valueGiven = str(_template.setStrokeWidth(_n));
    else if (_k == 'x') valueGiven = str(_template.setBeatDivider(_n));
    else if (_k == '%') valueGiven = str(_template.setBankIndex(_n));
    else if (_k == '$') valueGiven = str(_template.saveToBank()); // could take an _n to set bank index?
    // mod commands
    else if (int(_k) == 518) _template.reset();
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public String getValueGiven(){
    return valueGiven;
  }
}


// idea for a command class
//
class Cmd implements FreelinerConfig{
  String[] args;
  //
  public Cmd(String[] _args){
    args = _args;
  }

  public Cmd(String _cmd){
    args = split(_cmd, ' ');
  }

  public void append(String _arg){
    //
  }

  public int getInt(int _i){return 0;}
  public float gettFloat(float _flt){return 0.0;}

  public int length(){
    return args.length;
  }

  // is index equal to string
  public boolean is(int _i, String _s){
    if(_i < args.length){
      return args[_i].equals(_s);
    }
    else return false;
  }

}

// class to create loops of events.
class Looper {
  Synchroniser synchroniser;
  boolean recording;
  ArrayList<String> events;
  public Looper(Synchroniser _sn){
    synchroniser = _sn;
    recording = false;
    events = new ArrayList();
  }

  public void add(String _cmd){
    events.add(_cmd);
  }

  // going to need some sort of update function
  public void update(){

  }
}
