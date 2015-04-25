

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
	
	SegmentSelector[] segmentSelectors;
	final int SELECTOR_COUNT = 6;
  SegmentPainter[] segmentPainters;
  final int PAINTER_COUNT = 5;
	
	public PerSegment(){
		segmentSelectors = new SegmentSelector[SELECTOR_COUNT];
		segmentSelectors[0] = new AllSegments();
		segmentSelectors[1] = new SequentialSegments();
		segmentSelectors[2] = new RunThroughSegments();
		segmentSelectors[3] = new RandomSegment();
		segmentSelectors[4] = new SegmentBranch();
		segmentSelectors[5] = new RunThroughBranches();

    segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new SimpleBrusher();
    segmentPainters[1] = new TwoBrush();
    segmentPainters[2] = new SpiralBrush();
    segmentPainters[3] = new BrushFill();
    segmentPainters[4] = new FunLine();
	}

	public void doRender(RenderableTemplate _rt){
		super.doRender(_rt);
		ArrayList<Segment> segList = getSelector(event.getSegmentMode()).getSegments(event);
    int index = 0;
    for(Segment seg : segList){
    	event.setSegmentIndex(index);
    	index++;
      getPainter(event.getAnimationMode()).paintSegment(seg, event);
    }
	}

	public SegmentSelector getSelector(int _index){
		if(_index >= SELECTOR_COUNT) _index = SELECTOR_COUNT - 1;
		return segmentSelectors[_index];
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
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
		ArrayList<Segment> segList;
		SegmentSelector selector = getSelector(event.getSegmentMode()); //constrain(event.getSegmentMode(), 4, 5);
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
	GroupPainter[] groupPainters;
	final int PAINTER_COUNT = 2;
	public Geometry(){
		groupPainters = new GroupPainter[PAINTER_COUNT];
		groupPainters[0] = new Filler();
		groupPainters[1] = new FunFiller();
	}

	public void doRender(RenderableTemplate _rt){
		event = _rt;
		getPainter(event.getAnimationMode()).paintGroup(event);
	}

	public GroupPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return groupPainters[_index];
	}
}


