
// base class for color picking
// add global color pallette to manipulate.
// then the color cycling modes can hop between pre determined colours.
class Colorizer extends Mode{
	//custom colors?

  public Colorizer(){
		name = "Colorizer";
		description = "Pics a color according to stuff.";
  }

  public color get(RenderableTemplate _event, int _alpha){
  	return alphaMod(color(255), _alpha);
  }

  // need to multiplex alpha value for fill & stroke, just fill, or just stroke.

  public color HSBtoRGB(float _h, float _s, float _b){
  	return java.awt.Color.HSBtoRGB(_h, _s, _b);
  }

	public color getFromPallette(int _c){
		if(_c >= 0 || _c < PALLETTE_COUNT) return userPallet[_c];
		else return color(255);
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

/**
 * Basic Color
 */
class SimpleColor extends Colorizer{
	color col;
	public SimpleColor(color _c, int _ind){
    modeIndex = _ind;
		col = _c;
    name = "#"+hex(_c,6);
    description = "simpleColor";

		// set the name when instantiating.
	}
	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(col , _alpha);
	}
}

/**
 * Colors from the user's pallette
 */
class PalletteColor extends Colorizer {
	int colorIndex;

	public PalletteColor(int _i, int _ind){
    modeIndex = _ind;
		colorIndex = _i;
		name = "pallette "+_i;
		description = "Color of "+_i+" index in colorPalette";
	}

	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(getFromPallette(colorIndex) , _alpha);
	}
}

/**
 * Working with primary colors
 */
class PrimaryColor extends Colorizer {

  public PrimaryColor(){}
	public PrimaryColor(int _ind){
    modeIndex = _ind;
		name = "PrimaryColor "+hex(getPrimary(_ind));
		description = "A primary color";
	}

	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(1), _alpha);
	}

	public color getPrimary(int _c){
		switch(_c){
			case 0:
				return #ff0000;
			case 1:
				return #00ff00;
			default:
				return #0000ff;
		}
	}
}

/**
 * Random primary color
 */
class RandomPrimaryColor extends PrimaryColor {
	public RandomPrimaryColor(int _ind){
    modeIndex = _ind;
		name = "RandomPrimaryColor";
		description = "Primary color that should change every beat.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(_event.getRandomValue()%3), _alpha);
	}
}

/**
 * Changes primary color on the beat regardless of divider
 */
class PrimaryBeatColor extends PrimaryColor {
	public PrimaryBeatColor(int _ind){
    modeIndex = _ind;
		name = "PrimaryBeatColor";
		description = "Cycles through primary colors on beat.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary(_event.getRawBeatCount() % 3), _alpha);
	}
}

/**
 * Constantly changing random primary color
 */
class FlashyPrimaryColor extends PrimaryColor {
	public FlashyPrimaryColor(int _ind){
    modeIndex = _ind;
		name = "FlashyPrimaryColor";
		description = "Random primary color every frame.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		return alphaMod(getPrimary((int)random(3)), _alpha);
	}
}

/**
 * Per Repetition
 */
class RepetitionColor extends Colorizer {

	public RepetitionColor(int _ind){
    modeIndex = _ind;
		name = "RepetitionColor";
		description = "Cycles through colors of the pallette";
	}

	public color get(RenderableTemplate _event, int _alpha){
		int index = (_event.getBeatCount()-_event.getRepetition()+_event.getSegmentIndex()) % PALLETTE_COUNT;
		index %= PALLETTE_COUNT;
		if(index < 0) index = 0;
		color c = userPallet[index];
		return alphaMod(c , _alpha);
	}
}

/**
 * Constantly changing random value gray
 */
class FlashyGray extends Colorizer {
	public FlashyGray(int _ind){
    modeIndex = _ind;
		name = "FlashyGray";
		description = "Random shades of gray.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		color c = color(random(255));
		return alphaMod(c , _alpha);
	}
}


/**
 * Constantly changing random color
 */
class RandomRGB extends Colorizer {
	public RandomRGB(int _ind){
    modeIndex = _ind;
		name = "RGB";
		description = "Random red green and blue value every frame.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		color c = color(random(255),random(255),random(255));
		return alphaMod(c , _alpha);
	}
}

/**
 * Constantly changing random color
 */
class Strobe extends Colorizer {
	public Strobe(int _ind){
    modeIndex = _ind;
		name = "Strobe";
		description = "Strobes white";
	}

	public color get(RenderableTemplate _event, int _alpha){
		if(maybe(20)) return color(255);
		else return color(255,0);
	}
}

/**
 * flash once! then black?
 */
class Flash extends Colorizer {
	public Flash(int _ind){
    modeIndex = _ind;
		name = "Flash";
		description = "Flashes once per beat.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		if(_event.getUnitInterval()<0.01) return color(255, 255);
		else if(_event.getUnitInterval()>0.1) return color(0,0);
		else return color(0, 255);
	}
}

/**
 * Fade through the HUE
 */
class MillisFade extends Colorizer {
	public MillisFade(int _ind){
    modeIndex = _ind;
		name = "MillisFade";
		description = "HSB fade goes along with millis.";
	}

	public color get(RenderableTemplate _event, int _alpha){
		color c = HSBtoRGB(float(millis()%10000)/10000.0, 1.0, 1.0);
		return alphaMod(c , _alpha);
	}
}

/**
 * Fade through the HUE
 */
class HSBLerp extends Colorizer {
	public HSBLerp(int _ind){
    modeIndex = _ind;
		name = "HSBLerp";
		description = "HSB fade through beat.";
	}
	public color get(RenderableTemplate _event, int _alpha){
		color c = HSBtoRGB(_event.getLerp(), 1.0, 1.0);
		return alphaMod(c , _alpha);
	}
}

/**
 * HSB Lerp
 */
class HSBFade extends Colorizer {
	public HSBFade(int _ind){
    modeIndex = _ind;
		name = "HSBFade";
		description = "HSBFade stored on template/event.";
	}
	public color get(RenderableTemplate _event, int _alpha){
		float hue = _event.getHue();
		color c = HSBtoRGB(hue, 1.0, 1.0);
		hue+=0.001;
		hue = fltMod(hue);
		_event.setHue(hue);
		return alphaMod(c , _alpha);
	}
}

/**
 * Get template's custom color
 */
class CustomStrokeColor extends Colorizer {
	public CustomStrokeColor(int _ind){
    modeIndex = _ind;
		name = "CustomStrokeColor";
		description = "Custom stroke color for template.";
	}
	public color get(RenderableTemplate _event, int _alpha){
        if(_alpha >= 255)
            return _event.getCustomStrokeColor();
        else
            return alphaMod(_event.getCustomStrokeColor(), _alpha);
	}
}

/**
 * Get template's custom color
 */
class CustomFillColor extends Colorizer {
	public CustomFillColor(int _ind){
    modeIndex = _ind;
		name = "CustomFillColor";
		description = "Custom fill color for template.";
	}
	public color get(RenderableTemplate _event, int _alpha){
        if(_alpha >= 255)
            return _event.getCustomFillColor();
        else
            return alphaMod(_event.getCustomFillColor(), _alpha);
	}
}




/**
 * ColorMap color picker
 */
class ColorMapColorizer extends Colorizer {

	public ColorMapColorizer(int _ind){
        modeIndex = _ind;
		name = "ColorMap";
		description = "Meta-freelining - use linked template position markers to pick colors from the colormap, set one with: colormap map.png";
	}

	public color get(RenderableTemplate _event, int _alpha){
		int _index = (_event.getBeatCount()-_event.getRepetition()+_event.getSegmentIndex());

		Template linked = _event.getLinkedTemplate();
		if(linked == null){
			println("[meta-freelining] WARNING : template "+_event.getTemplateID()+" has no linked template");
            return color(255,0,0);
		}

        if(linked.getMetaPoisitionMarkers().size() > 0 && freeliner.colorMapImage != null){
            _index %= linked.getMetaPoisitionMarkers().size();
            PositionMarker _marker = linked.getMetaPoisitionMarkers().get(_index);
            int _x = (int)_marker.pos.x;
            int _y = (int)_marker.pos.y;

            if(_x < freeliner.colorMapImage.width && _y < freeliner.colorMapImage.height && _x >= 0 && _y >= 0) {
                return freeliner.colorMapImage.pixels[_y*freeliner.colorMapImage.width+_x];
            }
        }
        return color(255,0,0);
        //
        // index %= PALLETTE_COUNT;
		// if(index < 0) index = 0;
		// color c = userPallet[index];
		// return alphaMod(c , _alpha);
	}
}
