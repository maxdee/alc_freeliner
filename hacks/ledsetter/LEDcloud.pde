
class LEDcloud {
    ArrayList<LED> leds;
    BoundingBox box;
    float medianDistance;
    int clusterIndex;
    public LEDcloud(ArrayList<LED> _leds) {
        leds = _leds;
        box = new BoundingBox(this);
        clusterIndex = 0;
    }

    public void applyMatrix(){
        for(LED l : leds){
            l.pos = matrixIt(l.pos);
        }
    }

    void display() {
        strokeWeight(1);
        stroke(200,10,0);
        noFill();
        for(LED led : leds){
            led.display();
            // ellipse(led.pos.x, led.pos.y, 5, 5);
        }
        // box.display();
    }

    void nudgeAll(PVector _n) {
        for(LED _l : leds){
            _l.pos.add(_n);
        }
    }

    void click(PVector _c) {
        box.click(_c);
    }

    void drag(PVector _c) {
        box.drag(_c);
    }

    void findMedian(){
        FloatList distances = getDistances();
        distances.sort();
        medianDistance = distances.get(distances.size()/2);
        println("median distance : "+medianDistance);
    }

    void doClean(float slack){
        // drawLEDs(leds);

        // increase median distance by slack % to give some room to wiggle
        // medianDistance = medianDistance + (medianDistance * slack);
        // println ("Adding " + 100 * slack + "% slack to median distance. Is now "+ medianDistance);
        // println ("Detecting outliers...");
        // ArrayList<LED> outliers = getOutliers(_leds, medianDistance * slack);
        // println(outliers.size() + " outliers detected and fixed.");
        // translate(0, height/2);
        // drawLEDs(_leds);

        // println("clustering");
        // float ratio = 1.2;
        // float clusterSlack = 1.1;
        // ArrayList<Segment> segments = cluster(_leds, medianDistance * clusterSlack , ratio);
        // drawSegments(segments);
        // int pixelSpacing =

    }

    FloatList getDistances(){
        FloatList _dist = new FloatList();
        for(int i = 0; i < leds.size()-1; i++) {
            _dist.append(leds.get(i).dist(leds.get(i+1)));
        }
        return _dist;
    }

    void fixOutliers(float _slack, float _mult){
        float _median = _slack * medianDistance;
        // check of there's a pixel missing between two pixels
        ArrayList<LED> outliers = new ArrayList<LED>();
        for (int i = 0; i < leds.size()-2; i++) {
            LED led1 = leds.get(i);
            LED led2 = leds.get(i+1);
            LED led3 = leds.get(i+2);
            // if (dist(led1.x, led1.y, led3.x, led3.y) < medianDistance * startStopMultiplier && dist(led1.x, led1.y, led3.x, led3.y) > medianDistance * startStopMultiplier) {
            float multiplier = _mult; // formerly startStopMultiplier
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
        println("outliers :"+outliers.size());
        // return outliers;
    }

    ArrayList<Segment> cluster(float _median, float _ratio) {
        // check of there's a pixel missing between two pixels
        ArrayList<Segment> _segments = new ArrayList<Segment>();
        LED start = leds.get(0);
        LED end = null;

        for (int i = 1; i < leds.size()-2; i++) {
            LED led1 = leds.get(i);
            LED led2 = leds.get(i+1);
            LED led3 = leds.get(i+2);
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






}
