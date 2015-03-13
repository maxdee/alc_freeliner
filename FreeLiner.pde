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
 * @author              ##author##
 * @modified    ##date##
 * @version             ##version##
 */





///*** Todo ***///
// deco pgraphics as a texture to be shaded?
// loop mode = clock, non loop = trigger mode. (rendering speed stored in rederer?)
// yahoo!!

//bumper

// autoPilot for renderers b:1,3 q:2,3
//add middle to vertix


// the PGraphics deco should maybe be a P2D?


class  FreeLiner {

  OscP5 oscP5;
  //"graphical interface"
  Gui gui;
  // input
  Mouse mouse;
  Keyboard keyboard;
  // managers
  GroupManager groupManager;
  RendererManager rendererManager;

  public FreeLiner() {

    //network
    //oscP5 = new OscP5(this, 3333);
    rendererManager =  new RendererManager();
    groupManager = new GroupManager();
    mouse = new Mouse(groupManager, keyboard);
    keyboard = new Keyboard(groupManager, rendererManager, gui, mouse);
    
    
    gui = new Gui(groupManager, mouse);

  }

  public void update() {
    background(0);
    rendererManager.update(groupManager.getGroups());
    image(rendererManager.getCanvas(), 0, 0);
    
    if(gui.doDraw()){
      gui.update(mouse.getPosition(), mouse.isSnapped());
      image(gui.getCanvas(), 0, 0);
    }
    keyboard.resetInputFlag();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Playing functions
  ///////
  ////////////////////////////////////////////////////////////////////////////////////




  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Mouse Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     OSC
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // public void oscEvent(OscMessage mess) {
  //   println(mess);
  //   if (mess.checkAddrPattern("/freeliner/decorator")) {
  //     char dec = mess.get(0).stringValue().charAt(0);
  //     char edit = mess.get(1).stringValue().charAt(0);
  //     int value = mess.get(2).intValue();
  //     //renderers.get(charIndex(dec)).numberDispatch(edit, value);
  //     //println(dec+" "+edit+" "+value);
  //   }
  // }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Keyboard Input
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////
  private void printStatus() {
    //println("selectedGroupIndex : "+groupManager.getSelectedGroup()+" editKey : "+editKey+" grid "+viewGrid+" gridSize "+gridSize);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////


}
