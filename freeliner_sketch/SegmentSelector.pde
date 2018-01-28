

// Segment Selector take a segmentGroup and returns segments to render

class SegmentSelector extends Mode {
	public SegmentSelector(){}
	public SegmentSelector(int _ind){
		modeIndex = _ind;
		name = "SegmentSelector";
		description = "Selects segments to render";
	}

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
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

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<Segment> _segs = _event.getSegmentGroup().getSegments();
		ArrayList<LerpSegment> _list = new ArrayList();
		for(Segment _seg : _segs){
			_list.add(new LerpSegment(_seg, _event.getLerp()));
		}
		return _list;
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

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999);
		Segment _seg = _event.segmentGroup.getSegmentSequence(index);
		if(_seg == null) return null;
		_segs.add(new LerpSegment(_seg, _event.getLerp()));
		return _segs;
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

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();
		float _segCount = _event.segmentGroup.getCount();
		float _unit = _event.getLerp();// getUnitInterval();
		int _index = int(_unit * _segCount);
		float _inc = 1.0/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;
		// this right here is important
		Segment _seg = _event.segmentGroup.getSegment(_index);
		_segs.add(new LerpSegment(_seg, _lrp));
		return _segs;
	}
}

/**
 * Get the segments in order of creation
 */
class ConstantSpeed extends SegmentSelector{
	public ConstantSpeed(int _ind){
		modeIndex = _ind;
		name = "ConstantSpeed";
		description = "Runs through segments at a consistant speed.";
	}

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();
		float _segCount = _event.segmentGroup.getCount();
		float _unit = _event.getLerp();
		Segment _seg = _event.segmentGroup.getSegmentByTotalLength(_unit);
		if(_seg != null) _segs.add(new LerpSegment(_seg, _seg.getLerp()));
		return _segs;
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
	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();
		int index = _event.getLargeRandomValue() % _event.segmentGroup.getCount();
		Segment _seg = _event.segmentGroup.getSegment(index);
		_segs.add(new LerpSegment(_seg, _event.getLerp()));
		// could get R's worth of random segments?
		// then setLerp...
		return _segs;
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
	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();
		int index = (int)random(_event.segmentGroup.getCount());
		Segment _seg = _event.segmentGroup.getSegment(index);
		_segs.add(new LerpSegment(_seg, _event.getLerp()));
		return _segs;
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
	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		int index = _event.getBeatCount();
		if(_event.getDirection()) index = 10000 - (index % 9999); // dosent seem to work...
		ArrayList<LerpSegment> _segs = new ArrayList();
		for(Segment _seg : _event.segmentGroup.getBranch(index)){
			_segs.add(new LerpSegment(_seg, _event.getLerp()));
		}
		return _segs;
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
	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		float _segCount = _event.segmentGroup.treeBranches.size();
		float _unit = _event.getLerp();//UnitInterval();
		int _index = int(_unit * _segCount);
		float _inc = 1.0/_segCount;
		float _lrp = (_unit - (_index * _inc))/_inc;
		ArrayList<Segment> _s = _event.segmentGroup.getBranch(_index);
		ArrayList<LerpSegment> _segs = new ArrayList();
		for(Segment _seg : _s) _segs.add(new LerpSegment(_seg, _lrp));
		return _segs;
	}
}



/////////////////// meta segment selectors

class MetaSegmentSelector extends SegmentSelector{
	public MetaSegmentSelector(int _ind){
		modeIndex = _ind;
		name = "MetaSegmentSelector";
		description = "Use metapoints to select segments";
	}

	public ArrayList<LerpSegment> getSegments(RenderableTemplate _event){
		ArrayList<LerpSegment> _segs = new ArrayList();

		PVector _pos = null;
		for(PVector _marker :_event.getSourceTemplate().getMetaPoisitionMarkers()){
			if(_marker != null){
				for(Segment _seg : _event.segmentGroup.getSegments()){
					if(_seg != null) {
						PVector _center = _seg.getMidPoint();
						float _s = _marker.z;
						float _d = _marker.dist(_center)-_s;
						if(_d < _s && _d > 0){
							_segs.add(new LerpSegment(_seg, _d/_s));
						}
					}
				}
			}
		}
		return _segs;
	}
}



//
//
//
// class MarkerEnabler extends Enabler{
// 	// final float DIST = 200.0;//float(width)/4.0;
//
// 	public MarkerEnabler(){
// 	}
// 	public MarkerEnabler(int _ind){
// 		modeIndex = _ind;
// 		name = "MarkerEnabler";
// 		description = "Use meta points to enablestuff";
// 	}
// 	public boolean enable(RenderableTemplate _rt){
//
// 		if(_pos != null){
// 			PVector _center = _rt.getSegmentGroup().getCenter();
// 			float _s = _pos.z;
// 			float _d = _pos.dist(_center)-_s;
// 			if(_d < _s && _d > 0){
// 				_rt.setUnitInterval(_d/_s);
// 				return true;
// 			}
// 			else return false;
// 		}
// 		// else return false;
// 		return false;
// 	}
// }
