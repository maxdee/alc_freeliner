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


class Synchroniser implements FreelinerConfig{

  // millis to render one frame
  int renderTime = 0;
  int lastRender = 0;

  // tapTempo
  int lastTap = 0;
  int lastTime = 0;
  FloatSmoother tapTimer;
  int tempo = DEFAULT_TEMPO;

  boolean record;

  FloatSmoother intervalTimer;
  float renderIncrement = 0.1;
  float lerper = 0;
  int periodCount = 0;

	public Synchroniser(){
    tapTimer = new FloatSmoother(5, 350);
    intervalTimer = new FloatSmoother(5, 34);
    record = false;
	}

  public void update() {
    // calculate how much to increment
    if(!record){
      renderIncrement = intervalTimer.addF(float(millis()-lastRender))/tempo;
      lastRender = millis();
    }
    lerper += renderIncrement;

    if(lerper > 1.0){
      lerper = 0.0000001;
      periodCount++;
      oscTick();
    }
  }

  public float getLerp(int _div){
    if(_div < 1) _div = 1;
    int cyc_ = (periodCount%_div);
    float lrp_ = (1.0/_div)*cyc_;
    return (lerper/_div) + lrp_;
  }

  public int getPeriod(int _div){
    if(_div < 1) _div = 1;
    return int(periodCount/_div);
  }


  //tap the tempo
  public void tap() {
    int elapsed = millis()-lastTap;
    lastTap = millis();
    if (elapsed> 100 && elapsed < 3000) {
      tempo = int(tapTimer.addF(elapsed));///2;
    }
  }

  //adjust tempo by +- 100 millis
  public void nudgeTime(int t){
    println(lastTime);
    if(t==-2) lastTime -= 100;
    else if(t==-1) lastTime += 100;
  }

  /////////////////////// cruft

  public void setRecording(boolean _r) {
    record = _r;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Sequencer extention
///////
////////////////////////////////////////////////////////////////////////////////////

class SequenceSync extends Synchroniser{
  TemplateList[] lists;
  TemplateList selectedList;
  boolean doStep = false;
  final int SEQ_STEP_COUNT = 16;
  int step = 0;
  int editStep = 0;


  boolean stepChanged = false;

  public SequenceSync(){
    super();
    lists = new TemplateList[SEQ_STEP_COUNT];
    for(int i = 0; i < SEQ_STEP_COUNT; i++){
      lists[i] = new TemplateList();
    }
    selectedList = lists[0];
  }
  //
  public void update(){
    super.update();
    int oldStep = step;
    step = periodCount % SEQ_STEP_COUNT;
    if(step != oldStep) doStep = true;
  }

  // add or remove the Templates, gets called by triggering
  public void templateInput(TweakableTemplate _tw){
    // if(record){
    //   lists[step].toggle(_tw);
    //   //if(!lists[step].contains(_tw))
    //   //if(lists[step].contains(_tw)) templateList[step].toggle(_tw);
    // }
  }

  public void templateInput(TweakableTemplate _tw, int _stp){
    // set for specific steps? show the tags for each step, cycle with -=
  }

  public void clear(){
    for(int i = 0; i < SEQ_STEP_COUNT; i++){
      lists[i].clear();
    }
  }


  // set which step to edit
  public int setEditStep(int _n){
    editStep = numTweaker(_n, editStep);
    editStep %= SEQ_STEP_COUNT;
    selectedList = lists[editStep];
    stepChanged = true;
    return editStep;
  }

  public TemplateList getStepToEdit(){
    return selectedList;
  }

  // check for things to trigger
  public TemplateList getStepList(){
    if(doStep){
      doStep = false;
      return lists[step];
    }
    else return null;
  }

  public int getStep(){
    return step;
  }
}
