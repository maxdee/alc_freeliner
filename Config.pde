interface FreelinerConfig{

  // UDP Port for incomming messages
  final int OSC_IN_PORT = 6667;
  // UDP Port for outgoing sync message
  final int OSC_OUT_PORT = 6668;
  // IP address to send sync messages to
  final String OSC_OUT_IP = "127.0.0.1";

  // GUI options
  final int CURSOR_SIZE = 18;
  final int CURSOR_GAP_SIZE = 6;
final int CURSOR_STROKE_WIDTH = 3;
  final int GUI_TIMEOUT = 1000;
  // final int DEFAULT_GRID_SIZE = 32; // used by mouse too
  final int NODE_STROKE_WEIGTH = 4;
  final int NODE_COLOR = #FFFFFF;
  final int PREVIEW_LINE_STROKE_WIDTH = 1;
  final color PREVIEW_LINE_COLOR = #ffffff;
  final color CURSOR_COLOR = #FFFFFF;
  final color SNAPPED_CURSOR_COLOR = #00C800;
  final color TEXT_COLOR = #FFFFFF;
  final color GRID_COLOR = #969696;//9696;
  final color SEGMENT_COLOR = #BEBEBE;
  final color SEGMENT_COLOR_UNSELECTED = #6E6E6E;



  // If you are using a DLP with no colour wheel
  final boolean BW_BEAMER = false;
  // If you are using a dual head setup
  final boolean DUAL_HEAD = false;//true;
  // invert colors
  final boolean INVERTED_COLOR = false;

  // Rendering options
  final color BACKGROUND_COLOR = #000000;
  final int STROKE_CAP = ROUND;
  final int STROKE_JOIN = MITER;
  final boolean BRUSH_SCALING = false;

  // Timing and stuff
  final int DEFAULT_TEMPO = 1500;
  final int SEQ_STEP_COUNT = 16; // change not recommended, there in spirit

  // to enable / disable experimental parts.
  final boolean EXPERIMENTAL = false;

  // Mouse options
  final int DEFAULT_GRID_SIZE = 64;
  final int DEFAULT_LINE_ANGLE = 30;
  final int DEFAULT_LINE_LENGTH = 128;
  final int MOUSE_DEBOUNCE = 100;

  // Keyboard Section
  // final char ...
  //provides strings to show what is happening.
  final String KEY_MAP[] = {
    "a    animationMode",
    "b    renderMode",
    "c    placeCenter",
    "d    setShape",
    "e    enterpolator",
    "f    fillColor",
    "g    grid/size",
    "h    easingMode",
    "i    repetitonMode",
    "j    reverseMode",
    "k    strokeAlpha",
    "l    fillAlpha",
    "m    breakLine",
    "n    newItem",
    "o    rotation",
    "p    shader",
    "q    strkColor",
    "r    polka",
    "s    size",
    "t    tempo",
    "u    enabler",
    "v    segmentSelector",
    "w    strkWeigth",
    "x    beatMultiplier",
    "y    tracers",
    //"z    ???????",
    ",    showTags",
    "/    showLines",
    ";    showCrosshair",
    ".    snapping",
    "|    enterText",
    "]    fixedLenght",
    "[    fixedAngle",
    "-    decreaseValue",
    "=    increaseValue",
    "$    saveTemplate",
    "%    loadTemplate",
    "*    record",
    ">    steps",
    "?    clearSeq"
  };

  final String CTRL_KEY_MAP[] = {
    "a    selectAll",
    "c    clone",
    "b    groupAddTemplate",
    "d    customShape",
    "i    reverseMouse",
    "r    resetTemplate",
    "s    saveStuff",
    "o    loadStuff",
    "l    loadLED",
    "m    masking",
    "k    showLEDmap"
  };

}
