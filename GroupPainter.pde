

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
		float angle = _rt.getAngleMod();  //getRotationMode()*(_rt.getLerp()*TWO_PI);
		float lorp = 1-_rt.getLerp();
		lorp*=lorp;
		PVector center = _rt.getSegmentGroup().getCenter();
		PShape shpe = _rt.getSegmentGroup().getShape();
		// PShape shpe = cloneShape(_rt.getSegmentGroup().getShape(),
		// 												 lorp,//1.0,
		// 												 center);
		canvas.pushMatrix();
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.scale(lorp);
		canvas.rotate(angle);
		canvas.shape(shpe, -center.x, -center.y);
		canvas.popMatrix();
	}

}
//
// class FlashFiller extends GroupPainter{
// 	public FlashFiller(){}
// 	public void paintGroup(RenderableTemplate _rt){
// 		super.paintGroup(_rt);
// 		if(_rt.getLerp() < 0.04) {
// 			PVector center = _rt.getSegmentGroup().getCenter();
// 			PShape shpe = _rt.getSegmentGroup().getShape();
// 			canvas.pushMatrix();
// 			applyStyle(shpe);
// 			canvas.translate(center.x, center.y);
// 			canvas.shape(shpe, -center.x, -center.y);
// 			canvas.popMatrix();
// 		}
// 		else if(_rt.getLerp() >= 0.04 && _rt.getLerp() < 0.05){
// 			PVector center = _rt.getSegmentGroup().getCenter();
// 			PShape shpe = _rt.getSegmentGroup().getShape();
// 			canvas.pushMatrix();
// 			shpe.setStroke(0);
// 			shpe.setFill(0);
//
// 			canvas.translate(center.x, center.y);
// 			canvas.shape(shpe, -center.x, -center.y);
// 			canvas.popMatrix();
// 		}
// 	}
// }

// filler with moving center

class FunFiller extends GroupPainter{

	public FunFiller(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);

		float angle = _rt.getAngleMod();  //getRotationMode()*(_rt.getLerp()*TWO_PI);
		float lorp = 1-_rt.getLerp();
		lorp*=lorp;
		PVector center = _rt.getSegmentGroup().getCenter();
		float fluct = (float(_rt.getBeatCount())/4)*TWO_PI;
		center = angleMove(center.get(), fluct, center.dist(_rt.getSegmentGroup().getSegment(0).getPointA())/2);
		PShape shpe = cloneShape(_rt.getSegmentGroup().getShape(),
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



class InterpolatorShape extends GroupPainter{
	public InterpolatorShape(){}

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
		canvas.endShape();
	}
}
