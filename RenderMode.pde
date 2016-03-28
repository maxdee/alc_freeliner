

/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode implements FreelinerConfig{

	public RenderMode(){

	}

	public void doRender(RenderableTemplate _rt){}
}


/**
 * Parent class for all rendering that happens per segment.
 */
class PerSegment extends RenderMode{
	// selectorModeCount in Config.pde
	SegmentSelector[] segmentSelectors;

	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 1;

	public PerSegment(){
		segmentSelectors = new SegmentSelector[SEGMENT_MODE_COUNT];
		segmentSelectors[0] = new AllSegments();
		segmentSelectors[1] = new SequentialSegments();
		segmentSelectors[2] = new RunThroughSegments();
		segmentSelectors[3] = new RandomSegment();
		segmentSelectors[4] = new FastRandomSegment();
		segmentSelectors[5] = new SegmentBranch();
		segmentSelectors[6] = new RunThroughBranches();
		// place holder for painter
		segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new SimpleBrusher();
	}

	public void doRender(RenderableTemplate _event){
		ArrayList<Segment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
    int index = 0;
    if(segList == null) return;
    for(Segment seg : segList){
    	_event.setSegmentIndex(index);
    	index++;
      if(seg != null) getPainter(_event.getAnimationMode()).paintSegment(seg, _event);
    }
	}

	public SegmentSelector getSelector(int _index){
		if(_index >= SEGMENT_MODE_COUNT) _index = SEGMENT_MODE_COUNT - 1;
		return segmentSelectors[_index];
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}
//
// /**
//  * Parent class for all rendering that happens per segment.
//  */
// class PerSegmentOffset extends PerSegment{
//
//
//
// 	public PerSegmentOffset(){
// 		super();
// 	}
//
// 	public void doRender(RenderableTemplate _event){
// 		ArrayList<Segment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
//     int index = 0;
//     if(segList == null) return;
//     for(Segment seg : segList){
//     	_event.setSegmentIndex(index);
//     	index++;
//       if(seg != null) getPainter(_event.getAnimationMode()).paintSegment(seg, _event);
//     }
// 	}
//
// 	public SegmentSelector getSelector(int _index){
// 		if(_index >= SEGMENT_MODE_COUNT) _index = SEGMENT_MODE_COUNT - 1;
// 		return segmentSelectors[_index];
// 	}
//
// 	public SegmentPainter getPainter(int _index){
// 		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
// 		return segmentPainters[_index];
// 	}
// }
//



// Place brushes on segments
class BrushSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
  final int PAINTER_COUNT = 6;

  public BrushSegment(){
  	super();
  	segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new SimpleBrusher();
    segmentPainters[1] = new TwoBrusher();
    segmentPainters[2] = new SpiralBrusher();
    segmentPainters[3] = new InShapeBrusher();
    segmentPainters[4] = new CenterBrusher();
		segmentPainters[5] = new OppositeBrusher();
    // segmentPainters[6] = new CircularBrusher();
  }
	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}

// Make lines on segments
class LineSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 6;

	public LineSegment(){
		super();
		segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new FunLine();
    segmentPainters[1] = new FullLine();
    segmentPainters[2] = new MiddleLine();
		segmentPainters[3]  = new TrainLine();
    segmentPainters[4] = new Maypole();
    segmentPainters[5] = new SegToSeg();
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}

// Make circles on segments
class CircularSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 2;

	public CircularSegment(){
		super();
		segmentPainters = new SegmentPainter[PAINTER_COUNT];
		segmentPainters[0] = new Elliptic();
    segmentPainters[1] = new RadarPainter();
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}


// text rendering
class TextLine extends PerSegment{
	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 1;

	public TextLine(){
		super();
		segmentPainters = new SegmentPainter[PAINTER_COUNT];
		segmentPainters[0] = new TextWritter();
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}


class WrapLine extends PerSegment{
	LineToLine painter;

	public WrapLine(){
		painter = new LineToLine();
	}
	public void doRender(RenderableTemplate _rt) {
		//super.doRender(_rt);
		ArrayList<Segment> segList;
		SegmentSelector selector = getSelector(_rt.getSegmentMode()); //constrain(_rt.getSegmentMode(), 4, 5);
		// need to constrain to a few segmentSelectors...
		if(selector instanceof SegmentBranch){
			segList = selector.getSegments(_rt);
			painter.paint(segList, _rt);
		}
		else if(selector instanceof RunThroughBranches){
			segList = selector.getSegments(_rt);
			painter.paint(segList, _rt);
		}
		else {
			ArrayList<ArrayList<Segment>> trees = _rt.getSegmentGroup().getBranches();
			for(ArrayList<Segment> branch : trees){
				painter.paint(branch, _rt);
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
		groupPainters[1] = new InterpolatorShape();
		//groupPainters[2] = new FlashFiller();
	}

	public void doRender(RenderableTemplate _event){

		getPainter(_event.getAnimationMode()).paintGroup(_event);
	}

	public GroupPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return groupPainters[_index];
	}
}
