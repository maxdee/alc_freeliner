
interface FreelinerConfig {
    // windowed mode width and height
    // final int WIDTH = 1024;
    // final int HEIGHT = 768;
    // final boolean FULLSCREEN = false;
    // // which screen is used for fullscreen
    // final int FULLSCREEN_DISPLAY = 2;
    // final int CONFIGURED_FPS = 60;

    // UDP Port for incomming OSC messages
    // final int OSC_IN_PORT = 6667;
    // // UDP Port for outgoing OSC message
    // final int OSC_OUT_PORT = 6668;
    // // IP address to send sync messages to
    // final String OSC_OUT_IP = "127.0.0.1";
    // // use TCP or UDP
    // final boolean OSC_USE_TCP = false;
    // // Websocket port
    // final int WEBSOCKET_PORT = 8025;
    // // Disbale Webserving
    // final boolean SERVE_HTTP = true;
    // // HTTP server port
    // final int HTTPSERVER_PORT = 8000;

    // very beta
    // final boolean DOME_MODE = true;

    // bad for beginners but crucial
    boolean ENABLE_KEY_REPEAT = true;

    // Mouse options
    final int DEFAULT_GRID_SIZE = 64;
    final int DEFAULT_LINE_ANGLE = 30;
    final int DEFAULT_LINE_LENGTH = 128;
    final int MOUSE_DEBOUNCE = 100;
    // use scrollwheel as - +
    final boolean SCROLLWHEEL_SELECTOR = false;

    // GUI options
    final int CURSOR_SIZE = 15;
    final int CURSOR_GAP_SIZE = 10;
    final int CURSOR_STROKE_WIDTH = 2;
    final int GUI_TIMEOUT = 10000;
    final int GUI_FONT_SIZE = 20;
    // final int DEFAULT_GRID_SIZE = 32; // used by mouse too
    final int NODE_STROKE_WEIGTH = 5;
    final int NODE_COLOR = #989898;
    final int PREVIEW_LINE_STROKE_WIDTH = 1;
    final color PREVIEW_LINE_COLOR = #ffffff;
    final color CURSOR_COLOR = #FFFFFF;
    final color SNAPPED_CURSOR_COLOR = #00FF00;
    final boolean ENABLE_SNAP_MIDDLE = true;
    final color TEXT_COLOR = #FFFFFF;
    final color GRID_COLOR = #969696;//9696;
    final int GRID_STROKE_WEIGHT = 1;//9696;
    final color SEGMENT_COLOR = #BEBEBE;
    final color ARROW_COLOR = #5D5D5D;

    final color SEGMENT_COLOR_UNSELECTED = #2D2D2D;

    // If you are using a DLP with no colour wheel
    final boolean BW_BEAMER = false;
    // If you are using a dual head setup
    final boolean DUAL_HEAD = false;
    // invert colors
    final boolean INVERTED_COLOR = true;

    // Rendering options
    final color BACKGROUND_COLOR = #000000;
    final int STROKE_CAP = ROUND;//PROJECT;//SQUARE; // or ROUND
    final int STROKE_JOIN = ROUND;//MITER; // or BEVEL or ROUND
    final boolean BRUSH_SCALING = false;

    // Timing and stuff
    final int DEFAULT_TEMPO = 1300;
    final int SEQ_STEP_COUNT = 16; // change not recommended, there in spirit

    // Pick your rendering pipeline,
    // 0 is lightest, best for older hardware
    // 1 is fancy, but only good with newer hardware
    final int RENDERING_PIPELINE = 1;
    final int SMOOTH_LEVEL = 2;
    // to enable / disable experimental parts.
    final boolean EXPERIMENTAL = false;

    // generate documentation on startup, pretty much mandatory now.
    final boolean MAKE_DOCUMENTATION = true;

    final boolean FIXTURE_CORRECT_GAMMA = false;
    final boolean DRAW_FIXTURE_ADDRESS = false;

    final boolean EASE_SHADER_UNIFORMS = true;

    final String PATH_TO_SHADERS = "userdata/shaders/";
    final String PATH_TO_IMAGES = "userdata/images/";
    final String PATH_TO_FIXTURES = "userdata/fixtures/";
    final String PATH_TO_GEOMETRY = "userdata/geometry/";
    final String PATH_TO_TEMPLATES = "userdata/template/";
    final String PATH_TO_VECTOR_GRAPHICS = "userdata/svg/";
    final String PATH_TO_CAPTURE_FILES = "userdata/capture/";
    final String PATH_TO_LAYERS = "userdata/layerSetups/";
}


class FreelinerProject {
    String fullPath = "data/default_project/";
    String projectName = "project";
    // windowed mode width and height
    int width = 1024;
    int height = 768;
    boolean fullscreen = false;
    boolean layers = true;
    int fullscreenDisplay = 2;
    int maxfps = 60;
    int smoothLevel = 2;
    boolean splash = true;
    // Rendering options
    color BACKGROUND_COLOR = #000000;
    int STROKE_CAP = ROUND;//PROJECT;//SQUARE; // or ROUND
    int STROKE_JOIN = ROUND;//MITER; // or BEVEL or ROUND
    boolean BRUSH_SCALING = false;

    // network
    int oscInPort = 6667;
    int oscOutPort = 6668;
    String oscOutIP = "127.0.0.1";
    boolean oscUseTCP = false;
    int websocketPort = 8025;
    boolean serveHTTP = true;
    int httpServerPort = 8000;

    // ui options

    boolean keyRepeat = true;
    int mouseDebounce = 100;
    // Mouse options
    int gridSize = 64;
    int lineToolFixedAngle = 30;
    int lineToolFixedLength = 128;
    // use scrollwheel as - +
    boolean scrollWheelTweaker = false;

    // GUI options
    int cursorSize = 15;
    int cursorGapSize = 10;
    int cursorStrokeWeight = 2;
    int guiTimeout = 10000;
    int guiFontSize = 20;
    // int DEFAULT_GRID_SIZE = 32; // used by mouse too
    int nodeSize = 5;
    int nodeColor = #989898;
    int previewLineStrokeWeight = 1;
    color previewLineColor = #ffffff;
    int previewLineAlpha = 100;
    color cursorColor = #FFFFFF;
    int cursorAlpha = 100;
    color cursorColorSnapped = #00FF00;
    int cursorAlphaSnapped = 200;
    boolean enableSnapeToLines = true;
    color guiTextColor = #FFFFFF;
    int guiTextAlpha = 100;
    color gridColor = #969696;//9696;
    int gridAlpha = 100;
    int gridStrokeWeight = 1;//9696;
    color lineSegmentColor = #BEBEBE;
    color arrowColor = #5D5D5D;
    int arrowAlpha = 100;
    color segmentColor = #2D2D2D;

    boolean rotateCursorOnSnap = false;
    // invert colors
    boolean invertedColor = true;

    // Timing and stuff
    int tempo = 1300;
    int seqStepCount = 16;

    // generate documentation on startup, pretty much mandatory now.

    boolean FIXTURE_CORRECT_GAMMA = false;
    boolean DRAW_FIXTURE_ADDRESS = false;

    boolean EASE_SHADER_UNIFORMS = true;

    String PATH_TO_SHADERS = "userdata/shaders/";
    String PATH_TO_IMAGES = "userdata/images/";
    String PATH_TO_FIXTURES = "userdata/fixtures/";
    String PATH_TO_GEOMETRY = "userdata/geometry/";
    String PATH_TO_TEMPLATES = "userdata/template/";
    String PATH_TO_VECTOR_GRAPHICS = "userdata/svg/";
    String PATH_TO_CAPTURE_FILES = "userdata/capture/";
    String PATH_TO_LAYERS = "userdata/layerSetups/";

    public FreelinerProject(){}
    // this basicaly mutates it
    void load(String path){
        fullPath = path;
        //extract project name
        String[] splt = path.split("/");
        projectName = splt[splt.length-1];
        println("[freeliner] loading project : "+projectName);
        JSONObject _json = null;
        try {
            _json = loadJSONObject(fullPath+"/config.json");
        }
        catch (Exception e) {
            println("[ERROR] could not load : \n" + path);
            return;
        }
        loadJSON(_json);
    }

    void save(){
        JSONObject _cfg =  new JSONObject();
        _cfg.setJSONObject("config",makeJson());
        saveJSONObject(_cfg, fullPath+"/config.json");
    }

    void loadJSON(JSONObject _json) {
        JSONObject _config = _json.getJSONObject("config");
        if(_config == null) {
            // println("[ERROR] no config : \n" + _json);
            return;
        }

        JSONObject _renderConfig = _config.getJSONObject("render");
        if(_renderConfig != null) {
            this.width = _renderConfig.getInt("width", this.width);
            this.height = _renderConfig.getInt("height", this.height);
            this.fullscreen = _renderConfig.getBoolean("fullscreen", this.fullscreen);
            this.fullscreenDisplay = _renderConfig.getInt("fullscreenDisplay", this.fullscreenDisplay);
            this.layers = _renderConfig.getBoolean("layers", this.layers);
            this.maxfps = _renderConfig.getInt("maxfps", this.maxfps);
            this.smoothLevel = _renderConfig.getInt("smoothLevel", this.smoothLevel);
            this.splash = _renderConfig.getBoolean("splash", this.splash);
            if(!this.splash) {
                println("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
                println("$$$  I see you disabled splash, consider donating $$$");
                println("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
            }
        }
        JSONObject _networkConfig = _config.getJSONObject("network");
        if(_networkConfig != null) {
            this.oscInPort = _renderConfig.getInt("oscInPort", this.oscInPort);
            this.oscOutPort = _renderConfig.getInt("oscOutPort", this.oscOutPort);
            this.oscOutIP = _renderConfig.getString("oscOutIP", this.oscOutIP);
            this.oscUseTCP = _renderConfig.getBoolean("oscUseTCP", this.oscUseTCP);
            this.websocketPort = _renderConfig.getInt("websocketPort", this.websocketPort);
            this.serveHTTP = _renderConfig.getBoolean("serveHTTP", this.serveHTTP);
            this.httpServerPort = _renderConfig.getInt("httpServerPort", this.httpServerPort);
        }

    }

    JSONObject makeJson(){
        JSONObject _renderConfig = new JSONObject();
        _renderConfig.setInt("width", this.width);
        _renderConfig.setInt("height", this.height);
        _renderConfig.setBoolean("fullscreen", this.fullscreen);
        _renderConfig.setInt("fullscreenDisplay", this.fullscreenDisplay);
        _renderConfig.setBoolean("layers", this.layers);
        _renderConfig.setInt("maxfps", this.maxfps);
        _renderConfig.setInt("smoothLevel", this.smoothLevel);
        _renderConfig.setBoolean("splash", this.splash);

        JSONObject _networkConfig =  new JSONObject();
        _networkConfig.setInt("oscInPort", this.oscInPort);
        _networkConfig.setInt("oscOutPort", this.oscOutPort);
        _networkConfig.setString("oscOutIP", this.oscOutIP);
        _networkConfig.setBoolean("oscUseTCP", this.oscUseTCP);
        _networkConfig.setInt("websocketPort", this.websocketPort);
        _networkConfig.setBoolean("serveHTTP", this.serveHTTP);
        _networkConfig.setInt("httpServerPort", this.httpServerPort);

        JSONObject _config = new JSONObject();//.getJSONObject("config");
        _config.setJSONObject("render", _renderConfig);
        _config.setJSONObject("network", _networkConfig);

        return _config;
    }
}
