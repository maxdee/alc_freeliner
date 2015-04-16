
// base class for color picking
class Colorizer {
	//custom colors?
	final String name = "Colorizer";

  final color[] pallet = {
  									color(255),
  									color(0),
                    color(255,0,0),
                    color(0,255,0),
                    color(0,0,255),
                    color(0,255,255),
                    color(255,255,0),
                    color(255,22,255),
                    color(100,3,255),
                    color(255,0,255),
                  };

  public Colorizer(){
  }

  public color get(RenderableTemplate _event){
  	return color(255);
  }


  // util methods
  private color getPalletIndex(int _index){
  	if(_index < pallet.length) return pallet[_index];
  	else return color(0);
  }

  private color HSBtoRGB(int _h, int _s, int _b){
  	return java.awt.Color.HSBtoRGB(_h, _s, _b);
  }

  public String getName(){
  	return name;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////

/*
 * Basic white
 */
class White extends Colorizer {
	public White(){
		
	}

	public color get(RenderableTemplate _event){
		return color(255);//pallet[_event.getBeatCount() % 3];
	}
}

/*
 * Basic white
 */
class RandomPrimaryColor extends Colorizer {
	public RandomPrimaryColor(){
		
	}

	public color get(RenderableTemplate _event){
		return color(255);//pallet[_event.getBeatCount() % 3];
	}
}

/*
 * Constantly changing random primary color
 */
class FlashyPrimaryColor extends Colorizer {
	public FlashyPrimaryColor(){
		
	}

	public color get(RenderableTemplate _event){
		return pallet[(int)random(3)];
	}
}

/*
 * Constantly changing random value gray
 */
class FlashyGray extends Colorizer {
	public FlashyGray(){
		
	}

	public color get(RenderableTemplate _event){
		return color(random(255));
	}
}

/*
 * Constantly changing random color
 */
class FlashyRandom extends Colorizer {
	public FlashyRandom(){
		
	}

	public color get(RenderableTemplate _event){
		return color(random(255),random(255),random(255));
	}
}


/*
 * Constantly changing random color
 */
class Strobe extends Colorizer {
	public Strobe(){
	}

	public color get(RenderableTemplate _event){
		if(_event.getLerp()<0.2) return color(255);
		else return color(0);
	}
}



/*
 * Fade through the HUE
 */
class HSBFade extends Colorizer {
	public HSBFade(){
	}
	public color get(RenderableTemplate _event){
		return java.awt.Color.HSBtoRGB(float(_event.getBeatCount())/255, 1.0, 1.0);
	}	
}

