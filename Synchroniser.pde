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


  FloatSmoother intervalTimer;
  float renderIncrement = 0.1;
  float lerper = 0;
  int cycleCount = 0;

	public Synchroniser(){
    tapTimer = new FloatSmoother(5, 350);
    intervalTimer = new FloatSmoother(5, 34);
	}

  public void update() {
    // calculate how much to increment
    renderIncrement = intervalTimer.addF(float(millis()-lastRender))/tempo;
    lastRender = millis();
    lerper += renderIncrement;

    if(lerper > 1.0){
      lerper = 0;
      cycleCount++;
      //println("bomp " + cycleCount);
    }
  }

  public float getLerp(int _div){
    int cyc_ = (cycleCount%_div);
    float lrp_ = (1.0/_div)*cyc_;
    return (lerper/_div) + lrp_; 
  }
  
  public int getCycle(int _div){
    return int(cycleCount/_div);
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

  public void setAllClockSpeeds(int s) {
    // for (int i = 0; i < clocksCnt; i++) {
    //   clocks.get(i).setTempo(s);
    // }
  }
}