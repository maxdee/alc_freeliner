

class GroupPainter extends Painter{

	public GroupPainter(){}

	public void paintGroup(RenderableTemplate _rt){
		event = _rt;
		canvas = event.getCanvas();
	}

}


class Filler extends GroupPainter{
	public Filler(){}

	public void paintGroup(RenderableTemplate _rt){
		super.paintGroup(_rt);

		float angle = event.getRotationMode()*(event.getLerp()*TWO_PI);
		canvas.pushMatrix();
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		PShape shpe = cloneShape(event.getSegmentGroup().getShape(),
														 lorp, 
														 center);
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.rotate(angle);
		canvas.shape(shpe);
		canvas.popMatrix();
	}
}