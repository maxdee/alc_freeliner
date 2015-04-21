
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



////////////////////////////////////////////////////////////////////////////////////
///////
///////    Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////

// base brush putter
class BrushPutter extends SegmentPainter{
	final String name = "BrusPutter";
	SafeList<Brush> brushes;
	

	public BrushPutter(){
		loadBrushes();
	}

	public void loadBrushes(){
		brushes = new SafeList();
		brushes.add(new PointBrush());
		brushes.add(new LineBrush());
		brushes.add(new ChevronBrush());
		brushes.add(new SquareBrush());
		brushes.add(new CustomBrush());
	}


	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		_seg.setSize(event.getScaledBrushSize());
	}

	// regular putShape
	public void putShape(PVector _p, float _a){
		PShape shape_; 
    shape_ = brushes.get(event.getBrushMode()).getShape(event);
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
 //    shape_ = brushes.get(event.getBrushMode()).getShape(_s);
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
		super.paintSegment(_seg, _event);
		PVector center = _seg.getCenter().get();
		// find the distance from the middle to the center
		float dst = center.dist(_seg.getPos(0.5));

		int count = constrain(event.getRepetitionCount(), 1, 20); //ceil(dst/event.getScaledBrushSize());
		// force the brush size
		event.forceScaledBrushSize(dst/count);
		float lrp = event.getLerp();
		float ang =  _seg.getAngle(event.getDirection());
		//int count = 5; // what should I attach this to?
		float inter = 1.0/count;
		PVector pos = new PVector(0,0); _seg.getPos(lrp).get();
		float tmpLrp = 0;
		
		for(int i = 0; i < count; i++){
			tmpLrp = (i%2 == 0) ? lrp : (lrp-1)*-1;
			pos = vecLerp(_seg.getPos(tmpLrp).get(), center, i*inter);
			putShape(pos, (i%2 == 0) ? ang : ang + PI);
		}		
	}


}