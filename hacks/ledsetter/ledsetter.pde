

// IntList numbers;

boolean redraw = true;

String project_name = "maptest";

void setup(){
    size(800, 800, P2D);
    background(0);

    // selectInput("Select a file to process:", "fileDialogCallback");
    // drawLEDs(loadFile("harhar.xml"));
    // doThing(loadFile("harhar_mess.xml"));
    doThing(loadFile("space_pubes_raw.xml"));

    // ledGroups = groupLEDs(leds);
    // sortLEDs(new ArrayList<LED>(leds), 0);
}

void stop(){
    // saveXML(fixtures, project_name+".xml");
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

void draw(){
    // redraw();
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


void doThing(ArrayList<LED> _leds){
    background(40);
    drawLEDs(_leds);
    FloatList distances = getDistances(_leds);
    distances.sort();
    float medianDistance = distances.get(distances.size()/2);
    println("median distance : "+medianDistance);

    // increase median distance by slack % to give some room to wiggle
    // medianDistance = medianDistance + (medianDistance * slack);
    // println ("Adding " + 100 * slack + "% slack to median distance. Is now "+ medianDistance);
    println ("Detecting outliers...");
    float slack = 1.8;
    ArrayList<LED> outliers = getOutliers(_leds, medianDistance * slack);
    println(outliers.size() + " outliers detected and fixed.");
    translate(0, height/2);
    drawLEDs(_leds);

    println("clustering");
    float ratio = 1.2;
    float clusterSlack = 1.1;
    ArrayList<Segment> segments = cluster(_leds, medianDistance * clusterSlack , ratio);
    drawSegments(segments);
    // int pixelSpacing =
}

ArrayList<LED> getOutliers(ArrayList<LED> _leds, float _median){
    // check of there's a pixel missing between two pixels
    ArrayList<LED> outliers = new ArrayList<LED>();
    for (int i = 0; i < _leds.size()-2; i++) {
        LED led1 = _leds.get(i);
        LED led2 = _leds.get(i+1);
        LED led3 = _leds.get(i+2);
        // if (dist(led1.x, led1.y, led3.x, led3.y) < medianDistance * startStopMultiplier && dist(led1.x, led1.y, led3.x, led3.y) > medianDistance * startStopMultiplier) {
        float multiplier = 1.8; // formerly startStopMultiplier
        // find the mid point between 1 and 3 and compare to median
        if(vecLerp(led1.pos, led3.pos, 0.5).dist(led1.pos) < _median*multiplier){
            // assume that both are part of a strip and led 2 should be in between them
            if (led1.dist(led2) > _median && led2.dist(led3) > _median) {
                stroke (255, 255, 0);
                line (led1.pos.x, led1.pos.y, led2.pos.x, led2.pos.y);
                line (led2.pos.x, led2.pos.y, led3.pos.x, led3.pos.y);

                // most likely an outlier
                // put led 2 between led 1 and 3
                led2.pos = vecLerp(led1.pos, led3.pos, 0.5);
                // put address into list of outliers
                outliers.add(led2);
                stroke(0, 255, 255);
                point(led2.pos.x, led2.pos.y);
            }
        }
    }
    return outliers;
}

ArrayList<Segment> cluster(ArrayList<LED> _leds, float _median, float _ratio) {
    // check of there's a pixel missing between two pixels
    ArrayList<Segment> _segments = new ArrayList<Segment>();
    LED start = _leds.get(0);
    LED end = null;

    for (int i = 1; i < _leds.size()-2; i++) {
        LED led1 = _leds.get(i);
        LED led2 = _leds.get(i+1);
        LED led3 = _leds.get(i+2);
        // if led1 is far away and led 3 is close: assume that led2 is the starting point
        if(led1.dist(led2) > _median && led2.dist(led3) < _median) {
            start = led2;
        }
        // if led3 is far and led 1 is close: assume that led2 is an end point
        else if(led1.dist(led2) < _median && led2.dist(led3) > _median) {
            end = led2;
        }
        // we have a finished line
        if(end != null && start != null) {
            if(start.dist(end) > _median * _ratio) {
                _segments.add(new Segment(start, end));
            }
            // reset
            end = null;
            start = null;
        }
    }
    return _segments;
}

FloatList getDistances(ArrayList<LED> _leds){
    FloatList _dist = new FloatList();
    for(int i = 0; i < _leds.size()-1; i++) {
        _dist.append(_leds.get(i).dist(_leds.get(i+1)));
    }
    return _dist;
}

/**
 * linear interpolation between two PVectors
 * @param PVector first vector
 * @param PVector second vector
 * @param float unit interval
 * @return PVector interpolated
 */
PVector vecLerp(PVector a, PVector b, float l){
  return new PVector(lerp(a.x, b.x, l), lerp(a.y, b.y, l), 0);
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


class LED {
    PVector pos;
    int address;
    boolean selected = false;
    int groupIndex = 0;
    public LED(float _x, float _y, int _a){
        pos = new PVector(_x, _y);
        address = _a;
    }
    public LED(XML _xml) {
        pos =  new PVector(_xml.getFloat("x"), _xml.getFloat("y"));
        address = (int)_xml.getFloat("a");
    }
    float dist(LED _other){
        return pos.dist(_other.pos);
    }
}
