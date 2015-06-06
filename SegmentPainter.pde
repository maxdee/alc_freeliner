
// base class
class SegmentPainter extends Painter{
	final String name = "SegmentPainter";
	// reference to the _event being rendered
	// RenderableTemplate _event; 


	public SegmentPainter(){
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
	final String name = "LinePainter";

	public LinePainter(){
	}

	// paint the segment in question
	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		applyStyle(event.getCanvas());
	}
}

class FunLine extends LinePainter {
	final String name = "FunLine";

	public FunLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getRegA(), _seg.getRegPos(event.getLerp()));
	}
}

class FullLine extends LinePainter {
	final String name = "FullLine";

	public FullLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getRegA(), _seg.getRegB());
	}
}

class MiddleLine extends LinePainter {
	final String name = "MiddleLine";

	public MiddleLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float aa = (event.getLerp()/2)+0.5;
		float bb = -(event.getLerp()/2)+0.5;
		vecLine(event.getCanvas(), _seg.getRegPos(aa), _seg.getRegPos(bb));
	}
}

class Maypole extends LinePainter {
	public Maypole(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getCenter(), _seg.getRegPos(event.getLerp()));
	}
}


class Elliptic extends LinePainter {
	public Elliptic(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = _seg.getRegA();
		float sz = pos.dist(_seg.getRegPos(event.getLerp()))*2;
		event.getCanvas().ellipse(pos.x, pos.y, sz, sz);
	}
}



class SegToSeg extends LinePainter{
	public SegToSeg(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		Segment secondSeg = getNextSegment(_seg, _event.getBrushMode());
		vecLine(event.getCanvas(), _seg.getRegPos(_event.getLerp()), secondSeg.getRegPos(_event.getLerp()));
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
	final String name = "BrusPutter";
	Brush[] brushes;
	final int BRUSH_COUNT = 9;
	

	public BrushPutter(){
		loadBrushes();
	}

	public void loadBrushes(){
		brushes = new Brush[BRUSH_COUNT];
		brushes[0] = new PointBrush(); // dosent work with P2D
		brushes[1] = new LineBrush();
		brushes[2] = new ChevronBrush();
		brushes[3] = new SquareBrush();
		brushes[4] = new XBrush();
		brushes[5] = new CircleBrush();
		brushes[6] = new TriangleBrush();
		brushes[7] = new SprinkleBrush();
		brushes[8] = new CustomBrush();
	}

	public Brush getBrush(int _index){
		if(_index >= BRUSH_COUNT) _index = BRUSH_COUNT - 1;
		return brushes[_index];
	}


	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setSize(event.getScaledBrushSize());
	}

	// regular putShape
	public void putShape(PVector _p, float _a){
		PShape shape_; 
    shape_ = getBrush(event.getBrushMode()).getShape(event);
    applyStyle(shape_);
    canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a+HALF_PI+event.getAngleMod()); 
    canvas.shape(shape_);
    canvas.popMatrix();
	}
	// // putShape with overidable size
	// public void putShape(PVector _p, float _a, float _s){
	// 	PShape shape_; 
 //    shape_ = getBrush(event.getBrushMode()).getShape(_s);
 //    applyStyle(shape_);
 //    canvas.pushMatrix();
 //    canvas.translate(_p.x, _p.y);
 //    canvas.rotate(_a+HALF_PI+event.getAngleMod()); 
 //    canvas.shape(shape_);
 //    canvas.popMatrix();
	// }
}

class SimpleBrusher extends BrushPutter{

	public SimpleBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		putShape(_seg.getPos(event.getLerp()), _seg.getAngle(event.getDirection()) + event.getAngleMod());
	}
}


class SpiralBrush extends BrushPutter{
	final String name = "SpiralBrush";
	public SpiralBrush(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pv = _seg.getPos(event.getLerp()).get();
    pv = vecLerp(pv, _seg.getCenter(), event.getLerp()).get();
		putShape(pv, _seg.getAngle(event.getDirection()));
	}
}

class TwoBrush extends BrushPutter{
	public TwoBrush(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float lrp = event.getLerp();
		PVector pv = _seg.getPos(lrp).get();
		putShape(pv, _seg.getAngle(false));
		pv = _seg.getPos(-lrp+1).get();
		putShape(pv, _seg.getAngle(true));
	}
}


class BrushFill extends BrushPutter{
	public BrushFill(){

	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		PVector center = _seg.getCenter().get();
		// find the distance from the middle to the center
		float dst = center.dist(_seg.getPos(0.5));
		// how many things
		int count = constrain(_event.getRepetitionCount(), 1, 20); //ceil(dst/event.getScaledBrushSize());
		// force the brush size
		_event.forceScaledBrushSize(dst/count);
		float lrp = _event.getLerp();
		float ang =  _seg.getAngle(_event.getDirection());
		//int count = 5; // what should I attach this to?
		float inter = 1.0/count;
		PVector pos = new PVector(0,0); _seg.getPos(lrp).get();
		float tmpLrp = 0;
		
		// calling super after due to custom brush size
		super.paintSegment(_seg, _event);

		for(int i = 0; i < count; i++){
			tmpLrp = (i%2 == 0) ? lrp : (lrp-1)*-1;
			pos = vecLerp(_seg.getPos(tmpLrp).get(), center, i*inter);
			putShape(pos, (i%2 == 0) ? ang : ang + PI);
		}		
	}


}
// center brusher

class CenterBrusher extends BrushPutter{

	public CenterBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pA = _seg.getA();
		PVector cent = _seg.getCenter();
		float ang = atan2(pA.y - cent.y, pA.x - cent.x);
		putShape(vecLerp(pA, cent, event.getLerp()),  ang+(event.getDirection() ? PI : 0) + event.getAngleMod());
	}
}