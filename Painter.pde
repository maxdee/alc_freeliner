
// Anything that has to do with rendering things with one segment
// basic painter dosent know what to paint but knows what color
class Painter{

	// Since we paint we need colors
	Colorizer[] colorizers;
  final int COLORIZER_COUNT = 18;

  PGraphics canvas;
	String name = "Painter";
	RenderableTemplate event;

	public Painter(){
		initColorizers();
	}

  public void paint(RenderableTemplate _rt){
    event = _rt;
    canvas = event.getCanvas();
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
		colorizers[10] = new RepetitionColor();
		colorizers[11] = new RandomPrimaryColor();
		colorizers[12] = new HSBFade();
    colorizers[13] = new FlashyPrimaryColor();
    colorizers[14] = new FlashyGray();
    colorizers[15] = new FlashyRandom();
    colorizers[16] = new FlashyWhiteRedBlack();
    colorizers[17] = new Strobe();

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
      _s.setStroke(getColorizer(strokeMode).get(event));
      _s.setStrokeWeight(strokeWidth);
    }
    else _s.noStroke();
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