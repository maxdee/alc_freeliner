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
     Capture cam;
     PApplet applet;

    ArrayList<PGraphics> frames = new ArrayList();
    FloatList selectedFrames = new FloatList();
    final int MAX_BUFFER_SIZE = 60;
    int bufferSize = MAX_BUFFER_SIZE;
    int frameIndex = 0;

    float shaker = 0;
    PVector center;
    boolean overdub = true;
    boolean second = false;

    public FrameSamplerLayer(PApplet _ap) {
        super();
        applet = _ap;
        name = "frameSamplerLayer";
        id = name;
        description = "webcams and capture cards, but with a twist";
        makeFrames();

        // if(cam != null) cam.stop();
        cam = new Capture(applet, "name=/dev/video0,size=1440x900,fps=60");// width, height, "/dev/video/1", 60);//_opt);
        cam.start();
    }

    public PGraphics apply(PGraphics _pg) {
        if(!enabled) return _pg;
        if(cam == null) return _pg;
        if(cam.available()) {
            cam.read();
            addFrameToBuffer();
        }

        if(_pg == null) {
            canvas.beginDraw();
            canvas.blendMode(LIGHTEST);
            doSamplerDraw(canvas);
            canvas.endDraw();
            return canvas;
        } else {
            _pg.beginDraw();
            _pg.blendMode(LIGHTEST);
            doSamplerDraw(_pg);
            _pg.endDraw();
            return _pg;
        }
    }

    void doSamplerDraw(PGraphics _canvas){
        if(shaker != 0) {
            shaker -= shaker/8.0;
            if(shaker < 0.01) shaker = 0;
        }
        scale(1.0+random(shaker)/20.0);

        _canvas.image(cam,0,0);
        _canvas.image(frames.get(0),0,0,width,height);
        if(second) _canvas.image(frames.get(5),0,0,width,height);
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
        selectedFrames.append(0.0);
    }

    private void addFrameToBuffer() {
        cam.read();
        PGraphics img;
        if(overdub) {
            frameIndex++;
            frameIndex %= bufferSize;
            img = frames.get(frameIndex);
        }
        else {
            img = frames.get(0);
        }
        img.beginDraw();
        img.image(cam,0,0);
        img.endDraw();
    }

    /**
     * Override parent's
     */
    public boolean parseCMD(String[] _args) {
        boolean _parsed = super.parseCMD(_args);
        if(_parsed) return true;
        else if(_args.length > 3) {
            if(_args[2].equals("shaker")) {
                shaker = stringFloat(_args[3]);
            }
        } else return false;
        return true;
    }
    public void selectOption(String _opt) {
        selectedOption = _opt;
        if(_opt.equals("haha")){
            second = !second;
        }
    }
}

void doWeirdStuffHere(){

}
