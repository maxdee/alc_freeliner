/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * This distributes events to templates and stuff.
 */



class FrameSamplerLayer extends CanvasLayer {
    int blendMode = LIGHTEST;
    // meta
    TweakableTemplate metaTemplate;
    // frame sampler
    ArrayList<PGraphics> frames = new ArrayList();
    FloatList selectedFrames = new FloatList();
    final int MAX_BUFFER_SIZE = 50;
    int bufferSize = MAX_BUFFER_SIZE;
    int frameIndex = 0;

    float shaker = 0;
    PVector center;

    int overdub = 1;
    boolean doIncrement = true;
    boolean doDrawInput = false;
    int counter = 0;
    Synchroniser sync;


    public FrameSamplerLayer(Synchroniser _s) {
        super();
        sync = _s;
        name = "frameSamplerLayer";
        id = name;
        description = "webcams and capture cards, but with a twist";
        makeFrames();
        center = new PVector(width/2, height/2);
        // if(cam != null) cam.stop();
        String[] _opt = {"blend","add","subtract","darkest","lightest","difference","exclusion","multiply","screen","replace"};
        options= _opt;
    }

    public PGraphics apply(PGraphics _pg) {
        if(metaTemplate == null){
            metaTemplate = freeliner.templateManager.getTemplate('Z');
        }
        if(!enabled) return _pg;

        if(_pg != null){
            addFrameToBuffer(_pg);
        }

        // if(_pg == null) {
        canvas.beginDraw();
        canvas.background(0);
        canvas.blendMode(blendMode);
        doSamplerDraw(canvas, _pg);
        canvas.endDraw();
        return canvas;
        // } else {
        //
            // _pg.beginDraw();
            // _pg.blendMode(blendMode);
            // doSamplerDraw(_pg);
            // _pg.blendMode(BLEND);
            // _pg.endDraw();
            // return _pg;
        // }
    }

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    void doSamplerDraw(PGraphics _canvas, PGraphics _input){
        if(shaker != 0) {
            shaker -= shaker/8.0;
            if(shaker < 0.01) shaker = 0;
        }
        ArrayList<PVector> _metaPoints = metaTemplate.getMetaPoisitionMarkers();

        _canvas.pushMatrix();
        _canvas.translate(center.x, center.y);

        _canvas.scale(1.0+random(shaker)/20.0);

        if(doDrawInput){
            _canvas.image(_input,-center.x,-center.y);
        }

        if(_metaPoints!= null){
            for(PVector _p: _metaPoints){
                int _frame = getFrameIndex(_p.x/width);
                _canvas.image(frames.get(_frame),-center.x,-center.y);
            }
        }
        for(float _f : selectedFrames){
            int _frame = getFrameIndex(_f);
            _canvas.image(frames.get(_frame),-center.x,-center.y);
        }
        // else {
        //     _canvas.image(frames.get(frameIndex),-center.x,-center.y);
        // }
        // if(second) _canvas.image(frames.get(5),-center.x,-center.y);
        _canvas.popMatrix();
        // metaTemplate.clearMarkers();
    }

    private void addFrameToBuffer(PGraphics _pg) {
        counter++;
        PGraphics img;
        if(overdub != 0){
            if(counter % overdub == 0) {
                frameIndex++;
                frameIndex %= bufferSize;
                img = frames.get(frameIndex);
                img.beginDraw();
                img.image(_pg,0,0);
                img.endDraw();
            }
        }
    }

    int getFrameIndex(float _float){
        _float = abs(_float);
        _float *= bufferSize;
        if(doIncrement) _float += frameIndex;
        _float %= bufferSize;
        return (int)_float;
    }

    void makeFrames() {
        print("CUSTOM-SAMPLER : making layers ");
        for(int i = 0; i < MAX_BUFFER_SIZE; i++) {
            PGraphics _pg = createGraphics(width, height, P2D);
            _pg.beginDraw();
            _pg.background(0,0);
            _pg.endDraw();
            frames.add(_pg);
            print(".");
        }
        println();
        selectedFrames = new FloatList();
    }


    void clearFrames(){
        for(PGraphics _pg : frames){
            _pg.beginDraw();
            _pg.background(0);
            _pg.endDraw();
        }
        println("CUSTOM-SAMPLER : cleared");
    }

    public void parseFramesCmd(String[] _args){
        selectedFrames.clear();
        for(int i = 3; i < _args.length; i++){
            float _frame = (float)stringInt(_args[i])/bufferSize;
            // _frame %= bufferSize;
            selectedFrames.append(_frame);
        }
    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length <= 3){
            if(_args[2].equals("clear")){
                clearFrames();
            }
            else if(_args[2].equals("frames")){
                parseFramesCmd(_args);
            }
        }
        else if(_args[2].equals("frames")){
            parseFramesCmd(_args);
        }
        else if(_args.length > 3){
            if(_args[2].equals("shaker")) {
                shaker = stringFloat(_args[3]);
            }
            else if(_args[2].equals("overdub")){
                overdub = stringInt(_args[3]);
                if(overdub < 0) overdub = 0;
                if(overdub > 3) overdub = 3;
            }
            else if(_args[2].equals("drawInput")){
                doDrawInput = stringFloat(_args[3]) == 1;
            }
            else if(_args[2].equals("increment")){
                doIncrement = stringFloat(_args[3]) == 1;
            }
            else if(_args[2].equals("bufferSize")){
                setWorkingBufferSize(stringInt(_args[3]));
            }
            else if(_args[2].equals("frames")){
                setDrawnFrames(_args);
            }
            else if(_args.length > 4){
                if(_args[2].equals("center")){
                    float _x = stringFloat(_args[3]);
                    float _y = stringFloat(_args[4]);
                    center.set(_x, _y);
                }
            }
        } else return false;
        return true;
    }

    void setDrawnFrames(String[] _args){

    }

    void setWorkingBufferSize(int _i){
        bufferSize = _i;
        if(bufferSize > MAX_BUFFER_SIZE){
            bufferSize = MAX_BUFFER_SIZE;
        }
        else if(bufferSize < 1){
            bufferSize = 1;
        }
        println("bufferSize : "+bufferSize);
    }
    // public void selectOption(String _opt) {
    //     selectedOption = _opt;
    //     if(_opt.equals("haha")){
    //         second = !second;
    //     }
    // }
    public void selectOption(String _opt) {
        selectedOption = _opt;
        switch(_opt) {
        case "blend":
            blendMode = BLEND;
            break;
        case "add":
            blendMode = ADD;
            break;
        case "subtract":
            blendMode = SUBTRACT;
            break;
        case "darkest":
            blendMode = DARKEST;
            break;
        case "lightest":
            blendMode = LIGHTEST;
            break;
        case "difference":
            blendMode = DIFFERENCE;
            break;
        case "exclusion":
            blendMode = EXCLUSION;
            break;
        case "multiply":
            blendMode = MULTIPLY;
            break;
        case "screen":
            blendMode = SCREEN;
            break;
        case "replace":
            blendMode = REPLACE;
            break;
        default:
            blendMode = BLEND;
            break;
        }
    }
}

void doWeirdStuffHere(){

}
