/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-08-23
 */

/**
 * Syphon output!
 * To enable you must remove all the double slashes //
 */

// import spout.*;

class SpoutLayer extends Layer{
  //  Spout spout;

  public SpoutLayer(PApplet _pa){
    enabled = false;
    //  spout = new Spout(_pa);
    //  enabled = true;
    name = "SpoutLayer";
    id = name;
    description = "Output layer to other software, only on win, requires SpoutLibrary, and uncoment code in SpoutLayer.pde";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled) return _pg;
    //    spout.sendTexture(_pg);
    return _pg;
  }
}
