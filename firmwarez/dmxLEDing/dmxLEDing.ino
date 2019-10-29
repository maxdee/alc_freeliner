/*
  A freeLEDing firmware for DMX par lights
  By maxD (aka userZero) of the aziz!LightCrew 2015
*/

#include <DmxSimple.h>

// how many channels the RGB lights have
// with a value of 10 your fixtures should be adressed 1 11 21 31...
const int CHAN_COUNT = 10; // 12 for pds
// how many fixtures
const int NUM_LEDS = 12;

const int DATA_PIN = 12;
const int LED_COUNT = NUM_LEDS;
const int BUFFER_SIZE = LED_COUNT * 3;
byte LEDbuffer[BUFFER_SIZE];
int errorCount = 0;

void setup() {
  Serial.begin(115200);
  DmxSimple.usePin(DATA_PIN);
  initTest();
}

void loop() {
  int startChar = Serial.read();

  if (startChar == '*') {
    int count = Serial.readBytes((char *)LEDbuffer, BUFFER_SIZE);
    if (count == BUFFER_SIZE) drawBuffer();
    else {
      Serial.print("badSize ");
      Serial.println(errorCount++);
    }
  }
  else if (startChar == '?') {
    // for easy and automatic configuration
    Serial.print(LED_COUNT);
  } else if (startChar >= 0) {
    // discard unknown characters
    Serial.print("badheader ");
    Serial.println(errorCount++);
  }
}

void drawBuffer() {
  int ind;
  for (int i = 0; i < LED_COUNT; i++) {
    ind = i * 3;
    setRGB(i, LEDbuffer[ind], LEDbuffer[ind + 1], LEDbuffer[ind + 2]);
    if(i == 9) digitalWrite(13, LEDbuffer[ind] > 127);
  }
}

// set RGB of fixture
void setRGB(int _chan, int _r, int _g, int _b){
  DmxSimple.write(_chan*CHAN_COUNT+1, 255); // some fixtures have a brightness scalar
  DmxSimple.write(_chan*CHAN_COUNT+2, _r);
  DmxSimple.write(_chan*CHAN_COUNT+3, _g);
  DmxSimple.write(_chan*CHAN_COUNT+4, _b);
}

// will happen really fast
void initTest() {
  int del = 20;
  for (int i = 0 ; i < LED_COUNT; i++) {
    setRGB(i, 100, 10, 10);
    delay(del);
  }
  for (int i = 0 ; i < LED_COUNT; i++) {
    setRGB(i, 0, 0, 0);
    delay(del);
  }
}
