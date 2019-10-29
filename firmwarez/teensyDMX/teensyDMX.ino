/*
  A arduino DMX firmware for DMX fixtures
  By maxD (aka userZero) of the aziz!LightCrew 2015
*/

#include <DmxSimple.h>

const int CHAN_COUNT = 512; 
const int DATA_PIN = 1;
const int STATUS_PIN = 2;
const int BUFFER_SIZE = CHAN_COUNT;
byte DMXbuffer[BUFFER_SIZE];
int errorCount = 0;

void setup() {
  Serial.begin(115200);
  DmxSimple.usePin(DATA_PIN);
//  initTest();
  pinMode(STATUS_PIN, OUTPUT);
}

void loop() {
  int startChar = Serial.read();
  if (startChar == '*') {
    int count = Serial.readBytes((char *)DMXbuffer, BUFFER_SIZE);
    if (count == BUFFER_SIZE) outputBuffer();
    else {
      Serial.print("badSize ");
      Serial.println(errorCount++);
    }
  }
  else if (startChar == '?') {
    // for easy and automatic configuration
    Serial.print(CHAN_COUNT);
  } else if (startChar >= 0) {
    // discard unknown characters
    Serial.print("badheader ");
    Serial.println(errorCount++);
  }
}

//about 4 millis
void outputBuffer() {
  digitalWrite(STATUS_PIN, HIGH);
  for (int i = 0; i < 510; i++) {
    DmxSimple.write(i+1, DMXbuffer[i]); // added a i+1 here!!!
  }
  digitalWrite(STATUS_PIN, LOW);
}

// will happen really fast
void initTest() {

}
