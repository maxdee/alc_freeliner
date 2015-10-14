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

  // millis to render one frame
  int renderTime = 0;
  int lastRender = 0;

  // tapTempo
  int lastTap = 0;
  int lastTime = 0;
  FloatSmoother tapTimer;
  int tempo = 1500;

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
      lerper = 0;
      periodCount++;
      oscTick();
      //println("bomp " + periodCount);
    }
  }

  public float getLerp(int _div){
    if(_div < 1) _div = 1;
    int cyc_ = (periodCount%_div);
    float lrp_ = (1.0/_div)*cyc_;
    return (lerper/_div) + lrp_;
  }

  public int getPeriod(int _div){
    if(_div <1) _div = 1;
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



class SequenceSync extends Synchroniser{
  TemplateList[] lists;
  boolean doStep = false;
  final int STEP_COUNT = 16;
  int step = 0;
  boolean record = false;
  boolean play = false;

  public SequenceSync(){
    super();
    lists = new TemplateList[STEP_COUNT];
    for(int i = 0; i < STEP_COUNT; i++){
      lists[i] = new TemplateList();
    }
  }
  //
  public void update(){
    super.update();
    int oldStep = step;
    if(play) step = periodCount % STEP_COUNT;
    if(step != oldStep) doStep = true;
    // println(step);
  }

  // add or remove the Templates if
  public void templateInput(TweakableTemplate _tw){
    if(record){
      lists[step].toggle(_tw);
      //if(!lists[step].contains(_tw))
      //if(lists[step].contains(_tw)) templateList[step].toggle(_tw);
    }
  }

  public void clear(){
    for(int i = 0; i < STEP_COUNT; i++){
      lists[i].clear();
    }
  }

  public String toggleRec(){
    record = !record;
    return str(record);
  }
  public String togglePlay(){
    play = !play;
    return str(play);
  }

  // check for things to trigger
  public TemplateList getStepList(){
    if(doStep){
      doStep = false;
      if(play) return lists[step];
      else return null;
    }
    else return null;
  }
  public int getStep(){
    return step;
  }
}
