

class Reverse extends Mode {

  public Reverse(){
    name = "Reverse";
    description = "Goes reverse";
  }

  public float getDirection(RenderableTemplate _event){
    return -1.0;
  }
}

class NotReverse extends Reverse{

  public NotReverse(){
    name = "NotReverse";
    description = "Goes forward";
  }

  public float getDirection(RenderableTemplate _event){
    return 1.0;
  }
}


class BackForth extends Reverse{
	public BackForth(){}

	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 2 == 0) return 1.0;
		else return -1.0;
	}
}


class InOut extends Reverse{
	public InOut(){
    name = "InOut";
    description = "Goes out and in one beat";
  }

	public float getDirection(RenderableTemplate _rt){
    float _lrp = _rt.getUnitInterval();
    if(_lrp < 0.5) {
      _rt.setUnitInterval(_lrp *= 2);
      return 1.0;
    }
    else {
      _rt.setUnitInterval(_lrp = 2*(_lrp-1.0));
      return -1.0;
    }
	}
}


class TwoTwoReverse extends Reverse{
	public TwoTwoReverse(){
    name = "TwoTwoReverse";
    description = "Goes twice forward then twice in reverse";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 4 > 1) return 1.0;
		else return -1.0;
	}
}

class RandomReverse extends Reverse{
	public RandomReverse(){
    name = "RandomReverse";
    description = "Might go forward, might go backwards";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getRandomValue() % 2 == 1) return 1.0;
	   else return -1.0;
	}
}
