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
	Clock clk;
  ArrayList<Clock> clocks;
  int clocksCnt = 17;



  // millis to render one frame
  int renderTime = 0;
  int lastRender = 0;
  
  // tapTempo
  int lastTap = 0;
  int lastTime = 0;
  FloatSmoother tapTimer;
  int tempo = 1500;

  FloatSmoother intervalTimer;
  float increment = 0.1;
  float lerper = 0;
  // every time we fold over
  int cycleCount = 0;

	public Synchroniser(){
		initClocks();
    tapTimer = new FloatSmoother(5, 350);
    intervalTimer = new FloatSmoother(5, 34);
	}

	private void initClocks() {
    clocks =  new ArrayList();
    for (int i = 0; i < clocksCnt; i++) {
      clocks.add(new Clock(i+2));
    }
  }



  public void update() {
    increment = intervalTimer.addF(float(millis()-lastRender))/tempo;
    lastRender = millis();
    lerper += increment;
    if(lerper > 1.0){
      lerper = 0;
      cycleCount++;
      println("bomp " + renderTime);
    }


    // if (millis()-lastTime > tempo) {
    //   cycleCount++;
    //   lastTime = millis();
    // }
    for (int i = 0; i < clocksCnt; i++) {
      //clocks.get(i).update(cycleCount);
      clocks.get(i).setLerper(lerper);
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

  public void setAllClockSpeeds(int s) {
    for (int i = 0; i < clocksCnt; i++) {
      clocks.get(i).setTempo(s);
    }
  }

  //adjust tempo by +- 100 millis
  public void nudgeTime(int t){
    println(lastTime);
    if(t==-2) lastTime -= 100;
    else if(t==-1) lastTime += 100;
  }
}