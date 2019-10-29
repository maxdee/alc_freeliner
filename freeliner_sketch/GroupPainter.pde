

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
