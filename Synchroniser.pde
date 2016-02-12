/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-12-01
 */


/*
 * The synchroniser is in charge of the timing. Tap tempo with compensation for render time.
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

  // for frame capture to loc rendertime
  public void setRecording(boolean _r) {
   record = _r;
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

  public int getPeriodCount(){
    return periodCount;
  }
}
