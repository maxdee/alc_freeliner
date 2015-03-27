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
    mouse = new Mouse();
    keyboard = new Keyboard();
    gui = new Gui();

    mouse.inject(groupManager, keyboard);
    keyboard.inject(groupManager, rendererManager, gui, mouse);
    gui.inject(groupManager, mouse);
  }

  public void update() {
    background(0);
    rendererManager.update(groupManager.getGroups());
    image(rendererManager.getCanvas(), 0, 0);
    
    if(gui.doDraw()){
      gui.update();
      image(gui.getCanvas(), 0, 0);
    }
    keyboard.resetInputFlag();
  }

 
  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void printStatus() {
    //println("selectedGroupIndex : "+groupManager.getSelectedGroup()+" editKey : "+editKey+" grid "+viewGrid+" gridSize "+gridSize);
  }
}
