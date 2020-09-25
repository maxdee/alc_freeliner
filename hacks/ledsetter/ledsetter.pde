import oscP5.*;
import netP5.*;

OscP5 oscP5;
// OscP5 sender;
NetAddress address;

// IntList numbers;

boolean redraw = true;

String project_name = "maptest";
// String sourceFileName = "p-ice_cloud_raw.xml";
String sourceFileName = "haha.xml";

LEDcloud cloud;
int LED_PER_STRIP = 550;
color[] stripColors = {
    color(255,0,0),
    color(255,0,255),
    color(0,0,255),
    color(0,255,255),
    color(0,255,0),
    color(255,255,255),
    color(0,0,0),
    color(255,255,0)
};
void setup(){
    size(1500, 720, P2D);
    background(0);
    frameRate(20);
hint(ENABLE_KEY_REPEAT);
    oscP5 = new OscP5(this,6670);
    address = new NetAddress("127.0.0.1", 6667);
    // selectInput("Select a file to process:", "fileDialogCallback");
    // drawLEDs(loadFile("harhar.xml"));
    // doThing(loadFile("harhar_mess.xml"));
    // doThing(loadFile("space_pubes_raw.xml"));
    // cloud = new LEDcloud(loadFile("space_pubes_raw_thursday.xml"));
    cloud = new LEDcloud(loadFile(sourceFileName));
    cloud.findMedian();
    cloud.fixOutliers(1.5, 2.2);
    // cloud.makeSegments();/
    // cloud.evenSpacing();

    //

    // ledGroups = groupLEDs(leds);
    // sortLEDs(new ArrayList<LED>(leds),


    // background(40);
    // cloud.display();
    // cloud.applyMatrix();
    // translate(0, width/2);
    // cloud.display();

    // background(40);
    // // cloud.display();
    // int prev=0;
    // color c = color(255,0,0);
    // strokeWeight(4);
    // for(LED l : cloud.leds) {
    //     // println(l.clusterIndex);
    //     if(l.clusterIndex != prev) {
    //         c = color(random(255),random(255),random(255));
    //         stroke(c);
    //         prev = l.clusterIndex;
    //     }
    //     point(l.pos.x,l.pos.y);
    // }
}


void fileDialogCallback(File _file) {
    loadFile(_file.getAbsolutePath());
}

// load a file to work with.
ArrayList<LED> loadFile(String _file) {
    if(_file == null) {
        println("file no good");
        exit();
        return null;
    }
    else {
        XML _xml = loadXML(_file);
        XML[] children = _xml.getChildren("xyled");
        ArrayList<LED> _leds = new ArrayList<LED>();
        for(XML xyled : children) {
            _leds.add(new LED(xyled));
        }
        println("found "+_leds.size()+" leds");
        return _leds;
    }
}


void setChannel(int _c, int _v) {
    OscMessage myMessage = new OscMessage("/layer/fix/setchan/"+_c+"/"+_v);
    send(myMessage);
}

// output command to freeliner
void send(OscMessage _osc){
    // sender.send(_osc);
    println(_osc);
    oscP5.send(_osc, address);
}

void draw(){
    // println(mouseX+" "+mouseY);
    // setChannel(20,0);
    // setChannel(21,0);
    // setChannel(22,0);

    // float pitch = (mouseY-height/2.0)/200.0;
    // float yaw = (mouseX-width/2.0)/200.0;
    // FloatList matrix = makeMatrix(0, pitch, yaw);
    // PVector haha;
    // stroke(255);
    // strokeWeight(3);
    // for(LED l : cloud.leds) {
    //     haha = matrixIt(l.pos, matrix);
    //     point(haha.x, haha.y);
    // }
    // background(40);
    // cloud.display();
    // cloud.fixOutliers(1.8, 3.2);//mouseX/width*4.0, mouseY/height*4.0);

    //
    background(40);
    cloud.display();
    fill(255);
    String t = "inpsector : "+inspectorIndex;
    text(t,10,10);

    // cloud.applyMatrix();
    // translate(0, width/2);
    // cloud.display();

    // redraw();
}
int walkerIndex = -1;
int clusterIndex = 0;

void clusterNext(){
    walkerIndex++;
    cloud.leds.get(walkerIndex).clusterIndex = clusterIndex;
    setChannel(cloud.leds.get(walkerIndex).address, 255);
}
void clusterPrevious(){
    setChannel(cloud.leds.get(walkerIndex).address, 0);
    walkerIndex--;
    if(walkerIndex < 0) walkerIndex = 0;
}
void closeCluster(){
    // clear previous
    for(LED l : cloud.leds){
        if(l.clusterIndex == clusterIndex){
            println("hah "+l.address);
            setChannel(l.address, 0);
        }
    }
    clusterIndex++;
    clusterNext();
}
int inspectorIndex = 0;
void keyPressed(){
    // if(key == '-') clusterPrevious();
    // if(key == '=') clusterNext();
    // if(key == ' ') closeCluster();
    if(key == '=') inspectorIndex+=3;
    if(key == '-') inspectorIndex-=3;
    if(key == '0') inspectorIndex+=30;
    if(key == '9') inspectorIndex-=30;

    if(inspectorIndex<0)inspectorIndex = 0;

    else if(key == 27){
        stop();
    }
}
void stop() {
    println("saving and quitting");
    saveShadelLEDFile();
    // XML fixtures = new XML("fixture");
    // for(LED led : cloud.leds) {
    //     XML xyled = new XML("xyled");
    //     xyled.setFloat("a", led.address);
    //     xyled.setFloat("x", led.pos.x);
    //     xyled.setFloat("y", led.pos.y);
    //     xyled.setFloat("c", led.clusterIndex);
    //     fixtures.addChild(xyled);
    //     // point(_x, _y);
    // }
    // saveXML(fixtures, "fixed.xml");
    // saveGroups(cloud.segments);
    // saveXML(fixtures, "hihi.xml");
}

void saveShadelLEDFile(){
    // do normalise
    float maxX = 0;
    float minX = 10000000.0;
    float maxY = 0;
    float minY = 10000000.0;
    for(LED led : cloud.leds) {
        if(led.pos.y < minY) minY = led.pos.y;
        if(led.pos.x < minX) minX = led.pos.x;

        if(led.pos.y > maxY) maxY = led.pos.y;
        if(led.pos.x > maxX) maxX = led.pos.x;
    }
    PVector lowest = new PVector(minX, minY);
    // PVector highest = new PVector(maxX, maxY);
    maxX-=minX;
    maxY-=minY;
    float saclar = (maxX>maxY) ? maxX:maxY;

    PVector center = new PVector(0.5,0.5);
    for(LED led : cloud.leds) {
        led.pos.sub(lowest);
        led.pos.div(saclar);
        led.pos.sub(center);
        led.pos.mult(2.0);
    }


    ArrayList<String> strs = new ArrayList<String>();
    if(false) {
        strs.add("static Pixel pixelBuffer["+cloud.leds.size()+"] = {");
        for(LED led : cloud.leds) {
            // if(led.address < 2){
            //     // dont add
            // }
            // else {
            XML xyled = new XML("xyled");
            String e = "{";
            e+= "CRGB::Black, ";
            e+= led.address/3;//(led.address/3) - 1; // off by one correction
            e+=", {";
            e+= led.pos.x;
            e+=", ";
            e+= led.pos.y;
            e+="}},";
            println(e);
            strs.add(e);
            // }
        }
        strs.add("};");
    }
    else {
        strs.add("static MappedLED ledMapping["+cloud.leds.size()+"] = {");
        for(LED led : cloud.leds) {
            // if(led.address < 2){
            //     // dont add
            // }
            // else {
            XML xyled = new XML("xyled");
            String e = "{";
            e+= led.address/3;//(led.address/3) - 1; // off by one correction
            e+=", ";
            e+= led.pos.x;
            e+=", ";
            e+= led.pos.y;
            e+="},";
            println(e);
            strs.add(e);
            // }
        }
        strs.add("};");
    }

    String[] arr = new String[strs.size()];
    for(int i = 0; i < strs.size(); i++){
        arr[i] = strs.get(i);
    }
    saveStrings("shadelMap.txt", arr);
}

void mousePressed(){
    PVector _c = new PVector(mouseX, mouseY);
    cloud.click(_c);
}

void mouseDragged(){
    PVector _c = new PVector(mouseX, mouseY);
    cloud.drag(_c);
}
//
// void drawLEDs(ArrayList<LED> _leds) {
//     strokeWeight(2);
//     noFill();
//     for(LED led : _leds){
//         int stripNum = led.address/LED_PER_STRIP;
//         stroke(stripColors[stripNum]);
//         ellipse(led.pos.x, led.pos.y, 5, 5);
//     }
// }

void drawSegments(ArrayList<Segment> _segs) {
    stroke(255,100);
    strokeWeight(6);
    // for(Segment _seg : _segs) {
    //     line(_seg.start.pos.x, _seg.start.pos.y, _seg.end.pos.x, _seg.end.pos.y);
    // }
}


public void saveGroups(ArrayList<Segment> _segs) {
    if(_segs == null) return;
    XML groupData = new XML("groups");
    groupData.setInt("width", width);
    groupData.setInt("height", height);

    //if (grp.isEmpty()) continue;
    XML xgroup = groupData.addChild("group");
    xgroup.setInt("ID", 2);
    xgroup.setString("text", "Hi, I'm an auto-mapped geometry!");
    xgroup.setString("type", "map");

    xgroup.setString("tags", "");
    for (Segment _seg : _segs) {
        XML xseg = xgroup.addChild("segment");
        xseg.setFloat("aX", _seg.getStart().pos.x);
        xseg.setFloat("aY", _seg.getStart().pos.y);
        xseg.setFloat("bX", _seg.getEnd().pos.x);
        xseg.setFloat("bY", _seg.getEnd().pos.y);
        // for leds and such
        xseg.setString("txt", "/led " + int(_seg.getStart().address/3-1)+" "+int(_seg.getEnd().address/3-1));
    }
    saveXML(groupData, "fixture_file.xml");
}





class LED extends Handle{
    PVector pos;
    int address;
    boolean selected = false;
    int clusterIndex;

    public LED(float _x, float _y, int _a){
        super();
        pos = new PVector(_x, _y);
        size = 3;
        col = color(255,255,255, 100);
        address = _a;
    }
    public LED(XML _xml) {
        pos =  new PVector(_xml.getFloat("x"), _xml.getFloat("y"));
        address = (int)_xml.getFloat("a");
        clusterIndex = (int)_xml.getFloat("c");
    }
    float dist(LED _other){
        return pos.dist(_other.pos);
    }
    public void display(){
        // stroke(col);
        strokeWeight(1);
        selected = address == inspectorIndex;
        if(selected) fill(0,255,0);
        else noFill();

        int stripNum = address/(LED_PER_STRIP*3);
        stroke(stripColors[stripNum]);
        ellipse(pos.x, pos.y, size, size);
    }
}




// the item interface standardises selection  and deletion and such?
// interface Item {
//     boolean selected;
// }
class Segment {
    ArrayList<LED> strip;
    public Segment() {
        strip = new ArrayList<LED>();
    }
    public void addLED(LED _led){
        strip.add(_led);
    }
    int getCount(){
        return abs(getStart().address - getEnd().address);
    }
    float length(){
        return getStart().dist(getEnd());
    }
    void evenSpacing(){
        LED first = getStart();
        LED last = getEnd();
        int count = strip.size()-1;
        float spacing = float(1)/float(count);
        for(int i = 1; i < strip.size()-1; i++){
            strip.get(i).pos = vecLerp(first.pos, last.pos, i*spacing);
        }
    }
    void setSpacing(int _s){
        int count = strip.size()-1;
        if(count < 2) return;
        int targetLength = count*_s;
        LED first = getStart();
        LED last = getEnd();
        if(abs(first.pos.x- last.pos.x) < abs(first.pos.x- last.pos.x)) {
            last.pos.x = first.pos.x + targetLength;
        }
        else {
            last.pos.y = first.pos.y + targetLength;
        }

        // float spacing = 1/(count-1);
        // for(int i = 1; i < strip.size()-1; i++){
        //     strip.get(i).pos = vecLerp(first.pos, last.pos, i*spacing);
        // }
    }

    LED getStart(){
        return strip.get(0);
    }
    LED getEnd(){
        return strip.get(strip.size()-1);
    }

    void alignXY(){
        FloatList xpos = new FloatList();
        FloatList ypos = new FloatList();
        for(LED l : strip) {
            xpos.append(l.pos.x);
            ypos.append(l.pos.y);
        }
        xpos.sort();
        ypos.sort();
        // check which axis the strip is in.
        if(xpos.max()-xpos.min() < ypos.max()-ypos.min()){
            // align X axis
            float median = xpos.get(xpos.size()/2);
            for(LED l : strip){
                l.pos.x = median;
            }
        }
        else {
            // align Y axis
            float median = ypos.get(ypos.size()/2);
            for(LED l : strip){
                l.pos.y = median;
            }
        }

    }
}

// class Segment {
//     LED start;
//     LED end;
//     public Segment(LED _start, LED _end) {
//         start = _start;
//         end = _end;
//     }
//     int getCount(){
//         return abs(start.address - end.address);
//     }
//     float length(){
//         return start.dist(end);
//     }
// }
