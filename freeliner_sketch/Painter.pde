 	/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



// Anything that has to do with rendering things with one segment
// basic painter dosent know what to paint but knows what color

// extract colorizers?
// gets a reference to one.

class Painter extends Mode{

	// Since we paint we need colors
	// arraySizes int Config.pde
	Colorizer[] colorizers;
	Interpolator[] posGetters;

  PGraphics canvas;
	RenderableTemplate event;
	int interpolatorCount;
	int colorizerCount;

	public Painter(){
		name = "Painter";
		description = "Paints stuff";

		initColorizers();
		interpolatorCount = 10;
		posGetters = new Interpolator[interpolatorCount];
		posGetters[0] = new Interpolator(0);
		posGetters[1] = new CenterSender(1);
		posGetters[2] = new CenterSender(2);
		posGetters[3] = new HalfWayInterpolator(3);
		posGetters[4] = new RandomExpandingInterpolator(4);
		posGetters[5] = new RandomInterpolator(5);
		posGetters[6] = new DiameterInterpolator(6);
		posGetters[7] = new RadiusInterpolator(7);
		posGetters[8] = new SegmentOffsetInterpolator(8);
		posGetters[9] = new OppositInterpolator(9);

		if(MAKE_DOCUMENTATION) documenter.documentModes( (Mode[])posGetters, 'e', this, "Enterpolator");
	}

  public void paint(RenderableTemplate _rt){
    event = _rt;
    canvas = event.getCanvas();
		applyStyle(canvas);
  }

	public Interpolator getInterpolator(int _index){
		if(_index >= interpolatorCount) _index = interpolatorCount - 1;
		return posGetters[_index];
	}

	public PVector getPosition(Segment _seg){
		return getInterpolator(event.getInterpolateMode()).getPosition(_seg, event, this);
	}

	public float getAngle(Segment _seg, RenderableTemplate _event){
		float ang = getInterpolator(_event.getInterpolateMode()).getAngle(_seg, _event, this);
		if(_event.getDirection()) ang += PI;
		if(_seg.isClockWise()) return ang + _event.getAngleMod();
		else return ang + (-_event.getAngleMod());
	}

	// color stuffs
	public void initColorizers(){
		colorizerCount = 32;
		colorizers = new Colorizer[colorizerCount];
		// basic colors
		colorizers[0] = new SimpleColor(color(0), 0);
		colorizers[0].setDescrition("None");
    colorizers[1] = new SimpleColor(color(255), 1);
		colorizers[1].setDescrition("white");
    colorizers[2] = new SimpleColor(color(255, 0, 0), 2);
		colorizers[2].setDescrition("red");
    colorizers[3] = new SimpleColor(color(0, 255, 0), 3);
		colorizers[3].setDescrition("green");
    colorizers[4] = new SimpleColor(color(0, 0, 255), 4);
		colorizers[4].setDescrition("blue");
    colorizers[5] = new SimpleColor(color(0), 5);
		colorizers[5].setDescrition("black");
		// userPallet colors
    colorizers[6] = new PalletteColor(0, 6);
    colorizers[7] = new PalletteColor(1, 7);
    colorizers[8] = new PalletteColor(2, 8);
    colorizers[9] = new PalletteColor(3, 9);
    colorizers[10] = new PalletteColor(4, 10);
		colorizers[11] = new PalletteColor(5, 11);
		colorizers[12] = new PalletteColor(6, 12);
		colorizers[13] = new PalletteColor(7, 13);
		colorizers[14] = new PalletteColor(8, 14);
		colorizers[15] = new PalletteColor(9, 15);
		colorizers[16] = new PalletteColor(10, 16);
		colorizers[17] = new PalletteColor(11, 17);
		// changing color modes
		colorizers[18] = new RepetitionColor(18);
		colorizers[19] = new RandomPrimaryColor(19);
    colorizers[20] = new PrimaryBeatColor(20);
		colorizers[21] = new HSBFade(21);
    colorizers[22] = new FlashyPrimaryColor(22);
    colorizers[23] = new FlashyGray(23);
    colorizers[24] = new RandomRGB(24);
    colorizers[25] = new Strobe(25);
		colorizers[26] = new Flash(26);
		colorizers[27] = new JahColor(27);
    colorizers[28] = new CustomStrokeColor(28);
		colorizers[29] = new CustomFillColor(29);

		colorizers[30] = new MillisFade(30);
		colorizers[31] = new HSBLerp(31);
		if(MAKE_DOCUMENTATION) documenter.documentModes( (Mode[])colorizers, 'q', this, "Colorizers");
	}

  public Colorizer getColorizer(int _index){
    if(_index >= colorizerCount) _index = colorizerCount - 1;
    return colorizers[_index];
  }

	// apply colors to shape
  public void applyStyle(PShape _s){
  	int fillMode = event.getFillMode();
  	int strokeMode = event.getStrokeMode();
  	int strokeWidth = event.getStrokeWeight();
		int strokeAlpha = event.getStrokeAlpha();
		int fillAlpha = event.getFillAlpha();

		if (fillMode != 0){
      _s.setFill(true);
      _s.setFill(getColorizer(fillMode).get(event, fillAlpha));
    }
		else _s.setFill(false);

    if(strokeMode != 0 && strokeAlpha != 0) {
			_s.setStroke(true);
      _s.setStroke(getColorizer(strokeMode).get(event, strokeAlpha)); // _s.getStyle().stroke = getColorizer(strokeMode).get(event);//
      _s.setStrokeWeight(strokeWidth);
    }
    else _s.setStroke(false);
  }

  //apply settings to a canvas
  public void applyStyle(PGraphics _g){
    int fillMode = event.getFillMode();
  	int strokeMode = event.getStrokeMode();
  	int strokeWidth = event.getStrokeWeight();
		int strokeAlpha = event.getStrokeAlpha();
		int fillAlpha = event.getFillAlpha();

    if(fillMode != 0){
      _g.fill(getColorizer(fillMode).get(event, fillAlpha));
    }
    else _g.noFill();

    if(strokeMode != 0 && strokeAlpha != 0) {
      _g.stroke(getColorizer(strokeMode).get(event, strokeAlpha));
      _g.strokeWeight(strokeWidth);
    }
    else _g.noStroke();
  }

  public String getName(){
  	return name;
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Misc painters
///////
////////////////////////////////////////////////////////////////////////////////////

class LineToLine extends Painter{
	String name = "lineToLine";

  public LineToLine(int _ind){
		modeIndex = _ind;
		name = "LineToLine";
		description = "Draws a line from a point interpolated on a segment to a point interpolated on a different segment, `d` key sets the different segment.";
  }
  public void paint(ArrayList<Segment> _segs, RenderableTemplate _rt){
    super.paint(_rt);
		applyStyle(canvas);
    PVector pos = new PVector(-10,-10);
		PVector prev = new PVector(-10,-10);
		if(_segs == null) return;
    for(Segment seg : _segs){
			prev = pos.get();
			pos = seg.getStrokePos(event.getLerp()).get();
			if(prev.x != -10 && pos.x != -10) vecLine(canvas, pos, prev);
    }
  }
}
