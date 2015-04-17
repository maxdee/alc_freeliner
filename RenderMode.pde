

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
    segmentPainters.add(new SimpleBrush());
    segmentPainters.add(new SpiralBrush());
    segmentPainters.add(new FunLine());
	}

	public void doRender(RenderableTemplate _rt){
		super.doRender(_rt);
		ArrayList<Segment> segList = segmentSelectors.get(event.getSegmentMode()).getSegments(event);
    for(Segment seg : segList)
      segmentPainters.get(event.getAnimationMode()).paintSegment(seg, event);
	}
}




////////////////////////////////////////////////////////////////////////////////////
///////
///////    String Art?
///////
////////////////////////////////////////////////////////////////////////////////////

class WrapLine extends PerSegment{
	
	LineToLine painter;

	public WrapLine(){
		painter = new LineToLine();
	}

	public void doRender(RenderableTemplate _rt) {
		//super.doRender(_rt);
		event = _rt;
		ArrayList<Segment> segList;
		SegmentSelector selector = segmentSelectors.get(event.getSegmentMode()); //constrain(event.getSegmentMode(), 4, 5);
		// need to constrain to a few segmentSelectors...
		if(selector instanceof SegmentBranch){
			segList = selector.getSegments(event);
			painter.paint(segList, event);
		}
		else if(selector instanceof RunThroughBranches){
			segList = selector.getSegments(event);
			painter.paint(segList, event);
		}
		else {
			ArrayList<ArrayList<Segment>> trees = event.getSegmentGroup().getBranches();
			for(ArrayList<Segment> branch : trees){
				painter.paint(branch, event);
			}
			//println("=============================");
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////    fill etc
///////
////////////////////////////////////////////////////////////////////////////////////

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


