import oscP5.*;
import netP5.*;

OscP5 oscP5;
// OscP5 sender;
NetAddress address;

// IntList numbers;

boolean redraw = true;

String project_name = "maptest";

LEDcloud cloud;

void setup(){
    size(800, 800, P2D);
    background(0);
    frameRate(20);

    oscP5 = new OscP5(this,6670);
    address = new NetAddress("127.0.0.1", 6667);
    // selectInput("Select a file to process:", "fileDialogCallback");
    // drawLEDs(loadFile("harhar.xml"));
    // doThing(loadFile("harhar_mess.xml"));
    // doThing(loadFile("space_pubes_raw.xml"));
    // cloud = new LEDcloud(loadFile("space_pubes_raw_thursday.xml"));
    cloud = new LEDcloud(loadFile("clustered_save.xml"));

    // ledGroups = groupLEDs(leds);
    // sortLEDs(new ArrayList<LED>(leds), 0);


    // background(40);
    // cloud.display();
    // cloud.applyMatrix();
    // translate(0, width/2);
    // cloud.display();

    background(40);
    // cloud.display();
    int prev=0;
    color c = color(255,0,0);
    strokeWeight(4);
    for(LED l : cloud.leds) {
        println(l.clusterIndex);
        if(l.clusterIndex != prev) {
            c = color(random(255),random(255),random(255));
            stroke(c);
            prev = l.clusterIndex;
        }
        point(l.pos.x,l.pos.y);
    }
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


    // background(40);
    // cloud.display();
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
void keyPressed(){
    if(key == '-') clusterPrevious();
    if(key == '=') clusterNext();
    if(key == ' ') closeCluster();
    else if(key == 27){
        stop();
    }
}
void stop() {
    println("saving and quitting");
    XML fixtures = new XML("fixture");
    for(LED led : cloud.leds) {
        XML xyled = new XML("xyled");
        xyled.setFloat("a", led.address);
        xyled.setFloat("x", led.pos.x);
        xyled.setFloat("y", led.pos.y);
        xyled.setFloat("c", led.clusterIndex);
        fixtures.addChild(xyled);
        // point(_x, _y);
    }
    saveXML(fixtures, "clustered.xml");
    // saveXML(fixtures, "hihi.xml");
}

void mousePressed(){
    PVector _c = new PVector(mouseX, mouseY);
    cloud.click(_c);
}

void mouseDragged(){
    PVector _c = new PVector(mouseX, mouseY);
    cloud.drag(_c);
}

void drawLEDs(ArrayList<LED> _leds) {
    strokeWeight(1);
    stroke(200,10,0);
    noFill();
    for(LED led : _leds){
        ellipse(led.pos.x, led.pos.y, 5, 5);
    }
}

void drawSegments(ArrayList<Segment> _segs) {
    stroke(255,100);
    strokeWeight(6);
    for(Segment _seg : _segs) {
        line(_seg.start.pos.x, _seg.start.pos.y, _seg.end.pos.x, _seg.end.pos.y);
    }
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
        stroke(col);
        strokeWeight(1);
        if(selected) fill(0,255,0);
        else noFill();
        ellipse(pos.x, pos.y, size, size);
    }
}

class BoundingBox {
    ArrayList<Handle> handles;
    LEDcloud parent;
    Handle topLeft;
    Handle topRight;
    Handle bottomRight;
    Handle bottomLeft;
    Handle middle;
    Handle bottomMiddle;
    Handle topMiddle;
    Handle leftMiddle;
    Handle rightMiddle;

    public BoundingBox(LEDcloud _p) {
        parent = _p;
        handles = new ArrayList<Handle>();
        setupHandles(parent.leds);
    }

    void click(PVector _c) {
        for(Handle _h : handles) {
            _h.click(_c);
        }
    }

    void drag(PVector _c) {
        if(middle.selected) {
            PVector _prev = middle.pos.copy();
            middle.drag(_c);
            _prev.sub(middle.pos);
            _prev.mult(-1.0);
            // apply to leds
            parent.nudgeAll(_prev);
            for(Handle _h : handles) {
                if(_h != middle){
                    _h.pos.add(_prev);
                }
            }
        }
        else {
            for(Handle _h : handles) {
                _h.drag(_c);
            }
        }
        updateHandles();
    }

    void updateHandles() {
        middle.pos.set(
            vecLerp(
                vecLerp(topRight.pos, bottomLeft.pos, 0.5),
                vecLerp(topLeft.pos, bottomRight.pos, 0.5),
                0.5
            )
        );
        topMiddle.pos.set(vecLerp(topLeft.pos, topRight.pos, 0.5));
        bottomMiddle.pos.set(vecLerp(bottomLeft.pos, bottomRight.pos, 0.5));
        rightMiddle.pos.set(vecLerp(topRight.pos, bottomRight.pos, 0.5));
        leftMiddle.pos.set(vecLerp(topLeft.pos, bottomLeft.pos, 0.5));
    }

    void setupHandles(ArrayList<LED> _leds){
        float minX = width;
        float maxX = 0;
        float minY = height;
        float maxY = 0;

        for(LED led : _leds) {
            if(led.pos.x < minX) minX = led.pos.x;
            if(led.pos.x > maxX) maxX = led.pos.x;
            if(led.pos.y < minY) minY = led.pos.y;
            if(led.pos.y > maxY) maxY = led.pos.y;
        }

        topLeft = new Handle(new PVector(minX, minY));
        topRight = new Handle(new PVector(maxX, minY));
        bottomRight = new Handle(new PVector(maxX, maxY));
        bottomLeft = new Handle(new PVector(minX, maxY));
        middle = new Handle(vecLerp(topLeft.pos, bottomRight.pos, 0.5));
        topMiddle = new Handle(vecLerp(topLeft.pos, topRight.pos, 0.5));
        bottomMiddle = new Handle(vecLerp(bottomLeft.pos, bottomRight.pos, 0.5));
        rightMiddle = new Handle(vecLerp(topRight.pos, bottomRight.pos, 0.5));
        leftMiddle = new Handle(vecLerp(topLeft.pos, bottomLeft.pos, 0.5));

        handles.clear();
        handles.add(topLeft);
        handles.add(topRight);
        handles.add(bottomRight);
        handles.add(bottomLeft);
        handles.add(middle);
        handles.add(topMiddle);
        handles.add(bottomMiddle);
        handles.add(rightMiddle);
        handles.add(leftMiddle);
    }
    void display(){
        for(Handle _h : handles) {
            _h.display();
        }
    }
}



class Handle {
    PVector pos;
    color col;
    int size;
    boolean selected = false;
    public Handle(){

    }
    public Handle(PVector _pos) {
        pos = _pos.copy();
        size = 10;
        col = color(255,255,255, 100);
    }

    public void display(){
        stroke(col);
        strokeWeight(1);
        if(selected) fill(0,255,0);
        else noFill();
        ellipse(pos.x, pos.y, size, size);
    }

    public void click(PVector _click) {
        if(_click.dist(pos) < size/2) selected = true;
        else selected = false;
    }

    public void drag(PVector _drag){
        if(selected) {
            pos.set(_drag);
        }
    }

    // public void hover(PVector hover) {
    //
    // }
    public Handle setStroke(color _c){
        col = _c;
        return this;
    }

    public Handle setSize(int _s){
        size = _s;
        return this;
    }

}



// the item interface standardises selection  and deletion and such?
// interface Item {
//     boolean selected;
// }
class Segment {
    LED start;
    LED end;
    public Segment(LED _start, LED _end) {
        start = _start;
        end = _end;
    }
    int getCount(){
        return abs(start.address - end.address);
    }
    float length(){
        return start.dist(end);
    }
}
