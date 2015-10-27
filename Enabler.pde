class Enabler{
	public Enabler(){}

	public boolean enable(RenderableTemplate _rt){
		return true;
	}
}


class Disabler extends Enabler{
	public Disabler(){}

	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}


class Triggerable extends Enabler{
	public Triggerable(){
	}
	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}



class RandomEnabler extends Enabler{
	public RandomEnabler(){}
	public boolean enable(RenderableTemplate _rt){
		if(_rt.getRandomValue()%6 == 1) return true;
		else return false;
	}
}

class SweepingEnabler extends Enabler{
	final float DIST = 200.0;//float(width)/4.0;
	public SweepingEnabler(){
		super();
	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x + DIST/2.0;
		float tracker = _rt.getUnitInterval()*float(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}

class SwoopingEnabler extends Enabler{
	final float DIST = 200.0;//float(width)/4.0;
	public SwoopingEnabler(){
		super();

	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x - DIST/2.0;
		float tracker = (-_rt.getUnitInterval()+1)*float(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}
