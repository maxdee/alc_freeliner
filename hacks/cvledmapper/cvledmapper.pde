import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Capture video;
SerialSender sender;
int ledCount = 0;
byte buffer[];
PImage diff;
int contrast = 0;
int brightness = 0;
int selectedLED = 0;

XML fixtures;

void setup(){

    size(640,480,P2D);
    video = new Capture(this, 640/2, 480/2, "/dev/video1");
    video.start();
    opencv = new OpenCV(this, 640/2, 480/2);
    sender = new SerialSender(this);
    sender.connect("/dev/ttyACM0", 115200);
    ledCount = sender.getCount();
    buffer = new byte[ledCount*3];
    // for(String _str : Capture.list()){
    //     println(_str);
    // }
    frameRate(15);
    XML fixtures = new XML("fixture");

}

void stop() {
    saveXML(fixtures, "haha.xml");
}

void draw(){
    clearbuffer();
    setLED(selectedLED,0,0,100);
    background(0);
    opencv.loadImage(video);
    opencv.setGray(opencv.getB());
    opencv.brightness(brightness);
    opencv.contrast(contrast);
    if(diff != null) opencv.diff(diff);

    image(opencv.getOutput(), 0,0,640,480);

    PVector _loc = opencv.max();
    stroke(0);
    strokeWeight(3);
    clearbuffer();
    ellipse(_loc.x, _loc.y, 10,10);
}

void setDiff(){
    diff = opencv.getOutput();
    println("set diff");
}

void detect(){

}

void captureEvent(Capture c) {
  c.read();
}

void mouseDragged(){
    contrast = ((int)map(mouseX, 0, width, 0, 255));
    brightness = ((int)map(mouseY, 0, height, -255, 255));
}

void keyPressed(){
    if(key == ' '){
        setDiff();
    }
    else if(key == '-'){
        selectedLED--;
    }
    else if(key == '='){
        selectedLED++;
    }
    selectedLED %= ledCount;
    println(selectedLED);
}

void setLED(int _index, int _red, int _green, int _blue){
    if(_index < ledCount && _index >= 0){
        buffer[_index * 3] = (byte) _red;
        buffer[_index * 3 +1] = (byte) _green;
        buffer[_index * 3 +2] = (byte) _blue;
    }
    sender.sendData(buffer);
}

void clearbuffer(){
    for(int i = 0; i < buffer.length; i++){
        buffer[i] = (byte)0;
    }
}



void addLEDtoXML(int _x, int _y, int _a){
    XML xyled = new XML("xyled");
    xyled.setFloat("a", i*3);
    xyled.setFloat("x", _x);
    xyled.setFloat("y", _y);
    fixtures.addChild(xyled);
    point(_x, _y);
}
