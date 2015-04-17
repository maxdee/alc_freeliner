
// Anything that has to do with rendering things with one segment
// basic painter dosent know what to paint but knows what color
class Painter{

	// Since we paint we need colors
	SafeList<Colorizer> colorizers;
  PGraphics canvas;
	String name = "Painter";

	RenderableTemplate event;

	public Painter(){
		initColorizers();
	}

	// color stuffs
	public void initColorizers(){
		colorizers = new SafeList();
		colorizers.add(new White());
		colorizers.add(new White());
		colorizers.add(new RandomPrimaryColor());
		colorizers.add(new FlashyPrimaryColor());
		colorizers.add(new FlashyGray());
		colorizers.add(new FlashyRandom());
    colorizers.add(new Strobe());
		colorizers.add(new HSBFade());
	}

// apply colors to shape
  public void applyStyle(PShape _s){
  	int fillMode = event.getFillMode();
  	int strokeMode = event.getStrokeMode();
  	int strokeWidth = event.getStrokeWeight();
    if (fillMode != 0){
      _s.setFill(true);
      _s.setFill(colorizers.get(fillMode).get(event));
    }
    else _s.setFill(false);
    if(strokeMode != 0) {
      _s.setStroke(colorizers.get(strokeMode).get(event));
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
      _g.fill(colorizers.get(fillMode).get(event));
    }
    else _g.noFill();

    if(strokeMode != 0) {
      _g.stroke(colorizers.get(strokeMode).get(event));
      _g.strokeWeight(strokeWidth);
    }
    else _g.noStroke();
  }

  public String getName(){
  	return name;
  }
}


