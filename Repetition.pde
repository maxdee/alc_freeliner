
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
		easers[0] = new NoEasing();
		easers[1] = new Square();
		easers[2] = new Sine();
		easers[3] = new Cosine();
		easers[4] = new Boost();
		easers[5] = new RandomUnit();
		easers[6] = new TargetNoise();
		easers[7] = new Fixed(1.0);
		easers[8] = new Fixed(0.5);
		easers[9] = new Fixed(0.0);
		easers[10] = new EaseInOut();

		if(MAKE_DOCUMENTATION) documenter.addDoc((Mode[])easers, 'h', name);

		reversers = new Reverse[REVERSE_MODE_COUNT];
		reversers[0] = new NotReverse();
		reversers[1] = new Reverse();
		reversers[2] = new BackForth();
		reversers[3] = new TwoTwoReverse();
		reversers[4] = new RandomReverse();
		if(MAKE_DOCUMENTATION) documenter.addDoc((Mode[])reversers, 'j', name);

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

	public Single(){
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
	public EvenlySpaced(){
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
	public EvenlySpacedWithZero(){
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
	public ExpoSpaced(){
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
	public TwoFull(){
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
	public TwoSpaced(){
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
