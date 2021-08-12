

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
		for(int i = 0; i < dashCount; i++){
			float ll = i*gap + lerp/dashCount;
			float lerpA = fltMod(ll-dashSize);
			float lerpB = fltMod(ll+dashSize);
			Segment segA = _event.getSegmentGroup().getSegmentByTotalLength(lerpA);
			if(segA != null){
				PVector posA = getPosition(segA, segA.getLerp());
				Segment segB = _event.getSegmentGroup().getSegmentByTotalLength(lerpB);
				if(segB != null){
					PVector posB = getPosition(segB, segB.getLerp());
					PVector lastPoint = posB.get();
					if(segA != segB){
						canvas.beginShape();
					}
					else {
						canvas.beginShape(LINES);
					}
					if(segB.getPrev() == null && segA != segB){
						posA = getPosition(segB, 0.0);
					}
					canvas.vertex(posA.x, posA.y);
					if(segA != segB && segA.getNext() == segB){
						PVector pos = getPosition(segA, 1.0);
						canvas.vertex(pos.x, pos.y);
					}
					else if(segA != segB){
						Segment s = segA;
						while(s != segB && s != null && s.getNext() != null){
							PVector p = getPosition(s, 1.0);
							canvas.vertex(p.x, p.y);
							lastPoint = p.get();
							s = s.getNext();
						}
					}
					if(segB.getPrev() == null){
						posB = lastPoint;
					}

					canvas.vertex(posB.x, posB.y);
					canvas.endShape();

					canvas.rect(posB.x, posB.y, 4,4);

				}
			}
		}
    }
}
