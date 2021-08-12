

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
		float dashSize = _event.getBrushSize()/1000.0;
		applyStyle(canvas);
		canvas.noFill();

		float gap = 1.0/float(dashCount);
		// float fakeLerp = mouseX/float(width);
		// println(lerp);
		ArrayList<Segment> dashBuff = new ArrayList<Segment>();
		PVector pos;

		for(int i = 0; i < dashCount; i++){
			float ll = i*gap + lerp/dashCount;
			float lerpA = fltMod(ll);//-dashSize);
			float lerpB = fltMod(ll+dashSize);
			Segment segA = _event.getSegmentGroup().getSegmentByTotalLength(lerpA);
			if(segA != null){
				lerpA = segA.getLerp();
				Segment segB = _event.getSegmentGroup().getSegmentByTotalLength(lerpB);
				if(segB != null){
					lerpB = segB.getLerp();
					if(segA == segB){// && lerpA < lerpB){
						// problem here with wrap around.
						canvas.beginShape(LINES);
						// canvas.stroke(0,255,0);
						pos = getPosition(segA, lerpA);
						canvas.vertex(pos.x, pos.y);
						pos = getPosition(segB, lerpB);
						canvas.vertex(pos.x, pos.y);
						canvas.endShape();
					}
					// if(segA == segB && lerpA > lerpB){
					// 	// problem here with wrap around.
					// 	canvas.beginShape(LINES);
					// 	// canvas.stroke(0,255,0);
					// 	pos = getPosition(segA, lerpA);
					// 	canvas.vertex(pos.x, pos.y);
					// 	pos = getPosition(segA, 1.0);
					// 	canvas.vertex(pos.x, pos.y);
					// 	pos = getPosition(segB, 0.0);
					// 	canvas.vertex(pos.x, pos.y);
					// 	pos = getPosition(segB, lerpB);
					// 	canvas.vertex(pos.x, pos.y);
					// 	canvas.endShape();
					// }
					else if(segA.getNext() == segB) {
						canvas.beginShape();
						// canvas.stroke(255,0,0);
						pos = getPosition(segA, lerpA);
						canvas.vertex(pos.x, pos.y);
						pos = getPosition(segA, 1.0);
						canvas.vertex(pos.x, pos.y);
						pos = getPosition(segB, lerpB);
						canvas.vertex(pos.x, pos.y);
						canvas.endShape();
					}
					else {
						// boolean break
						// canvas.stroke(255);
						if(segA.getNext() == null){
							canvas.beginShape(LINES);
							pos = getPosition(segA, lerpA);
							canvas.vertex(pos.x, pos.y);
							pos = getPosition(segA, 1.0);
							canvas.vertex(pos.x, pos.y);
							canvas.endShape();
						}
						if(segB.getPrev() == null){
							canvas.beginShape(LINES);
							pos = getPosition(segB, lerpB);
							canvas.vertex(pos.x, pos.y);
							pos = getPosition(segB, 0.0);
							canvas.vertex(pos.x, pos.y);
							canvas.endShape();
						}
						else {
							canvas.beginShape();
							pos = getPosition(segA, lerpA);
							canvas.vertex(pos.x, pos.y);
							Segment s = segA;
							while(s != segB && s != null){
								pos = getPosition(s, 1.0);
								canvas.vertex(pos.x, pos.y);
								s = s.getNext();
							}
							pos = getPosition(segB, lerpB);
							canvas.vertex(pos.x, pos.y);
							canvas.endShape();
						}
					}

				}
			}
		}
    }
}
