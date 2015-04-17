
// base class
class SegmentPainter extends Painter{
	final String name = "SegmentPainter";
	// reference to the _event being rendered
	// RenderableTemplate _event; 


	public SegmentPainter(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		event = _event;
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Line Painters
///////
////////////////////////////////////////////////////////////////////////////////////


class LinePainter extends SegmentPainter{
	final String name = "LinePainter";

	public LinePainter(){
	}

	// paint the segment in question
	public void paintSegment(Segment _seg, RenderableTemplate _event){
		event = _event;
		applyStyle(event.getCanvas());
		vecLine(event.getCanvas(), _seg.getRegA(), _seg.getRegB());
	}
}

class FunLine extends LinePainter {
	final String name = "FunLine";

	public FunLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		event = _event;
		applyStyle(event.getCanvas());
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
		event = _event;
		canvas = event.getCanvas();
		//println(event.getLerp());
		_seg.setSize(event.getScaledBrushSize());
		putShape(_seg.getPos(event.getLerp()), _seg.getAngle(event.getDirection()) + event.getAngleMod());
	}

	public void putShape(PVector _p, float _a){
		PShape shape_; 
    shape_ = brushes.get(event.getBrushMode()).getShape(event.getScaledBrushSize());

    applyStyle(shape_);
    canvas.pushMatrix();
    canvas.translate(_p.x, _p.y);
    canvas.rotate(_a+HALF_PI); 
    canvas.shape(shape_);
    canvas.popMatrix();
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