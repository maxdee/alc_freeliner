


// Repetition was iterator
// returns different unit intervals in relation to 
// unit intervals that are negative means reverse.
class Repetition {
	SafeList<Easing> easers;
	public Repetition(){
		easers = new SafeList();
		easers.add(new NoEasing());
		easers.add(new Square());
		easers.add(new Sine());
		easers.add(new RandomUnit());
	}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = easers.get(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		flts.append(lrp);
		return flts;
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
		float lrp = easers.get(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
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
		FloatList flts = new FloatList();
		float lrp = easers.get(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);
		int count = _rt.getRepetitionCount();
		float amount = lrp/count;
		float increments = 1.0/count;
		for (int i = 0; i < count; i++)
			flts.append((increments * i) + amount);
		return flts;
	}
}

/**
 * TwoFull
 */
class TwoFull extends Repetition{
	public TwoFull(){}

	public FloatList getFloats(RenderableTemplate _rt){
		FloatList flts = new FloatList();
		float lrp = easers.get(_rt.getEasingMode()).ease(_rt.getUnitInterval(), _rt);

		flts.append(lrp);
		flts.append(lrp-1);
		return flts;
	}
}