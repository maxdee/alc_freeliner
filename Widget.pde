/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */


/**
 * Widgets! from scratch!
 * could of used a library but this is fun too.
 */


/**
 * Basic widget class
 *
 *
 */
public class Widget implements FreelinerConfig{
  // position and size
  PVector pos;
  PVector size;
  // mouse position relative to widget 0,0
  PVector mouseDelta;
  // mouse XY 0.0 to 1.0
  PVector mouseFloat;
  // if the mouse is over the widget
  boolean selected;
  // enable disable widget
  boolean active;
  // basic colors
  color bgColor = color(100);
  color hoverColor = color(150);
  color frontColor = color(200,0,0);
  // label
  String label = "";
  int inset = 2;
  /**
   * Constructor
   * @param PVector position of top left corner of widget
   * @param PVector widget dimentions
   */
  public Widget(PVector _pos, PVector _sz){
    pos = _pos.get();
    size = _sz.get();
    mouseDelta = new PVector(0,0);
    mouseFloat = new PVector(0,0);
    active = true;
  }

  /**
   * Render the widget, draws the basic background and changes its color if widget selected.
   * @param PGraphics canvas to draw on
   */
  public void show(PGraphics _pg){
    if(!active) return;
    _pg.noStroke();
    if(selected) _pg.fill(hoverColor);
    else _pg.fill(bgColor);
    _pg.rect(pos.x, pos.y, size.x, size.y);
  }

  public void showLabel(PGraphics _pg){
    _pg.fill(255);
    _pg.textSize(18);
    if(label.length()>0) _pg.text(label, pos.x+size.x+2, pos.y + size.y - inset);
  }

  /**
   * Update the widget
   * @param PVector cursor position
   * @return boolean cursor is over widget
   */
  public boolean update(PVector _cursor){
    setCursor(_cursor);
    if(!active) selected = false;
    else selected = isOver();
    return selected;
  }

  /**
   * Update the cursor position, determin the mouseDelta and unit interval
   * @param PVector cursor position
   */
  public void setCursor(PVector _cursor){
    mouseDelta = _cursor.get().sub(pos);
    mouseFloat.set(mouseDelta.x/size.x, mouseDelta.y/size.y);
  }

  /**
   * Is mouse over widget
   * @return boolean
   */
  public boolean isOver(){
    return (mouseDelta.x > 0 && mouseDelta.y > 0) && (mouseDelta.x < size.x && mouseDelta.y < size.y);
  }

  /**
   * receive mouse press
   * @param int mouse button
   */
  public void click(int _mb){
    if(selected) action(_mb);
  }

  /**
   * receive mouse drag,
   * @param int mouse button
   */
  public void drag(int _mb){
    if(selected) action(_mb);
  }

  /**
   * where the action of the widget happens
   * @param int mouse button
   * @return boolean
   */
  public void action(int _button){
    // you can use mouseFloat for info
  }

  public void setPos(PVector _pos){
    pos = _pos.get();
  }

  public void setBackgroundColor(color _col){
    bgColor = _col;
  }
  public void setHoverColor(color _col){
    hoverColor = _col;
  }
  public void setFrontColor(color _col){
    frontColor = _col;
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     Real Widgets!
///////
////////////////////////////////////////////////////////////////////////////////////
/**
 * Basic button widget, subclass and inject things to control.
 */
class Button extends Widget {
  int counter;
  public Button(PVector _pos, PVector _sz){
    super(_pos, _sz);
    counter = 0;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active && counter > 0){
      counter--;
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, size.x-(2*inset), size.y-(2*inset));
    }
  }

  public void action(int _button){
  }

  public void click(int _mb){
    super.click(_mb);
    counter = 4;
  }

  // do nothing on drag
  public void drag(int _mb){

  }
}

/**
 * Basic toggle widget, subclass and inject things to control.
 */
class Toggle extends Widget {
  boolean value;
  color toggleCol = color(255,0,0);

  public Toggle(PVector _pos, PVector _sz){
    super(_pos, _sz);
    value = false;
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active && value){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, size.x-(2*inset), size.y-(2*inset));
    }
  }

  public void action(int _button){
    value = !value;
  }
}

/**
 * Basic horizontal fader widget, subclass and inject things to control.
 */
class Fader extends Widget {
  float value;

  public Fader(PVector _pos, PVector _sz){
    super(_pos, _sz);
    value = 0.5;
    label = "haha";
  }

  public void show(PGraphics _canvas){
    super.show(_canvas);
    if(active){
      _canvas.fill(frontColor);
      _canvas.rect(pos.x+inset, pos.y+inset, (size.x-(2*inset)) * value, size.y-(2*inset));
    }
    showLabel(_canvas);
  }

  public void action(int _button){
    value = constrain(mouseFloat.x, 0.0, 1.0);
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Actual widgets
///////
////////////////////////////////////////////////////////////////////////////////////


/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
class InfoLine extends Widget {
  Gui flGui;
  int txtSize;
  public InfoLine(PVector _pos, PVector _sz, Gui _g){
    super(_pos, _sz);
    txtSize = int(_sz.y);
    flGui = _g;
    active = true;
  }

  public void show(PGraphics _canvas){
    if(!active) return;
    _canvas.textSize(txtSize);
    String[] _info = reverse(flGui.getAllInfo());
    String _txt = "";
    for(String str : _info) _txt += str+"  ";
    _canvas.fill(255);
    _canvas.text(_txt, pos.x, pos.y+txtSize);
  }
}


/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
public class GeometryLoader extends Button {
  GroupManager groupManager;

  public GeometryLoader(PVector _pos, PVector _sz, GroupManager _gm){
    super(_pos, _sz);
    active = true;
    groupManager = _gm;
    label = "load";
  }

  public void show(PGraphics _canvas){
    if(!active) return;
    super.show(_canvas);
    showLabel(_canvas);
  }

  public void action(int _mb){
    if(_mb == LEFT) selectInput("load file :", "useFile", null, this);
  }

  public void useFile(File _fn){
    if (_fn == null) println("Window was closed or the user hit cancel.");
    else groupManager.loadGroups(_fn.getAbsolutePath());
  }
}

/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
public class GeometrySaver extends GeometryLoader {

  public GeometrySaver(PVector _pos, PVector _sz, GroupManager _gm){
    super(_pos, _sz, _gm);
    active = true;
    label = "saver";
  }

  public void action(int _mb){
    if(_mb == LEFT) selectInput("save file :", "useFile", null, this);
  }

  public void useFile(File _fn){
    if (_fn == null) println("Window was closed or the user hit cancel.");
    else groupManager.saveGroups(_fn.getAbsolutePath());
  }
}


/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
public class ShaderLoader extends Button {
  FreeLiner freeliner;
  public ShaderLoader(PVector _pos, PVector _sz, FreeLiner _fl){
    super(_pos, _sz);
    active = true;
    this.label = "reloadShader";
    freeliner = _fl;
  }

  public void action(int _mb){
    if(_mb == LEFT) freeliner.canvasManager.reloadShader();
  }
}

/**
 * Widget to display GUI info compiled by the regular Freeliner GUI
 */
public class MaskLoader extends Button {
  FreeLiner freeliner;
  public MaskLoader(PVector _pos, PVector _sz, FreeLiner _fl){
    super(_pos, _sz);
    active = true;
    this.label = "makeMask";
    freeliner = _fl;
  }

  public void action(int _mb){
    if(_mb == LEFT) freeliner.canvasManager.generateMask();
  }
}


/**
 * Widget to control the sequencer
 */
class SequenceGUI extends Widget {
  int txtSize = 20;
  int inset = 2;
  Sequencer sequencer;
  TemplateList managerList;

  public SequenceGUI(PVector _pos, PVector _sz, Sequencer _seq, TemplateList _tl){
    super(_pos, _sz);
    //txtSize = int(_sz.y);
    sequencer = _seq;
    managerList = _tl;
    active = true;
  }

  public void action(int _mb){
    int _clickedStep = int(mouseFloat.x * SEQ_STEP_COUNT);
    if(_mb == LEFT) sequencer.forceStep(_clickedStep);
    else if(_mb == RIGHT){
      ArrayList<TweakableTemplate> _tmps = managerList.getAll();
      if(_tmps == null) return;
      sequencer.setEditStep(_clickedStep);
      for(TweakableTemplate _tw : _tmps){
        sequencer.getStepToEdit().toggle(_tw);
      }
    }
  }


  public void show(PGraphics _canvas){
    if(!active) return;
    int _index = 0;
    int _stepSize = int(size.x/ 16.0);
    _canvas.textSize(txtSize);
    for(TemplateList _tl : sequencer.getStepLists()){
      _canvas.pushMatrix();
      _canvas.translate(_stepSize * _index, pos.y);
      if(_index == sequencer.getStep()) _canvas.fill(hoverColor);
      else _canvas.fill(bgColor);
      _canvas.stroke(0);
      _canvas.strokeWeight(1);
      _canvas.rect(0, 0, _stepSize, size.y);
      _canvas.noStroke();
      if(_tl == sequencer.getStepToEdit()){
        _canvas.fill(frontColor);
        _canvas.rect(inset, inset, _stepSize-(2*inset), size.y-(2*inset));
      }
      _canvas.rotate(HALF_PI);
      _canvas.fill(255);
      _canvas.text(_tl.getTags(),inset*4,-inset*4);
      _canvas.popMatrix();
      _index++;
    }
  }
}
