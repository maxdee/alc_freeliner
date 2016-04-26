

class Reverse extends Mode {

  public Reverse(int _ind){
    super(_ind);
    name = "Reverse";
    description = "Goes reverse";
  }

  public float getDirection(RenderableTemplate _event){
    return -1.0;
  }
}

class NotReverse extends Reverse{

  public NotReverse(int _ind){
    super(_ind);
    name = "NotReverse";
    description = "Goes forward";
  }

  public float getDirection(RenderableTemplate _event){
    return 1.0;
  }
}


class BackForth extends Reverse{
	public BackForth(int _ind){
  super(_ind);}

	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 2 == 0) return 1.0;
		else return -1.0;
	}
}


class TwoTwoReverse extends Reverse{
	public TwoTwoReverse(int _ind){
    super(_ind);
    name = "TwoTwoReverse";
    description = "Goes twice forward then twice in reverse";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 4 > 1) return 1.0;
		else return -1.0;
	}
}

class RandomReverse extends Reverse{
	public RandomReverse(int _ind){
    super(_ind);
    name = "RandomReverse";
    description = "Might go forward, might go backwards";
  }
	public float getDirection(RenderableTemplate _rt){
		if(_rt.getRandomValue() % 2 == 1) return 1.0;
	   else return -1.0;
	}
}
