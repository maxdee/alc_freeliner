

IntList numbers;
XML fixtures;

void setup(){
    size(800, 800, P2D);
    fixtures = new XML("fixture");
    background(0);

    // int _spread = 190;
    // plotTriangle(0, _spread+20, 40);
    // plotTriangleUp(170, 2*_spread+20, 180);
    // plotTriangle(340, 3*_spread+20, 40);
    // // plotTriangleUp(510, 4*_spread+20, 180);

    // specialMap();
    // saveXML(fixtures, "haha.xml");
    // exit();
}



void stop(){
    saveXML(fixtures, "haha.xml");
}

void draw(){
    background(0);
    noFill();
    translate(width/2, height/2);
    PShape haha = createShape();
    haha.stroke(0,100,0);
    haha.beginShape();
    haha.curveVertex(84,  91);
    haha.curveVertex(84,  91);
    haha.curveVertex(68,  19);
    haha.curveVertex(21,  17);
    haha.curveVertex(32, 100);
    haha.curveVertex(32, 100);
    haha.endShape();

    // shape(haha);

    stroke(255);
    strokeWeight(1);
    for (int i = 0; i < haha.getVertexCount(); i++) {
        PVector v = haha.getVertex(i);
        // for(int j = 0; )
        point(v.x, v.y);
    }
}


void specialMap(){
    int _ledCount = 1357;
    int _indexCount = 32;
    int lx[] = {-24, -38, -72, -95, -84, -44, -35, -64, -95, -116, -94, -52, -20, 8, 29, 69, 35+69, 73+69, 106+69, 102+69, 64+69, 26+69, 17+69, 59+69, 91+69, 76+69, 36+69, 67, 38, 15, 0, -7};
    int ly[] = {88, 119, 130, 98, 67, 67, 95, 121, 103, 64, 24, 26, 53, 81, 99, 103, 98, 87, 89, 10+89, 109, 92, 56, 47, 66, 103, 118, 109, 80, 45, 23, 48};

    // int _index = _start;
    // addLED(_index, (int)_pos.x, (int)_pos.y);
    beginShape();
    int _index = 0;
    for(int i = 0; i < _ledCount; i++){
        _index = int(i / 42.4);
        println(_index+1);
        int _x = 2*(int)lerp(lx[_index]+116, lx[(_index+1)%_indexCount]+116, (i%42.4)/42.4);
        int _y = 2*(int)lerp(ly[_index], ly[(_index+1)%_indexCount], (i%42.4)/42.4);
        addLED(i, _x, _y);
    }
    endShape();
}


void addLED(int _index, int _x, int _y){
    text(_index, _x, _y);
    XML xyled = new XML("xyled");
    xyled.setFloat("a", _index*3);
    xyled.setFloat("x", _x);
    xyled.setFloat("y", _y);
    fixtures.addChild(xyled);
    point(_x, _y);
}

void plotTriangle(int _start, int _startX, int _startY){

    int _size = 8;
    int _gap = 24;
    PVector _pos = new PVector(_startX, _startY);
    int _index = _start;
    for(int i = _size; i >= 0; i--){
        for(int j = 0; j < i; j++){
            _pos.x += (i%2 == 0) ? -_gap : _gap;
            addLED(_index, (int)_pos.x, (int)_pos.y);
            _index++;
        }
        _pos = angleMove(_pos, radians((i%2 == 1) ? 120 : 60), _gap);
        _pos.x += (i%2 == 0) ? -_gap : _gap;
    }
    println(_index);
}



void plotTriangleUp(int _start, int _startX, int _startY){

    int _size = 8;
    int _gap = 24;
    PVector _pos = new PVector(_startX, _startY);
    int _index = _start;
    for(int i = _size; i >= 0; i--){
        for(int j = 0; j < i; j++){
            _pos.x += (i%2 == 0) ? -_gap : _gap;
            addLED(_index, (int)_pos.x, (int)_pos.y);
            _index++;
        }
        _pos = angleMove(_pos, radians((i%2 == 1) ? 60 : 120), -_gap);
        _pos.x += (i%2 == 0) ? -_gap : _gap;
    }
    println(_index);
}

/**
 * Polar to euclidean conversion
 * @param PVector center point
 * @param float angle
 * @param float distance
 * @return PVector euclidean of polar
 */
PVector angleMove(PVector p, float a, float s){
  PVector out = new PVector(cos(a)*s, sin(a)*s, 0);
  out.add(p);
  return out;
}


void circlething(){
    background(0);
    stroke(100);
    strokeWeight(3);
    int _numberCount = numbers.size();
    XML fixtures = new XML("fixture");
    float gaps = TWO_PI/(float)_numberCount;
    float angle = 0;
    float radius = 256;
    for(int i : numbers){
        println(i);
        float _x = cos(angle)*radius;
        _x += width/2;
        float _y = sin(angle)*radius;
        _y += height/2;
        XML xyled = new XML("xyled");
        xyled.setFloat("a", i*3);
        xyled.setFloat("x", _x);
        xyled.setFloat("y", _y);
        fixtures.addChild(xyled);
        point(_x, _y);
        angle += gaps;
    }
}

void setAddressArray(){
    int groupCount = 7;
    int[][] ranges = {{516,659},
                      {341, 489},
                      {1,149},
                      {171,319},
                      {1021,1169},
                      {851, 999},
                      {1191, 1357}};
    numbers = new IntList();
    for(int i = 0; i < groupCount; i++){
        for(int j = ranges[i][0]; j <= ranges[i][1]; j++){
            numbers.append(j);
        }
    }
}
