/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
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
}


class CenterSender extends Interpolator{

  public CenterSender(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    if(_painter instanceof BrushPutter) return vecLerp(_seg.getBrushOffsetA(), _seg.getCenter(), _tp.getLerp());
    else return vecLerp(_seg.getStrokeOffsetA(), _seg.getCenter(), _tp.getLerp());
  }
}

class CircularInterpolator extends Interpolator{
  public CircularInterpolator(){
    super();
  }
  // interpolate to center
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
	  float dist = 0;
    if(_painter instanceof BrushPutter) dist = _seg.getLength()-(_tp.getScaledBrushSize()/2.0);
    else dist = _seg.getLength()-(_tp.getStrokeWeight()/2.0);
  	float ang = getAngle(_seg, _tp, _painter);

  	PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
  	pos.add(_seg.getPointA());
    return pos;
  }

  public float getAngle(Segment _seg, RenderableTemplate _tp, Painter _painter){
    return (_tp.getLerp()*TAU)+_seg.getAngle(true);
  }
}
