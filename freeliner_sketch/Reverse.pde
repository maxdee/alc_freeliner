

class Reverse extends Mode {

  public Reverse(){}
  public Reverse(int _ind){
    modeIndex = _ind;
    name = "Reverse";
    description = "Goes reverse";
  }

  public boolean getDirection(RenderableTemplate _event){
    return true;
  }
}

class NotReverse extends Reverse{

  public NotReverse(int _ind){
    modeIndex = _ind;
    name = "NotReverse";
    description = "Goes forward";
  }

  public boolean getDirection(RenderableTemplate _event){
    return false;
  }
}


class BackForth extends Reverse{
	public BackForth(int _ind){
  modeIndex = _ind;}

	public boolean getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 2 == 0) return false;
		else return true;
	}
}


class TwoTwoReverse extends Reverse{
	public TwoTwoReverse(int _ind){
    modeIndex = _ind;
    name = "TwoTwoReverse";
    description = "Goes twice forward then twice in reverse";
  }
	public boolean getDirection(RenderableTemplate _rt){
		if(_rt.getBeatCount() % 4 > 1) return false;
		else return true;
	}
}

class RandomReverse extends Reverse{
	public RandomReverse(int _ind){
    modeIndex = _ind;
    name = "RandomReverse";
    description = "Might go forward, might go backwards";
  }
	public boolean getDirection(RenderableTemplate _rt){
		if(_rt.getRandomValue() % 2 == 1) return false;
	   else return true;
	}
}
