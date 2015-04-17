

/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode {

	RenderableTemplate event;

	public RenderMode(){

	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
	}

}


/**
 * Parent class for all rendering that happens per segment.
 */
class PerSegment extends RenderMode{
	
	SafeList<SegmentSelector> segmentSelectors;
  SafeList<SegmentPainter> segmentPainters;
	
	public PerSegment(){
		segmentSelectors = new SafeList();
		segmentSelectors.add(new AllSegments());
		segmentSelectors.add(new SequentialSegments());
		segmentSelectors.add(new RunThroughSegments());
		segmentSelectors.add(new RandomSegment());
		segmentSelectors.add(new SegmentBranch());
		segmentSelectors.add(new RunThroughBranches());

    segmentPainters = new SafeList();
    segmentPainters.add(new BrushPutter());
    segmentPainters.add(new SpiralBrush());
    segmentPainters.add(new LinePainter());
    segmentPainters.add(new FunLine());
	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
		ArrayList<Segment> segList = segmentSelectors.get(event.getSegmentMode()).getSegments(event);
    for(Segment seg : segList)
      segmentPainters.get(event.getAnimationMode()).paintSegment(seg, event);
	}
}

/**
 * Parent class for all rendering that happens with all segments.
 */

class Geometry extends RenderMode{
	SafeList<GroupPainter> groupPainters;
	public Geometry(){
		groupPainters = new SafeList();
		groupPainters.add(new Filler());
	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
		groupPainters.get(event.getAnimationMode()).paintGroup(event);
	}
}



