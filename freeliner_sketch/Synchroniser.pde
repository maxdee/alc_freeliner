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

class Synchroniser /**tagtagtag**/{

    // millis to render one frame
    int renderTime = 0;
    int lastRender = 0;

    // tapTempo
    int lastTap = 0;
    int lastTime = 0;
    FloatSmoother tapTimer;
    int tempo = projectConfig.tempo/4;

    boolean steadyFrameRate;

    FloatSmoother intervalTimer;
    float renderIncrement = 0.1;
    float lerper = 0;
    float unit = 0;
    int periodCount = 0;

    // new time scaler!
    float timeScaler = 1.0;

    public Synchroniser(){
        tapTimer = new FloatSmoother(5, 350);
        intervalTimer = new FloatSmoother(5, 34);
        steadyFrameRate = false;
    }

    public void update() {
        // calculate how much to increment
        if(!steadyFrameRate){
            renderIncrement = intervalTimer.addF(float(millis()-lastRender))/tempo;
            lastRender = millis();
        }
        lerper += renderIncrement*timeScaler;
        unit += renderIncrement*timeScaler;
        if(lerper > 1.0){
            lerper = 0.0000001;
            periodCount++;
            freeliner.oscTick();
        }
        else if(lerper < 0.0){
            lerper = 0.99999999;
            periodCount--;
            if(periodCount < 1) periodCount = 9999;
            freeliner.oscTick();
        }
    }

    //tap the tempo
    public void tap() {
        int elapsed = millis()-lastTap;
        lastTap = millis();
        if (elapsed> 100 && elapsed < 3000) {
          tempo = int(tapTimer.addF(elapsed))/2;
          // needs to sync/line up with x 4
        }
    }

    //adjust tempo by +- 100 millis
    public void nudgeTime(int t){
        // println(lastTime);
        if(t==-2) lastTime -= 100;
        else if(t==-1) lastTime += 100;
    }

  // for frame capture to loc rendertime
    public void setSteady(boolean _r) {
        steadyFrameRate = _r;
    }

    public void setTimeScaler(float _f){
        timeScaler = _f;
    }

    public float getLerp(int _div){
        if(_div < 1) _div = 1;
        int cyc_ = (periodCount%_div);
        float lrp_ = (1.0/_div)*cyc_;
        return (lerper/_div) + lrp_;
    }

    public float getUnit(){
        return unit;
    }

    public int getPeriod(int _div){
        if(_div < 1) _div = 1;
        return int(periodCount/_div);
    }

    public int getPeriodCount(){
        return periodCount;
    }

    public float getTime(){
        return periodCount + unit;
    }
}
