

/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode {

	public RenderMode(){

	}

	public void doRender(RenderableTemplate _rt){}
}


/**
 * Parent class for all rendering that happens per segment.
 */
class PerSegment extends RenderMode{
	
	SegmentSelector[] segmentSelectors;
	final int SELECTOR_COUNT = 6;

	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 1;

	public PerSegment(){
		segmentSelectors = new SegmentSelector[SELECTOR_COUNT];
		segmentSelectors[0] = new AllSegments();
		segmentSelectors[1] = new SequentialSegments();
		segmentSelectors[2] = new RunThroughSegments();
		segmentSelectors[3] = new RandomSegment();
		segmentSelectors[4] = new SegmentBranch();
		segmentSelectors[5] = new RunThroughBranches();
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
		if(_index >= SELECTOR_COUNT) _index = SELECTOR_COUNT - 1;
		return segmentSelectors[_index];
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}

// Place brushes on segments
class BrushSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
  final int PAINTER_COUNT = 6;

  public BrushSegment(){
  	super();
  	segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new SimpleBrusher();
    segmentPainters[1] = new TwoBrush();
    segmentPainters[2] = new SpiralBrush();
    segmentPainters[3] = new BrushFill();
    segmentPainters[4] = new CenterBrusher();
    segmentPainters[5] = new CircularBrusher();
  }
	public SegmentPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return segmentPainters[_index];
	}
}

// Make lines on segments
class LineSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	final int PAINTER_COUNT = 5;

	public LineSegment(){
		super();
		segmentPainters = new SegmentPainter[PAINTER_COUNT];
    segmentPainters[0] = new FunLine();
    segmentPainters[1] = new FullLine();
    segmentPainters[2] = new MiddleLine();
    segmentPainters[3] = new Maypole();
    segmentPainters[4] = new SegToSeg();
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

	public void doRender(RenderableTemplate _event) {
		ArrayList<Segment> segList;
		SegmentSelector selector = getSelector(_event.getSegmentMode()); //constrain(_event.getSegmentMode(), 4, 5);
		// need to constrain to a few segmentSelectors...
		if(selector instanceof SegmentBranch){
			segList = selector.getSegments(_event);
			painter.paint(segList, _event);
		}
		else if(selector instanceof RunThroughBranches){
			segList = selector.getSegments(_event);
			painter.paint(segList, _event);
		}
		else {
			ArrayList<ArrayList<Segment>> trees = _event.getSegmentGroup().getBranches();
			for(ArrayList<Segment> branch : trees){
				painter.paint(branch, _event);
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
	final int PAINTER_COUNT = 3;
	public Geometry(){
		groupPainters = new GroupPainter[PAINTER_COUNT];
		groupPainters[0] = new Filler();
		groupPainters[1] = new FunFiller();
		groupPainters[2] = new NoiseShape();
		//groupPainters[3] = new SegToSeg();
	}

	public void doRender(RenderableTemplate _event){

		getPainter(_event.getAnimationMode()).paintGroup(_event);
	}

	public GroupPainter getPainter(int _index){
		if(_index >= PAINTER_COUNT) _index = PAINTER_COUNT - 1;
		return groupPainters[_index];
	}
}


