
interface FreelinerConfig {
    // windowed mode width and height
    final int CONFIGURED_WIDTH = 960;
    final int CONFIGURED_HEIGHT = 720;
    final boolean USE_FULLSCREEN = true;//true;
    // which screen is used for fullscreen
    final int FULLSCREEN_DISPLAY = 2;
    final int CONFIGURED_FPS = 60;

    // UDP Port for incomming OSC messages
    final int OSC_IN_PORT = 6667;
    // UDP Port for outgoing OSC message
    final int OSC_OUT_PORT = 6668;
    // IP address to send sync messages to
    final String OSC_OUT_IP = "127.0.0.1";
    // use TCP or UDP
    final boolean OSC_USE_TCP = false;
    // Websocket port
    final int WEBSOCKET_PORT = 8025;
    // Disbale Webserving
    final boolean SERVE_HTTP = true;
    // HTTP server port
    final int HTTPSERVER_PORT = 8000;

    // very beta
    final boolean DOME_MODE = false;

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
