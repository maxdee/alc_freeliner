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
class Template {
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
	Template linkedTemplate;

	IntList geometries;

	// for stats
	float fixLerp;

	// moved from tweakable
	int bankIndex;
	ArrayList<Template> bank;
	ArrayList<PVector> metaPositionMarkers;
	boolean flagClearMarkers = false;
	PVector lastPosition;
	boolean markersUpdated = false;

	// track launches, will replace the beat count in killable templates
	int launchCount;


	public Template(){
		reset();
		bank = new ArrayList();
		metaPositionMarkers = new ArrayList();
		bankIndex = 0;
		launchCount = 0;
		lastPosition = new PVector(0,0);
	}

	public Template(char _id){
		templateID = _id;
		reset();
		bank = new ArrayList();
		metaPositionMarkers = new ArrayList();
		bankIndex = 0;
		launchCount = 0;
		lastPosition = new PVector(0,0);
	}


	////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////    Bank management
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

	public int saveToBank(){
		Template _tp = new Template();
		_tp.copy(this);
		bank.add(_tp);
		return bank.size()-1;
	}

	public void loadFromBank(int _index){
		if(_index < bank.size()){
			copy(bank.get(_index));
		}
	}

	public void launch(){
		launchCount++;
	}

	public int getLaunchCount(){
		return launchCount;
	}

	public String getStatusString(){
		String _stat = str(templateID);
		_stat += " a-"+animationMode;
		_stat += " b-"+renderMode;
		_stat += " j-"+reverseMode;
		_stat += " e-"+interpolateMode;
		_stat += " f-"+fillMode;
		_stat += " h-"+easingMode;
		_stat += " i-"+repetitionMode;
		_stat += " j-"+reverseMode;
		_stat += " k-"+strokeAlpha;
		_stat += " l-"+fillAlpha;
		_stat += " m-"+miscValue;
		_stat += " j-"+reverseMode;
		_stat += " j-"+reverseMode;
		_stat += " j-"+reverseMode;
		_stat += " o-"+rotationMode;
		_stat += " p-"+renderLayer;
		_stat += " q-"+strokeMode;
		_stat += " r-"+repetitionCount;
		_stat += " s-"+brushSize;
		_stat += " u-"+enablerMode;
		_stat += " v-"+segmentMode;
		_stat += " w-"+strokeWidth;
		_stat += " x-"+beatDivider;
		return _stat;
	}

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
		beatDivider = 2;
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

	public void setLinkTemplate(Template _tp){
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
	public final Template getLinkedTemplate(){
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

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    setters
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public int setReverseMode(int _v, int _max){
		reverseMode = numTweaker(_v, reverseMode);
		if(reverseMode >= _max) reverseMode = _max - 1;
		return reverseMode;
	}

	public int setAnimationMode(int _v, int _max) {
		animationMode = numTweaker(_v, animationMode);
		if(animationMode >= _max) animationMode = _max - 1;
		return animationMode;
	}

	public int setInterpolateMode(int _v, int _max) {
		interpolateMode = numTweaker(_v, interpolateMode);
		if(interpolateMode >= _max) interpolateMode = _max - 1;
		return interpolateMode;
	}

	public int setRenderMode(int _v, int _max) {
		renderMode = numTweaker(_v, renderMode);
		if(renderMode >= _max) renderMode = _max - 1;
		return renderMode;
	}

	public int setSegmentMode(int _v, int _max){
		segmentMode = numTweaker(_v, segmentMode);
		if(segmentMode >= _max) segmentMode = _max - 1;
		return segmentMode;
	}

	public int setEasingMode(int _v, int _max){
		easingMode = numTweaker(_v, easingMode);
		if(easingMode >= _max) easingMode = _max - 1;
		return easingMode;
	}

	public int setRepetitionMode(int _v, int _max){
		repetitionMode = numTweaker(_v, repetitionMode);
		if(repetitionMode >= _max) repetitionMode = _max - 1;
		return repetitionMode;
	}

	public int setRepetitionCount(int _v, int _max) {
		repetitionCount = numTweaker(_v, repetitionCount);
		if(repetitionCount >= _max) repetitionCount = _max - 1;
		return repetitionCount;
	}

	public int setBeatDivider(int _v, int _max) {
		beatDivider = numTweaker(_v, beatDivider);
		if(beatDivider >= _max) beatDivider = _max - 1;
		return beatDivider;
	}

	public int setRotationMode(int _v, int _max){
		rotationMode = numTweaker(_v, rotationMode);
		if(rotationMode >= _max) rotationMode = _max - 1;
		return rotationMode;
	}

	public int setStrokeMode(int _v, int _max) {
		strokeMode = numTweaker(_v, strokeMode);
		if(strokeMode >= _max) strokeMode = _max - 1;
		return strokeMode;
	}

	public int setFillMode(int _v, int _max) {
		fillMode = numTweaker(_v, fillMode);
		if(fillMode >= _max) fillMode = _max - 1;
		return fillMode;
	}

	public int setStrokeWidth(int _v, int _max) {
		strokeWidth = numTweaker(_v, strokeWidth);
		if(strokeWidth >= _max) strokeWidth = _max - 1;
		if(strokeWidth <= 0) strokeWidth = 1;
		return strokeWidth;
	}

	public int setStrokeAlpha(int _v, int _max){
		strokeAlpha = numTweaker(_v, strokeAlpha);
		if(strokeAlpha >= _max) strokeAlpha = _max - 1;
		return strokeAlpha;
	}

	public int setFillAlpha(int _v, int _max){
		fillAlpha = numTweaker(_v, fillAlpha);
		if(strokeAlpha >= _max) strokeAlpha = _max - 1;
		return fillAlpha;
	}

	public int setBrushSize(int _v, int _max) {
		brushSize = numTweaker(_v, brushSize);
		if(brushSize >= _max) brushSize = _max - 1;
		if(brushSize <= 0) brushSize = 1;
		return brushSize;
	}

	public int setMiscValue(int _v, int _max) {
		miscValue = numTweaker(_v, miscValue);
		if(miscValue >= _max) miscValue = _max - 1;
		return miscValue;
	}

	public int setEnablerMode(int _v, int _max) {
		enablerMode = numTweaker(_v, enablerMode);
		if(enablerMode >= _max) enablerMode = _max - 1;
		return enablerMode;
	}

	public int setRenderLayer(int _v, int _max) {
		renderLayer = numTweaker(_v, renderLayer);
		if(renderLayer >= _max) renderLayer = _max - 1;
		return renderLayer;
	}

	public void setFixLerp(float _lrp){
		fixLerp = _lrp;
	}

	public void setTranslation(PVector _pv){
		translation.set(_pv);
	}

	public void setRotation(PVector _pv){
		rotation.set(_pv);
	}

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Colors
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void setCustomStrokeColor(color _c){
	  customStrokeColor = _c;
	}

	public void setCustomFillColor(color _c){
	  customFillColor = _c;
	}

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Meta
	///////
	////////////////////////////////////////////////////////////////////////////////////

	public void setLastPosition(PVector _pv){
		lastPosition = _pv.get();
	}

	public final PVector getLastPosition(){
		return lastPosition.get();
	}

	public void addMetaPositionMarker(PVector _pv){
		markersUpdated = true;
		if(flagClearMarkers){
			clearMarkers();
			flagClearMarkers = false;
		}
		metaPositionMarkers.add(_pv);
	}

	public ArrayList<PVector> getMetaPoisitionMarkers(){
		flagClearMarkers = true;
		if(!markersUpdated) clearMarkers();
		markersUpdated = false;
		return metaPositionMarkers;
	}

	public void clearMarkers(){
		metaPositionMarkers.clear();
	}
}
