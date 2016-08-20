/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

// the data structure shared between a SegmentGroup and Renderer
class RenderableTemplate extends TweakableTemplate{
	//
	TweakableTemplate sourceTemplate;

	SegmentGroup segmentGroup;

	// reference to what to draw on
	PGraphics canvas;

/*
 * Second tier, data that can change per beat.
 */
 	// Which beat we are on
	int beatCount;
	int rawBeatCount;
	int launchCount;
	int randomValue;
	int largeRandom;
	boolean direction;

/*
 * Third tier, data that changes every render
 */
 	// unitInterval of animation, aka lerper
	protected float unitInterval;
	float lerp;

/*
 * Fourth Tier, data can change multiple times per render
 */
	// Which iteration we are on
	int repetition;
	int segmentIndex;
	float angleMod;
	float scaledBrushSize;
	int colorCount;
	float hue;
	PShape brushShape;
	boolean updateBrush;

/*
 * Variable for internal use.
 */
  float timeStamp;

	int groupID;
	boolean doRender;

	ArrayList<Segment> executedSegments;

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Constructors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public RenderableTemplate(){
		super();
	}

	public RenderableTemplate(char _id){
		super(_id);
	}


/*
 * Constructor
 * @param SegmentGroup in question
 */
	public RenderableTemplate(TweakableTemplate _te, SegmentGroup _sg){
		super(_te.getTemplateID());
		//println(_te.getStrokeMode());
		sourceTemplate = _te;
		copy(_te);
		segmentGroup = _sg;
		beatCount = -1;
		doRender = true;
		brushShape = null;
		updateBrush = true;
		executedSegments = new ArrayList();
	}

/*
 * Start a render event
 * @param float unitInterval reference
 */
	public void init(float _ts){
		timeStamp = _ts;
		setrandomValue((int)random(100));
    setLargeRan((int)random(10000));
	}

	public void setCanvas(PGraphics _pg){
		canvas = _pg;
	}

	public void setBeatCount(int _beat){
		if(beatCount != _beat){
			beatCount = _beat;
			setrandomValue((int)random(100));
	    setLargeRan((int)random(10000));
			clearExecutedSegments();
		}
		colorCount = 0;
		// this updates according to source template...
		copy(sourceTemplate);
		// find the scaled size, the brushSize of the source template may have changed
		scaledBrushSize = brushSize * (BRUSH_SCALING ? segmentGroup.getBrushScaler() : 1.0);
	}

	public void setRawBeatCount(int _raw){
		rawBeatCount = _raw;
	}

	public void setUnitInterval(float _u){
		unitInterval = _u;
	}

	public void forceScaledBrushSize(float _s){
		scaledBrushSize = _s;
	}

	public float conditionLerp(float _lrp){
		if(_lrp > timeStamp) return _lrp - timeStamp;
		else return (_lrp+1) - timeStamp; // _lrp < timestamp
	}

	public void setLastPosition(PVector _pv){
		sourceTemplate.setLastPosition(_pv);
	}
	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Mutators
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void setLerp(float _lrp){
		lerp = _lrp;
	}

	public void setrandomValue(int _rn){
 		randomValue = _rn;
 	}

 	public void setRepetition(int _c){
 		repetition = _c;
 	}

 	public void setSegmentIndex(int _i){
 		segmentIndex = _i;
 	}

 	public void setLargeRan(int _lr){
 		largeRandom = _lr;
 	}

 	public void setAngleMod(float _ang){
 		angleMod = _ang;
 	}

 	public void setDirection(boolean _dir){
 		direction = _dir;
 	}

 	public void setHue(float _h){
 		hue = _h;
 	}

 	public void setDoRender(boolean _b){
 		doRender = _b;
 	}

	public void setBrushShape(PShape _brush){
		updateBrush = false;
		brushShape = _brush;
	}

	public int setBrushSize(int _s){
		updateBrush = true;
		return super.setBrushSize(_s, 5000);
	}

	// public int setBrushMode(int _m){
	// 	updateBrush = true;
	// 	return super.setBrushMode(_m);
	// }
	public void executeSegment(Segment _seg){
		executedSegments.add(_seg);
	}
	public void clearExecutedSegments(){
		executedSegments.clear();
	}
	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Accessors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public boolean doUpdateBrush(){
		return updateBrush;
	}

	public boolean doRender(){
		return doRender;
	}

	public final int getGroupId(){
		return segmentGroup.getID();
	}

	public final SegmentGroup getSegmentGroup(){
		return segmentGroup;
	}

	public final PGraphics getCanvas(){
		return canvas;
	}

/*
 * Second tier accessors
 */
 	public int getBeatCount(){
 		return beatCount;
 	}

 	public final int getRawBeatCount(){
 		return rawBeatCount;
 	}

 	public final int getRandomValue(){
 		return randomValue;
 	}

 	public final int getLargeRandomValue(){
 		return largeRandom;
 	}

 	public final boolean getDirection(){
 		return direction;
 	}

	/*
	 * Third tier accessors
	 */
 	public float getUnitInterval(){
 		return unitInterval;
 	}

 	public final float getLerp(){
 		return lerp;
 	}

 	// add with potential
  public float getAngleMod(){
		return angleMod;
  }

/*
 * Fourth Tier accessors
 */
	public final int getRepetition(){
		return repetition;
	}

	public final int getSegmentIndex(){
		return segmentIndex;
	}

	public final float getScaledBrushSize(){
		return scaledBrushSize;
	}

	public final int getColorCount(){
		return colorCount++;
	}

	public final float getHue(){
		return hue;
	}

	public final PShape getBrushShape(){
		return brushShape;
	}

	public ArrayList<Segment> getExecutedSegments(){
		return executedSegments;
	}
	// // ask if the brush needs updating
	// public final boolean updateBrush(){
	// 	if(updateBrush || brush == null){
	// 		updateBrush = false;
	// 		return true;
	// 	}
	// 	return false;
	// }
}



// this is for triggering system
class KillableTemplate extends RenderableTemplate{

	float unitIntervalOffset;
	boolean toKill;

	/*
	 * Constructor
	 * @param SegmentGroup in question
	 */
	public KillableTemplate(TweakableTemplate _te, SegmentGroup _sg){
		super(_te.getTemplateID());
		sourceTemplate = _te;
		copy(_te);
		// force enable?
		if(enablerMode != 0) enablerMode = 1;
		segmentGroup = _sg;
		beatCount = -1;
		doRender = true; // remove?
		toKill = false;
	}


	public void copy(TweakableTemplate _te){
		super.copy(_te);
		launchCount = _te.getLaunchCount();
	}

	public void setOffset(float _o){
		unitIntervalOffset = _o;
	}

	public void setUnitInterval(float _u){
		float ha =   _u - unitIntervalOffset;
		if(ha < 0.0) ha += 1.0;
		if(ha < unitInterval) toKill = true;
		unitInterval = ha;
	}

	// does not update...
	public void setBeatCount(int _beat){
		if(beatCount != _beat){
			beatCount = _beat;
			setrandomValue((int)random(100));
	    setLargeRan((int)random(10000));
		}
		colorCount = 0;
		// this updates according to source template...
		//copy(sourceTemplate);
		// find the scaled size, the brushSize of the source template may have changed
		float sb = brushSize;// * segmentGroup.getBrushScaler();
		//scaledBrushSize = brushSize;
		if(sb != scaledBrushSize) {
			updateBrush = true;
			scaledBrushSize = sb;
		}
	}

	public boolean isDone(){
		return toKill;
	}

	public int getBeatCount(){
 		return launchCount;
 	}
 // public final float getUnitInterval(){
 //  println(beatCount+"  "+randomValue+"  "+largeRandom);
 //  return unitInterval;
 // }
}
