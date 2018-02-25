
interface FreelinerConfig {

  // make these defaults? will be changed with configuration files...
  // UDP Port for incomming messages
  final int OSC_IN_PORT = 6667;
  // UDP Port for outgoing sync message
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
  final int CURSOR_SIZE = 28;
  final int CURSOR_GAP_SIZE = 20;
  final int CURSOR_STROKE_WIDTH = 4;
  final int GUI_TIMEOUT = 100000;
  final int GUI_FONT_SIZE = 20;
  // final int DEFAULT_GRID_SIZE = 32; // used by mouse too
  final int NODE_STROKE_WEIGTH = 5;
  final int NODE_COLOR = #989898;
  final int PREVIEW_LINE_STROKE_WIDTH = 1;
  final color PREVIEW_LINE_COLOR = #ffffff;
  final color CURSOR_COLOR = #FFFFFF;
  final color SNAPPED_CURSOR_COLOR = #00C800;
  final color TEXT_COLOR = #FFFFFF;
  final color GRID_COLOR = #969696;//9696;
  final color SEGMENT_COLOR = #BEBEBE;
  final color SEGMENT_COLOR_UNSELECTED = #6E6E6E;

  // If you are using a DLP with no colour wheel
  final boolean BW_BEAMER = true;
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
  /**
   * Your color pallette! customize it!
   * Use hex value or color(0,100,200);
   */
  final color[] userPallet = {
                    #ffff00,
                    #ffad10,
                    #ff0000,
                    #ff00ad,
                    #f700f7,
                    #ad00ff,
                    #0000ff,
                    #009cff,
                    #00c6ff,
                    #00deb5,
                    #a5ff00,
                    #f700f7,
                  };
  //
  // final color[] userPallet = {
  //                   #0000fe,
  //                   #feff01,
  //                   #ff7f00,
  //                   #1200d2,
  //                   #0000fe,
  //                   #feff01,
  //                   #ff7f00,
  //                   #1200d2,
  //                   #0000fe,
  //                   #feff01,
  //                   #ff7f00,
  //                   #1200d2,
  //                 };


  final int PALLETTE_COUNT = 12;

  final String PATH_TO_SHADERS = "userdata/shaders/";
  final String PATH_TO_IMAGES = "userdata/images/";
  final String PATH_TO_FIXTURES = "userdata/fixtures/";
  final String PATH_TO_GEOMETRY = "userdata/geometry/";
  final String PATH_TO_TEMPLATES = "userdata/template/";
  final String PATH_TO_VECTOR_GRAPHICS = "userdata/svg/";
  final String PATH_TO_CAPTURE_FILES = "userdata/capture/";
  final String PATH_TO_LAYERS = "userdata/layerSetups/";



  // Freeliner LED options
  // final String LED_SERIAL_PORT = "/dev/ttyACM0";
  // final int LED_SYSTEM = 1; // FastLEDing 1, OctoLEDing 2
}
