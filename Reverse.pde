

class Reverse {

  public Reverse(){}

  public float getDirection(RenderableTemplate _event){
    return -1.0;
  }
}

class NotReverse extends Reverse{

  public NotReverse(){}

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

class TwoTwoReverse extends Reverse{
	public TwoTwoReverse(){}
	public float getDirection(float _lrp, RenderableTemplate _rt){
		if(_rt.getBeatCount() % 4 > 1) return 1.0;
		else return -1.0;
	}
}