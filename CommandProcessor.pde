/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */


/** LIST OF COMMMANDS !!!
 * tw AB q 3
 * tr AB (geometry)
 * tp copy (AB)
 * tp paste (AB)
 * tp add (AB)
 * tp reset (AB)
 * tp save (cooleffects.xml)
 * tp load (coolstuff.xml)
 * ///////////////////
 * seq tap (offset)
 * seq edit -1,-2,step
 * seq clear (step || AB)
 * seq add A (step)
 * seq play (step)
 * seq stop
 * cmd rec
 * cmd play
 * ///////////////////
 * tools grid (size)
 * tools lines
 * tools tags
 * tools snap (dist)
 * tools rec
 * tools fixed line (length)
 * tools fixed angle (angle)
 * ///////////////////
 * geom txt ?????????????????
 * geom save (coolMap.xml)
 * geom load (coolMap.xml)
 * ///////////////////
 * post trails (alpha)
 * post shader (coolfrag.glsl)
 */


/**
 * This distributes events to templates and stuff.
 */
class CommandProcessor implements FreelinerConfig{

  TemplateManager templateManager;
  TemplateRenderer templateRenderer;
  GroupManager groupManager;
  SequenceSync synchroniser;

  // this string gets set to whatever value was set
  String valueGiven = "";

  /**
   * Constructor, nothing to do here.
   */
  public CommandProcessor(){ }

  /**
   * Dependency injection
   * @param FreeLiner
   */
  public void inject(FreeLiner _fl){
    templateManager = _fl.getTemplateManager();
    synchroniser = templateManager.getSynchroniser();
    templateRenderer = _fl.getTemplateRenderer();
    groupManager = _fl.getGroupManager();
  }


  // keyboard triggered commands go through here? might be able to hack a undo feature...
  public void processCmdStack(String _cmd){
    // add to stack
    processCMD(_cmd);
  }

  /**
   * This is where commands come to do stuff.
   * Commands like "tw A q 3" "tr A" "tg A 2 3 4" "tx 2 0 quakeroats"
   * Sequencer "sq ABC 3" "sq A *"
   * and maybe like "np 2 xyz" "sv tp ha.xml" "ld gm map.xml"
   * @param String command
   * @return boolean was used
   */
  public void processCMD(String _cmd){
    // if(record)
    String[] _args = split(_cmd, ' ');
    if(_args.length == 0) return;
    if(_args[0].equals("tw")) templateCMD(_args); // good
    else if(_args[0].equals("tr")) templateCMD(_args); // need to check trigger group
    else if(_args[0].equals("tp")) templateCMD(_args);
    else if(_args[0].equals("seq")) sequencerCMD(_args);
    else if(_args[0].equals("post")) postCMD(_args);
    else if(_args[0].equals("tools")) toolsCMD(_args);
    else println("Unknown CMD : "+join(_args, ' '));
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     toolsCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  // * tools grid (size)
  // * tools lines
  // * tools tags
  // * tools snap (dist)
  // * tools rec
  // * tools fixed line (length)
  // * tools fixed angle (angle)
  public void toolsCMD(String[] _args){
    println("toolsCMD : "+_args);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     postCMD
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void postCMD(String[] _args){
    //println("PostCMD : "+_args);
    if(_args.length < 1) return;
    else if(_args[1].equals("trails")) trailsCMD(_args);
    else println("Unknown CMD : "+join(_args, ' '));
  }

  public void trailsCMD(String[] _args){
    if(_args.length < 2) return;
    else if(_args[1].equals("trails")){
      if(_args.length == 2) valueGiven = str(templateRenderer.toggleTrails());
      else {
        int _v = stringInt(_args[2]);
        valueGiven = str(templateRenderer.setTrails(_v));
      }
    }
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

  public void sequencerCMD(String[] _args){
    //if(_args.length < 3) return;
    if(_args[1].equals("tap")) synchroniser.tap();
    else if(_args[1].equals("edit")) editStep(_args); // up down or specific
    else if(_args[1].equals("clear")) clear(_args); //
    else if(_args[1].equals("toggle")) toggleStep(_args);
    else println("Unknown CMD : "+join(_args, ' '));
  }

  public void editStep(String[] _args){
    if(_args.length == 3) valueGiven = str(synchroniser.setEditStep(stringInt(_args[2])));
  }

  public void clear(String[] _args){
    if(_args.length == 2) synchroniser.clear();
    else if(_args.length == 3){
      int _v = stringInt(_args[2]);
      if(_v != -42) synchroniser.clear(_v);
      else {
        templateManager.getTemplates(_args[2]);
        // for(TweakableTemplate _tw : templateManager.getTemplates(_args[2]))
        //   synchroniser.clear(_tw);
      }
    }
  }

  public void toggleStep(String[] _args){
    // if(_args.length > 2){
    //   for(TweakableTemplate _tw : templateManager.getTemplates(_args[2]))
    //     synchroniser.toggle(_tw);
    // }
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Template commands ********TESTED********
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void templateCMD(String[] _args){
    if(_args[0].equals("tw")) tweakTemplates(_args);
    else if(_args[0].equals("tr")) triggerTemplates(_args);
    else if(_args[0].equals("tp")){
      if(_args[1].equals("copy")) copy(_args);
      else if(_args[1].equals("paste")) paste(_args);
      else if(_args[1].equals("reset")) reset(_args);
      else if(_args[1].equals("tog")) add(_args);
    }
  }

  public void copy(String[] _args){
    if(_args.length == 3) templateManager.copyTemplate(_args[2]);
    else templateManager.copyTemplate();
  }

  public void paste(String[] _args){
    if(_args.length == 3) templateManager.pasteTemplate(_args[2]);
    else templateManager.pasteTemplate();
  }

  public void reset(String[] _args){
    if(_args.length == 3) templateManager.resetTemplate(_args[2]);
    else templateManager.resetTemplate();
  }

  public void add(String[] _args){
    if(_args.length == 3) templateManager.groupAddTemplate(_args[2]);
    else templateManager.groupAddTemplate();
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
    //if(_args.length < 4) return;
    //if(_args[3] == "-3") return;
    ArrayList<TweakableTemplate> _tmps = templateManager.getTemplates(_args[1]); // does handle wildcard
    if(_tmps == null) return;
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
