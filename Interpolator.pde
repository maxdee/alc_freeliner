/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// PositionGetters are responsible for fetching a position from a segment.
class Interpolator{

  public Interpolator(){}

  /**
   * Fetch a point from a segment
   * @param Segment to interpolate from
   * @param RenderableTemplate template being rendered
   * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
   * @return PVector the resulting coordinate
   */
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(_painter instanceof BrushPutter) return _seg.getBrushPos(_tp.getLerp());
    else return _seg.getStrokePos(_tp.getLerp());
  }

  /**
   * We also need to know a which angle the thing will be at.
   * @param Segment to interpolate from
   * @param RenderableTemplate template being rendered
   * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
   * @return float angle
   */
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return _seg.getAngle(false);
  }

  // might be a thing
  // public PVector getStart(){
  // }
  // public PVector getEnd(){
  // }
}

class SegmentOffsetInterpolator extends Interpolator{

  public SegmentOffsetInterpolator(){
    super();
  }
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    float offset = _seg.getPointA().x/float(width);

    float _lrp = fltMod(_tp.getLerp()+offset);
    if(_painter instanceof BrushPutter) return _seg.getBrushPos(_lrp);
    else return _seg.getStrokePos(_lrp);
  }
}


// front pointA to the center
class CenterSender extends Interpolator{

  public CenterSender(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(_painter instanceof BrushPutter) return vecLerp(_seg.getBrushOffsetA(), _seg.getCenter(), _tp.getLerp());
    else return vecLerp(_seg.getStrokeOffsetA(), _seg.getCenter(), _tp.getLerp());
  }
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
  }
}


// interpolated halfway to the center
class HalfWayInterpolator extends Interpolator{

  public HalfWayInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(_painter instanceof BrushPutter) return vecLerp(_seg.getBrushPos(_tp.getLerp()), _seg.getCenter(), 0.5);
    else return vecLerp(_seg.getStrokePos(_tp.getLerp()), _seg.getCenter(), 0.5);
  }
  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return atan2(_seg.getPointA().y - _seg.getCenter().y, _seg.getPointA().x - _seg.getCenter().x);
  }
}

// on a radius of segment pointA
class RadiusInterpolator extends Interpolator{
  public RadiusInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
	  float dist = 0;
    if(_painter instanceof BrushPutter) dist = _seg.getLength()-(_tp.getScaledBrushSize()/2.0);
    else dist = _seg.getLength()-(_tp.getStrokeWeight()/2.0);
  	float ang = (_tp.getLerp()*TAU)+_seg.getAngle(true);//getAngle(_seg, _tp, _painter);

  	PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
  	pos.add(_seg.getPointA());
    return pos;
  }

  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return (_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
  }
}

// from the middle of a segments
class DiameterInterpolator extends Interpolator{
  public DiameterInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
	  float dist = 0;
    if(_painter instanceof BrushPutter) dist = (_seg.getLength()-(_tp.getScaledBrushSize()/2.0))/2.0;
    else dist = (_seg.getLength()-(_tp.getStrokeWeight()/2.0))/2.0;
  	float ang = (_tp.getLerp()*TAU)+_seg.getAngle(true);//getAngle(_seg, _tp, _painter);

  	PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
  	pos.add(_seg.getMidPoint());
    return pos;
  }


  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return (_tp.getLerp()*TAU)+_seg.getAngle(true)+HALF_PI;
  }
}

class RandomInterpolator extends Interpolator{
  public RandomInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    PVector pos;
    if(_painter instanceof BrushPutter) pos = _seg.getBrushPos(random(0,1));
    else pos = _seg.getStrokePos(random(0,1));

    return vecLerp(pos, _seg.getCenter(), random(0,1));
  }

  //
  // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
  //   return random(TAU);
  // }
}


class RandomExpandingInterpolator extends Interpolator{
  public RandomExpandingInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    PVector pos;
    if(_painter instanceof BrushPutter) pos = _seg.getBrushPos(random(0,1));
    else pos = _seg.getStrokePos(random(0,1));

    return vecLerp(_seg.getCenter(), pos, random(0,_tp.getLerp()));
  }

  //
  // public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
  //   return random(TAU);
  // }
}



// // front midPoint to the center
// class MiddleCenterSender extends Interpolator{
//
//   public MiddleCenterSender(){
//     super();
//   }
//   // interpolate to center
//   public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
//     PVector _pos;
//     if(_painter instanceof BrushPutter) _pos = vecLerp(_seg.getBrushOffsetA(), _seg.getBrushOffsetB(), 0.5);
//     else _pos = vecLerp(_seg.getStrokeOffsetA(), _seg.getStrokeOffsetB(), 0.5);
//     return vecLerp(_pos, _seg.getCenter(), _tp.getLerp());
//   }
//   public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
//     return atan2(_seg.getMidPoint().y - _seg.getCenter().y, _seg.getMidPoint().x - _seg.getCenter().x);
//   }
// }
