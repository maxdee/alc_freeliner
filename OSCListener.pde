/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class OSClistener implements OscEventListener{

  FreeLiner freeliner;
  CommandProcessor commandProcessor;

  public OSClistener(PApplet _pa, FreeLiner _fl){
    // osc setup
    freeliner = _fl;
  }

  public void inject(CommandProcessor _cp){
    commandProcessor = _cp;
  }

  public void oscStatus(OscStatus theStatus){}

  // new OSC messages = /freeliner/tw/A/q 3 ???
  void oscEvent(OscMessage _mess) {  /* check if theOscMessage has the address pattern we are looking for. */
    commandProcessor.processCMD(split(_mess.addrPattern().replaceFirst("/", ""), '/'));
  }
}
