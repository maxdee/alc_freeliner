

// Segment Selector take a segmentGroup and returns segments to render

class SegmentSelector extends Mode {
	public SegmentSelector(){}
	public SegmentSelector(int _ind){
		modeIndex = _ind;
		name = "SegmentSelector";
		description = "Selects segments to render";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		return null;
	}
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////
/**
 * Get all the segments of an _event
 */
class AllSegments extends SegmentSelector {
	public AllSegments(int _ind){
		modeIndex = _ind;
		name = "AllSegments";
		description = "Renders all segments";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		return _event.getSegmentGroup().getSegments();
	}
}

/**
 * Get the segments in order of creation
 */
class SequentialSegments extends SegmentSelector{
	public SequentialSegments(int _ind){
		modeIndex = _ind;
		name = "SequentialSegments";
		description = "Renders one segment per beat in order.";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> segs = new ArrayList();
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999);
		segs.add(_event.segmentGroup.getSegmentSequence(index));
		return segs;
	}
}

/**
 * Get the segments in order of creation
 */
class RunThroughSegments extends SegmentSelector{
	public RunThroughSegments(int _ind){
		modeIndex = _ind;
		name = "RunThroughSegments";
		description = "Render all segments in order in one beat.";
	}

	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> segs = new ArrayList();
		float _segCount = _event.segmentGroup.getCount();
		float _unit = _event.getLerp();// getUnitInterval();
		int _index = int(_unit * _segCount);
		float _inc = 1.0/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;
		// this right here is important
		_event.setLerp(_lrp);
		segs.add(_event.segmentGroup.getSegment(_index));
		return segs;
	}
}

/**
 * Get a random segment
 */
class RandomSegment extends SegmentSelector{
	public RandomSegment(int _ind){
		modeIndex = _ind;
		name = "RandomSegment";
		description = "Render a random segment per beat.";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> segs = new ArrayList();
		int index = _event.getLargeRandomValue() % _event.segmentGroup.getCount();
		segs.add(_event.segmentGroup.getSegment(index));
		// could get R's worth of random segments?
		// then setLerp...
		return segs;
	}
}

/**
 * Get a random segment
 */
class FastRandomSegment extends SegmentSelector{
	public FastRandomSegment(int _ind){
		modeIndex = _ind;
		name = "FastRandomSegment";
		description = "Render a different segment per frame";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> segs = new ArrayList();
		int index = (int)random(_event.segmentGroup.getCount());
		segs.add(_event.segmentGroup.getSegment(index));
		return segs;
	}
}

/**
 * Render at a branch level
 */
class SegmentBranch extends SegmentSelector{
	public SegmentBranch(int _ind){
		modeIndex = _ind;
		name = "SegmentBranch";
		description = "Renders segment in branch level augmenting every beat";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999); // dosent seem to work...
		return _event.segmentGroup.getBranch(index);
	}
}

/**
 * Run through branches over lerp
 */
class RunThroughBranches extends SegmentSelector{
	public RunThroughBranches(int _ind){
		modeIndex = _ind;
		name = "RunThroughBranches";
		description = "Render throught all the branch levels in one beat.";
	}
	public ArrayList<Segment> getSegments(RenderableTemplate _event){
		float _segCount = _event.segmentGroup.treeBranches.size();
		float _unit = _event.getLerp();//UnitInterval();
		int _index = int(_unit * _segCount);
		float _inc = 1.0/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;

		_event.setLerp(_lrp);
		return _event.segmentGroup.getBranch(_index);
	}
}
