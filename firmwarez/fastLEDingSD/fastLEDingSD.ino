/*
  A freeLEDing firmware for fastLED library
  By maxD (aka Deglazer) of the aziz!LightCrew 2015
*/

#include <FastLED.h>
#include <SD.h>

// pins
#define SD_CS 10
#define BUTTON_PIN 15
#define POT_PIN 0

// fastLED settings
#define DATA_PIN 8
#define CLOCK_PIN 2
#define NUM_LEDS  140
#define BRIGHTNESS  100
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];

const int BUFFER_SIZE = NUM_LEDS * 3;
int errorCount = 0;

// start in sdplayback mode
bool useSerial = false;

// file playback stuff
#define HEADER_SIZE 2;
File myFile;
int animationNumber = 0;
int debounceTimer = 0;
char fileName[8];

void setup() {
    Serial.begin(115200);
    /*FastLED.addLeds<LED_TYPE, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);*/
    FastLED.addLeds<LED_TYPE, DATA_PIN, GRB>(leds, NUM_LEDS);
    for(int y = 0 ; y < NUM_LEDS ; y++) leds[y] = CRGB::Black;

    initSD();
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(BUTTON_PIN), buttonPress, FALLING);
    /*initTest();*/
}

void loop() {
    if(useSerial) serialMode();
    else playAnimationFromSD();
}

void serialMode(){
    int startChar = Serial.read();
    if (startChar == '*') {
        int count = Serial.readBytes((char *)leds, BUFFER_SIZE);
        FastLED.show();
    }
    else if (startChar == '?') {
        // for easy and automatic configuration
        Serial.print(NUM_LEDS);
    } else if (startChar >= 0) {
        // discard unknown characters
        Serial.print("badheader ");
        Serial.println(errorCount++);
    }
}

// initialise SDcard
void initSD(){
    Serial.print("Initializing SD card...");
    pinMode(SD_CS, OUTPUT);
    if (!SD.begin(SD_CS)) {
      Serial.println("initialization failed!");
      return;
    }
    Serial.println("initialization done.");
}

void buttonPress(){
    if(millis() > debounceTimer+200){
        debounceTimer = millis();
        animationNumber++;
        useSerial = false;
        Serial.println(animationNumber);
    }
}

// play animation from SD card
void playAnimationFromSD(){
    sprintf(fileName, "ani_%02d.bin", animationNumber);
    /*Serial.println(fileName);*/
    myFile = SD.open(fileName);

    if (myFile) {
        byte _header[HEADER_SIZE];
        myFile.readBytes(_header, HEADER_SIZE);
        int fileLEDcount = ((_header[0] << 8) | _header[1]);
        Serial.println(fileName);
        Serial.print(" loaded with ");
        Serial.print(fileLEDcount);
        Serial.print(" leds");
        int _aniTrack = animationNumber;
        // read from the file until there's nothing else in it:
        while (myFile.available()) {
            myFile.readBytes((char*)leds, fileLEDcount);
            FastLED.show();
            delay(analogRead(POT_PIN)/50);
            if(Serial.available()){
                useSerial = true;
                break;
            }
            if(_aniTrack != animationNumber) break;
        }
        myFile.close();
    }
    else {
        Serial.print("error opening ");
        Serial.println(fileName);
        animationNumber = 0;
        delay(20);
    }
}

// little animation to test leds
void initTest() {
    int del = 30;
    for (int i = 0 ; i < NUM_LEDS; i++) {
        leds[i] = CRGB(100, 10, 10);
        delay(del);
        FastLED.show();
    }
    for (int i = 0 ; i < NUM_LEDS; i++) {
        leds[i] = CRGB(0, 0, 0);
        delay(del);
        FastLED.show();
    }
}
