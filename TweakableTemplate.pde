
/*
 * Subclass of RenderEvent that is tweakable
 */
class TweakableTemplate extends Template {
  // store presets!
  int bankIndex;
  ArrayList<Template> bank;

  // track launches, will replace the beat count in killable templates
  int launchCount;

	public TweakableTemplate(char _id){
		super(_id);
    bank = new ArrayList();
    bankIndex = 0;
    launchCount = 0;
	}

  public TweakableTemplate(){
    super();
  }

  public void launch(){
    launchCount++;
  }
  public int getLaunchCount(){
    return launchCount;
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

	////////////////////////////////////////////////////////////////////////////////////
	///////
	///////    Tweakable mutators
	///////
	////////////////////////////////////////////////////////////////////////////////////


  public void setCustomColor(color _c){
    customColor = _c;
  }

  /*
   * Tweakables, all these more or less work the same.
   * @param int value, -1 increment, -2 decrement, >= 0 set, -3 return current value
   * @return int value given to parameter
   */

   public int setBankIndex(int _v){
     bankIndex = numTweaker(_v, bankIndex);
     if(bankIndex >= bank.size()) bankIndex = bank.size()-1;
     loadFromBank(bankIndex);
     return bankIndex;
   }

	public int setProbability(int v){
    // probability = numTweaker(v, probability);
    // if(probability > 100) probability = 100;
    // return probability;
    return 0;
  }

  public int setReverseMode(int _v){
    reverseMode = numTweaker(_v, reverseMode);
    if(reverseMode >= REVERSE_MODE_COUNT) reverseMode = REVERSE_MODE_COUNT - 1;
    return reverseMode;
  }

  public int setAnimationMode(int _v) {
    animationMode = numTweaker(_v, animationMode);
    if(animationMode >= ANIMATION_MODE_MAX) animationMode = ANIMATION_MODE_MAX - 1;
    return animationMode;
  }

  public int setInterpolateMode(int _v) {
    interpolateMode = numTweaker(_v, interpolateMode);
    if(interpolateMode >= INTERPOLATOR_MODE_COUNT) interpolateMode = INTERPOLATOR_MODE_COUNT - 1;
    return interpolateMode;
  }

  public int setRenderMode(int _v) {
    renderMode = numTweaker(_v, renderMode);
    if(renderMode >= RENDER_MODE_COUNT) renderMode = RENDER_MODE_COUNT - 1;
    return renderMode;
  }

  public int setSegmentMode(int _v){
    segmentMode = numTweaker(_v, segmentMode);
    if(segmentMode >= SEGMENT_MODE_COUNT) segmentMode = SEGMENT_MODE_COUNT - 1;
    return segmentMode;
  }

  public int setEasingMode(int v){
    easingMode = numTweaker(v, easingMode);
    if(easingMode >= EASING_MODE_COUNT) easingMode = EASING_MODE_COUNT - 1;
    return easingMode;
  }

  public int setRepetitionMode(int _v){
    repetitionMode = numTweaker(_v, repetitionMode);
    if(repetitionMode >= REPEATER_MODE_COUNT) repetitionMode = REPEATER_MODE_COUNT - 1;
    return repetitionMode;
  }

  public int setRepetitionCount(int _v) {
    repetitionCount = numTweaker(_v, repetitionCount);
    if(repetitionCount >= MAX_REPETITION) repetitionCount = MAX_REPETITION - 1;
    return repetitionCount;
  }

  public int setBeatDivider(int _v) {
    beatDivider = numTweaker(_v, beatDivider);
    if(beatDivider >= MAX_BEATDIVIDER) beatDivider = MAX_BEATDIVIDER - 1;
    return beatDivider;
  }

  public int setRotationMode(int _v){
    rotationMode = numTweaker(_v, rotationMode);
    if(rotationMode >= ROTATION_MODE_COUNT) rotationMode = ROTATION_MODE_COUNT - 1;
    return rotationMode;
  }

	public int setStrokeMode(int _v) {
    strokeMode = numTweaker(_v, strokeMode);
    if(strokeMode >= COLOR_MODE_COUNT) strokeMode = COLOR_MODE_COUNT - 1;
    return strokeMode;
  }

  public int setFillMode(int _v) {
    fillMode = numTweaker(_v, fillMode);
    if(fillMode >= COLOR_MODE_COUNT) fillMode = COLOR_MODE_COUNT - 1;
    return fillMode;
  }

  public int setStrokeWidth(int _v) {
    strokeWidth = numTweaker(_v, strokeWidth);
    if(strokeWidth >= MAX_STROKE_WEIGHT) strokeWidth = MAX_STROKE_WEIGHT - 1;
    if(strokeWidth <= 0) strokeWidth = 1;
    return strokeWidth;
  }

  public int setStrokeAlpha(int _v){
    strokeAlpha = numTweaker(_v, strokeAlpha);
    if(strokeAlpha >= MAX_STROKE_ALPHA) strokeAlpha = MAX_STROKE_ALPHA - 1;
    return strokeAlpha;
  }

  public int setFillAlpha(int _v){
    fillAlpha = numTweaker(_v, fillAlpha);
    if(strokeAlpha >= MAX_FILL_ALPHA) strokeAlpha = MAX_FILL_ALPHA - 1;
    return fillAlpha;
  }

  public int setBrushSize(int v) {
    brushSize = numTweaker(v, brushSize);
    if(brushSize >= MAX_BRUSH_SIZE) brushSize = MAX_BRUSH_SIZE - 1;
    return brushSize;
  }

  public int setBrushMode(int _v) {
    brushMode = numTweaker(_v, brushMode);
    if(brushMode >= BRUSH_COUNT) brushMode = BRUSH_COUNT - 1;
    return brushMode;
  }

  public int setEnablerMode(int _v) {
    enablerMode = numTweaker(_v, enablerMode);
    if(enablerMode >= ENABLER_MODE_COUNT) enablerMode = ENABLER_MODE_COUNT - 1;
    return enablerMode;
  }

  public int setRenderLayer(int _v) {
    renderLayer = numTweaker(_v, renderLayer);
    if(renderLayer >= MAX_RENDER_LAYER_COUNT) renderLayer = MAX_RENDER_LAYER_COUNT - 1;
    return renderLayer;
  }
}
