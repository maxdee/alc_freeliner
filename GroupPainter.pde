

class GroupPainter extends Painter{

	public GroupPainter(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paint(_rt);
	}

}


class Filler extends GroupPainter{
	public Filler(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);

		float angle = event.getAngleMod();  //getRotationMode()*(event.getLerp()*TWO_PI);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		PShape shpe = cloneShape(event.getSegmentGroup().getShape(),
														 1.0,//lorp, 
														 center);
		canvas.pushMatrix();
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.scale(lorp);
		canvas.rotate(angle);
		canvas.shape(shpe);
		canvas.popMatrix();
	}

}

// filler with moving center

class FunFiller extends GroupPainter{

	public FunFiller(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);

		float angle = event.getAngleMod();  //getRotationMode()*(event.getLerp()*TWO_PI);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		float fluct = (float(event.getBeatCount())/4)*TWO_PI;
		center = angleMove(center.get(), fluct, center.dist(event.getSegmentGroup().getSegment(0).getA())/2);
		PShape shpe = cloneShape(event.getSegmentGroup().getShape(),
														 1.0,//lorp, 
														 center);
		canvas.pushMatrix();
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.scale(lorp);
		canvas.rotate(angle);
		canvas.shape(shpe);
		canvas.popMatrix();
	}
}


class NoiseShape extends GroupPainter{
	public NoiseShape(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);
		float angle = event.getAngleMod();  //getRotationMode()*(event.getLerp()*TWO_PI);
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		PShape shpe = createShape();
		shpe.beginShape();
		PVector pos = new PVector(0,0);
		PVector pa = new PVector(0,0);
		boolean first = true;
		for(Segment seg : event.getSegmentGroup().getSegments()){
			pos = seg.getRegA().get();
			pos = vecLerp(pos, center, random(100)/100);
			pos.sub(center);
			if(first){
				first = false;
				pa = pos.get();
			}
			shpe.vertex(pos.x, pos.y);
		}
		shpe.vertex(pa.x, pa.y);
		shpe.endShape();

		canvas.pushMatrix();
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.scale(lorp);
		canvas.rotate(angle);
		canvas.shape(shpe);
		canvas.popMatrix();
	}
}

