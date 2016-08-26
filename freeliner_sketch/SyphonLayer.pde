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

//import codeanticode.syphon.*;

class SyphonLayer extends Layer{
  //  SyphonServer syphonServer;

  public SyphonLayer(PApplet _pa){
    enabled = false;
    //  syphonServer = new SyphonServer(_pa, "alcFreeliner");
    //  enabled = true;
    name = "SyphonLayer";
    id = name;
    description = "Output layer to other software, only on osx, requires SyphonLibrary, and uncoment code in SyphonLayer.pde";
  }

  public PGraphics apply(PGraphics _pg){
    if(!enabled || _pg == null) return _pg;
    //  syphonServer.sendImage(_pg);
    return _pg;
  }
}
