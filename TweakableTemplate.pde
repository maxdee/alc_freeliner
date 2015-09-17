
/*
 * Subclass of RenderEvent that is tweakable
 */
class TweakableTemplate extends Template {

  int bankIndex;
  ArrayList<Template> bank;

	public TweakableTemplate(char _id){
		super(_id);
    bank = new ArrayList();
    bankIndex = 0;
	}

  public TweakableTemplate(){
    super();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Bank management
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void saveToBank(){
    Template _tp = new Template();
    _tp.copy(this);
    bank.add(_tp);
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

	public int setProbability(int v){
    // probability = numTweaker(v, probability);
    // if(probability > 100) probability = 100;
    // return probability;
    return 0;
  }

  public int setReverseMode(int _v){
    reverseMode = numTweaker(_v, reverseMode);
    return reverseMode;
  }

  // public boolean toggleLoop(){
  //   looper = !looper;
  //   return looper;
  // }

  // public void setLooper(boolean _b){
  //   looper = _b;
  // }

  public int setAnimationMode(int _v) {
    animationMode = numTweaker(_v, animationMode);
    return animationMode;
  }

  public int setRenderMode(int _v) {
    renderMode = numTweaker(_v, renderMode);
    return renderMode;
  }

  public int setSegmentMode(int _v){
    segmentMode = numTweaker(_v, segmentMode);
    return segmentMode;
  }

  public int setEasingMode(int v){
    easingMode = numTweaker(v, easingMode);
    return easingMode;
  }

  public int setRepetitionMode(int _v){
    repetitionMode = numTweaker(_v, repetitionMode);
    return repetitionMode;
  }

  public int setRepetitionCount(int _v) {
    repetitionCount = numTweaker(_v, repetitionCount);
    return repetitionCount;
  }

  public int setBeatDivider(int _v) {
    beatDivider = numTweaker(_v, beatDivider);
    return beatDivider;
  }

  public int setRotation(int _v){
    rotationMode = numTweaker(_v, rotationMode);
    return rotationMode;
  }

	public int setStrokeMode(int _v) {
    strokeMode = numTweaker(_v, strokeMode);
    return strokeMode;
  }

  public int setFillMode(int _v) {
    fillMode = numTweaker(_v, fillMode);
    return fillMode;
  }

  public int setStrokeWidth(int _v) {
    strokeWidth = numTweaker(_v, strokeWidth);
    if(strokeWidth <= 0) strokeWidth = 1;
    return strokeWidth;
  }

  public int setAlpha(int _v){
    alphaValue = numTweaker(_v, alphaValue);
    return alphaValue;
  }

  public int setBrushSize(int v) {
    brushSize = numTweaker(v, brushSize);
    return brushSize;
  }

  public int setBrushMode(int _v) {
    brushMode = numTweaker(_v, brushMode);
    return brushMode;
  }

  public int setEnablerMode(int _v) {
    enablerMode = numTweaker(_v, enablerMode);
    return enablerMode;
  }

  public int setBankIndex(int _v){
    bankIndex = numTweaker(_v, bankIndex);
    if(bankIndex >= bank.size()) bankIndex = bank.size()-1;
    loadFromBank(bankIndex);
    return bankIndex;
  }

  public void setCustomColor(color _c){
    customColor = _c;
  }

}
