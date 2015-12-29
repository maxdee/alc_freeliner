interface FreelinerConfig{

  // UDP Port for incomming messages
  final int OSC_IN_PORT = 6667;
  // UDP Port for outgoing sync message
  final int OSC_OUT_PORT = 6668;
  // IP address to send sync messages to
  final String OSC_OUT_IP = "127.0.0.1";


  // GUI options
  final int CURSOR_SIZE = 20;
  final int CURSOR_GAP_SIZE = 4;
  final int CURSOR_STROKE_WIDTH = 3;
  final int GUI_TIMEOUT = 1000;
  final int DEFAULT_GRID_SIZE = 32;
  final color CURSOR_COLOR = #FFFFFF;
  final color SNAPPED_CURSOR_COLOR = #00C800;
  final color TEXT_COLOR = #FFFFFF;
  final color GRID_COLOR = #969696;
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
  final int SEQ_STEP_COUNT = 16; // customize step count of Sequencer

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
    //"p    probability??",
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
    ">    steps"
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
    "k    showLEDmap"
  };

}
