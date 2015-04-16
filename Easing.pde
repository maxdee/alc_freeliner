

class Easing {

	public Easing(){

	}
	// passed seperatly cause I may want to ease other things than the unit interval
	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class NoEasing extends Easing {
	public NoEasing(){

	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return _lrp;
	}
}

class Square extends Easing{
	public Square(){

	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return pow(_lrp, 2);
	}
}

class Sine extends Easing{
	public Sine(){

	}

	public float ease(float _lrp, RenderableTemplate _rt){
		return sin(_lrp*PI);

	}
}

