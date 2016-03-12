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

class Painter{

	// Since we paint we need colors
	Colorizer[] colorizers;
  final int COLORIZER_COUNT = 31;
	Interpolator[] posGetters;
	final int INTERPOLATOR_GETTER_COUNT = 8;


  PGraphics canvas;
	String name = "Painter";
	RenderableTemplate event;

	public Painter(){
		initColorizers();
		posGetters = new Interpolator[INTERPOLATOR_GETTER_COUNT];
		posGetters[0] = new Interpolator();
		posGetters[1] = new CenterSender();
		posGetters[2] = new CenterSender();
		posGetters[3] = new HalfWayInterpolator();
		posGetters[4] = new RandomExpandingInterpolator();
		posGetters[5] = new RandomInterpolator();
		posGetters[6] = new DiameterInterpolator();
		posGetters[7] = new RadiusInterpolator();
	}

  public void paint(RenderableTemplate _rt){
    event = _rt;
    canvas = event.getCanvas();
		applyStyle(canvas);
  }

	public Interpolator getInterpolator(int _index){
		if(_index >= INTERPOLATOR_GETTER_COUNT) _index = INTERPOLATOR_GETTER_COUNT - 1;
		return posGetters[_index];
	}

	public PVector getPosition(Segment _seg){
		return getInterpolator(event.getInterpolateMode()).getPosition(_seg, event, this);
	}

	// color stuffs
	public void initColorizers(){
		colorizers = new Colorizer[COLORIZER_COUNT];
		// basic colors
		colorizers[0] = new SimpleColor(color(0));
    colorizers[1] = new SimpleColor(color(255));
    colorizers[2] = new SimpleColor(color(255, 0, 0));
    colorizers[3] = new SimpleColor(color(0, 255, 0));
    colorizers[4] = new SimpleColor(color(0, 0, 255));
    colorizers[5] = new SimpleColor(color(0));
		// userPallet colors
    colorizers[6] = new PalletteColor(0);
    colorizers[7] = new PalletteColor(1);
    colorizers[8] = new PalletteColor(2);
    colorizers[9] = new PalletteColor(3);
    colorizers[10] = new PalletteColor(4);
		colorizers[11] = new PalletteColor(5);
		colorizers[12] = new PalletteColor(6);
		colorizers[13] = new PalletteColor(7);
		colorizers[14] = new PalletteColor(8);
		colorizers[15] = new PalletteColor(9);
		colorizers[16] = new PalletteColor(10);
		colorizers[17] = new PalletteColor(11);
		// changing color modes
		colorizers[18] = new RepetitionColor();
		colorizers[19] = new RandomPrimaryColor();
    colorizers[20] = new PrimaryBeatColor();
		colorizers[21] = new HSBFade();
    colorizers[22] = new FlashyPrimaryColor();
    colorizers[23] = new FlashyGray();
    colorizers[24] = new FlashyRandom();
    colorizers[25] = new Strobe();
		colorizers[26] = new Flash();
		colorizers[27] = new JahColor();
    colorizers[28] = new CustomColor();
		colorizers[29] = new MillisFade();
		colorizers[30] = new HSBLerp();

	}

  public Colorizer getColorizer(int _index){
    if(_index >= COLORIZER_COUNT) _index = COLORIZER_COUNT - 1;
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

    if(strokeMode != 0) {
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

    if(strokeMode != 0) {
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

  public LineToLine(){
  }
  public void paint(ArrayList<Segment> _segs, RenderableTemplate _rt){
    super.paint(_rt);
		applyStyle(canvas);
    PVector pos = new PVector(-10,-10);
		PVector prev = new PVector(-10,-10);
    for(Segment seg : _segs){
			prev = pos.get();
			pos = seg.getStrokePos(event.getLerp()).get();
			if(prev.x != -10 && pos.x != -10) vecLine(canvas, pos, prev);
    }
  }
}
