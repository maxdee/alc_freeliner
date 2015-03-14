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
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */



class Clock {
 
  boolean ticker = true; //goes true for one cycle when on
  int tempo = 1000; //in millis
  int lastTime = 0;
  int cycles = 0;



  int division;
  int increment = 0;
  float lerper = 0;
  float lerpIncrement = 0;
  FloatSmoother fs;

  public Clock(int d) {
    division = d;
    fs = new FloatSmoother(8, 0.1);
  }

  public void update(int inc) {
    cycles++;
    lerper += lerpIncrement;

    if(lerper > 1){
      lerper = 0;
      increment++;
    }

    if(inc % division == 0 && !ticker){
      ticker = true;
      lerpIncrement = fs.addF(1.0/cycles);
      cycles = 0;
    }
    if(inc % division == 1) ticker = false; 
  }


  public void reset(){
    lerper = 0;
    lastTime = millis();
    increment++;
  }

    //dosentreally work....
  public void internal(){
    if (millis()-lastTime > tempo) {
      increment++;
      lastTime = millis();
    }
    update(increment);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public void setTempo(int s){
    tempo = s * division;
  }

  public void setDiv(int d){
    if(d > 0) division = d;
  }
  public void setLerper(float _l){
    lerper = _l;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public final boolean getTicker() {
    return ticker;
  }

  public final int getTempo(){
    return tempo;
  }

  public final float getLerper() {
    return lerper;
  }

  public final int getIncrement() {
    return increment;
  }
}

