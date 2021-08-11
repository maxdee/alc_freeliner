

class GroupPainter extends Painter{

	public GroupPainter(){

	}

	public void paintGroup(RenderableTemplate _rt){
		super.paint(_rt);
	}

}


class Filler extends GroupPainter{
	public Filler(int _ind){
		name = "Filler";
		description = "make a filled shape, for nice color fill";
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		applyStyle(canvas);
		canvas.beginShape();
		PVector pos = new PVector(0,0);
		PVector pa = new PVector(0,0);
		boolean first = true;
		for(Segment _seg : event.getSegmentGroup().getSegments()){
			pos = getPosition(_seg, 0);
			if(first){
				first = false;
				pa = pos.get();
			}
			canvas.vertex(pos.x, pos.y);
		}
		canvas.vertex(pa.x, pa.y);
		canvas.endShape(CLOSE);
	}
}



class InterpolatorShape extends GroupPainter{
	public InterpolatorShape(int _ind){
		name = "InterpolatorShape";
		description = "shape delimited by positions determined by the interpolator";
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		// PVector center = event.getSegmentGroup().getCenter();
		applyStyle(canvas);
		canvas.beginShape();
		PVector pos = new PVector(0,0);
		PVector pa = new PVector(0,0);
		boolean first = true;
		for(Segment _seg : event.getSegmentGroup().getSegments()){
			pos = getPosition(_seg);
			if(first){
				first = false;
				pa = pos.get();
			}
			canvas.vertex(pos.x, pos.y);
		}
		canvas.vertex(pa.x, pa.y);
		canvas.endShape(CLOSE);
	}
}


class DashedLines extends GroupPainter {
    public DashedLines(int _ind){
        modeIndex = _ind;
        name = "DashedLines";
        description = "Dashing";
    }
    public void paintGroup(RenderableTemplate _event) {
		super.paintGroup(_event);
		float lerp = event.getLerp();
		int dashCount = _event.getRepetitionCount();
		float dashSize = _event.getBrushSize()/40.0;
		// PVector center = event.getSegmentGroup().getCenter();
		applyStyle(canvas);
		canvas.beginShape(LINES);
		// canvas.strokeWeight(_event.getStrokeWeight());
		// canvas.stroke(_event.getStrokeColor());
		Segment segA;
		Segment segB;
		float gap = 1.0/float(dashCount);
		PVector pos;
		lerp *= dashCount;
		// for(int i = 0; i < dashCount; i++){
			float fa = lerp;//+i*gap;
			float fb = fa+0.2;
			// fa-=0.2;
			fa = fltMod(fa);
			fb = fltMod(fb);

			segA = _event.getSegmentGroup().getSegmentByTotalLength(fa);
			segB = _event.getSegmentGroup().getSegmentByTotalLength(fb);
			if(segA != null && segB != null){
				pos = segA.getStrokePos(segA.getLerp());
				canvas.vertex(pos.x, pos.y);
				if(segA!=segB){
					pos = segA.getPointB();
					canvas.vertex(pos.x, pos.y);
				}
				pos = segB.getStrokePos(segB.getLerp());
				canvas.vertex(pos.x, pos.y);
			}
		// }
		canvas.endShape();
    }
}
