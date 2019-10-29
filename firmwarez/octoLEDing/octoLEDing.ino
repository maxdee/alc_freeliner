/*
  A freeLEDing firmware for OctoWS811 by Paul Stoffregen
  http://www.pjrc.com/teensy/td_libs_OctoWS2811.html

  By maxD (aka Deglazer) of the aziz!LightCrew 2015
*/

#include <OctoWS2811.h>

// OctoWS2811 settings
const int ledsPerStrip = 55; // change for your setup
const byte numStrips= 8; // change for your setup
DMAMEM int displayMemory[ledsPerStrip*6];
int drawingMemory[ledsPerStrip*6];
const int config = WS2811_GRB | WS2811_800kHz;
OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

const int LED_COUNT = ledsPerStrip*8;
const int BUFFER_SIZE = LED_COUNT*3;
byte LEDbuffer[BUFFER_SIZE];


void setup(){
  Serial.begin(115200);
  leds.begin();
  initTest();
}


void loop(){
  int startChar = Serial.read();

  if (startChar == '*') {
    int count = Serial.readBytes((char *)LEDbuffer, BUFFER_SIZE);
    if (count == BUFFER_SIZE) {
      drawBuffer();
    }
    else Serial.println("badSize");
  } else if (startChar == '?') {
    // for easy and automatic configuration
    Serial.print(LED_COUNT);
  } else if (startChar >= 0) {
    // discard unknown characters
    //Serial.println("badheader");
  }
}

void drawBuffer(){
  int ind;
  for(int i = 0; i < LED_COUNT; i++){
    ind = i*3;
    leds.setPixel(i, LEDbuffer[ind], LEDbuffer[ind+1], LEDbuffer[ind+2]);
  }
  leds.show();
}


void initTest(){
  int del = 5;
  for (int i = 0 ; i < ledsPerStrip * numStrips ; i++){
    leds.setPixel(i, 100, 10, 10);
    delay(del);
    leds.show();
  }
  for (int i = 0 ; i < ledsPerStrip * numStrips ; i++){
    leds.setPixel(i, 0, 0, 0);
    delay(del);
    leds.show();
  }
}
