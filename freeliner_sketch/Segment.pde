/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



/**
 * A segment consist of two vertices with special other data as a offset line.
 */
class Segment {
    // these are the main coordinates of the start and end of a segment
    PVector pointA;
    PVector pointB;
    // these are the coordinates of the offset of the brush size
    PVector brushOffsetA;
    PVector brushOffsetB;
    PVector strokeOffsetA;
    PVector strokeOffsetB;

    // these are alternative positions for pointA and pointB
    PVector ranA;
    PVector ranB;

    // previous and or next segments, needed to create offset line
    Segment neighbA;
    Segment neighbB;

    // center position of the segment
    PVector center;

    float scaledSize;
    float strokeWidth;

    float angle;
    //float anglePI;
    boolean centered;
    boolean clockWise;
    float ranFloat;
    int id;
    float length;
    float lerp;

    String segmentText;

    boolean hiddenSegment;

    public Segment(PVector pA, PVector pB) {

        pointA = pA.get();
        pointB = pB.get();
        center = new PVector(0, 0, 0);
        newRan();
        brushOffsetA = new PVector(0,0,0);
        brushOffsetB = new PVector(0,0,0);
        strokeOffsetA = new PVector(0,0,0);
        strokeOffsetB = new PVector(0,0,0);
        scaledSize = 10;
        strokeWidth  = 3;
        centered = false;
        lerp = 0;
        length = 0;
        updateAngle();
        segmentText = "freeliner!";
        hiddenSegment = false;
    }

    public void updateAngle() {
        angle = atan2(pointA.y-pointB.y, pointA.x-pointB.x);
        //anglePI = angle + PI;
        if(pointA.x > pointB.x) {
            if(pointA.y > pointB.y) clockWise = false;
            else clockWise = true;
        }
        else if(pointA.y > pointB.y) clockWise = true;
        else clockWise = false;
        length = dist(pointA.x, pointA.y, pointB.x, pointB.y);
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void newRan() {
        ranA = new PVector(pointA.x+random(-100, 100), pointA.y+random(-100, 100), 0);
        ranB = new PVector(pointB.x+random(-100, 100), pointB.y+random(-100, 100), 0);
        ranFloat = 1+random(50)/100.0;
    }

    public void setNeighbors(Segment a, Segment b) {
        neighbA = a;
        neighbB = b;
        findOffset();
    }

    private void findOffset() {
        if(neighbA == null || neighbB == null) return;
        brushOffsetA = inset(pointA, neighbA.getPointA(), pointB, center, scaledSize + strokeWidth, neighbA.getPointB());
        brushOffsetB = inset(pointB, pointA, neighbB.getPointB(), center, scaledSize + strokeWidth, neighbB.getPointA());
        strokeOffsetA = inset(pointA, neighbA.getPointA(), pointB, center, strokeWidth, neighbA.getPointB());
        strokeOffsetB = inset(pointB, pointA, neighbB.getPointB(), center, strokeWidth, neighbB.getPointA());
    }

    public void setPointA(PVector p) {
        pointA = p.get();
        updateAngle();
    }

    public void setPointB(PVector p) {
        pointB = p.get();
        updateAngle();
    }

    public void setCenter(PVector c) {
        centered = true;
        //scaledSize = 0;
        center = c.get();
        findOffset();
    }

    public void unCenter() {
        centered = false;
    }

    public void setSize(float _s) {
        if(_s != scaledSize && centered) {
            scaledSize = _s;
            findOffset();
        }
    }

    public void setStrokeWidth(float _w) {
        if(_w != scaledSize && centered) {
            strokeWidth = _w;
            findOffset();
        }
    }

    public void setText(String w) {
        segmentText = w;
    }

    public void setID(int _id) {
        id =_id;
    }

    public void toggleHidden() {
        hiddenSegment = !hiddenSegment;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Offset by brush size
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * This is to generate new vertices in relation to brush size.
     * @param PVector vertex to offset
     * @param PVector previous neighboring vertex
     * @param PVector following neighboring vertex
     * @param PVector center of shape
     * @param float distance to offset
     * @param PVector an other to point to check if the offset should be perpendicular
     * @return PVector offseted vertex
     */
    PVector inset(PVector p, PVector pA, PVector pB, PVector c, float d, PVector ot) {
        float angleA = (atan2(p.y-pA.y, p.x-pA.x));
        float angleB = (atan2(p.y-pB.y, p.x-pB.x));
        float A = radianAbs(angleA);
        float B = radianAbs(angleB);
        float ang = abs(A-B)/2; //the shortest angle
        d = (d/2);
        if(p.dist(ot) > 3.0) ang = HALF_PI + angle;
        else {
            d = d/sin(ang);
            if (A<B) ang = (ang+angleA);
            else ang = (ang+angleB);
        }

        PVector outA = new PVector(cos(ang)*d, sin(ang)*d, 0);
        PVector outB = new PVector(cos(ang+PI)*d, sin(ang+PI)*d, 0);
        outA.add(p);
        outB.add(p);

        PVector offset;
        if (c.dist(outA) < c.dist(outB)) return outA;
        else  return outB;
    }

    float radianAbs(float a) {
        while (a<0) {
            a+=TWO_PI;
        }
        while (a>TWO_PI) {
            a-=TWO_PI;
        }
        return a;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void setLerp(float _lrp) {
        lerp = _lrp;
    }

    /**
     * POINT POSITIONS
     */

    /**
     * Get the first vertex
     * @return PVector pointA
     */
    public final PVector getPointA() {
        return pointA;
    }

    /**
     * Get the second vertex
     * @return PVector pointB
     */
    public final PVector getPointB() {
        return pointB;
    }

    /**
     * Get pointA's strokeWidth offset
     * @return PVector offset of stroke width
     */
    public final PVector getStrokeOffsetA() {
        if(!centered) return pointA;
        return strokeOffsetA;
    }

    /**
     * Get pointB's strokeWidth offset
     * @return PVector offset of stroke width
     */
    public final PVector getStrokeOffsetB() {
        if(!centered) return pointB;
        return strokeOffsetB;
    }

    /**
     * Get pointA's brushSize offset
     * @return PVector offset of brushSize
     */
    public final PVector getBrushOffsetA() {
        if(!centered) return pointA;
        return brushOffsetA;
    }

    /**
     * Get pointB's brushSize offset
     * @return PVector offset of brushSize
     */
    public final PVector getBrushOffsetB() {
        if(!centered) return pointB;
        return brushOffsetB;
    }

    /**
     * INTERPOLATED POSTIONS
     */

    /**
     * Interpolate between pointA and pointB, offset by brush if centered
     * @param float unit interval (lerp)
     * @return PVector interpolated position
     */
    public final PVector getBrushPos(float _l) {
        if (centered) return vecLerp(brushOffsetA, brushOffsetB, _l);
        else return vecLerp(pointA, pointB, _l);
    }

    /**
     * Interpolate between pointA and pointB, offset by strokeWidth if centered
     * @param float unit interval (lerp)
     * @return PVector interpolated position
     */
    public final PVector getStrokePos(float _l) {
        if (centered) return vecLerp(strokeOffsetA, strokeOffsetB, _l);
        else return vecLerp(pointA, pointB, _l);
    }

    //random pos
    public final PVector getRanA() {
        return ranA;
    }

    public final PVector getRanB() {
        return ranB;
    }

    // other stuff
    public final boolean isCentered() {
        return centered;
    }

    public final boolean isClockWise() {
        return clockWise;
    }

    public final boolean isHidden() {
        return hiddenSegment;
    }

    public final float getAngle(boolean inv) {
        if(inv) return angle+PI;
        return angle;
    }

    public final float getRanFloat() {
        return ranFloat;
    }

    public final float getLength() {
        return length;
    }

    public final float getLerp() {
        return lerp;
    }

    public final PVector getCenter() {
        return center;
    }

    public final PVector getMidPoint() {
        return vecLerp(pointA, pointB, 0.5);
    }

    public final String getText() {
        return segmentText;
    }

    public final Segment getNext() {
        return neighbB;
    }

    public final Segment getPrev() {
        return neighbA;
    }
    public final int getID() {
        return id;
    }
}


class LerpSegment {
    Segment segment;
    float lerp;
    public LerpSegment(Segment _seg, float _lerp){
        segment = _seg;
        lerp = _lerp;
    }
    public Segment getSegment(){
        if(segment != null){
            segment.setLerp(lerp);
            return segment;
        }
        else return null;
    }
}
