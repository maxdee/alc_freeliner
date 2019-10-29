
// Repetition was iterator
// returns different unit intervals in relation to
// unit intervals that are negative means reverse.
class Repetition extends Mode {


	public Repetition(){
		name = "repetition";
	}

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList _flts = new FloatList();
		_flts.append(_unit);
		return _flts;
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

	// public FloatList getFloats(RenderableTemplate _rt){
	// 	FloatList flts = new FloatList();
	// 	rev = getReverser(_rt.getReverseMode()).getDirection(_rt);
	// 	float lrp = getEaser(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
	// 	flts.append(lrp*rev);
	// 	return flts;
	// }
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

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		int _count = _rt.getRepetitionCount();
		return getEvenlySpaced(_unit, _count);
	}

	public FloatList getEvenlySpaced(float _lrp, int _count){
		FloatList flts = new FloatList();
		float amount = abs(_lrp)/_count;
		float increments = 1.0/_count;
		for (int i = 0; i < _count; i++)
			flts.append((increments * i) + amount);
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
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = super.getFloats(_rt, _unit);
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
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt, _unit))  flts.append(pow(_f,2));
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

	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		flts.append(_unit);
		flts.append(_unit*-1.0);
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
	public FloatList getFloats(RenderableTemplate _rt, float _unit){
		FloatList flts = new FloatList();
		for(float _f : super.getFloats(_rt, _unit)){
			flts.append(_f);
			flts.append(_f*-1.0);
		}
		return flts;
	}
}
