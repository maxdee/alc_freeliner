

class GroupPainter extends Painter{

	public GroupPainter(){

	}

	public void paintGroup(RenderableTemplate _rt){
		super.paint(_rt);
	}

}


class Filler extends GroupPainter{
	public Filler(int _ind){
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float angle = _rt.getAngleMod();  //getRotationMode()*(_rt.getLerp()*TWO_PI);
		float lorp = 1-_rt.getLerp();
		lorp*=lorp;
		PVector center = _rt.getSegmentGroup().getCenter();
		PShape shpe = _rt.getSegmentGroup().getShape();

		float weight = event.getStrokeWeight();
		shpe.setStrokeWeight(weight/lorp);

		canvas.pushMatrix();
		applyColor(shpe);
		canvas.translate(center.x, center.y);
		canvas.rotate(angle);
		canvas.scale(lorp);
		canvas.shape(shpe, -center.x, -center.y);
		canvas.popMatrix();
	}
}


class InterpolatorShape extends GroupPainter{
	public InterpolatorShape(int _ind){
		modeIndex = _ind;
	}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
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
