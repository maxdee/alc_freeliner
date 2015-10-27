interface FreelinerConfig{

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

  // Rendering options
  final color BACKGROUND_COLOR = #000000;
  final int STROKE_CAP = ROUND;
  final int STROKE_JOIN = MITER;

  // Timing and stuff
  final int DEFAULT_TEMPO = 1500;
  final int SEQ_STEP_COUNT = 16; // customize step count of Sequencer

  // Keyboard Section
  // final char ...
}
