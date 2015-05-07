class Enabler{
	
	public Enabler(){

	}

	public boolean enable(RenderableTemplate _rt){
		return true;
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