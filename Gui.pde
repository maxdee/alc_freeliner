/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


/**
 * The gui class draws various information to a PGraphics canvas.
 * 
 * <p>
 * All drawing happens here.
 * </p>
 *
 * @see SegmentGroup
 */
 class Gui{

  // depends on a group manager and a mouse
  GroupManager groupManager;
  Mouse mouse;
  // SegmentGroup used to display information, aka group 0
  SegmentGroup guiSegments;
  
  // canvas for all the GUI elements.
  PGraphics canvas;
  // PShape of the crosshair cursor
  PShape crosshair;
  final int CURSOR_SIZE = 20;
  final int CURSOR_GAP_SIZE = 4;
  final int CURSOR_STROKE_WIDTH = 3;
  final color CURSOR_COLOR = INVERTED_COLOR ? color(0) : color(255);
  final color SNAPPED_CURSOR_COLOR = color(0, 200, 0);
  final color TEXT_COLOR = INVERTED_COLOR ? color(0) : color(255);

  final color SEGMENT_COLOR = color(170);

  PShape arrow;

  //gui and line placing
  boolean showGui;
  boolean viewLines;
  boolean viewTags;
  boolean viewCursor;
  // reference gridSize and grid canvas, gets updated if the mouse gridSize changes.
  int gridSize = 30;
  PShape grid;
  final color GRID_COLOR = color(75);
  //PGraphics grid;
  // for auto hiding the GUI
  int guiTimeout = 1000;
  int guiTimer = 1000;

  //ui strings
  // keyString is the parameter associated with lowercase keys, i.e. "q   strokeMode", "g   gridSize".
  String keyString = "derp";
  // value given to recently modified parameter 
  String valueGiven = "__";
  // The TweakableTemplate tags of templates selected by the TemplateManager
  String renderString = "_";

  /**
   * Constructor
   * @param GroupManager dependency injection
   */
  public Gui(){
    // init canvas, P2D significantly faster
    canvas = createGraphics(width, height, P2D);
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
    if(mouse.hasMoved()) resetTimeOut();
    if(!doDraw()) return;

    // prep canvas
    canvas.beginDraw();
    canvas.clear();
    canvas.textFont(font);
    canvas.textSize(15);
    canvas.textMode(CENTER);

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
    infoWritter();
    canvas.endDraw();
  }

  /**
   * This formats the information to display and assigns it to the segements of the gui group.
   */
  private void infoWritter() {
    // Template tags of selected by selectedGroup or templateManager selected 
    if(guiSegments.getSegments().size() == 0) return;
    String tags = " ";
    TemplateList rl = groupManager.getTemplateList();
    if (rl != null) tags += rl.getTags();
    else tags += renderString;
    if(tags.length()>20) tags = "*ALL*";
    // first segment shows which group is selected
    guiSegments.setWord("[Item: "+groupManager.getSelectedIndex()+"]", 0);
    // second segment shows the Templates selected
    guiSegments.setWord("[Rndr: "+tags+"]", 1);
    // third show the parameter associated with key and values given to parameters
    guiSegments.setWord("["+keyString+": "+valueGiven+"]", 2);
    // display how long we have been jamming
    guiSegments.setWord("["+getTimeRunning()+"]", 3);
    // framerate ish
    guiSegments.setWord("[FPS "+(int)frameRate+"]", 4);
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
    if(_snap) crosshair.setStroke(SNAPPED_CURSOR_COLOR);
    else crosshair.setStroke(CURSOR_COLOR);
    crosshair.setStrokeWeight(CURSOR_STROKE_WIDTH);
    canvas.pushMatrix();
    canvas.translate(_pos.x, _pos.y);
    // if dual projectors rotate the cursor by 45 when on second projector
    if(width > 2000 && _pos.x > width/2) {
      canvas.rotate(QUARTER_PI);
    }
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
    String tTags = _sg.getTemplateList().getTags();
    // display left and right of pos
    canvas.text(str(id), pos.x - (16+int(id>9)*6), pos.y+6);
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
    if(segs != null)
      for (Segment seg : segs)
        showSegmentLines(seg);
  }

  /**
   * Display the lines of a SegmentGroup, with nice little dots on corners.
   * If it is centered it also shows the path offset.
   * @param Segment segment to draw
   */
  public void showSegmentLines(Segment _s) {
    if(groupManager.getSnappedSegment() == _s) canvas.stroke(SNAPPED_CURSOR_COLOR);
    else canvas.stroke(SEGMENT_COLOR);
    canvas.strokeWeight(1);
    vecLine(canvas, _s.getRegA(), _s.getRegB());
    //canvas.stroke(100);
    //if(_s.isCentered()) vecLine(g, _s.getOffA(), _s.getOffB());
    canvas.stroke(200);
    canvas.strokeWeight(4);
    canvas.point(_s.getRegA().x, _s.getRegA().y);
    canvas.point(_s.getRegB().x, _s.getRegB().y);
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
      pos = _s.getRegPos(-((float)i/(l+1) + 1.0/(l+1))+1);
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
    // boolean tgs = viewTags;
    // boolean lns = viewLines;
    // viewLines = true;
    // viewTags = true;
    // update();
    // canvas.save("reference.jpg");
    // viewTags = tgs;
    // viewLines = lns;
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
    guiTimer = guiTimeout;
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
    if (guiTimer > 0 || mouse.useGrid()) {
      guiTimer--;
      return true;
    }
    else return false;
  }

  public PGraphics getCanvas(){
    return canvas;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  public void setKeyString(String _s){
    keyString = _s;
  }

  public void setValueGiven(String _s){
    valueGiven = _s;
  }  

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
}
