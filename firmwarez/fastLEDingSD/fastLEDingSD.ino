/*
  A freeLEDing firmware for fastLED library

  By maxD (aka Deglazer) of the aziz!LightCrew 2015
*/

#include <FastLED.h>
#include <SD.h>

// fastLED settings
#define DATA_PIN 6
#define CLOCK_PIN 2
#define NUM_LEDS    7
#define BRIGHTNESS  100
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];

const int LED_COUNT = NUM_LEDS;
const int BUFFER_SIZE = LED_COUNT * 3;
byte LEDbuffer[BUFFER_SIZE];

int errorCount = 0;

// start in sdplayback mode
bool useSerial = false;

// file playback stuff
File myFile;
int animationCount = 0;

bool debug = false;

void setup() {
    Serial.begin(115200);
    /*FastLED.addLeds<LED_TYPE, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);*/
    FastLED.addLeds<LED_TYPE, DATA_PIN, RGB>(leds, NUM_LEDS);
    initSD();
    /*initTest();*/
}

void loop() {
    if(useSerial) serialMode();
    else playAnimationFromSD();
}

void serialMode(){
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

// draw the LEDbuffer
void drawBuffer() {
    //  int t = millis();
    int ind;
    for (int i = 0; i < LED_COUNT; i++) {
        ind = i * 3;
        leds[i] = CRGB(LEDbuffer[ind], LEDbuffer[ind + 1], LEDbuffer[ind + 2]);
    }
    FastLED.show();
    //  Serial.println(millis() - t);
}

// little animation to test leds
void initTest() {
    int del = 30;
    for (int i = 0 ; i < LED_COUNT; i++) {
        leds[i] = CRGB(100, 10, 10);
        delay(del);
        FastLED.show();
    }
    for (int i = 0 ; i < LED_COUNT; i++) {
        leds[i] = CRGB(0, 0, 0);
        delay(del);
        FastLED.show();
    }
}

// initialise SDcard
void initSD(){
    Serial.print("Initializing SD card...");
    pinMode(10, OUTPUT);
    if (!SD.begin(10)) {
      Serial.println("initialization failed!");
      return;
    }
    Serial.println("initialization done.");
}

// play animation from SD card
void playAnimationFromSD(){
    myFile = SD.open("ledani_1");
    if (myFile) {
        Serial.println("file loaded");
        // read from the file until there's nothing else in it:
        while (myFile.available()) {
            myFile.readBytes((char*)leds, NUM_LEDS*3);
            FastLED.show();
            delay(20);
            if(Serial.available()){
                useSerial = true;
                break;
            }
        }
        myFile.close();
    }
    else {
        Serial.println("error opening file");
    }
}
