

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
    segmentPainters.add(new SimpleBrusher());
    segmentPainters.add(new TwoBrush());
    segmentPainters.add(new SpiralBrush());
    segmentPainters.add(new BrushFill());
    segmentPainters.add(new FunLine());
	}

	public void doRender(RenderableTemplate _rt){
		super.doRender(_rt);
		SafeList<Segment> segList = segmentSelectors.get(event.getSegmentMode()).getSegments(event);
    int index = 0;
    for(Segment seg : segList){
    	event.setSegmentIndex(index);
    	index++;
      segmentPainters.get(event.getAnimationMode()).paintSegment(seg, event);
    }
	}
}


//////////////   catch null segments?

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
		SafeList<Segment> segList;
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
			SafeList<SafeList<Segment>> trees = event.getSegmentGroup().getBranches();
			for(SafeList<Segment> branch : trees){
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
		groupPainters.add(new FunFiller());
	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
		groupPainters.get(event.getAnimationMode()).paintGroup(event);
	}
}


