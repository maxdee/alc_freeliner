import oscP5.*;
import netP5.*;

OscP5 oscP5;
// OscP5 sender;
NetAddress address;

void setup(){
    size(10, 10);
    oscP5 = new OscP5(this,6670);
    address = new NetAddress("127.0.0.1", 6667);

    // // makeShaderThing();
    // println("ahah");
    // background(0);
    // circleSub();
    // moveStuff(128, 128);
    parseGeom(2, "/home/mxd/user_data/geometry/geometry.xml");
    exit();
}

void loop(){
    println("here");

}
// int globalIndex = ;
void parseGeom(int _i, String _fileName){
    XML file = loadXML(_fileName);
    float wit = float(file.getInt("width"));
    float heit = float(file.getInt("height"));
    float scaler = heit/wit;
    // globalIndex = file.getChildCount();
    // clear(_i+1);
    // clear(_i+2);
    // clear(3);

    ArrayList<Polygon> subdividePolys = new ArrayList<Polygon>();
    for(XML grp : file.getChildren("group")){
        if(grp.getInt("ID") < 10){
            Polygon newPoly = new Polygon();
            for(XML seg : grp.getChildren("segment")){
                float ax = seg.getFloat("aX");
                float ay = seg.getFloat("aY");
                float bx = seg.getFloat("bX");
                float by = seg.getFloat("bY");
                Segment _seg = new Segment(new PVector(ax, ay), new PVector(bx, by));
                newPoly.addEdge(_seg);
                println("adding segment "+_seg);
            }
            if(grp.getInt("ID") == 2)
                subdividePolys.addAll( subdivideN(0.2, 12, newPoly) );
        }
    }
    int idx = 10;
    for(int i = idx; i < 2000; i++) clear(i);
    for(Polygon poly: subdividePolys){
        clear(idx);
        pushPolygon(idx, poly);
        setCenter(idx, poly.edges.get(0).pointA);
        addTemplate(idx, 'B');
        idx++;
    }
    // saveXML(file,"tweked.xml");
    println("done tweakin");
    exit();
}

ArrayList<Polygon> subdivideN(float _f, int iterations, Polygon seedPoly) {
    ArrayList<Polygon> result = new ArrayList<Polygon>();
    result.add(seedPoly);
    for (int i = 0; i < iterations; ++i) {
        ArrayList<Polygon> iterationPolys = new ArrayList<Polygon>();
        for (Polygon poly : result) {
            println("subdiving "+poly);
            ArrayList<Polygon> outPolys = poly.subdivide(_f);
            iterationPolys.addAll(outPolys);
            println("now have "+iterationPolys.size());
        }
        result = iterationPolys;
    }
    return result;
}

class Polygon {
    ArrayList<Segment> edges = new ArrayList<Segment>();

    Polygon() {}

    void addEdge(Segment newEdge) {
        edges.add(newEdge);
    }

    void translate(PVector translation) {
        for (Segment edge : edges) {
            edge.pointA.add(translation);
            edge.pointB.add(translation);
        }
    }

    Segment getPerp(int _edge, float _f) {
        // if(_edge < this.edges.size()) return null;
        Segment perpA = this.edges.get(_edge).getPerp(_f, true);
        Segment perpB = this.edges.get(_edge).getPerp(_f, false);
        for (int i = 0; i < this.edges.size(); ++i) {
            if(i != _edge){
                if(intersection(perpA, this.edges.get(i), new PVector(0,0))) {
                    return perpA;
                } else if(intersection(perpB, this.edges.get(i), new PVector(0,0))) {
                    return perpB;
                }
            }
        }
        return null;
    }

    ArrayList<Polygon> subdivide(float _f){
        int longestEdgeIdx = -1;
        float max = 0.0;
        for(int i = 0; i < this.edges.size(); ++i) {
            if(this.edges.get(i).getLength() > max) {
                longestEdgeIdx = i;
                max = this.edges.get(i).getLength();
            }
        }
        Segment perp = getPerp(longestEdgeIdx, _f);

        ArrayList<Polygon> outPolys = new ArrayList<Polygon>();

        if(perp == null) return outPolys;
        PVector result = new PVector(0,0);
        int dstEdgeIdx = -1;
        for (int i = 0; i < this.edges.size(); ++i) {
            if(i != longestEdgeIdx){
                if(intersection(perp, this.edges.get(i),result)) {
                    dstEdgeIdx = i;
                    perp.pointB.set(result);
                    break;
                }
            }
        }
        // pushSegment(3, perp);
        // addTemplate(5, 'D');
        // this.edges.add(perp);
        // ArrayList<Polygon> foo = new ArrayList<Polygon>();
        // foo.add(this);
        // return foo;
        // Now actually cut the poly into two with the perp
        Polygon polyA = new Polygon();
        Polygon polyB = new Polygon();

        // Create the first polygon
        polyA.addEdge(new Segment(perp.pointA, this.edges.get(longestEdgeIdx).pointB));

        int idx = longestEdgeIdx;
        idx %= this.edges.size();
        boolean closed = (idx == dstEdgeIdx);
        while (!closed) {
            idx++;
            idx %= this.edges.size();
            closed = (idx == dstEdgeIdx);
            if(!closed){
                polyA.addEdge(this.edges.get(idx));
            }
        }
        // do the last edge
        polyA.addEdge(new Segment(this.edges.get(idx).pointA, perp.pointB));
        polyA.addEdge(new Segment(perp.pointB, perp.pointA));
        println("made Polygon A!");
        // Create the second Polygon
        polyB.addEdge(new Segment(perp.pointB, this.edges.get(dstEdgeIdx).pointB));

        idx = dstEdgeIdx;
        idx %= this.edges.size();
        closed = (idx == longestEdgeIdx);
        while (!closed) {
            idx++;
            println(idx);
            idx %= this.edges.size();
            closed = (idx == longestEdgeIdx);
            if(!closed){
                polyB.addEdge(this.edges.get(idx));
            }
        }

        // do the last edge
        polyB.addEdge(new Segment(this.edges.get(longestEdgeIdx).pointA, perp.pointA));
        polyB.addEdge(new Segment(perp.pointA, perp.pointB));
        outPolys.add(polyA);
        outPolys.add(polyB);
        return outPolys;
    }
}

class Segment {
    PVector pointA;
    PVector pointB;
    Segment(PVector _a, PVector _b){
        pointA = _a.copy();
        pointB = _b.copy();
    }
    PVector getPos(float _f){
        return vecLerp(pointA, pointB, _f);
    }
    Segment getPerp(float _f, boolean direction) {
        PVector newPoint = getPos(_f);
        PVector slope;
        if(direction) {
            slope = PVector.sub(pointB, pointA);
        } else {
            slope = PVector.sub(pointA, pointB);
        }
        slope.normalize();
        slope.x += 0.6;
        slope.mult(20000.0);
        PVector endPoint = new PVector(-slope.y, slope.x);
        endPoint.add(newPoint);
        return new Segment(newPoint, endPoint);
    }
    float getLength(){
        return pointA.dist(pointB);
    }
}

/////////////////////////////////////////////////////////////////////////////

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

/**
 * linear interpolation between two PVectors
 * @param PGraphics to draw on
 * @param PVector first coordinate
 * @param PVector second coordinate
 */
void vecLine(PGraphics p, PVector a, PVector b){
  p.line(a.x,a.y,b.x,b.y);
}

/////////////////////////////////////////////////////////////////////////////

void pushPolygon(int _i, Polygon polygon) {
    clear(_i);
    for (Segment edge : polygon.edges) {
        pushSegment(_i, edge);
    }
}

void pushSegment(int _i, Segment edge) {
    addSegment(_i, edge.pointA, edge.pointB);
}

void clear(int _i){
    OscMessage myMessage = new OscMessage("/geom/clear/"+_i);
    send(myMessage);
}

void addTemplate(int _i, char _t) {
  OscMessage myMessage = new OscMessage("/tp/toggle/"+_t+"/"+_i);
  send(myMessage);
}

void newGroup(int _i) {
  OscMessage myMessage = new OscMessage("/geom/new/"+_i);
  send(myMessage);
}

void addSegment(int _i, PVector _a, PVector _b){
    int _x1 = (int)_a.x;
    int _y1 = (int)_a.y;
    int _x2 = (int)_b.x;
    int _y2 = (int)_b.y;
    OscMessage myMessage = new OscMessage("/geom/addseg/"+_i+"/"+_x1+"/"+_y1+"/"+_x2+"/"+_y2);
    send(myMessage);
}
void setCenter(int _i, PVector _p){
    setCenter(_i, (int) _p.x, (int) _p.y);
}
void setCenter(int _i, int _x, int _y){
    OscMessage myMessage = new OscMessage("/geom/center/"+_i+"/"+_x+"/"+_y);
    send(myMessage);
}

void send(OscMessage _osc){
    // println(_osc);
    // sender.send(_osc);
    oscP5.send(_osc, address);
}
