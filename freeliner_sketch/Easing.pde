
/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class Easing extends Mode{

	public Easing(){}
	public Easing(int _ind){
		modeIndex = _ind;
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
		modeIndex = _ind;
		name = "linear";
		description = "Linear movement";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class SquareEasing extends Easing{
	public SquareEasing(int _ind){
		modeIndex = _ind;
		name = "square";
		description = "Power of 2.";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 2);
	}
}

class CubeEasing extends Easing{
	public CubeEasing(int _ind){
		modeIndex = _ind;
		name = "cubic";
		description = "Power of 3.";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 3);
	}
}
//
// class SineEasing extends Easing{
// 	public Sine(int _ind){
// 		modeIndex = _ind;
// 		name = "sine";
// 		description = "Sine ish";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return (sin((_lrp+PI)*TWO_PI)+1.0)/2.0;
// 	}
// }

class CosineEasing extends Easing{
	public CosineEasing(int _ind){
		modeIndex = _ind;
		name = "cosine";
		description = "cosine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return (cos(_lrp*TWO_PI)+1.0)/2.0;
	}
}

class Boost extends Easing{
	public Boost(int _ind){
		modeIndex = _ind;
		name = "boost";
		description = "half a sine";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return 1.0-sin((_lrp)*HALF_PI);
	}
}

class SmoothStep extends Easing{
	public SmoothStep(int _ind){
		modeIndex = _ind;
		name = "smoothstep";
		description = "classic smoothstep";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return (_lrp * _lrp * (3 - 2 * _lrp));
	}
}

class SmootherStep extends Easing{
	public SmootherStep(int _ind){
		modeIndex = _ind;
		name = "smootherstep";
		description = "smoother smoothstep";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return (pow(_lrp,3) *(_lrp * (_lrp * 6 - 15) + 10));
	}
}

// class

class RandomUnit extends Easing{
	public RandomUnit(int _ind){
		modeIndex = _ind;
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
		modeIndex = _ind;
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
		modeIndex = _ind;
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
		modeIndex = _ind;
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

class FixLerp extends Easing{
	public FixLerp(int _ind){
		modeIndex = _ind;
		name = "fixLerp";
		description = "is set to template's tp lerp AB 0.5";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return _rt.getFixLerp();
	}
}
