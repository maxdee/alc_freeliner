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
 * @version   0.1
 * @since     2014-12-01
 */

// the data structure shared between a SegmentGroup and Renderer
class RenderableTemplate extends Template{

	Template sourceTemplate;

	SegmentGroup segmentGroup;

	// reference to what to draw on
	PGraphics canvas;
/*
 * Second tier, data that can change per beat.
 */
 	// Which beat we are on
	int beatCount;
	int randomValue;
	int largeRandom;
	boolean direction;

/*
 * Third tier, data that changes every render
 */
 	// unitInterval of animation, aka lerper
	float unitInterval;
	float lerp;

/*
 * Fourth Tier, data can change multiple times per render
 */
	// Which iteration we are on
	int repetition;
	int segmentIndex;
	float angleMod;
	int colorCount;
/*
 * Variable for internal use.
 */
  float timeStamp;
	
	int groupID;


	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Constructors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public RenderableTemplate(){
		super();
	}

/*
 * Constructor
 * @param SegmentGroup in question
 */
	public RenderableTemplate(Template _te, SegmentGroup _sg){
		super(_te.getTemplateID());
		println(_te.getStrokeMode());
		sourceTemplate = _te;
		copy(_te);
		segmentGroup = _sg;
		beatCount = -1;
	}

/*
 * Start a render event
 * @param float unitInterval reference
 */
	public void init(float _ts){
		timeStamp = _ts;
		//println(timeStamp);
		//beatCount++;
		setrandomValue((int)random(100));
    setLargeRan((int)random(10000));
	}

	public void setCanvas(PGraphics _pg){
		canvas = _pg;
	}

	public void setTime(float _lerp, int _beat){
		unitInterval = _lerp;
		if(beatCount != _beat){
			beatCount = _beat;
			randomValue = (int)random(1000);
		}
		colorCount = 0;
		copy(sourceTemplate);
		// in old render event we had  
		//if(_lrp > timeStamp) return _lrp - timeStamp;
		//else return (_lrp+1)-timeStamp; // _lrp < timestamp
	}

	public float conditionLerp(float _lrp){
		if(_lrp > timeStamp) return _lrp - timeStamp;
		else return (_lrp+1)-timeStamp; // _lrp < timestamp
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

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Accessors
	///////
	////////////////////////////////////////////////////////////////////////////////////

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
 	public final int getBeatCount(){
 		return beatCount;
 	}

 	public final int getRandomValue(){
 		return randomValue;
 	}

 	public final boolean getDirection(){
 		return direction;
 	}

/*
 * Third tier accessors
 */
 	public final float getUnitInterval(){
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
		return brushSize * segmentGroup.getBrushScaler();
	}

	public final int getColorCount(){
		return colorCount++;
	}
}

