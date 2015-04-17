

class GroupPainter extends Painter{

	public GroupPainter(){}

	public void paintGroup(RenderableTemplate _rt){

	}

}


class Filler extends GroupPainter{
	public Filler(){}

	public void paintGroup(RenderableTemplate _rt){
		event = _rt;
		canvas = event.getCanvas();

		canvas.pushMatrix();
		float lorp = 1-event.getLerp();
		lorp*=lorp;
		PVector center = event.getSegmentGroup().getCenter();
		PShape shpe = cloneShape(event.getSegmentGroup().getShape(),
														 lorp, 
														 center);
		applyStyle(shpe);
		canvas.translate(center.x, center.y);
		canvas.rotate(event.getAngleMod());
		canvas.shape(shpe);
		canvas.popMatrix();
	}
}