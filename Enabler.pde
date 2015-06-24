class Enabler{
	
	public Enabler(){

	}
	public boolean enable(RenderableTemplate _rt){
		return true;
	}
}


class Disabler extends Enabler{
	
	public Disabler(){

	}
	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}




class RandomTimes extends Enabler{
	public RandomTimes(){}
	public boolean enable(RenderableTemplate _rt){
		if(_rt.getRandomValue()%6 == 1) return true;
		else return false;
	}
}

class EveryX extends Enabler{
	int beatSelect = 0;
	public EveryX(int _x){
		super();
		beatSelect = _x;
	}
	public boolean enable(RenderableTemplate _rt){
		if(_rt.getBeatCount()%beatSelect == 0) return true;
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
			_rt.setTime(diff/DIST, _rt.getBeatCount());
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
			_rt.setTime(diff/DIST, _rt.getBeatCount());
			return true;
		}
		else return false;
	}
}
