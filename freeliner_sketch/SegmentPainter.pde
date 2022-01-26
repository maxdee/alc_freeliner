/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


// base class
class SegmentPainter extends Painter {

    // reference to the _event being rendered
    // RenderableTemplate _event;
    public SegmentPainter() {}
    public SegmentPainter(int _ind) {
        modeIndex = _ind;
        name = "segmentPainter";
        description = "paints segments";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paint(_event);
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Line Painters
///////
////////////////////////////////////////////////////////////////////////////////////

// base class for line painter
class LinePainter extends SegmentPainter {
    public LinePainter() {}
    public LinePainter(int _ind) {
        modeIndex = _ind;
        name = "LinePainter";
        description = "base class for making lines";
    }

    // paint the segment in question
    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        _seg.setStrokeWidth(_event.getStrokeWeight());
        applyStyle(event.getCanvas());
    }
}

class FunLine extends LinePainter {

    public FunLine(int _ind) {
        modeIndex = _ind;
        name = "FunLine";
        description = "Makes a line between pointA and a position.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        //PVector pos = getInterpolator(_event.getInterpolateMode()).getPosition(_seg,_event,this);
        // vecLine(event.getCanvas(), _seg.getPointA(), getPosition(_seg));//_seg.getStrokePos(event.getLerp()));
        int _ent = _event.getInterpolateMode();
        if(_ent == 6 || _ent == 7 || _ent == 11) {
            vecLine(event.getCanvas(), _seg.getPointA(), getPosition(_seg));//_seg.getStrokePos(event.getLerp()));
        }
        else {
            vecLine(event.getCanvas(), getPosition(_seg, 0.0), getPosition(_seg));//_seg.getStrokePos(event.getLerp()));
        }
    }
}

class FullLine extends LinePainter {

    public FullLine(int _ind) {
        modeIndex = _ind;
        name = "FullLine";
        description = "Draws a line on a segment, not animated.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        vecLine(event.getCanvas(), getPosition(_seg, 0.0), getPosition(_seg, 1.0));
    }
}

class AlphaLine extends LinePainter {
    public AlphaLine(int _ind) {
        modeIndex = _ind;
        name = "AlphaLine";
        description = "modulates alpha channel, made for LEDs";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        color _col = getColorizer(event.getStrokeMode()).get(event,int(event.getLerp()*event.getStrokeAlpha()));
        if(int(event.getLerp()*event.getStrokeAlpha())==0) return;//event.getCanvas().noStroke();
        else event.getCanvas().stroke(_col);
        vecLine(event.getCanvas(), getPosition(_seg, 0.0), getPosition(_seg, 1.0));
    }
}


class TrainLine extends LinePainter {

    public TrainLine(int _ind) {
        modeIndex = _ind;
        name = "TrainLine";
        description = "Line that comes out of point A and exits through pointB";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        float lrp = event.getLerp();
        if(lrp < 0.5) vecLine(event.getCanvas(), getPosition(_seg, 0.0), getPosition(_seg,lrp*2));
        else vecLine(event.getCanvas(), getPosition(_seg, 2*(lrp-0.5)), getPosition(_seg, 1.0));

        // if(lrp < 0.5) vecLine(event.getCanvas(), getPosition(_seg, 0.0), _seg.getStrokePos(lrp*2));
        // else vecLine(event.getCanvas(), _seg.getStrokePos(2*(lrp-0.5)), getPosition(_seg, 1.0));

        // test with enterpolator...
        // if(lrp < 0.5){
        // 	_event.setLerp(lrp*2.0);
        // 	vecLine(event.getCanvas(), getPosition(_seg, 0.0), getPosition(_seg));
        // 	_event.setLerp(lrp);
        // }
        // else {
        // 	_event.setLerp(2*(lrp-0.5));
        // 	vecLine(event.getCanvas(), getPosition(_seg), _seg.getCenter());
        // 	_event.setLerp(lrp);
        // }
    }
}


class MiddleLine extends LinePainter {

    public MiddleLine(int _ind) {
        modeIndex = _ind;
        name = "MiddleLine";
        description = "line that expands from the middle of a segment.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        float aa = (event.getLerp()/2)+0.5;
        float bb = -(event.getLerp()/2)+0.5;
        vecLine(event.getCanvas(), getPosition(_seg, aa), getPosition(_seg, bb));
    }
}

class Maypole extends LinePainter {
    public Maypole(int _ind) {
        modeIndex = _ind;
        name = "Maypole";
        description = "Draw a line from center to position.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        vecLine(event.getCanvas(), _seg.getCenter(), getPosition(_seg));
    }
}


class Elliptic extends LinePainter {
    public Elliptic(int _ind) {
        modeIndex = _ind;
        name = "Elliptic";
        description = "Makes a expanding circle with segment as final radius.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        PVector pos = _seg.getPointA();
        float sz = pos.dist(getPosition(_seg, event.getLerp()))*2;
        event.getCanvas().ellipse(pos.x, pos.y, sz, sz);
    }
}

class SegToSeg extends LinePainter {
    public SegToSeg(int _ind) {
        modeIndex = _ind;
        name = "SegToSeg";
        description = "Draws a line from a point on a segment to a point on a different segment. Affected by `e`";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        Segment secondSeg = getNextSegment(_seg, _event.getMiscValue());
        vecLine(event.getCanvas(), getPosition(_seg), getPosition(secondSeg));
    }

    public Segment getNextSegment(Segment _seg, int _iter) {
        if(_seg!=null){
            Segment next = _seg.getNext();
            if(_iter == 0) return next;
            else return getNextSegment(next, _iter - 1);
        }
        return null;
    }
}

class GradientLine extends LinePainter {

    public GradientLine(int _ind){
        modeIndex = _ind;
        name = "GradientLine";
        description = "Stroke to fill gradient";
    }
    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        PGraphics _pg = event.getCanvas();

        PVector _a = getPosition(_seg, 0.0);
        PVector _b =  getPosition(_seg, 1.0);
        _pg.beginShape(LINES);
        _pg.strokeWeight(_event.getStrokeWeight());
        _pg.stroke(getStrokeColor());
        _pg.vertex(_a.x, _a.y);
        _pg.stroke(getFillColor());
        _pg.vertex(_b.x, _b.y);
        _pg.endShape();
    }
}


class MovingGradientLine extends LinePainter {

    public MovingGradientLine(int _ind){
        modeIndex = _ind;
        name = "MovingGradientLine";
        description = "Moving Stroke to fill gradient";
    }
    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        PGraphics _pg = event.getCanvas();
        float gradientSize = 1.0;
        float edgeA = gradientSize / 2.0 * _event.getLerp();
        float edgeB = gradientSize / 2.0 * (1.0-_event.getLerp());
        PVector _a = getPosition(_seg, 0.0);
        PVector _b = getPosition(_seg, _event.getLerp());
        PVector _c = getPosition(_seg, 1.0);
        color colorA = colorLerp(getStrokeColor(), getFillColor(), edgeA);
        color colorB = getFillColor();
        color colorC = colorLerp(getStrokeColor(), getFillColor(), edgeB);
        _pg.beginShape(LINES);
        _pg.strokeWeight(_event.getStrokeWeight());
        _pg.stroke(colorA);
        _pg.vertex(_a.x, _a.y);
        _pg.stroke(colorB);
        _pg.vertex(_b.x, _b.y);
        _pg.stroke(colorC);
        _pg.vertex(_c.x, _c.y);
        _pg.endShape();
    }
}






// class DashedSegments extends LinePainter {
//
//     public DashedSegments(int _ind){
//         modeIndex = _ind;
//         name = "GradientLine";
//         description = "Stroke to fill gradient";
//     }
//     public void paintSegment(Segment _seg, RenderableTemplate _event) {
//         super.paintSegment(_seg, _event);
//         PGraphics _pg = event.getCanvas();
//
//         PVector _a = getPosition(_seg, 0.0);
//         PVector _b =  getPosition(_seg, 1.0);
//         _pg.beginShape(LINES);
//         _pg.strokeWeight(_event.getStrokeWeight());
//         _pg.stroke(getStrokeColor());
//         _pg.vertex(_a.x, _a.y);
//         _pg.stroke(getFillColor());
//         _pg.vertex(_b.x, _b.y);
//         _pg.endShape();
//     }
// }


////////////////////////////////////////////////////////////////////////////////////
///////
///////    Brush System
///////
////////////////////////////////////////////////////////////////////////////////////

// base brush putter
class BrushPutter extends SegmentPainter {
    final int BRUSH_COUNT = 9;
    Brush[] brushes;
    // brush count in Config.pde
    public BrushPutter() {
        loadBrushes();
        name = "BrushPainter";
        description = "Place brush onto segment. Affected by `e`.";
    }
    public void loadBrushes() {
        brushes = new Brush[BRUSH_COUNT];
        brushes[0] = new PointBrush(0);
        brushes[1] = new LineBrush(1);
        brushes[2] = new CircleBrush(2);
        brushes[3] = new ChevronBrush(3);
        brushes[4] = new SquareBrush(4);
        brushes[5] = new XBrush(5);
        brushes[6] = new TriangleBrush(6);
        brushes[7] = new SprinkleBrush(7);
        brushes[8] = new CustomBrush(8);
        if(MAKE_DOCUMENTATION) documenter.documentModes(brushes,'a', this, "Brushes");
    }

    public Brush getBrush(int _index) {
        if(_index >= BRUSH_COUNT) _index = BRUSH_COUNT - 1;
        return brushes[_index];
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        _seg.setSize(_event.getScaledBrushSize()+_event.getStrokeWeight());
    }

    // regular putShape
    public void putShape(PVector _p, float _a) {
        PShape shape_;
        shape_ = getBrush(event.getAnimationMode()).getShape(event);
        if(shape_ == null) return;
        // applyStyle(shape_);
        applyColor(shape_);
        float scale = event.getBrushSize() / 20.0; // devided by base brush size
        shape_.setStrokeWeight(event.getStrokeWeight()/scale);
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+ HALF_PI);
        canvas.scale(scale);
        canvas.shape(shape_);
        canvas.popMatrix();
    }
}

class SimpleBrusher extends BrushPutter {
    public SimpleBrusher(int _ind) {
        modeIndex = _ind;
    }
    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        putShape(getPosition(_seg), getAngle(_seg, _event));
    }
}

class FadedPointBrusher extends BrushPutter {
    public FadedPointBrusher(int _ind) {
        modeIndex = _ind;
        name = "FadedBrusher";
        description = "same as brush but adds a faded edge";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        putShape(getPosition(_seg), getAngle(_seg, _event));
    }


        public void putShape(PVector _p, float _a) {
            float _w = event.getStrokeWeight();
            float _h = event.getBrushSize();
            // float scale = event.getBrushSize() / 20.0; // devided by base brush size
            canvas.pushMatrix();
            canvas.translate(_p.x, _p.y);
            canvas.rotate(_a+ PI);
            // canvas.scale(scale);
            ////////////////////////
            canvas.beginShape();
            canvas.noStroke();
            PVector a = new PVector(-_h,0);
            PVector b = new PVector(-_w,0);
            PVector c = new PVector(0,0);

            for(int i = 0; i < 361; i+= 10){
                canvas.fill(getStrokeColor());
                canvas.vertex(0,0);
                canvas.vertex(b.x,b.y);
                canvas.fill(getFillColor());
                canvas.vertex(a.x, a.y);
                a = angleMove(c, radians(i), _h);
                b = angleMove(c, radians(i), _w);
                canvas.vertex(a.x, a.y);
                canvas.fill(getStrokeColor());
                canvas.vertex(b.x,b.y);
                canvas.vertex(0,0);


                // a = angleMove(c, radians(i), _h);
                // b = angleMove(c, radians(i), _w);
                // canvas.fill(f);
                // canvas.vertex(a.x, a.y);
                // canvas.fill(getStrokeColor());
                // canvas.vertex(b.x,b.y);
                // canvas.vertex(0,0);
                // canvas.vertex(b.x,b.y);
                // canvas.fill(f);
                // canvas.vertex(a.x, a.y);
            }
            canvas.endShape();//CLOSE);
            ///////////////////////
            // canvas.shape(fadedLineShape);
            canvas.popMatrix();
        }
}


class FadedLineBrusher extends BrushPutter {
    PShape fadedLineShape;
    public FadedLineBrusher(int _ind) {
        modeIndex = _ind;
        name = "FadedBrusher";
        description = "same as brush but adds a faded edge";
    }

    public void paint(RenderableTemplate _rt) {
        event = _rt;
        canvas = event.getCanvas();

    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        putShape(getPosition(_seg), getAngle(_seg, _event));
    }

    public void putShape(PVector _p, float _a) {
        float _w = event.getStrokeWeight();
        float _h = event.getBrushSize();
        // float scale = event.getBrushSize() / 20.0; // devided by base brush size
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+ PI);
        // canvas.scale(scale);
        ////////////////////////
        canvas.beginShape();
        canvas.noStroke();
        color f = getFillColor();
        f = alphaMod(f, event.getFillAlpha());
        canvas.fill(f);//getFillColor());
        canvas.vertex(-_w, -_h);
        canvas.fill(getStrokeColor());
        canvas.vertex(0, -_h);
        canvas.fill(f);//getFillColor());
        canvas.vertex(_w, -_h);
        canvas.vertex(_w, _h);
        canvas.fill(getStrokeColor());
        canvas.vertex(0, _h);
        canvas.fill(f);//getFillColor());
        canvas.vertex(-_w, _h);
        canvas.vertex(-_w, -_h);
        canvas.endShape(CLOSE);
        ///////////////////////
        // canvas.shape(fadedLineShape);
        canvas.popMatrix();
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Text displaying
///////
////////////////////////////////////////////////////////////////////////////////////

class BasicText extends SegmentPainter {

    public BasicText() {}
    public BasicText(int _ind) {
        modeIndex = _ind;
        name = "BasicText";
        description = "Extendable object fo text displaying";
    }

    public void putChar(char _chr, PVector _p, float _a) {
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a);
        canvas.text(_chr, 0, event.getScaledBrushSize()/3.0);
        canvas.popMatrix();
    }
}


class TextWritter extends BasicText {

    public TextWritter(int _ind) {
        modeIndex = _ind;
        name = "TextWritter";
        description = "Fit a bunch of text on a segment";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        String _txt = _seg.getText();
        canvas.textFont(font);
        canvas.textSize(_event.getScaledBrushSize());
        char[] carr = _txt.toCharArray();
        int l = _txt.length();
        for(int i = 0; i < l; i++) {
            _event.setLerp(-((float)i/(l+1) + 1.0/(l+1))+1);
            putChar(carr[i], getPosition(_seg), getAngle(_seg, _event));
        }
    }
}

class ScrollingText extends BasicText {
    public ScrollingText(int _ind) {
        modeIndex = _ind;
        name = "ScrollingText";
        description = "Scrolls text, acording to enterpolator";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        String _txt = _seg.getText();
        canvas.textFont(font);
        canvas.textSize(_event.getScaledBrushSize());
        char[] _chars = _txt.toCharArray();

        float _textWidth = _chars.length * _event.getScaledBrushSize();//canvas.textWidth(_txt);
        float _distance = _textWidth+_seg.getLength();

        float  _covered = 0;
        float _lrp = _event.getLerp();
        for(int i = 0; i < _chars.length; i++) {
            _covered += _event.getScaledBrushSize()*0.666;//canvas.textWidth(_chars[i]);
            float place = ((_distance*_lrp)-_covered)/_seg.getLength();
            if(place > 0.0 && place < 1.0) {
                _event.setLerp(place);
                putChar(_chars[i], getPosition(_seg), getAngle(_seg, _event));
            }
        }
        _event.setLerp(_lrp);

    }
}

class LeftAlignedText extends BasicText {
    public LeftAlignedText(int _ind) {
        modeIndex = _ind;
        name = "LeftAlignedText";
        description = "Aligns text to the left";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        String _txt = _seg.getText();
        canvas.textFont(font);
        canvas.textSize(_event.getScaledBrushSize());
        putString(_txt, _seg.getPointB(), _seg.getAngle(true));
    }

    public void putString(String _str, PVector _p, float _a) {
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+PI);
        canvas.textAlign(LEFT);
        canvas.text(_str, 0, event.getScaledBrushSize()/3.0);
        canvas.popMatrix();
    }
}


class CenterAlignedText extends BasicText {
    public CenterAlignedText(int _ind) {
        modeIndex = _ind;
        name = "CenterAlignedText";
        description = "Aligns text to center";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        String _txt = _seg.getText();
        canvas.textFont(font);
        canvas.textSize(_event.getScaledBrushSize());
        putString(_txt, _seg.getMidPoint(), _seg.getAngle(true));
    }

    public void putString(String _str, PVector _p, float _a) {
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+PI);
        canvas.textAlign(CENTER);
        canvas.text(_str, 0, event.getScaledBrushSize()/3.0);
        canvas.popMatrix();
    }
}

class RightAlignedText extends BasicText {
    public RightAlignedText(int _ind) {
        modeIndex = _ind;
        name = "RightAlignedText";
        description = "Aligns text to right";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        String _txt = _seg.getText();
        canvas.textFont(font);
        canvas.textSize(_event.getScaledBrushSize());
        putString(_txt, _seg.getPointA(), _seg.getAngle(true));
    }

    public void putString(String _str, PVector _p, float _a) {
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+PI);
        canvas.textAlign(RIGHT);
        canvas.text(_str, 0, event.getScaledBrushSize()/3.0);
        canvas.popMatrix();
    }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Meta Freelining
///////
////////////////////////////////////////////////////////////////////////////////////

class MetaBrush extends BrushPutter {
    public MetaBrush() {}

    public MetaBrush(int _mi) {
        modeIndex = _mi;
        name = "MetaBrush";
        description = "A simple dot that is used to do stuff!";
    }
    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        putShape(getPosition(_seg), getAngle(_seg, _event));
    }
    // overide and force chevron
    public void putShape(PVector _p, float _a) {
        PShape shape_;
        shape_ = getBrush(3).getShape(event);
        if(shape_ == null) return;
        // applyStyle(shape_);
        applyColor(shape_);
        float scale = event.getBrushSize() / 20.0;
        shape_.setStrokeWeight(event.getStrokeWeight()/scale);
        canvas.pushMatrix();
        canvas.translate(_p.x, _p.y);
        canvas.rotate(_a+ HALF_PI);
        canvas.scale(scale);
        canvas.shape(shape_);
        canvas.popMatrix();
    }

}

class PositionCollector extends MetaBrush {
    public PositionCollector(int _mi) {
        modeIndex = _mi;
        name = "PositionCollector";
        description = "Save position markers into template, for use use with meta-freelining.";
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        PVector _pos = getPosition(_seg);
        float _a = getAngle(_seg, _event)+HALF_PI;
        // apply translations to _pos and angle...
        _pos.add(_event.getTranslation());
        _event.getSourceTemplate().addMetaPositionMarker(_pos, _a, _event.getBrushSize());
    }
}

class PositionMarker {
    PVector pos;
    float angle;
    int size;
    PositionMarker(PVector _p, float _a, int _s){
        pos = _p.get();
        angle = _a;
        size = _s;
    }
}

// base brush putter
class SegmentCommandParser extends MetaBrush {
    ArrayList<Segment> commandSegments;
    CommandProcessor commandProcessor;

    public SegmentCommandParser(int _mi) {
        super(_mi);
        name = "SegmentCommand";
        description = "MetaFreelining, execute commands of commandSegments";
        commandSegments = null;
    }

    public void paintSegment(Segment _seg, RenderableTemplate _event) {
        super.paintSegment(_seg, _event);
        // PVector pos = getPosition(_seg);
        // float _a = getAngle(_seg, _event);
        // putShape(pos, _a);
        if(commandSegments != null) {
            for(Segment _s : commandSegments) {
                if(_s.getPointA().dist(_seg.getPointA()) < 0.0001) {
                    // if(_s.getPointA().dist(pos) < 2){
                    if(!_event.getExecutedSegments().contains(_seg)) {
                        _event.executeSegment(_seg);
                        commandProcessor.queueCMD(_s.getText());
                    }
                }
            }
        }
    }

    public void setCommandSegments(ArrayList<Segment> _cmdSegs) {
        commandSegments = _cmdSegs;
    }
    public void setCommandProcessor(CommandProcessor _cp) {
        commandProcessor = _cp;
    }
}
