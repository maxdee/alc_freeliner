/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */


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
		_seg.setStrokeWidth(_event.getStrokeWeight());
		applyStyle(event.getCanvas());
	}
}

class FunLine extends LinePainter {
	final String name = "FunLine";

	public FunLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), pos);//_seg.getStrokePos(event.getLerp()));
	}
}

class FullLine extends LinePainter {
	final String name = "FullLine";

	public FullLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}

class TrainLine extends LinePainter {
	final String name = "MiddleLine";

	public TrainLine(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float lrp = event.getLerp();
		if(lrp < 0.5) vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokePos(lrp*2));
		else vecLine(event.getCanvas(), _seg.getStrokePos(2*(lrp-0.5)), _seg.getStrokeOffsetB());
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
		vecLine(event.getCanvas(), _seg.getStrokePos(aa), _seg.getStrokePos(bb));
	}
}

class Maypole extends LinePainter {
	public Maypole(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getCenter(), _seg.getStrokePos(event.getLerp()));
	}
}


class Elliptic extends LinePainter {
	public Elliptic(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pos = _seg.getPointA();
		float sz = pos.dist(_seg.getStrokePos(event.getLerp()))*2;
		event.getCanvas().ellipse(pos.x, pos.y, sz, sz);
	}
}

class RadarPainter extends LinePainter {
	public RadarPainter(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float dist = _seg.getLength();
		float ang = (_event.getLerp()*TAU)+_seg.getAngle(true);
		PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
		pos.add(_seg.getStrokeOffsetA());
		vecLine(_event.getCanvas(), _seg.getStrokeOffsetA(), pos);
	}
}



class SegToSeg extends LinePainter{
	public SegToSeg(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		Segment secondSeg = getNextSegment(_seg, _event.getBrushMode());
		vecLine(event.getCanvas(), _seg.getStrokePos(_event.getLerp()), secondSeg.getStrokePos(_event.getLerp()));
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
	final int BRUSH_COUNT = 10;


	public BrushPutter(){
		loadBrushes();
	}

	public void loadBrushes(){
		brushes = new Brush[BRUSH_COUNT];
		brushes[0] = new CircleBrush();
		brushes[1] = new LineBrush();
		brushes[2] = new PointBrush();
		brushes[3] = new ChevronBrush();
		brushes[4] = new SquareBrush();
		brushes[5] = new XBrush();
		brushes[6] = new TriangleBrush();
		brushes[7] = new SprinkleBrush();
		brushes[8] = new LeafBrush();
		brushes[9] = new CustomBrush();
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

	public float getAngle(Segment _seg, RenderableTemplate _event){
		float ang = getInterpolator(_event.getInterpolateMode()).getAngle(_seg, _event, this);
		if(_event.getDirection()) ang += PI;
		return ang + _event.getAngleMod();
	}

	// regular putShape
	public void putShape(PVector _p, float _a){
		PShape shape_;
    shape_ = getBrush(event.getBrushMode()).getShape(event);//event.getBrushShape(); //
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

	public SimpleBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//putShape(_seg.getBrushPos(_event.getLerp()), _seg.getAngle(_event.getDirection()) + _event.getAngleMod());
		PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		putShape(pos, getAngle(_seg, _event));
	}
}


class SpiralBrusher extends BrushPutter{
	final String name = "SpiralBrush";
	public SpiralBrusher(){
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pv = _seg.getBrushPos(event.getLerp()).get();
    pv = vecLerp(pv, _seg.getCenter(), event.getLerp()).get();
		putShape(pv, _seg.getAngle(event.getDirection()));
	}
}

class TwoBrusher extends BrushPutter{
	public TwoBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float lrp = _event.getLerp();
		PVector pv = _seg.getBrushPos(lrp).get();
		putShape(pv, _seg.getAngle(false));
		pv = _seg.getBrushPos(-lrp+1).get();
		putShape(pv, _seg.getAngle(true));
	}
}


class InShapeBrusher extends BrushPutter{
	public InShapeBrusher(){

	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pA = _seg.getStrokePos(_event.getLerp());
		PVector cent = _seg.getCenter();
		putShape(vecLerp(pA, cent, 0.5),  _seg.getAngle(event.getDirection()));
	}
}

// center brusher

class CenterBrusher extends BrushPutter{

	public CenterBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		PVector pA = _seg.getBrushPos(0.0);
		PVector cent = _seg.getCenter();
		float ang = atan2(pA.y - cent.y, pA.x - cent.x);
		putShape(vecLerp(pA, cent, event.getLerp()),  ang+(event.getDirection() ? PI : 0) + event.getAngleMod());
	}
}

class OppositeBrusher extends BrushPutter{

	public OppositeBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		boolean _dir = _event.getDirection();
		float _lerp = _event.getLerp();
		if(_event.getSegmentIndex() % 2 == 1){
			_dir = !_dir;
			_lerp = -_lerp+1;
		}
		putShape(_seg.getBrushPos(_lerp), _seg.getAngle(_dir) + _event.getAngleMod());
	}
}


class CircularBrusher extends BrushPutter{

	public CircularBrusher(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		float dist = _seg.getLength()-(_event.getScaledBrushSize()/2.0);
		float ang = (_event.getLerp()*TAU)+_seg.getAngle(true);
		PVector pos = new PVector(dist*cos(ang),dist*sin(ang));
		pos.add(_seg.getPointA());
		if(!event.getDirection()) ang += PI;
		putShape(pos, event.getAngleMod() + ang + HALF_PI);
	}
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Text painting
///////
////////////////////////////////////////////////////////////////////////////////////

class TextWritter extends SegmentPainter{

	public TextWritter(){}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
		float _ang = _seg.getAngle(_event.getDirection());
		canvas.textFont(font);
		canvas.textSize(_event.getScaledBrushSize());
		char[] carr = _txt.toCharArray();
		int l = _txt.length();
		PVector pos = new PVector(0,0);
		for(int i = 0; i < l; i++){
			pos = _seg.getStrokePos(-((float)i/(l+1) + 1.0/(l+1))+1);
			putChar(carr[i], pos, _ang);
		}
	}

	public void putChar(char _chr, PVector _p, float _a){
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a + event.getAngleMod());
		canvas.text(_chr, 0, event.getScaledBrushSize()/3.0);
		canvas.popMatrix();
	}
}
