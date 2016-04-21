/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


// base class
class SegmentPainter extends Painter{

	// reference to the _event being rendered
	// RenderableTemplate _event;

	public SegmentPainter(){
		name = "segmentPainter";
		description = "paints segments";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paint(_event);
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Line Painters
///////
////////////////////////////////////////////////////////////////////////////////////

// base class for line painter
class LinePainter extends SegmentPainter{

	public LinePainter(){
		name = "LinePainter";
		description = "base class for making lines";
	}

	// paint the segment in question
	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setStrokeWidth(_event.getStrokeWeight());
		applyStyle(event.getCanvas());
	}
}

class FunLine extends LinePainter {

	public FunLine(){
		name = "FunLine";
		description = "Makes a line between pointA and a position.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), getPosition(_seg));//_seg.getStrokePos(event.getLerp()));
	}
}

class FullLine extends LinePainter {

	public FullLine(){
		name = "FullLine";
		description = "Draws a line on a segment, not animated.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}

class AlphaLine extends LinePainter{
	public AlphaLine(){
		name = "AlphaLine";
		description = "modulates alpha channel, made for LEDs";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		color _col = getColorizer(event.getStrokeMode()).get(event,int(event.getLerp()*event.getStrokeAlpha()));
		event.getCanvas().stroke(_col);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}


class TrainLine extends LinePainter {

	public TrainLine(){
		name = "TrainLine";
		description = "Line that comes out of point A and exits through pointB";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float lrp = event.getLerp();
		if(lrp < 0.5) vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokePos(lrp*2));
		else vecLine(event.getCanvas(), _seg.getStrokePos(2*(lrp-0.5)), _seg.getStrokeOffsetB());

		// test with enterpolator...
		// if(lrp < 0.5){
		// 	_event.setLerp(lrp*2.0);
		// 	vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), getPosition(_seg));
		// 	_event.setLerp(lrp);
		// }
		// else {
		// 	_event.setLerp(2*(lrp-0.5));
		// 	vecLine(event.getCanvas(), getPosition(_seg), _seg.getCenter());
		// 	_event.setLerp(lrp);
		// }
	}
}


class MiddleLine extends LinePainter {

	public MiddleLine(){
		name = "MiddleLine";
		description = "line that expands from the middle of a segment.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float aa = (event.getLerp()/2)+0.5;
		float bb = -(event.getLerp()/2)+0.5;
		vecLine(event.getCanvas(), _seg.getStrokePos(aa), _seg.getStrokePos(bb));
	}
}

class Maypole extends LinePainter {
	public Maypole(){
		name = "Maypole";
		description = "Draw a line from center to position.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getCenter(), getPosition(_seg));
	}
}


class Elliptic extends LinePainter {
	public Elliptic(){
		name = "Elliptic";
		description = "Makes a expanding circle with segment as final radius.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = _seg.getPointA();
		float sz = pos.dist(_seg.getStrokePos(event.getLerp()))*2;
		event.getCanvas().ellipse(pos.x, pos.y, sz, sz);
	}
}

class SegToSeg extends LinePainter{
	public SegToSeg(){
		name = "SegToSeg";
		description = "Draws a line from a point on a segment to a point on a different segment. Affected by `e`";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		Segment secondSeg = getNextSegment(_seg, _event.getMiscValue());
		vecLine(event.getCanvas(), getPosition(_seg), getPosition(secondSeg));
		//vecLine(event.getCanvas(), _seg.getStrokePos(_event.getLerp()), secondSeg.getStrokePos(_event.getLerp()));
	}

	public Segment getNextSegment(Segment _seg, int _iter){
		Segment next = _seg.getNext();
		if(_iter == 0) return next;
		else return getNextSegment(next, _iter - 1);
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////

// base brush putter
class BrushPutter extends SegmentPainter{

	Brush[] brushes;
	// brush count in Config.pde


	public BrushPutter(){
		loadBrushes();
		name = "BrusPainter";
		description = "Place brush onto segment. Affected by `e`.";
	}

	public void loadBrushes(){
		brushes = new Brush[BRUSH_COUNT];
		brushes[0] = new PointBrush();
		brushes[1] = new LineBrush();
		brushes[2] = new CircleBrush();
		brushes[3] = new ChevronBrush();
		brushes[4] = new SquareBrush();
		brushes[5] = new XBrush();
		brushes[6] = new TriangleBrush();
		brushes[7] = new SprinkleBrush();
		brushes[8] = new LeafBrush();
		brushes[9] = new CustomBrush();
		if(MAKE_DOCUMENTATION) documenter.addDoc(brushes,'d',name);
	}

	public Brush getBrush(int _index){
		if(_index >= BRUSH_COUNT) _index = BRUSH_COUNT - 1;
		return brushes[_index];
	}


	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setSize(_event.getScaledBrushSize()+_event.getStrokeWeight());
		//if(event.doUpdateBrush()) event.setBrushShape(getBrush(event.getBrushMode()).getShape(event));
	}

	// regular putShape
	public void putShape(PVector _p, float _a){
		PShape shape_;
    shape_ = getBrush(event.getAnimationMode()).getShape(event);//event.getBrushShape(); //
		if(shape_ == null) return;
    applyStyle(shape_);
    canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a+ HALF_PI);// +event.getAngleMod());
		canvas.shape(shape_);

		canvas.popMatrix();
	}
}

class SimpleBrusher extends BrushPutter{

	public SimpleBrusher(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//putShape(_seg.getBrushPos(_event.getLerp()), _seg.getAngle(_event.getDirection()) + _event.getAngleMod());
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		putShape(getPosition(_seg), getAngle(_seg, _event));
	}
}



// class OppositeBrusher extends BrushPutter{
//
// 	public OppositeBrusher(){
// 		name = "OpositeBrusher";
// 		description = "Brushing direction alternates each segment.";
// 	}
//
// 	public void paintSegment(Segment _seg, RenderableTemplate _event){
// 		super.paintSegment(_seg, _event);
// 		boolean _dir = _event.getDirection();
// 		float _lerp = _event.getLerp();
// 		if(_event.getSegmentIndex() % 2 == 1){
// 			_dir = !_dir;
// 			_lerp = -_lerp+1;
// 		}
// 		putShape(_seg.getBrushPos(_lerp), _seg.getAngle(_dir) + _event.getAngleMod());
// 	}
// }


// class PolkaBrusher extends BrushPutter{
//
// 	public PolkaBrusher(){}
//
// 	public void paintSegment(Segment _seg, RenderableTemplate _event){
// 		super.paintSegment(_seg, _event);
//
// 		float dist = _seg.getLength();
// 		int gap = _event.getRepetitionCount()*10;
// 		for(int i = 0; i < cnt; i++){
// 			putShape(getPosition(_seg), getAngle(_seg, _event));
// 		}
// 	}
// }
//
