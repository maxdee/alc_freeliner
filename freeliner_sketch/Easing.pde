
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
		description = "ease the planet";
	}
	// passed seperatly cause I may want to ease other things than the unit interval
	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class LinearEasing extends Easing {
	public LinearEasing(int _ind){
		modeIndex = _ind;
		name = "linear";
		description = "Linear movement";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class EaseInQuad extends Easing{
	public EaseInQuad(int _ind){
		modeIndex = _ind;
		name = "EaseInQuad";
		description = "quad acceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp*_lrp;
	}
}

class EaseOutQuad extends Easing{
	public EaseOutQuad(int _ind){
		modeIndex = _ind;
		name = "EaseOutQuad";
		description = "quad deceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp*(2.0-_lrp);
	}
}

class EaseInOutQuad extends Easing{
	public EaseInOutQuad(int _ind){
		modeIndex = _ind;
		name = "EaseInOutQuad";
		description = "quad acceleration & deceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return  _lrp < .5 ? 2.*_lrp*_lrp : -1.+(4.-2.*_lrp)*_lrp;
	}
}

class EaseInCubic extends Easing {
	public EaseInCubic(int _ind){
		modeIndex = _ind;
		name = "EaseInCubic";
		description = "cubic acceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		return _lrp*_lrp*_lrp;
	}
}

class EaseOutCubic extends Easing {
	public EaseOutCubic(int _ind){
		modeIndex = _ind;
		name = "EaseOutCubic";
		description = "cubic deceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		_lrp -= 1;
		return _lrp*_lrp*_lrp+1.;
	}
}

class EaseInOutCubic extends Easing {
	public EaseInOutCubic(int _ind){
		modeIndex = _ind;
		name = "EaseInOutCubic";
		description = "cubic acceleration & deceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		return _lrp < 0.5 ? 4*_lrp*_lrp*_lrp : (_lrp-1)*(2*_lrp-2)*(2*_lrp-2)+1;
	}
}

class EaseInQuart extends Easing {
	public EaseInQuart(int _ind){
		modeIndex = _ind;
		name = "EaseInQuart";
		description = "quart acceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		return _lrp*_lrp*_lrp*_lrp;
	}
}

class EaseOutQuart extends Easing {
	public EaseOutQuart(int _ind){
		modeIndex = _ind;
		name = "EaseOutQuart";
		description = "quart acceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		_lrp -= 1;
		return 1-_lrp*_lrp*_lrp*_lrp;
	}
}

class EaseInOutQuart extends Easing {
	public EaseInOutQuart(int _ind){
		modeIndex = _ind;
		name = "EaseInOutQuart";
		description = "quart acceleration and deceleration";
	}

	public float ease(float _lrp, RenderableTemplate _rt) {
		return _lrp < 0.5 ? 8*_lrp*_lrp*_lrp*_lrp : 1-8*(--_lrp)*_lrp*_lrp*_lrp;
	}
}

class EaseSpringIn extends Easing {
	public EaseSpringIn(int _ind){
		modeIndex = _ind;
		name = "EaseSpringIn";
		description = "like a reverse door stopper spring";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return .04 * _lrp / (--_lrp) * sin(25*_lrp);
	}
}

class EaseSpringOut extends Easing {
	public EaseSpringOut(int _ind){
		modeIndex = _ind;
		name = "EaseSpringOut";
		description = "like a door stopper spring";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return (.04 - .04 / _lrp) * sin(25*_lrp) +1;
	}
}

class EaseSpringInOut extends Easing {
	public EaseSpringInOut(int _ind){
		modeIndex = _ind;
		name = "EaseSpringInOut";
		description = "like a weird door stopper spring";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return (_lrp-=0.5) < 0 ? (.02+.01/_lrp) * sin(50*_lrp) : (.02-.01/_lrp)*sin(50*_lrp)+1;
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
//
// class CosineEasing extends Easing{
// 	public CosineEasing(int _ind){
// 		modeIndex = _ind;
// 		name = "cosine";
// 		description = "cosine";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return (cos(_lrp*TWO_PI)+1.0)/2.0;
// 	}
// }
//
// class Boost extends Easing{
// 	public Boost(int _ind){
// 		modeIndex = _ind;
// 		name = "boost";
// 		description = "half a sine";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return sin((_lrp)*HALF_PI);
// 	}
// }
//
// class SmoothStep extends Easing{
// 	public SmoothStep(int _ind){
// 		modeIndex = _ind;
// 		name = "smoothstep";
// 		description = "classic smoothstep";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return (_lrp * _lrp * (3 - 2 * _lrp));
// 	}
// }
//
// class SmootherStep extends Easing{
// 	public SmootherStep(int _ind){
// 		modeIndex = _ind;
// 		name = "smootherstep";
// 		description = "smoother smoothstep";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return smootherStep(_lrp);
// 	}
//
// 	float smootherStep(float _lrp){
// 		return (pow(_lrp,3) *(_lrp * (_lrp * 6 - 15) + 10));
// 	}
// }
//
// class DoubleSmootherStep extends Easing{
// 	public DoubleSmootherStep(int _ind){
// 		modeIndex = _ind;
// 		name = "doublesmootherstep";
// 		description = "double smoother smoothstep";
// 	}
//
// 	public float ease(float _lrp, RenderableTemplate _rt){
// 		return smootherStep(smootherStep(_lrp));
// 	}
//
// 	float smootherStep(float _lrp){
// 		return (pow(_lrp,3) *(_lrp * (_lrp * 6 - 15) + 10));
// 	}
// }
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
		name = "fixed-"+_f;
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

class CustomLerp extends Easing{
	public CustomLerp(int _ind){
		modeIndex = _ind;
		name = "custom";
		description = "is set to template's with this command tp lerp AB 0.5";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		return _rt.getFixLerp();
	}
}


class SpringEasing extends Easing {
	public SpringEasing(int _ind) {
		modeIndex = _ind;
		name = "spring";
		description = "like your door stopper but less zingy";
	}
	public float ease(float _lrp, RenderableTemplate _rt){
		// if(_lrp < 1/2.75){
		// 	return _lrp *
		// }


		return _rt.getFixLerp();
	}
}
