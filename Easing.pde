

class Easing {

	public Easing(){}
	// passed seperatly cause I may want to ease other things than the unit interval
	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}

	public float invert(float _f){
		return -_f+1.0;
	}
}

class NoEasing extends Easing {
	public NoEasing(){}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class Square extends Easing{
	public Square(){}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 2);
	}
}

class Sine extends Easing{
	public Sine(){}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin(_lrp*PI);
	}
}

class RandomUnit extends Easing{
	public RandomUnit(){}

	public float ease(float _lrp, RenderableTemplate _rt){
		return random(1.0);
	}
}

class Fixed extends Easing{
	float value;
	public Fixed(float _f){
		value = _f;
	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return value;
	}
}	

class BackForth extends Easing{
	public BackForth(){}

	public float ease(float _lrp, RenderableTemplate _rt){
		if(_rt.getBeatCount() % 2 == 0) return _lrp;
		else return -invert(_lrp); 
	}
}

class TargetNoise extends Easing{
	int target;
	int position;
	int frame;

	public TargetNoise(){
		target = 0;
		position = 0;
		frame = 0;
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