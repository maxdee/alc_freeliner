/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

 import oscP5.*;
 import netP5.*;
 import websockets.*;

 /**
  * The FreelinerCommunicator handles communication with other programs over various protocols.
  */
class FreelinerCommunicator implements FreelinerConfig{

  CommandProcessor commandProcessor;
  PApplet applet;

  public FreelinerCommunicator(PApplet _pa, CommandProcessor _cp){
    commandProcessor = _cp;
    applet = _pa;
  }

  /**
  * Pass commands to the command processor
  * @param String cmd
  */
  public void receive(String _cmd){
    commandProcessor.queueCMD(_cmd);
  }

  /**
  * Send info to the communicating end.
  * @param String stuff
  */
  public void send(String _s){
    println("Sending : "+_s);
  }

}



/**
 * OSC communicator, send and receive messages with freeliner!
 */
class OSCCommunicator extends FreelinerCommunicator implements OscEventListener{
  // network
  OscP5 oscP5;
  NetAddress toPDpatch;
  OscMessage tickmsg = new OscMessage("/freeliner/tick");

  public OSCCommunicator(PApplet _pa, CommandProcessor _cp){
    super(_pa, _cp);
    oscP5 = new OscP5(applet, OSC_IN_PORT);
    toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);
    oscP5.addListener(this);
  }

  public void send(String _cmd){
    String _adr = "/"+_cmd.replaceAll(" ", "/");
    oscP5.send(new OscMessage(_adr), toPDpatch);
  }

  // oscMessage callback
  public void oscStatus(OscStatus theStatus){
  }

  public void setSyncAddress(String _ip, int _port){
    toPDpatch = new NetAddress(_ip, _port);
  }

  void oscEvent(OscMessage _mess) {
    String _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
    receive(_cmd);
  }

}

/**
 * WebSocket for browser based gui!!
 */
class WebSocketCommunicator extends FreelinerCommunicator{
  WebsocketServer webSock;

  public WebSocketCommunicator(PApplet _pa, CommandProcessor _cp){
    super(_pa, _cp);
    webSock = new WebsocketServer(applet, WEBSOCKET_PORT,"/freeliner");
    //webSock.setNewCallback(this);
  }

  public void send(String _s){
    webSock.sendMessage(_s);
  }

  public void webSocketServerEvent(String _cmd){
    // it
    receive(_cmd);
  }
}
