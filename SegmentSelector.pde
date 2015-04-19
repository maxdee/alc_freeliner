

// Segment Selector take a segmentGroup and returns segments to render

class SegmentSelector {
	public SegmentSelector(){
	}

	public SafeList<Segment> getSegments(RenderableTemplate _event){
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
	public AllSegments(){
	}

	public SafeList<Segment> getSegments(RenderableTemplate _event){
		return _event.getSegmentGroup().getSegments();
	} 
}

/**
 * Get the segments in order of creation
 */
class SequentialSegments extends SegmentSelector{
	public SequentialSegments(){
	}

	public SafeList<Segment> getSegments(RenderableTemplate _event){
		SafeList<Segment> segs = new SafeList();
		int index = _event.getBeatCount();
		segs.add(_event.segmentGroup.getSegment(index));
		return segs;
	} 
}

/**
 * Get the segments in order of creation
 */
class RunThroughSegments extends SegmentSelector{
	public RunThroughSegments(){
	}

	public SafeList<Segment> getSegments(RenderableTemplate _event){
		SafeList<Segment> segs = new SafeList();
		int index = int(_event.getLerp() * _event.segmentGroup.getCount());
		segs.add(_event.segmentGroup.getSegment(index));
		return segs;
	} 
}

/**
 * Get a random segment
 */
class RandomSegment extends SegmentSelector{
	public RandomSegment(){
	}
	public SafeList<Segment> getSegments(RenderableTemplate _event){
		SafeList<Segment> segs = new SafeList();
		int index = (int)random(_event.segmentGroup.getCount());
		segs.add(_event.segmentGroup.getSegment(index));
		return segs;
	} 
}

/**
 * Render at a branch level
 */
class SegmentBranch extends SegmentSelector{
	public SegmentBranch(){
	}
	public SafeList<Segment> getSegments(RenderableTemplate _event){
		return _event.segmentGroup.getBranch(_event.getBeatCount());
	} 
}

/**
 * Run through brnaches over lerp
 */
class RunThroughBranches extends SegmentSelector{
	public RunThroughBranches(){
	}
	public SafeList<Segment> getSegments(RenderableTemplate _event){
		int index = int(_event.getLerp() * _event.segmentGroup.treeBranches.size());
		return _event.segmentGroup.getBranch(_event.beatCount);
	} 
}


// /**
//  * Run through brnaches over lerp
//  */
// class Random extends SegmentSelector{
// 	public Random(){
// 	}
// 	public SafeList<Segment> getSegments(RenderableTemplate _event){
// 		int index = int(_event.getLerp() * _event.segmentGroup.treeBranches.size());
// 		return _event.segmentGroup.getBranch(_event.beatCount);
// 	} 
// }
