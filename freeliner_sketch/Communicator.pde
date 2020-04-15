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
class FreelinerCommunicator implements FreelinerConfig {

    CommandProcessor commandProcessor;
    PApplet applet;

    public FreelinerCommunicator(PApplet _pa, CommandProcessor _cp) {
        commandProcessor = _cp;
        applet = _pa;
    }

    /**
     * Pass commands to the command processor
     * @param String cmd
     */
    public void receive(String _cmd) {
        commandProcessor.queueCMD(_cmd);
    }

    /**
     * Send info to the communicating end.
     * @param String stuff
     */
    public void send(String _s) {
        println("Sending : "+_s);
    }
}



/**
 * OSC communicator, send and receive messages with freeliner!
 */
class OSCCommunicator extends FreelinerCommunicator implements OscEventListener {
    // network
    OscP5 oscP5;
    NetAddress toPDpatch;
    OscMessage tickmsg = new OscMessage("/freeliner/tick");

    public OSCCommunicator(PApplet _pa, CommandProcessor _cp) {
        super(_pa, _cp);
    }

    public void send(String _cmd) {

    }

    // oscMessage callback
    public void oscStatus(OscStatus theStatus) {
    }

    public void setSyncAddress(String _ip, int _port) {
        projectConfig.oscOutPort = _port;
        projectConfig.oscOutIP = _ip;
        updateConnection();
        // toPDpatch = new NetAddress(_ip, _port);
    }
    public void updateConnection(){

    }

    void oscEvent(OscMessage _mess) {
        String _cmd = "";
        // check if it's a proper osc message. if it has a typetag, it is.
        // in that case, the value will be the last part of the command
        if (_mess.checkTypetag("f")) {
            _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
            _cmd = _cmd + " " + _mess.get(0).floatValue();
        } else if (_mess.checkTypetag("i")) {
            _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
            _cmd = _cmd + " " + _mess.get(0).intValue();
        } else if (_mess.checkTypetag("s")) {
            _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
            _cmd = _cmd + " " + _mess.get(0).stringValue();
            // otherwise, it's a proprietary freeliner osc message.
            // hence, there is no value and the addrPattern is the whole command
        } else if (_mess.checkTypetag("")) {
            _cmd = _mess.addrPattern().replaceAll("/", " ").replaceFirst(" ", "");
        }
        // println(_cmd);
        // proceed to process the command
        receive(_cmd);
    }
}


class UDPOSCCommunicator extends OSCCommunicator {
    public UDPOSCCommunicator(PApplet _pa, CommandProcessor _cp) {
        super(_pa, _cp);
        updateConnection();
    }
    public void updateConnection(){
        oscP5 = new OscP5(applet, projectConfig.oscInPort);
        toPDpatch = new NetAddress(projectConfig.oscOutIP, projectConfig.oscOutPort);
        oscP5.addListener(this);
    }
    public void send(String _cmd) {
        String _adr = "/"+_cmd.replaceAll(" ", "/");
        oscP5.send(new OscMessage(_adr), toPDpatch);
    }
}


class TCPOSCCommunicator extends OSCCommunicator {
    OscP5 oscP5tcpClient;
    public TCPOSCCommunicator(PApplet _pa, CommandProcessor _cp) {
        super(_pa, _cp);
        updateConnection();
    }

    public void updateConnection(){
        oscP5 = new OscP5(applet, projectConfig.oscInPort, OscP5.TCP);
        oscP5tcpClient = new OscP5(applet,
                                   projectConfig.oscOutIP,
                                   projectConfig.oscOutPort,
                                   OscP5.TCP);
        oscP5.addListener(this);
    }

    public void send(String _cmd) {
        String _adr = "/"+_cmd.replaceAll(" ", "/");
        oscP5tcpClient.send(new OscMessage(_adr));
    }
}

/**
 * WebSocket for browser based gui!!
 */
class WebSocketCommunicator extends FreelinerCommunicator {
    WebsocketServer webSock;

    public WebSocketCommunicator(PApplet _pa, CommandProcessor _cp) {
        super(_pa, _cp);
        webSock = new WebsocketServer(applet,
                                      projectConfig.websocketPort,
                                      "/freeliner");
        //webSock.setNewCallback(this);
    }

    public void send(String _s) {
        webSock.sendMessage(_s);
    }

    public void webSocketServerEvent(String _cmd) {
        // it
        receive(_cmd);
    }
}
