/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */

/**
 * The gui class draws various information to a PGraphics canvas.
 *
 * <p>
 * All grafical user interface stuff goes here.
 * </p>
 *
 * @see SegmentGroup
 */

 class Gui implements FreelinerConfig{

  // depends on a group manager and a mouse
  GroupManager groupManager;
  Mouse mouse;
  // SegmentGroup used to display information, aka group 0
  SegmentGroup guiSegments;
  SegmentGroup refSegments;

  // canvas for all the GUI elements.
  PGraphics canvas;
  // PShape of the crosshair cursor
  PShape crosshair;

  // for displaying segment direction
  PShape arrow;

  //gui and line placing
  boolean showGui;
  boolean viewLines;
  boolean viewTags;
  boolean viewCursor;

  // reference gridSize and grid canvas, gets updated if the mouse gridSize changes.
  int gridSize = DEFAULT_GRID_SIZE;
  PShape grid;

  // for auto hiding the GUI
  int guiTimer = GUI_TIMEOUT;

  //ui strings
  // keyString is the parameter associated with lowercase keys, i.e. "q   strokeMode", "g   gridSize".
  String keyString = "derp";
  // value given to recently modified parameter
  String valueGiven = "__";
  // The TweakableTemplate tags of templates selected by the TemplateManager
  String renderString = "_";

  String[] allInfo = {"Geom", "Rndr", "Key", "Time", "FPS"};

  /**
   * Constructor
   * @param GroupManager dependency injection
   */
  public Gui(){
    // init canvas, P2D significantly faster
    canvas = createGraphics(width, height, P2D);//, FX2D)
    canvas.smooth(0);
    // make grid
    generateGrid(gridSize);
    // make the cursor PShape
    makecrosshair();
    makeArrow();
    // init options
    showGui = true;
    viewLines = false;
    viewTags = false;
    viewCursor = true;
  }


  /**
   * Depends on a groupManager to display all the segment groups and a mouse to draw the cursor.
   * @param GroupManager dependency injection
   * @param Mouse instance dependency injection
   */
  public void inject(GroupManager _gm, Mouse _m){
    groupManager = _gm;
    mouse = _m;
    // set the SegmentGroup used by the GUI
    guiSegments = groupManager.getGroup(0);
    refSegments = groupManager.getGroup(1);
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Main GUI parts
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Main update function, draws all of the GUI elements to a PGraphics
   */
  public void update() {
    updateInfo();
    if(mouse.hasMoved()) resetTimeOut();
    if(!doDraw()) return;

    // prep canvas
    canvas.beginDraw();
    canvas.clear();
    canvas.textFont(font);
    canvas.textSize(15);
    //canvas.setText(CENTER);

    // draw the grid
    if (mouse.useGrid()){
      // re-draw the grid if the size changed.
      if(mouse.getGridSize() != gridSize) generateGrid(mouse.getGridSize());
      canvas.shape(grid,0,0); // was without canvas before
    }
    // draw the cursor
    putCrosshair(mouse.getPosition(), mouse.isSnapped());

    // draw the segments of the selected group
    SegmentGroup sg = groupManager.getSelectedGroup();
    if(sg != null){
      //canvas.fill(255);
      showTag(sg);
      showGroupLines(sg);
      if (viewCursor) previewLine(sg);
    }

    // draw other segment groups if necessary
    if(viewLines || viewTags){
      for (SegmentGroup seg : groupManager.getGroups()) {
        groupGui(seg);
      }
    }

    // draw on screen information with group 0
    displayInfo();
    canvas.endDraw();
  }

  /**
   * This formats the information.
   */
  private void updateInfo(){
    // first segment shows which group is selected
    int geom = groupManager.getSelectedIndex();
    if(geom == -1) allInfo[0] = "[Geom : ]";
    else allInfo[0] = "[Geom : "+geom+"]";
    // second segment shows the Templates selected
    TemplateList _rl = groupManager.getTemplateList();
    String _tags = "";
    if (_rl != null) _tags = _rl.getTags();
    else _tags = renderString;
    if(_tags.length()>20) _tags = "*ALL*";
    allInfo[1] = "[Rndr : "+_tags+"]";
    // third show the parameter associated with key and values given to parameters
    allInfo[2] = "["+keyString+": "+valueGiven+"]";
    // display how long we have been jamming
    allInfo[3] = "["+getTimeRunning()+"]";
    // framerate ish
    allInfo[4] = "[FPS "+(int)frameRate+"]";
  }

  /**
   * This displays the info on the gui group.
   */
  private void displayInfo() {
    if(guiSegments.getSegments().size() == 0) return;
    for(int i = 0; i < 5; i++) guiSegments.setText(allInfo[i], i);
    // draw the information that was just set to segments of group 0
    ArrayList<Segment> segs = guiSegments.getSegments();
    int sz = int(guiSegments.getBrushScaler()*20);
    if(segs != null)
      for(Segment seg : segs)
        simpleText(seg, sz);
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Cursor Parts
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Display the cursor.
   * If it is snapped we display it green.
   * If it seems like we are using a matrox dual head, rotates the cursor to show which projector you are on.
   * @param PVector cursor coordinates
   * @param boolean isSnapped
   */
  private void putCrosshair(PVector _pos, boolean _snap){
    // if snapped, make cursor green, white otherwise
    if(_snap && !BW_BEAMER) crosshair.setStroke(SNAPPED_CURSOR_COLOR);
    else crosshair.setStroke(CURSOR_COLOR);
    crosshair.setStrokeWeight(CURSOR_STROKE_WIDTH);
    canvas.pushMatrix();
    canvas.translate(_pos.x, _pos.y);
    // if dual projectors rotate the cursor by 45 when on second projector
    if(DUAL_HEAD && _pos.x > width/2) {
      canvas.rotate(QUARTER_PI);
    }
    if(_snap && BW_BEAMER) canvas.rotate(QUARTER_PI);
    canvas.shape(crosshair);
    canvas.popMatrix();
  }

  /**
   * This shows a line between the last point and the cursor.
   * @param SegmentGroup selected
   */
  private void previewLine(SegmentGroup _sg) {
    PVector pos = _sg.getSegmentStart();
    if (pos.x > 0) {
      canvas.stroke(CURSOR_COLOR);
      canvas.strokeWeight(3);
      vecLine(canvas, pos, mouse.getPosition());
    }
  }

  /**
   * Create the PShape for the cursor.
   */
  private void makecrosshair(){
    int out = CURSOR_SIZE;
    int in = CURSOR_GAP_SIZE;
    crosshair = createShape();
    crosshair.beginShape(LINES);
    //if(INVERTED_COLOR) crosshair.stroke(0);
    crosshair.vertex(-out, -out);
    crosshair.vertex(-in, -in);

    crosshair.vertex(out, out);
    crosshair.vertex(in, in);

    crosshair.vertex(out, -out);
    crosshair.vertex(in, -in);

    crosshair.vertex(-out, out);
    crosshair.vertex(-in, in);
    crosshair.endShape();
  }

  /**
   * Create the PShape for the arrows that point the direction of segments
   */
  private void makeArrow(){
    int sz = 5;
    arrow = createShape();
    arrow.beginShape(LINES);
    arrow.stroke(SEGMENT_COLOR);
    arrow.vertex(sz, -sz);
    arrow.vertex(0,0);
    arrow.vertex(0,0);
    arrow.vertex(sz,sz);
    arrow.endShape();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Segment Group drawing
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Displays the segments of a SegmentGroup
   * @param SegmentGroup to draw
   */
  private void groupGui(SegmentGroup _sg){
    canvas.fill(200);
    if(viewTags) showTag(_sg);
    if(viewLines) showGroupLines(_sg);
  }

  /**
   * Display the tag and center of a group
   * The tag has the group ID "5" and all the associated Template tags
   */
  public void showTag(SegmentGroup _sg) {
    // Get center if centered or last point made
    PVector pos = _sg.isCentered() ? _sg.getCenter() : _sg.getSegmentStart();
    canvas.noStroke();
    canvas.fill(TEXT_COLOR);
    // group ID and template tags
    int id = _sg.getID();
    String idTag = str(id);
    if(_sg == guiSegments) idTag = "info";
    else if(_sg == refSegments) idTag = "ref";
    String tTags = _sg.getTemplateList().getTags();
    // display left and right of pos
    int fset = (16+int(id>9)*6);
    if(idTag == "info") fset = 35;
    else if(idTag == "ref") fset = 28;
    canvas.text(idTag, pos.x - fset, pos.y+6);
    canvas.text(tTags, pos.x + 6, pos.y+6);
    canvas.noFill();
    canvas.stroke(TEXT_COLOR);
    canvas.strokeWeight(1);
    // ellipse showing center or last point
    canvas.ellipse(pos.x, pos.y, 10, 10);
  }

  /**
   * Display all the segments of a group
   */
  public void showGroupLines(SegmentGroup _sg) {
    ArrayList<Segment> segs =  _sg.getSegments();
    if(segs != null){
      for (Segment seg : segs){
        showSegmentLines(seg, _sg);
      }
    }
  }

  /**
   * Display the lines of a SegmentGroup, with nice little dots on corners.
   * If it is centered it also shows the path offset.
   * @param Segment segment to draw
   */
  public void showSegmentLines(Segment _s, SegmentGroup _sg) {
    if(groupManager.getSnappedSegment() == _s) canvas.stroke(SNAPPED_CURSOR_COLOR);
    else if(_sg == groupManager.getSelectedGroup()) canvas.stroke(SEGMENT_COLOR);
    else canvas.stroke(SEGMENT_COLOR_UNSELECTED);
    canvas.strokeWeight(1);
    vecLine(canvas, _s.getPointA(), _s.getPointB());
    //canvas.stroke(100);
    //if(_s.isCentered()) vecLine(g, _s.getOffA(), _s.getOffB());
    canvas.stroke(NODE_COLOR);
    canvas.strokeWeight(NODE_STROKE_WEIGTH);
    canvas.point(_s.getPointA().x, _s.getPointA().y);
    canvas.point(_s.getPointB().x, _s.getPointB().y);
    PVector midpoint = _s.getMidPoint();
    canvas.pushMatrix();
    canvas.translate(midpoint.x, midpoint.y);
    canvas.rotate(_s.getAngle(false));
    canvas.shape(arrow);
    canvas.popMatrix();
  }

  /**
   * Display the text of a segment. used with guiSegmentGroup
   * @param Segment
   * @param int size of text
   */
  public void simpleText(Segment _s, int _size){
    String txt = _s.getText();
    int l = txt.length();
    PVector pos = new PVector(0,0);
    canvas.pushStyle();
    canvas.fill(TEXT_COLOR);
    canvas.noStroke();
    canvas.textFont(font);
    canvas.textSize(_size);
    char[] carr = txt.toCharArray();
    for(int i = 0; i < l; i++){
      pos = _s.getStrokePos(-((float)i/(l+1) + 1.0/(l+1))+1);
      canvas.pushMatrix();
      canvas.translate(pos.x, pos.y);
      canvas.rotate(_s.getAngle(false));
      canvas.translate(0,5);
      canvas.text(carr[i], 0, 0);
      canvas.popMatrix();
    }
    canvas.popStyle();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     GUI tools
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * The idea is to see how long your mapping jams having been going on for.
   * @return String of time since session started
   */
  private String getTimeRunning(){
    int millis = millis();
    int h = millis/3600000;
    millis %= 3600000;
    int m = millis/60000;
    millis %= 60000;
    int s = millis/1000;
    return h+":"+m+":"+s;
  }

  /**
   * Makes a screenshot with all lines and itemNumbers/renderers.
   * This is helpfull to have a reference as to what is what when rocking out.
   * Gets called everytime a new group is create.
   */
   // disable cause too slooooow?
  private void updateReference() {
    boolean tgs = viewTags;
    boolean lns = viewLines;
    viewLines = true;
    viewTags = true;
    update();
    canvas.save("userdata/reference.jpg");
    viewTags = tgs;
    viewLines = lns;
  }

  /**
   * Generate a PGraphics with the grid.
   * @param int resolution
   */
  private void generateGrid(int _sz){
    gridSize = _sz;
    //PShape grd;
    grid = createShape();
    grid.beginShape(LINES);
    grid.stroke(GRID_COLOR);
    grid.strokeWeight(1);
    for (int x = 0; x < width; x+=gridSize) {
      for (int y = 0; y < height; y+=gridSize) {
        grid.vertex(x, 0);
        grid.vertex(x, height);
        grid.vertex(0, y);
        grid.vertex(width, y);
      }
    }
    grid.endShape();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  /**
   * Force auto hiding of GUI
   */
  public void hide(){
    guiTimer = -1;
  }

  /**
   * Reset the time of the GUI auto hiding
   */
  public void resetTimeOut(){
    guiTimer = GUI_TIMEOUT;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Check if GUI needs to be drawn and update the GUI timeout for auto hiding.
   */
  public boolean doDraw(){
    if ((guiTimer > 0 || mouse.useGrid()) && focused) { // recently added window focus
      guiTimer--;
      return true;
    }
    else return false;
  }

  public PGraphics getCanvas(){
    return canvas;
  }

  public String[] getAllInfo(){
    return allInfo;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  /**
   * Set the key-parameter combo to display.
   * @param String "e   example"
   */
  public void setKeyString(String _s){
    String ks = _s.replaceAll(" ", "");
    keyString = ks.charAt(0)+" "+ks.substring(1);
  }

  /**
   * Display the latest value that was given to whatever.
   * @param String "true" "false" "haha" "123"
   */
  public void setValueGiven(String _s){
    if(_s != null) valueGiven = _s;
  }

  /**
   * Display the list of templates currently selected.
   * @param String "ABC"
   */
  public void setTemplateString(String _s){
    renderString = _s;
  }

  // modifiers with value return

  public boolean toggleViewPosition(){
    viewCursor = !viewCursor;
    return viewCursor;
  }

  public boolean toggleViewTags(){
    viewTags = !viewTags;
    return viewTags;
  }

  public boolean toggleViewLines(){
    viewLines = !viewLines;
    return viewLines;
  }
  public void hideStuff(){
    viewTags = false;
    viewLines = false;
    mouse.
  }
}
