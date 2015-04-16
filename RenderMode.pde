

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
    segmentPainters.add(new LinePainter());
    segmentPainters.add(new FunLine());
    segmentPainters.add(new BrushPutter());
    segmentPainters.add(new SpiralBrush());
	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
		ArrayList<Segment> segList = segmentSelectors.get(event.getSegmentMode()).getSegments(event);
    for(Segment seg : segList)
      segmentPainters.get(event.getAnimationMode()).paintSegment(seg, event);
	}

}

class Geometry extends RenderMode{
	public Geometry(){}

	public void doRender(RenderableTemplate _rt){

	}
}