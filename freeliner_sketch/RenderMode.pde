

/*
 * RenderMode contains the different rendering types, from segement renderers to fill renderers.
 * @param SegmentGroup in question
 */
class RenderMode extends Mode {

    public RenderMode() {

    }

    public void doRender(RenderableTemplate _rt) {}
}

/**
 * Parent class for all rendering that happens per segment.
 */
class PerSegment extends RenderMode {
    // selectorModeCount in Config.pde
    SegmentSelector[] segmentSelectors;

    SegmentPainter[] segmentPainters;
    int painterCount = 1;
    int segmentModeCount = 9;

    public PerSegment() {
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
        segmentSelectors[8] = new MetaSegmentSelector(8);


        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentSelectors, 'v', this, "SegmentSelector");
        // place holder for painter
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new SimpleBrusher(0);
    }

    public void doRender(RenderableTemplate _event) {
        ArrayList<LerpSegment> segList = getSelector(_event.getSegmentMode()).getSegments(_event);
        int index = 0;
        if(segList == null) return;
		Segment _seg;
        for(LerpSegment _seglerp : segList) {
			_seg = _seglerp.getSegment();
			_event.setSegmentIndex(index);
            index++;
            if(_seglerp != null && _seg != null) {
                if(!_seg.isHidden()){
                    _event.setLerp(_seg.getLerp());
                    getPainter(_event.getAnimationMode()).paintSegment(_seg, _event);
                }
            }
        }
    }

    public SegmentSelector getSelector(int _index) {
        if(_index >= segmentModeCount) _index = segmentModeCount - 1;
        return segmentSelectors[_index];
    }

    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
}



// Place brushes on segments
class BrushSegment extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 1;

    public BrushSegment(int _ind) {
        super();
        modeIndex = _ind;
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new SimpleBrusher(0);
        // segmentPainters[1] = new FadedBrusher(1);
        name = "BrushSegment";
        description = "Render mode for drawing with brushes";
        //if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "None?");
        // segmentPainters[6] = new CircularBrusher();
    }
    // public SegmentPainter getPainter(int _index){
    // 	if(_index >= painterCount) _index = painterCount - 1;
    // 	return segmentPainters[_index];
    // }
}

// Make lines on segments
class LineSegment extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 9;

    public LineSegment(int _ind) {
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
        segmentPainters[7] = new GradientLine(7);
        segmentPainters[8] = new MovingGradientLine(8);


        name = "LineSegment";
        description = "Draw lines related to segments";
        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "LineModes");
    }
    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
}

// Make circles on segments
class CircularSegment extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 1;

    public CircularSegment(int _ind) {
        super();
        modeIndex = _ind;
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new Elliptic(0);
        // segmentPainters[1] = new RadarPainter();
        name = "CircularSegment";
        description = "Circles and stuff";
        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "CicularModes");
    }
    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
}

// text rendering
class TextRenderMode extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 5;

    public TextRenderMode(int _ind) {
        super();
        modeIndex = _ind;
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new TextWritter(0);
        segmentPainters[1] = new ScrollingText(1);
        segmentPainters[2] = new LeftAlignedText(2);
        segmentPainters[3] = new CenterAlignedText(3);
        segmentPainters[4] = new RightAlignedText(4);

        name = "TextRenderMode";
        description = "Stuff that draws text";
        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "TextModes");
    }

    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
}


class WrapLine extends PerSegment {
    LineToLine painter;

    public WrapLine(int _ind) {
        super();
        modeIndex = _ind;
        name = "WrapLine";
        description = "line from segment to segment";
        painter = new LineToLine(0);
    }
    public SegmentSelector getSelector(int _index) {
        return segmentSelectors[6];
    }

    public void doRender(RenderableTemplate _rt) {
        ArrayList<LerpSegment> segList = getSelector(_rt.getSegmentMode()).getSegments(_rt);
        int index = 0;
        if(segList == null) return;
        painter.paint(segList, _rt);
    }

}

class FeatheredRender extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 2;

    public FeatheredRender(int _ind) {
        super();
        modeIndex = _ind;
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new FadedPointBrusher(3);
        segmentPainters[1] = new FadedLineBrusher(4);

        name = "FadedRenders";
        description = "Render options with feathered edges, good for LEDs";
        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "FeatherModes");
    }
    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
}

// Make lines on segments
class MetaFreelining extends PerSegment {
    SegmentPainter[] segmentPainters;
    int painterCount = 2;
    SegmentCommandParser segmentCommandParser;

    public MetaFreelining(int _ind) {
        super();
        modeIndex = _ind;
        segmentPainters = new SegmentPainter[painterCount];
        segmentPainters[0] = new PositionCollector(0);
        segmentCommandParser = new SegmentCommandParser(1);
        segmentPainters[1] = segmentCommandParser;

        name = "MetaFreelining";
        description = "Use freeliner to automate itself.";

        if(MAKE_DOCUMENTATION) documenter.documentModes((Mode[])segmentPainters, 'a', this, "MetaModes");

    }

    public SegmentPainter getPainter(int _index) {
        if(_index >= painterCount) _index = painterCount - 1;
        return segmentPainters[_index];
    }
    public void setCommandSegments(ArrayList<Segment> _segs) {
        segmentCommandParser.setCommandSegments(_segs);
    }
    public void setCommandProcessor(CommandProcessor _cp) {
        segmentCommandParser.setCommandProcessor(_cp);
    }
    public void setColorMap(PImage _im) {
        _im.loadPixels();
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
class MultiLineRender extends RenderMode {
    GroupPainter[] groupPainters;
    int painterCount = 3;

    public MultiLineRender(int _ind) {
        modeIndex = _ind;
        name = "MultiLineRender";
        description = "RenderModes that involve all segments.";
        groupPainters = new GroupPainter[painterCount];
        groupPainters[0] = new InterpolatorShape(0);
        groupPainters[1] = new Filler(1);
        groupPainters[2] = new DashedLines(2);

        if(MAKE_DOCUMENTATION) documenter.documentModes(groupPainters, 'a', this, "FillModes");
        //groupPainters[2] = new FlashFiller();
    }

    public void doRender(RenderableTemplate _event) {
        getPainter(_event.getAnimationMode()).paintGroup(_event);
    }

    public GroupPainter getPainter(int _index) {
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
