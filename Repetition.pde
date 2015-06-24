


// Repetition was iterator
// returns different unit intervals in relation to 
// unit intervals that are negative means reverse.
class Repetition {
	Easing[] easers;
	final int EASER_COUNT = 10;
	public Repetition(){
		easers = new Easing[EASER_COUNT];
		easers[0] = new NoEasing();
		easers[1] = new ReverseLerp();
		easers[2] = new Square();
		easers[3] = new Sine();
		easers[4] = new BackForth();
		easers[5] = new RandomUnit();
		easers[6] = new TargetNoise();
		easers[7] = new Fixed(1.0);
		easers[8] = new Fixed(0.5);
		easers[9] = new Fixed(0.0);
	}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp);
		return flts;
	}

	public Easing getEaser(int _index){
		if(_index >= EASER_COUNT) _index = EASER_COUNT - 1;
		return easers[_index]; 
	}
}


/**
 * One single unit interval
 */
class Single extends Repetition {

	public Single(){
	}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp);
		return flts;
	}
}

/**
 * Evenly spaced
 */
class EvenlySpaced extends Repetition{
	public EvenlySpaced(){}

	public FloatList getFloats(RenderableTemplate _rt){
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		int count = _rt.getRepetitionCount();
		return getEvenlySpaced(lrp, count);
	}

	public FloatList getEvenlySpaced(float _lrp, int _count){
		FloatList flts = new FloatList();
		float dir;
		if(_lrp != 0.0) dir = abs(_lrp)/_lrp;
		else dir = 1.0;
		float amount = abs(_lrp)/_count;
		float increments = 1.0/_count;
		for (int i = 0; i < _count; i++)
			flts.append(((increments * i) + amount)*dir);
		return flts;
	}
}

class EvenlySpacedWithZero extends EvenlySpaced{
	public EvenlySpacedWithZero(){}
	public FloatList getFloats(RenderableTemplate _rt){
		FloatList floats = super.getFloats(_rt);
		floats.append(0);
		floats.append(0.999);
		return floats;
	}
}


/**
 * TwoFull
 */
class TwoFull extends Repetition{
	public TwoFull(){}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);

		flts.append(lrp);
		flts.append(lrp-1);
		return flts;
	}
}