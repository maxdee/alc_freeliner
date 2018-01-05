/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// PositionGetters are responsible for fetching a position from a segment.
class Interpolator extends Mode {
    public Interpolator() {}
    public Interpolator(int _ind) {
        modeIndex = _ind;
        name = "Interpolator";
        description = "Pics a position in relation to a segment";
    }

    /**
     * Fetch a point from a segment
     * @param Segment to interpolate from
     * @param RenderableTemplate template being rendered
     * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
     * @return PVector the resulting coordinate
     */
    public PVector getPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        PVector _pos = findPosition(_seg, _tp, _lerp, _painter);
        _tp.setLastPosition(_pos);
        // catch NaN or Infinit
        if(_pos.x != _pos.x || _pos.y!=_pos.y) _pos.set(0,0);
        return _pos;
    }

    public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        PVector _pos = findPosition(_seg, _tp, _tp.getLerp(), _painter);
        _tp.setLastPosition(_pos);
        // catch NaN or Infinit
        if(_pos.x != _pos.x || _pos.y!=_pos.y) _pos.set(0,0);
        return _pos;
    }


    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        if(useOffset(_painter)) return _seg.getBrushPos(_lerp);
        else return _seg.getStrokePos(_lerp);
    }
    /**
     * We also need to know a which angle the thing will be at.
     * @param Segment to interpolate from
     * @param RenderableTemplate template being rendered
     * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
     * @return float angle
     */
    public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        return _seg.getAngle(false);
    }

    public boolean useOffset(Painter _painter) {
        if(_painter instanceof BrushPutter) return true;
        else if(_painter instanceof TextWritter) return true;
        else return false;
    }
    // might be a thing
    // public PVector getStart(){
    // }
    // public PVector getEnd(){
    // }
}

class OppositInterpolator extends Interpolator {
    public OppositInterpolator(int _ind) {
        modeIndex = _ind;
        name = "OppositInterpolator";
        description = "invert direction every segment";
    }
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        if(_seg.getID()%2 == 0) _lerp = 1.0-_lerp;
        if(useOffset(_painter)) return _seg.getBrushPos(_lerp);
        else return _seg.getStrokePos(_lerp);
    }

    public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        return _seg.getAngle(_seg.getID()%2 == 0);
    }
}

class SegmentOffsetInterpolator extends Interpolator {

    public SegmentOffsetInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "SegmentOffsetInterpolator";
        description = "Prototype thing that offsets the position according to segments X position.";
    }
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        float offset = _seg.getPointA().x/float(width);

        float _lrp = fltMod(_lerp + offset);
        if(useOffset(_painter)) return _seg.getBrushPos(_lrp);
        else return _seg.getStrokePos(_lrp);
    }
}


// front pointA to the center
class CenterSender extends Interpolator {

    public CenterSender(int _ind) {
        modeIndex = _ind;
        //super();
        name = "CenterSender";
        description = "Moves between pointA and center";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        if(useOffset(_painter)) return vecLerp(_seg.getBrushOffsetA(), _seg.getCenter(), _tp.getLerp());
        else return vecLerp(_seg.getStrokeOffsetA(), _seg.getCenter(), _lerp);
    }
    public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
    }
}


// interpolated halfway to the center
class HalfWayInterpolator extends Interpolator {

    public HalfWayInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "HalfWayInterpolator";
        description = "Moves along segment, but halfway to center.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        if(useOffset(_painter)) return vecLerp(_seg.getBrushPos(_lerp), _seg.getCenter(), 0.5);
        else return vecLerp(_seg.getStrokePos(_lerp), _seg.getCenter(), 0.5);
    }
    public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
    }
}

// on a radius of segment pointA
class RadiusInterpolator extends Interpolator {
    public RadiusInterpolator() {}
    public RadiusInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "RadiusInterpolator";
        description = "Rotates with segments as Radius.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        float dist = 0;
        if(useOffset(_painter)) dist = _seg.getLength()-(_tp.getScaledBrushSize()/2.0);
        else dist = _seg.getLength()-(_tp.getStrokeWeight()/2.0);
        // good we got dist.
        float ang = getAngle(_seg, _tp, _painter)-HALF_PI;
        PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
        pos.add(_seg.getPointA());
        return pos;
    }
    // added a clockwise counter clockwise option
    public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter) {
        if(!_seg.isClockWise()) return -(-_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
        return -(_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
    }
}

// from the middle of a segments
class DiameterInterpolator extends RadiusInterpolator {
    public DiameterInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "DiameterInterpolator";
        description = "Rotates with segments as diameter.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        float dist = 0;
        if(useOffset(_painter)) dist = (_seg.getLength()-(_tp.getScaledBrushSize()/2.0))/2.0;
        else dist = (_seg.getLength()-(_tp.getStrokeWeight()/2.0))/2.0;
        float ang = getAngle(_seg, _tp, _painter)-HALF_PI;

        PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
        pos.add(_seg.getMidPoint());
        return pos;
    }
}

class RandomRadiusInterpolator extends RadiusInterpolator {
    public RandomRadiusInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "RandomRadiusInterpolator";
        description = "Rotates with segments as diameter.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        float dist = 0;
        if(useOffset(_painter)) dist = _seg.getLength()-(_tp.getScaledBrushSize()/2.0);
        else dist = _seg.getLength()-(_tp.getStrokeWeight()/2.0);
        dist = random(dist);
        // good we got dist.
        float ang = getAngle(_seg, _tp, _painter)-HALF_PI;
        PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
        pos.add(_seg.getPointA());
        return pos;
    }
}

class RandomInterpolator extends Interpolator {
    public RandomInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "RandomInterpolator";
        description = "Provides random position between segment and center.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        PVector pos;
        if(useOffset(_painter)) pos = _seg.getBrushPos(random(0,1));
        else pos = _seg.getStrokePos(random(0,1));

        return vecLerp(pos, _seg.getCenter(), random(0,1));
    }

    //
    // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    //   return random(TAU);
    // }
}


class RandomExpandingInterpolator extends Interpolator {
    public RandomExpandingInterpolator(int _ind) {
        modeIndex = _ind;
        //super();
        name = "RandomExpandingInterpolator";
        description = "Provides an expanding random position between segment and center.";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        PVector pos;
        if(useOffset(_painter)) pos = _seg.getBrushPos(random(0,1));
        else pos = _seg.getStrokePos(random(0,1));

        return vecLerp(_seg.getCenter(), pos, random(0,_lerp));
    }

    //
    // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    //   return random(TAU);
    // }
}


class NoisyInterpolator extends Interpolator {
    public NoisyInterpolator(int _ind) {
        modeIndex = _ind;
        name = "NoisyInterpolator";
        description = "noise along segment";
    }
    // interpolate to center
    public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter) {
        PVector pos;
        if(useOffset(_painter)) pos = _seg.getBrushPos(_lerp);
        else pos = _seg.getStrokePos(_lerp);
        pos = angleMove(pos, _seg.getAngle(false)-HALF_PI, random(_tp.getScaledBrushSize())-_tp.getScaledBrushSize()/2);
        // float ang = getAngle(_seg, _tp, _painter)-HALF_PI;
        return pos;
    }
}
// // front midPoint to the center
// class MiddleCenterSender extends Interpolator{
//
//   public MiddleCenterSender(){
//     super();
//   }
//   // interpolate to center
//   public PVector findPosition(Segment _seg, RenderableTemplate _tp, float _lerp, Painter _painter){
//     PVector _pos;
//     if(useOffset(_painter)) _pos = vecLerp(_seg.getBrushOffsetA(), _seg.getBrushOffsetB(), 0.5);
//     else _pos = vecLerp(_seg.getStrokeOffsetA(), _seg.getStrokeOffsetB(), 0.5);
//     return vecLerp(_pos, _seg.getCenter(), _lerp);
//   }
//   public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
//     return atan2(_seg.getMidPoint().y - _seg.getCenter().y, _seg.getMidPoint().x - _seg.getCenter().x);
//   }
// }
