/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4.1
 * @since     2016-4-20
 */

class BasicText extends SegmentPainter{

  public BasicText(){
    name = "BasicText";
    description = "Extendable object fo text displaying";
  }

  public void putChar(char _chr, PVector _p, float _a){
		canvas.pushMatrix();
		canvas.translate(_p.x, _p.y);
		canvas.rotate(_a + event.getAngleMod());
		canvas.text(_chr, 0, event.getScaledBrushSize()/3.0);
		canvas.popMatrix();
	}

}


class TextWritter extends BasicText{

	public TextWritter(){
		name = "TextWritter";
		description = "Fit a bunch of text on a segment";
	}

	public void paintSegment(Segment _seg, RenderableTemplate _event){
		super.paintSegment(_seg, _event);
		String _txt = _seg.getText();
		float _ang = _seg.getAngle(_event.getDirection());
		canvas.textFont(font);
		canvas.textSize(_event.getScaledBrushSize());
		char[] carr = _txt.toCharArray();
		int l = _txt.length();
		PVector pos = new PVector(0,0);
		for(int i = 0; i < l; i++){
			pos = _seg.getStrokePos(-((float)i/(l+1) + 1.0/(l+1))+1);
			putChar(carr[i], pos, _ang);
		}
	}
}
