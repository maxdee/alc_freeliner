
/*
 * Subclass of RenderEvent that is tweakable
 */
class TweakableTemplate extends Template {
  // store presets!
  int bankIndex;
  ArrayList<Template> bank;

  // track launches, will replace the beat count in killable templates
  int launchCount;

  /*
   * data that can be read post render
   */
  PVector lastPosition;


	public TweakableTemplate(char _id){
		super(_id);
    bank = new ArrayList();
    bankIndex = 0;
    launchCount = 0;
    lastPosition = new PVector(0,0);
	}

  public TweakableTemplate(){
    super();
  }

  public void setLastPosition(PVector _pv){
		lastPosition = _pv.get();
	}

  public final PVector getLastPosition(){
		return lastPosition.get();
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


  public void setCustomStrokeColor(color _c){
    customStrokeColor = _c;
  }

  public void setCustomFillColor(color _c){
    customFillColor = _c;
  }

  /*
   * Tweakables, all these more or less work the same.
   * @param int value, -1 increment, -2 decrement, >= 0 set, -3 return current value
   * @return int value given to parameter
   */

   public int setBankIndex(int _v, int _max){
     bankIndex = numTweaker(_v, bankIndex);
     if(bankIndex >= bank.size()) bankIndex = bank.size()-1;
     loadFromBank(bankIndex);
     return bankIndex;
   }

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
}
