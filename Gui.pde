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
 * Gui class handles anything on the PGraphics gui
 * <p>
 * All drawing happens here.
 * </p>
 *
 * @see SegmentGroup
 */
 class Gui{

  // depends on a group manager
  GroupManager groupManager;
  Mouse mouse;
  PGraphics grid;
  PGraphics canvas;
  PShape crosshair;

  //gui and line placing
  boolean showGui;
  boolean viewLines;
  boolean viewTags;
  boolean viewPosition;

  int gridSize = 30;
  int guiTimeout = 1000;
  int guiTimer = 1000;
  //display elapsed time!
  int[] timeStarted = new int[3];

  //ui strings
  String keyString = "derp";
  String valueGiven = "__";
  String renderString = "_";

  boolean updateFlag = false;


/**
 * Constructor
 * @param GroupManager dependency injection
 */
  public Gui(){

    canvas = createGraphics(width, height);
    canvas.smooth(0);
    canvas.textFont(font);
    
    grid = createGraphics(width, height);
    grid.smooth(0);

    makecrosshair();

    showGui = true;
    viewLines = false;
    viewTags = false;
    viewPosition = true;
    timeStarted[0] = hour();
    timeStarted[1] = minute();
    timeStarted[2] = second();
  }

  public void inject(GroupManager _gm, Mouse _m){
    groupManager = _gm;
    mouse = _m;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     GUI
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  //gui bits
  private void update() {
    canvas.beginDraw();
    canvas.clear();
    canvas.textFont(font);
    canvas.textSize(15);
    canvas.textMode(CENTER);
    if (mouse.useGrid()){
      if(mouse.getGridSize() != gridSize) generateGrid(mouse.getGridSize());
      canvas.image(grid,0,0); // was without canvas before
    }
    if(viewPosition) putcrosshair(mouse.getPosition(), mouse.isSnapped());
    if(viewLines || viewTags){
      for (SegmentGroup sg : groupManager.getGroups()) {
        canvas.fill(200);
        sg.showLines(canvas); 
        sg.showTag(canvas);
      }
    }
    SegmentGroup sg = groupManager.getSelectedGroup();
    if(sg != null){
      canvas.fill(255);
      sg.showLines(canvas); 
      sg.showTag(canvas);
      if (viewPosition) sg.previewLine(canvas, mouse.getPosition());
    }
    infoWritter(canvas);
    canvas.endDraw();
  }



  private void infoWritter(PGraphics pg) {
    if(updateFlag){
      String rn = " ";
      if (groupManager.isFocused()) rn += groupManager.getSelectedGroup().getRenderList().getString();
      else rn += renderString; //renderList.getString();
      if(rn.length()>20) rn = "*ALL*";

      groupManager.getIndex(0).setWord("[Item: "+groupManager.getSelectedIndex()+"]", 0);
      groupManager.getIndex(0).setWord("[Rndr: "+rn+"]", 1);
      groupManager.getIndex(0).setWord("["+keyString+": "+valueGiven+"]", 2);
      groupManager.getIndex(0).setWord("[FPS "+frameRate+"]", 3);
      groupManager.getIndex(0).setWord("[Run "+getTimeRunning()+"]", 4);
      updateFlag = false;
    }
    groupManager.getIndex(0).showText(pg);

  }

  private String getTimeRunning(){
    return str(hour()-timeStarted[0])+':'+str(minute()-timeStarted[1])+':'+str(second()-timeStarted[2]); 
  }

  // makes a screenshot with all lines and itemNumbers/renderers.
  private void updateReference() {
    boolean tgs = viewTags;
    boolean lns = viewLines;
    viewLines = true;
    viewTags = true;
    update();
    canvas.save("reference.jpg");
    viewTags = tgs;
    viewLines = lns;
  }


  private void generateGrid(int _sz){
    gridSize = _sz;
    PShape grd;
    grd = createShape();
    grd.beginShape(LINES);
    for (int x = 0; x < width; x+=gridSize) {
      for (int y = 0; y < height; y+=gridSize) {
        grd.vertex(x, 0);
        grd.vertex(x, height);
        grd.vertex(0, y);
        grd.vertex(width, y);
      }
    }
    grd.endShape();
    grd.setStroke(color(100, 100, 100, 10));
    grd.setStrokeWeight(1);
    grid.beginDraw();
    grid.clear();
    grid.shape(grd);
    grid.endDraw();
  }
  


  private void putcrosshair(PVector _pos, boolean _snap){
    if(_snap) crosshair.setStroke(color(0,200,0));
    else crosshair.setStroke(color(255));
    crosshair.setStrokeWeight(3);
    canvas.pushMatrix();
    canvas.translate(_pos.x, _pos.y);
    if(width > 1026 && _pos.x > width/2) canvas.rotate(QUARTER_PI);
    canvas.shape(crosshair);
    canvas.popMatrix();
  }

  private void makecrosshair(){
    int out = 20;
    int in = 3;
    crosshair = createShape();
    crosshair.beginShape(LINES);
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

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Actions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  public void hide(){
    guiTimer = -1;
  }
  public void resetTimeOut(){
    guiTimer = guiTimeout;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////



  public boolean doDraw(){
    // if (guiTimer < 0 || mouse.useGrid()) {
    //   guiTimer--;
    //   return true;
    // }
    //else 
    return true;//false;
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
    updateFlag = true;
  }

  public void setValueGiven(String _s){
    valueGiven = _s;
    updateFlag = true;
  }  

  public void setRenderString(String _s){
    renderString = _s;
    updateFlag = true;
  }


  public boolean toggleViewPosition(){
    viewPosition = !viewPosition;
    return viewPosition;
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

