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

	public SegmentPainter(int _ind){
		super(_ind);
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

	public LinePainter(int _ind){
		super(_ind);
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

	public FunLine(int _ind){
		super(_ind);
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

	public FullLine(int _ind){
		super(_ind);
		name = "FullLine";
		description = "Draws a line on a segment, not animated.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getStrokeOffsetA(), _seg.getStrokeOffsetB());
	}
}

class AlphaLine extends LinePainter{
	public AlphaLine(int _ind){
		super(_ind);
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

	public TrainLine(int _ind){
		super(_ind);
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

	public MiddleLine(int _ind){
		super(_ind);
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
	public Maypole(int _ind){
		super(_ind);
		name = "Maypole";
		description = "Draw a line from center to position.";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		vecLine(event.getCanvas(), _seg.getCenter(), getPosition(_seg));
	}
}


class Elliptic extends LinePainter {
	public Elliptic(int _ind){
		super(_ind);
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
	public SegToSeg(int _ind){
		super(_ind);
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
///////    Brush System
///////
////////////////////////////////////////////////////////////////////////////////////

// base brush putter
class BrushPutter extends SegmentPainter{

	Brush[] brushes;
	// brush count in Config.pde


	public BrushPutter(int _ind){
		super(_ind);
		loadBrushes();
		name = "BrushPainter";
		description = "Place brush onto segment. Affected by `e`.";
	}

	public void loadBrushes(){
		brushes = new Brush[BRUSH_COUNT];
		brushes[0] = new PointBrush(0);
		brushes[1] = new LineBrush(1);
		brushes[2] = new CircleBrush(2);
		brushes[3] = new ChevronBrush(3);
		brushes[4] = new SquareBrush(4);
		brushes[5] = new XBrush(5);
		brushes[6] = new TriangleBrush(6);
		brushes[7] = new SprinkleBrush(7);
		brushes[8] = new LeafBrush(8);
		brushes[9] = new CustomBrush(9);
		if(MAKE_DOCUMENTATION) documenter.documentModes(brushes,'a', this);
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

	public SimpleBrusher(int _ind){
		super(_ind);
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		//putShape(_seg.getBrushPos(_event.getLerp()), _seg.getAngle(_event.getDirection()) + _event.getAngleMod());
		//PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
		putShape(getPosition(_seg), getAngle(_seg, _event));
	}
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Text displaying
///////
////////////////////////////////////////////////////////////////////////////////////

class BasicText extends SegmentPainter{

  public BasicText(int _ind){
		super(_ind);
    name = "BasicText";
    description = "Extendable object fo text displaying";
  }

  public void putChar(char _chr, PVector _p, float _a){
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a);
		canvas.text(_chr, 0, event.getScaledBrushSize()/3.0);
		canvas.popMatrix();
	}
}


class TextWritter extends BasicText{

	public TextWritter(int _ind){
		super(_ind);
		name = "TextWritter";
		description = "Fit a bunch of text on a segment";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
		canvas.textFont(font);
		canvas.textSize(_event.getScaledBrushSize());
		char[] carr = _txt.toCharArray();
		int l = _txt.length();
		for(int i = 0; i < l; i++){
      _event.setLerp(-((float)i/(l+1) + 1.0/(l+1))+1);
			putChar(carr[i], getPosition(_seg), getAngle(_seg, _event));
		}
	}
}

class ScrollingText extends BasicText{
  public ScrollingText(int _ind){
		super(_ind);
    name = "ScrollingText";
    description = "Scrolls text, acording to enterpolator";
  }

  public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
    canvas.textFont(font);
    canvas.textSize(_event.getScaledBrushSize());
    char[] _chars = _txt.toCharArray();

    float _textWidth = _chars.length * _event.getScaledBrushSize();//canvas.textWidth(_txt);
    float _distance = _textWidth+_seg.getLength();


    float  _covered = 0;
    float _lrp = _event.getLerp();
    for(int i = 0; i < _chars.length; i++){
      _covered += _event.getScaledBrushSize()*0.666;//canvas.textWidth(_chars[i]);
      float place = ((_distance*_lrp)-_covered)/_seg.getLength();
      if(place > 0.0 && place < 1.0) {
        _event.setLerp(place);
        putChar(_chars[i], getPosition(_seg), getAngle(_seg, _event));
      }
    }
    _event.setLerp(_lrp);

	}
}
