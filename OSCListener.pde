/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class OSClistener implements OscEventListener{

  CommandProcessor commandProcessor;

  public OSClistener(){}

  public void inject(CommandProcessor _cp){
    commandProcessor = _cp;
  }

  public void oscStatus(OscStatus theStatus){}

  // new OSC messages = /freeliner/tw/A/q 3 ???
  void oscEvent(OscMessage _mess) {  /* check if theOscMessage has the address pattern we are looking for. */
    String _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
    commandProcessor.queueCMD(_cmd);//processCMD(_cmd);
    //commandProcessor.processCMD(_cmd);
  }
}
