
// Anything that has to do with rendering things with one segment
// basic painter dosent know what to paint but knows what color
class Painter{

	// Since we paint we need colors
	Colorizer[] colorizers;
  final int COLORIZER_COUNT = 21;

  PGraphics canvas;
	String name = "Painter";
	RenderableTemplate event;

	public Painter(){
		initColorizers();
	}

  public void paint(RenderableTemplate _rt){
    event = _rt;
    canvas = event.getCanvas();
		//applyStyle(canvas);
  }

	// color stuffs
	public void initColorizers(){
		colorizers = new Colorizer[COLORIZER_COUNT];
		colorizers[0] = new PalletteColor(0);
    colorizers[1] = new PalletteColor(0);
    colorizers[2] = new PalletteColor(2);
    colorizers[3] = new PalletteColor(3);
    colorizers[4] = new PalletteColor(4);
    colorizers[5] = new PalletteColor(5);
    colorizers[6] = new PalletteColor(6);
    colorizers[7] = new PalletteColor(7);
    colorizers[8] = new PalletteColor(8);
    colorizers[9] = new PalletteColor(9);
    colorizers[10] = new PalletteColor(1);
		colorizers[11] = new RepetitionColor();
		colorizers[12] = new RandomPrimaryColor();
    colorizers[13] = new PrimaryBeatColor();
		colorizers[14] = new HSBFade();
    colorizers[15] = new FlashyPrimaryColor();
    colorizers[16] = new FlashyGray();
    colorizers[17] = new FlashyRandom();
    colorizers[18] = new FlashyWhiteRedBlack();
    colorizers[19] = new Strobe();
    colorizers[20] = new CustomColor();

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

		if (fillMode != 0){
      _s.setFill(true);
      _s.setFill(getColorizer(fillMode).get(event));
    }
		else _s.setFill(false);

    if(strokeMode != 0) {
			_s.setStroke(true);
      _s.setStroke(getColorizer(strokeMode).get(event)); // _s.getStyle().stroke = getColorizer(strokeMode).get(event);//
      _s.setStrokeWeight(strokeWidth);
    }
    else _s.setStroke(false);
  }

  //apply settings to a canvas
  public void applyStyle(PGraphics _g){
    int fillMode = event.getFillMode();
  	int strokeMode = event.getStrokeMode();
  	int strokeWidth = event.getStrokeWeight();

    if(fillMode != 0){
      _g.fill(getColorizer(fillMode).get(event));
    }
    else _g.noFill();

    if(strokeMode != 0) {
      _g.stroke(getColorizer(strokeMode).get(event));
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
  public LineToLine(){
  }
  public void paint(ArrayList<Segment> _segs, RenderableTemplate _rt){
    super.paint(_rt);
    PShape shp = createShape();
    shp.beginShape();
    PVector pos = new PVector(0,0);
    canvas.stroke(255);
    canvas.strokeWeight(6);
    int weighter = 0;
    for(Segment seg : _segs){
      pos = seg.getRegPos(event.getLerp()).get();
      shp.vertex(pos.x, pos.y);
    }
    shp.endShape();
    applyStyle(shp);
    canvas.shape(shp);
  }
}
