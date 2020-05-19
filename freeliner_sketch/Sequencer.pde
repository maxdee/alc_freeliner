/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


 /**
  * A sequencer inspired by electronic music instruments, particularly after hands on experience with korg volca beats and bass.
  */
class Sequencer {

  TemplateList[] lists; // should have an array of lists
  TemplateList selectedList;
  boolean doStep = false;
  final int SEQ_STEP_COUNT = 16;
  // current step for playback
  int step = 0;
  int periodCount;
  // step being edited
  int editStep = 0;
  boolean playing = true;
  boolean recording = false; // implement this
  boolean stepChanged = false;

  public Sequencer(){
    lists = new TemplateList[SEQ_STEP_COUNT];
    for(int i = 0; i < SEQ_STEP_COUNT; i++){
      lists[i] = new TemplateList();
    }
    selectedList = lists[0];
  }

  // update the step according to synchroniser
  public void update(int _periodCount){
    if(periodCount != _periodCount){
      doStep = true;
      step++;
      step %= SEQ_STEP_COUNT;
      periodCount = _periodCount;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Toggle template for selectedlist
   */
  public void toggle(TweakableTemplate _tw){
    selectedList.toggle(_tw);
  }

  /**
   * Clear everything
   */
  public void clear(){
    for(TemplateList _tl : lists) _tl.clear();
  }

  /**
   * Clear specific step
   * @param int step index
   */
  public void clear(int _s){
    if(_s < SEQ_STEP_COUNT) lists[_s].clear();
  }

  /**
   * Clear a specific Template
   * @param TweakableTemplate template to clear
   */
  public void clear(TweakableTemplate _tw){
    for(TemplateList _tl : lists) _tl.remove(_tw);
  }

  /**
   * Set step to edit
   * @param int step index
   */
  public int setEditStep(int _n){
    editStep = numTweaker(_n, editStep);
    if(editStep >= SEQ_STEP_COUNT) editStep = SEQ_STEP_COUNT-1;
    selectedList = lists[editStep];
    stepChanged = true;
    return editStep;
  }

  /**
   * Jump to specific step and trigger it
   * @param int step index
   */
  public void forceStep(int _step){
   step = _step % SEQ_STEP_COUNT;
   doStep = true; // might need a time delay
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public boolean play(boolean _b){
    playing = _b;
    return playing;
  }

  public boolean play(){
    playing = !playing;
    return playing;
  }

  public boolean record(boolean _b){
    recording = _b;
    return recording;
  }

  public boolean record(){
    recording = !recording;
    return recording;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public TemplateList getStepToEdit(){
    return selectedList;
  }

  // check for things to trigger
  public TemplateList getStepList(){
    if(doStep && playing){
      doStep = false;
      return lists[step];
    }
    else return null;
  }

  public String getStatusString(){
    String _buff = "";
    for(TemplateList _tl : lists){
      _buff += "/"+_tl.getTags();
    }
    return _buff;
  }

  public TemplateList[] getStepLists(){
    return lists;
  }

  public int getStep(){
    return step;
  }

  public boolean isPlaying(){
    return playing;
  }

  public boolean isRecording(){
    return recording;
  }
}
