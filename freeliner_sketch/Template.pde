/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */


 /**
  * Templates hold all the parameters for the renderer.
  *
  */
class Template implements FreelinerConfig{
/*
 * First tier, data that dosent change unless told to
 */
	// Which type of rendering: per segment, all the segments...
	int renderMode;
	// how we pic which segments to paint
	int segmentMode;
	// different "animations" of a rendering style
	int animationMode;
	// how to extract position from a segment
	int interpolateMode;
	// Colorizer mode for stroke, 0 is noStroke()
	int strokeMode;
	// Colorizer mode for fill, 0 is noFill()
	int fillMode;
	// alpha channel
	int strokeAlpha;
	int fillAlpha;
	// Add rotation to elements such as brushes
	int rotationMode;
	// how we manipulate unitIntervals
	int easingMode;
	// Reversing diretction of unitInterval
	int reverseMode;
	// Mode to render more than once while changing the unitInterval
	int repetitionMode;
	// was polka
	int repetitionCount;
	// Defines speed
	int beatDivider;
	// Width of stroke
	int strokeWidth;
	// Size of brush
	int brushSize;
	// a general purpose value
  	int miscValue;
	// enablers decide if render or not
	int enablerMode;
	// which layer to render to
	int renderLayer;

	// custom shape
  	PShape customShape;
	PVector translation;
	PVector rotation;


  	// custom color
  	color customStrokeColor;
	color customFillColor;

	char templateID;
	TweakableTemplate linkedTemplate;

	IntList geometries;

	// for stats
	float fixLerp;

	public Template(){
		reset();
	}

	public Template(char _id){
		templateID = _id;
		reset();
	}
	//
	// public Template(Template _source){
	// 	templateID = 'z';
	// 	reset();
	// 	copy(_source);
	// }

	/**
	 * Copy a Template
	 * @parma RenderEvent to copy
	 */
 	public void copy(Template _tp){
 		// copy the first tier of variables
 		templateID = _tp.getTemplateID();
 		copyParameters(_tp);
 	}

	/**
	 * Copy Template parameters
	 * @parma RenderEvent to copy
	 */
 	public void copyParameters(Template _tp){
 		strokeAlpha = _tp.getStrokeAlpha();
		fillAlpha = _tp.getFillAlpha();
		renderMode = _tp.getRenderMode();
		segmentMode = _tp.getSegmentMode();
		animationMode = _tp.getAnimationMode();
		interpolateMode = _tp.getInterpolateMode();
		strokeMode = _tp.getStrokeMode();
		fillMode = _tp.getFillMode();
		rotationMode = _tp.getRotationMode();
		reverseMode = _tp.getReverseMode();
		repetitionMode = _tp.getRepetitionMode();
		repetitionCount = _tp.getRepetitionCount();
		easingMode = _tp.getEasingMode();
		beatDivider = _tp.getBeatDivider();
		strokeWidth = _tp.getStrokeWeight();
		brushSize = _tp.getBrushSize();
		miscValue = _tp.getMiscValue();
		customShape = _tp.getCustomShape();
		enablerMode = _tp.getEnablerMode();
		customStrokeColor = _tp.getCustomStrokeColor();
		customFillColor = _tp.getCustomFillColor();

		renderLayer = _tp.getRenderLayer();
		linkedTemplate = _tp.getLinkedTemplate();
		fixLerp = _tp.getFixLerp();
		translation = _tp.getTranslation();
		rotation = _tp.getRotation();

		geometries = _tp.getGeometries().copy();
		// if(templateID != 'A' && templateID != 'B'){println("copied geometries "+templateID);
		// println(geometries);}
 	}

	/**
	 * Reset to default values
	 * Defaults from Config.pde?
	 */
 	public void reset(){
 		fillAlpha = 255;
		strokeAlpha = 255;
		renderMode = 0;
		animationMode = 0;
		segmentMode  = 0;
		interpolateMode = 0;
		strokeMode = 1;
		fillMode = 1;
		rotationMode = 0;
		reverseMode = 0;
		repetitionMode = 0;
		repetitionCount = 5;
		easingMode = 0;
		beatDivider = 4;
		strokeWidth = 3;
		brushSize = 20;
		enablerMode = 1;
		renderLayer = 1;
		customStrokeColor = color(0,0,50,255);
		customFillColor = color(50,50,50,255);
		translation = new PVector(0,0,0);
		rotation = new PVector(0,0,0);
		linkedTemplate = null;
		geometries = new IntList();
 	}

	public void addGeometry(int _g){
		if(!geometries.hasValue(_g)){
			geometries.append(_g);
		}
	}

	public void removeGeometry(int _g){
		for(int i = 0; i < geometries.size(); i++){
			if(geometries.get(i) == _g) geometries.remove(i);
		}
	}

	public void toggleGeometry(int _g){
		if(geometries.hasValue(_g)) removeGeometry(_g);
		else addGeometry(_g);
	}

	public IntList getGeometries(){
		return geometries;
	}

	public void setCustomShape(PShape _shp){
    	customShape = _shp;
  	}

	public void setLinkTemplate(TweakableTemplate _tp){
		linkedTemplate = _tp;
		// linkedTemplateID = _id;
	}
	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Debug
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void print(){
		println("++++++++++++++++++++++++");
		println("Template : "+templateID);
		println("renderMode "+renderMode);
		println("animationMode "+animationMode);
		println("strokeMode "+strokeMode);
		println("fillMode "+fillMode);
		println("rotationMode "+rotationMode);
		println("reverseMode "+reverseMode);
		println("repetitionMode "+repetitionMode);
		println("repetitionCount "+repetitionCount);
		println("beatDivider "+beatDivider);
		println("strokeWidth "+strokeWidth);
		println("brushSize "+brushSize );
		println("renderLayer "+renderLayer);
		// println("linkedTemplate "+)
		println("++++++++++++++++++++++++");
	}



	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Accessors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	// public boolean equals(Object _obj){
	// 	println(templateID+" "+((Template)_obj).getTemplateID());
	// 	return (templateID == ((Template)_obj).getTemplateID());
	// }

  public PShape getCustomShape(){
    return customShape;
  }

	public final char getTemplateID(){
		return templateID;
	}

	/**
	 * First tier accessors
	 */
	public final int getRenderMode(){
		return renderMode;
	}

	public final int getSegmentMode(){
		return segmentMode;
	}

	public final int getAnimationMode(){
		return animationMode;
	}

	public final int getInterpolateMode(){
		return interpolateMode;
	}

	public final int getEasingMode(){
		return easingMode;
	}

	public final int getFillMode(){
		return fillMode;
	}

	public final int getStrokeMode(){
		return strokeMode;
	}

	public final int getStrokeAlpha(){
		return strokeAlpha;
	}

	public final int getFillAlpha(){
		return fillAlpha;
	}

	public final int getStrokeWeight(){
		return strokeWidth;
	}

	public final int getMiscValue(){
		return miscValue;
	}

	public final int getBrushSize(){
		return brushSize;
	}

	public final int getRotationMode(){
		return rotationMode;
	}

	public final int getReverseMode(){
		return reverseMode;
	}

	public final int getRepetitionMode(){
		return repetitionMode;
	}

	public final int getRepetitionCount(){
		return repetitionCount;
	}

	public final int getBeatDivider(){
		return beatDivider;
	}

	public final int getEnablerMode(){
		return enablerMode;
	}

	public final int getRenderLayer(){
		return renderLayer;
	}

	public final color getCustomStrokeColor(){
		return customStrokeColor;
	}
	public final color getCustomFillColor(){
		return customFillColor;
	}
	public final TweakableTemplate getLinkedTemplate(){
		return linkedTemplate;
	}
	public float getFixLerp(){
		return fixLerp;
	}
	public PVector getTranslation(){
		return translation;
	}
	public PVector getRotation(){
		return rotation;
	}
}
