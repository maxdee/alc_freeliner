

/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode extends Mode{

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
	int painterCount = 1;
	int segmentModeCount = 8;

	public PerSegment(){
		name = "PersegmentRender";
		description = "Things that render per each segment";
		segmentSelectors = new SegmentSelector[segmentModeCount];
		segmentSelectors[0] = new AllSegments(0);
		segmentSelectors[1] = new SequentialSegments(1);
		segmentSelectors[2] = new RunThroughSegments(2);
		segmentSelectors[3] = new RandomSegment(3);
		segmentSelectors[4] = new FastRandomSegment(4);
		segmentSelectors[5] = new SegmentBranch(5);
		segmentSelectors[6] = new RunThroughBranches(6);
		segmentSelectors[7] = new ConstantSpeed(7);


		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentSelectors, 'v', this, "SegmentSelector");
		// place holder for painter
		segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new SimpleBrusher(0);
	}

	public void doRender(RenderableTemplate _event){
		ArrayList<Segment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
    int index = 0;
    if(segList == null) return;
    for(Segment seg : segList){
    	_event.setSegmentIndex(index);
    	index++;
      if(seg != null && !seg.isHidden()) {
				_event.setLerp(seg.getLerp());
				getPainter(_event.getAnimationMode()).paintSegment(seg, _event);
			}
    }
	}

	public SegmentSelector getSelector(int _index){
		if(_index >= segmentModeCount) _index = segmentModeCount - 1;
		return segmentSelectors[_index];
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}



// Place brushes on segments
class BrushSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
  int painterCount = 1;

  public BrushSegment(int _ind){
		super();
		modeIndex = _ind;
  	segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new SimpleBrusher(0);

		name = "BrushSegment";
		description = "Render mode for drawing with brushes";
		//if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "None?");
    // segmentPainters[6] = new CircularBrusher();
  }
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}

// Make lines on segments
class LineSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 7;

	public LineSegment(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
    segmentPainters[0] = new FunLine(0);
    segmentPainters[1] = new FullLine(1);
    segmentPainters[2] = new MiddleLine(2);
		segmentPainters[3]  = new TrainLine(3);
    segmentPainters[4] = new Maypole(4);
    segmentPainters[5] = new SegToSeg(5);
		segmentPainters[6] = new AlphaLine(6);

		name = "LineSegment";
		description = "Draw lines related to segments";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "LineModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}

// Make circles on segments
class CircularSegment extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 1;

	public CircularSegment(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentPainters[0] = new Elliptic(0);
    // segmentPainters[1] = new RadarPainter();
		name = "CircularSegment";
		description = "Circles and stuff";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "CicularModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}

// text rendering
class TextRenderMode extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 2;

	public TextRenderMode(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentPainters[0] = new TextWritter(0);
		segmentPainters[1] = new ScrollingText(1);

		name = "TextRenderMode";
		description = "Stuff that draws text";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "TextModes");
	}

	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
}


class WrapLine extends PerSegment{
	LineToLine painter;

	public WrapLine(int _ind){
		super();
		modeIndex = _ind;
		painter = new LineToLine(0);
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

// Make lines on segments
class MetaFreelining extends PerSegment{
	SegmentPainter[] segmentPainters;
	int painterCount = 1;
	SegmentCommandParser segmentCommandParser;
	public MetaFreelining(int _ind){
		super();
		modeIndex = _ind;
		segmentPainters = new SegmentPainter[painterCount];
		segmentCommandParser = new SegmentCommandParser(0);
    segmentPainters[0] = segmentCommandParser;
    //segmentPainters[1] = new ColorParser(1);

		name = "MetaFreelining";
		description = "Use freeliner to automate itself.";
		if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "MetaModes");
	}
	public SegmentPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return segmentPainters[_index];
	}
	public void setCommandSegments(ArrayList<Segment> _segs){
		segmentCommandParser.setCommandSegments(_segs);
	}
	public void setCommandProcessor(CommandProcessor _cp){
		segmentCommandParser.setCommandProcessor(_cp);
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
	int painterCount = 2;

	public Geometry(int _ind){
		modeIndex = _ind;
		name = "GeometryRender";
		description = "RenderModes that involve all segments.";
		groupPainters = new GroupPainter[painterCount];
		groupPainters[0] = new Filler(0);
		groupPainters[1] = new InterpolatorShape(1);
		if(MAKE_DOCUMENTATION) documenter.documentModes(groupPainters, 'a', this, "FillModes");
		//groupPainters[2] = new FlashFiller();
	}

	public void doRender(RenderableTemplate _event){

		getPainter(_event.getAnimationMode()).paintGroup(_event);
	}

	public GroupPainter getPainter(int _index){
		if(_index >= painterCount) _index = painterCount - 1;
		return groupPainters[_index];
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
//
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
// 		if(_index >= painterCount) _index = PAINTER_COUNT - 1;
// 		return segmentPainters[_index];
// 	}
// }
//
