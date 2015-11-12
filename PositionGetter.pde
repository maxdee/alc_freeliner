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
}


class CenterSender extends Interpolator{

  public CenterSender(){
    super();
  }

  /**
   * Fetch a point from a segment
   * @param Segment to interpolate from
   * @param RenderableTemplate template being rendered
   * @param Painter some modes should be able to check if _painter is a instance of brush vs others.
   * @return PVector the resulting coordinate
   */
  public PVector getPosition(Segment _seg, RenderableTemplate _tp, Painter _painter){
    println("haha");
    if(_painter instanceof BrushPutter) return vecLerp(_seg.getBrushOffsetA(), _seg.getCenter(), _tp.getLerp());
    else return vecLerp(_seg.getStrokeOffsetA(), _seg.getCenter(), _tp.getLerp());
  }
}
