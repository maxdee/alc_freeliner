/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2017-01-16
 */


// Now the idea would be to support regular arduino/FastLED and teensy/OctoWS811 and SD card playback :) all in one.
// Optional for OctoWS811
#define OCTOWSMODE true
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
#define NUM_LEDS_PER_STRIP 80//170
#define NUM_STRIPS 8
#define NUM_LEDS  NUM_STRIPS * NUM_LEDS_PER_STRIP

// fastLED settings
#define BRIGHTNESS  100
#define LED_TYPE    WS2812B
#define COLOR_ORDER RGB//GRB

/////////////////////////// Pin Definition
// fastLED Pin settings
#define DATA_PIN 6
#define CLOCK_PIN 2
// sdcard pins
#define SD_CS 4 // 3 on other setups...
//    pin 3:  SD Card, CS
//    pin 11: SD Card, MOSI
//    pin 12: SD Card, MISO
//    pin 13: SD Card, SCLK
// input pins, if they are 0, then they will not be used.
#define BUTTON_PIN 17
#define SPEED_POT_PIN 4 // A4 D18
#define DIM_POT_PIN 5 // A5 D19

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
    doShow();
    useSerial = false;
    initSD();
    // initTest();
}
int ha = 0;

void loop() {
    if(useSerial) serialMode();
    else playAnimationFromSD();
    updateOtherThings();
}

void serialMode(){
    if(Serial.available()){
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
            Serial.println(F("Not enough LEDs to play animation"));
            updateOtherThings();
            delay(500);
        }
        else {
            // read from the file until there's nothing else in it:
            while (myFile.available()) {
                myFile.readBytes((char*)leds, _fileBufferSize);
                doShow();
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

void doShow(){
    // for(int i = 0; i < NUM_STRIPS; i += NUM_LEDS_PER_STRIP){
    //     leds[i] = CRGB(0,0,0);
    // }
    FastLED.show();
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
    int del = 3;
    for (int i = 0 ; i < NUM_LEDS; i++) {
        leds[i] = CRGB(100, 10, 10);
        delay(del);
        doShow();
    }
    for (int i = 0 ; i < NUM_LEDS; i++) {
        leds[i] = CRGB(0, 0, 0);
        delay(del);
        doShow();
    }
}

void standby(){
    ha++;
    for(int i = 0; i < NUM_LEDS; i++){
        leds[i] = CHSV(ha+int(ha+i*2+millis()/1.0)%255,255,255);
    }
    FastLED.show();

}
