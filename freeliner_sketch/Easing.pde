
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class Easing extends Mode{

	public Easing(int _ind){
		super(_ind);
		name = "easing";
		description = "ease the unti interval";
	}
	// passed seperatly cause I may want to ease other things than the unit interval
	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class NoEasing extends Easing {
	public NoEasing(int _ind){
		super(_ind);
		name = "linear";
		description = "Linear movement";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class Square extends Easing{
	public Square(int _ind){
		super(_ind);
		name = "square";
		description = "Power of 2.";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 2);
	}
}

class Sine extends Easing{
	public Sine(int _ind){
		super(_ind);
		name = "sine";
		description = "Sine ish";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin((_lrp)*PI);
	}
}

class Cosine extends Easing{
	public Cosine(int _ind){
		super(_ind);
		name = "cosine";
		description = "cosine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return cos(_lrp*PI);
	}
}

class Boost extends Easing{
	public Boost(int _ind){
		super(_ind);
		name = "boost";
		description = "half a sine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin((_lrp)*HALF_PI);
	}
}

class RandomUnit extends Easing{
	public RandomUnit(int _ind){
		super(_ind);
		name = "random";
		description = "random unitInterval every frame";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return random(1.0);
	}
}

class Fixed extends Easing{
	float value;
	public Fixed(float _f, int _ind){
		super(_ind);
		value = _f;
		name = "fixed";
		description = "fixed at "+_f;
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return value;
	}
}

class EaseInOut extends Easing{

	public EaseInOut(int _ind){
		super(_ind);
		name = "EaseInOut";
		description = "Linera eas in and out";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
    if(_lrp < 0.5)
      return _lrp *= 2;
    else
      return _lrp = -2*(_lrp-1.0);
	}
}


class TargetNoise extends Easing{
	int target;
	int position;
	int frame;

	public TargetNoise(int _ind){
		super(_ind);
		target = 0;
		position = 0;
		frame = 0;
		name = "targetNoise";
		description = "fake audio response";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		// if new frame
		if(frame != frameCount){
			frame = frameCount;
			float ha = 10.0+(abs(sin(float(millis())/666))*5.0);
			if(target < 0){
				position -= ha;
				if(position < target)
					target = abs(target);
				}
			else {
				position+=ha;
				if(position > target)
					target = int(-random(100)+20);
			}
			target = constrain(target, -100, 100);
		}
		return float(position+100)/200.0;
	}
}
