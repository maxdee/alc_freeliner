/*
  A firmware to control LEDs with alc_freeliner and FastLED
  By maxD (aka Deglazer) of the aziz!LightCrew 2015
*/

// Now the idea would be to support regular arduino/FastLED and teensy/OctoWS811 and SD card playback :) all in one.
// Optional for OctoWS811
#define OCTOWSMODE false
#if OCTOWSMODE
    #define USE_OCTOWS2811
    #include<OctoWS2811.h>
#endif

// FastLED
#include <FastLED.h>
// Other libs
#include <SD.h>
#include <Bounce2.h>


// ledCount, if using single output, set NUM_STRIPS to 1
#define NUM_LEDS_PER_STRIP 15
#define NUM_STRIPS 1
#define NUM_LEDS  NUM_STRIPS * NUM_LEDS_PER_STRIP

// fastLED settings
#define BRIGHTNESS  100
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/////////////////////////// Pin Definition
// fastLED Pin settings
#define DATA_PIN 8
#define CLOCK_PIN 2
// sdcard pins
#define SD_CS 3
//    pin 3:  SD Card, CS
//    pin 11: SD Card, MOSI
//    pin 12: SD Card, MISO
//    pin 13: SD Card, SCLK
// input pins, if they are 0, then they will not be used.
#define BUTTON_PIN 0
#define SPEED_POT_PIN 0
#define DIM_POT_PIN 0

// led CRGB setup
CRGB leds[NUM_LEDS];
// serial in buffer
const int BUFFER_SIZE = NUM_LEDS * 3;
int errorCount = 0;

// start in sdplayback mode
bool useSerial = false;

// file playback stuff
#define HEADER_SIZE 2
File myFile;
int animationNumber = 0;
char fileName[8];

// input, pots or buttons
Bounce bouncer = Bounce();

void setup() {
    Serial.begin(115200);
    #if OCTOWSMODE
        LEDS.addLeds<OCTOWS2811>(leds, NUM_LEDS_PER_STRIP);
    #else
        FastLED.addLeds<LED_TYPE, DATA_PIN, GRB>(leds, NUM_LEDS);
    #endif
    
    #if BUTTON_PIN
        pinMode(BUTTON_PIN, INPUT_PULLUP);
        bouncer.attach(BUTTON_PIN);
        bouncer.interval(5);
    #endif

    FastLED.setDither( 0 );
    for(int y = 0 ; y < NUM_LEDS ; y++) leds[y] = CRGB::Black;
    FastLED.show();
    useSerial = false;
    initSD();
}

void loop() {
    if(useSerial) serialMode();
    else playAnimationFromSD();
    updateOtherThings();
}

void serialMode(){
    int startChar = Serial.read();
    if (startChar == '*') {
        int count = Serial.readBytes((char *)leds, BUFFER_SIZE);
        FastLED.show();
    }
    else if (startChar == '?') {
        Serial.print(NUM_LEDS);
        while(Serial.available()) Serial.read();
    } else if (startChar >= 0) {
        Serial.print("badheader ");
        Serial.println(errorCount++);
    }
}

// initialise SDcard
void initSD(){
    Serial.print(F("Initializing SD card..."));
    pinMode(SD_CS, OUTPUT);
    if (!SD.begin(SD_CS)) {
      Serial.println(F("initialization SD failed! ready on serial"));
      useSerial = true;
      return;
    }
    else Serial.println(F("initialization done."));
}

// play animation from SD card
void playAnimationFromSD(){
    sprintf(fileName, "ani_%02d.bin", animationNumber);
    Serial.println(fileName);
    myFile = SD.open(fileName);

    if (myFile) {
        byte _header[HEADER_SIZE];
        myFile.readBytes(_header, HEADER_SIZE);
        uint16_t _fileBufferSize = ((_header[0] << 8) | (_header[1] & 0xFF));
        if(_fileBufferSize > BUFFER_SIZE){
            Serial.println("Not enough LEDs to play animation");
            updateOtherThings();
            delay(500);
        }
        else {
            // read from the file until there's nothing else in it:
            while (myFile.available()) {
                myFile.readBytes((char*)leds, _fileBufferSize);
                FastLED.show();
                #if SPEED_POT_PIN
                    delay(analogRead(SPEED_POT_PIN)/30);
                #else
                    delay(20);
                #endif
                if(updateOtherThings()) break;
            }
        }
        myFile.close();
    }
    else {
        Serial.print(F("error opening "));
        Serial.println(fileName);
        animationNumber = 0;
        delay(20);
    }
}


bool updateOtherThings(){
    #if DIM_POT_PIN
    FastLED.setBrightness(map(analogRead(DIM_POT_PIN), 0, 1023, 255, 0));
    #endif
    #if BUTTON_PIN
        bouncer.update();
        if(bouncer.read() != 1){
            animationNumber++;
            Serial.println(animationNumber);
            useSerial = false;
            while(bouncer.read() != 1) bouncer.update();
            delay(100);
            return true;
        }
    #endif

    if(Serial.available()){
        useSerial = true;
        return true;
    }
    return false;
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
