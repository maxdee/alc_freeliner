
// Repetition was iterator
// returns different unit intervals in relation to
// unit intervals that are negative means reverse.
class Repetition extends Mode {
	Easing[] easers;
	Reverse[] reversers;
	// easer and reversers count in Config.pde

	float rev = 1.0;

	public Repetition(){
		name = "repetition";
		description = "how to darw multiples of one template";
		easers = new Easing[EASING_MODE_COUNT];
		easers[0] = new NoEasing(0);
		easers[1] = new Square(1);
		easers[2] = new Sine(2);
		easers[3] = new Cosine(3);
		easers[4] = new Boost(4);
		easers[5] = new RandomUnit(5);
		easers[6] = new TargetNoise(6);
		easers[7] = new Fixed(1.0, 7);
		easers[8] = new Fixed(0.5, 8);
		easers[9] = new Fixed(0.0, 9);
		easers[10] = new EaseInOut(10);

		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])easers, 'h', this, "EasingModes");

		reversers = new Reverse[REVERSE_MODE_COUNT];
		reversers[0] = new NotReverse(0);
		reversers[1] = new Reverse(1);
		reversers[2] = new BackForth(2);
		reversers[3] = new TwoTwoReverse(3);
		reversers[4] = new RandomReverse(4);
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])reversers, 'j', this, "ReverseModes");

	}

	public FloatList getFloats(RenderableTemplate _rt){
		rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
		FloatList flts = new FloatList();
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp*rev);
		return flts;
	}

	public Easing getEaser(int _index){
		if(_index >= EASING_MODE_COUNT) _index = EASING_MODE_COUNT - 1;
		return easers[_index];
	}

	public Reverse getReverser(int _index){
		if(_index >= REVERSE_MODE_COUNT) _index = REVERSE_MODE_COUNT - 1;
		return reversers[_index];
	}
}


/**
 * One single unit interval
 */
class Single extends Repetition {

	public Single(int _ind){
		super();
		modeIndex = _ind;
		name = "single";
		description = "only draw template once";
	}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp*rev);
		return flts;
	}
}

/**
 * Evenly spaced
 */
class EvenlySpaced extends Repetition{
	public EvenlySpaced(){}

	public EvenlySpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "EvenlySpaced";
		description = "Render things evenly spaced";
	}

	public FloatList getFloats(RenderableTemplate _rt){
		rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		int count = _rt.getRepetitionCount();
		return getEvenlySpaced(lrp, count);
	}

	public FloatList getEvenlySpaced(float _lrp, int _count){
		FloatList flts = new FloatList();
		float amount = abs(_lrp)/_count;
		float increments = 1.0/_count;
		for (int i = 0; i < _count; i++)
			flts.append(((increments * i) + amount)*rev);
		return flts;
	}
}

class EvenlySpacedWithZero extends EvenlySpaced{
	public EvenlySpacedWithZero(int _ind){
		super();
		modeIndex = _ind;
		name = "EvenlySpacedWithZero";
		description = "Render things evenly spaced with a fixed one at the begining and end";
	}
	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = super.getFloats(_rt);
		flts.append(0);
		flts.append(0.999);
		return flts;
	}
}

class ExpoSpaced extends EvenlySpaced{
	public ExpoSpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "ExpoSpaced";
		description = "RenderMultiples but make em go faster";
	}
	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt))  flts.append(pow(_f,2));
		return flts;
	}
}

/**
 * TwoFull
 */
class TwoFull extends Repetition{
	public TwoFull(int _ind){
		super();
		modeIndex = _ind;
		name = "TwoFull";
		description = "Render twice in opposite directions";
	}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp);
		flts.append(lrp*-1.0);
		return flts;
	}
}

class TwoSpaced extends EvenlySpaced{
	public TwoSpaced(int _ind){
		super();
		modeIndex = _ind;
		name = "TwoFull";
		description = "Render twice in opposite directions";
	}
	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt)){
			flts.append(_f);
			flts.append(-_f+1.0);
		}
		return flts;
	}
}
