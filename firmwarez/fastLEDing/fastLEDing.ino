/*
  A freeLEDing firmware for fastLED library

  By maxD (aka Deglazer) of the aziz!LightCrew 2015
*/

#include <FastLED.h>

// fastLED settings

#define DATA_PIN 6
#define CLOCK_PIN 2
#define NUM_LEDS    42
#define BRIGHTNESS  100
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];


const int LED_COUNT = NUM_LEDS;
const int BUFFER_SIZE = LED_COUNT * 3;
byte LEDbuffer[BUFFER_SIZE];

int errorCount = 0;


void setup() {
    Serial.begin(115200);
    /*FastLED.addLeds<LED_TYPE, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);*/
    FastLED.addLeds<LED_TYPE, DATA_PIN, RGB>(leds, NUM_LEDS);

    /*initTest();*/
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
    //  int t = millis();
    int ind;
    for (int i = 0; i < LED_COUNT; i++) {
        ind = i * 3;
        leds[i] = CRGB(LEDbuffer[ind], LEDbuffer[ind + 1], LEDbuffer[ind + 2]);
    }
    FastLED.show();
    //  Serial.println(millis() - t);
}


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
