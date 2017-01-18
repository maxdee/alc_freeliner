/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-10-17
 */


import java.io.*;
import java.net.*;
import processing.serial.*;

// A class to send byte arrays to lighting stuff.

public class ByteSender implements FreelinerConfig{

  public ByteSender(){

  }

  public void connect(String _port, int _baud){}
  public void connect(String _port){}
  public void disconnect(){}
  public void sendData(byte[] _data){}
  public int getCount(){return 0;}
}

public class SerialSender extends ByteSender{
  PApplet applet;
  Serial port;
  // byte[] packet;
  byte[] header = {42};
  int channelCount;

  public SerialSender(PApplet _ap){
    applet = _ap;
  }

  /**
 * Connect to a serial port
 * @param String portPath
 */
  public void connect(String _port, int _baud){
    // connect to port
    try{
      port = new Serial(applet, _port, _baud);
      delay(100);
      channelCount = 0;
      for(int i = 0; i < 10; i++){
        port.write('?');
        delay(300);
        try{
          channelCount = Integer.parseInt(getMessage());
          println("Connected to "+_port+" with "+channelCount+" channels");
          break;
        } catch (Exception e){
          println("Could not get channel count.");
        }
      }
    }
    catch(Exception e){
      println(_port+" does not seem to work...");
      // exit();
    }
  }

  public int getCount(){
    return channelCount;
  }

  public void disconnect(){
    if(port != null) port.stop();
  }
  // gets message from the serialPort
  public String getMessage(){
    String buff = "";
    while(port.available() != 0) buff += char(port.read());
    return buff;
  }

  public void sendData(byte[] _data){
    port.write(header);
    port.write(_data);
  }
}


// send udp packets of variable length
public class ArtNetSender extends ByteSender{

  String host;
  int port = 6454;
  InetAddress address;
  DatagramSocket dsocket;

  public ArtNetSender(){}

  public void connect(String _adr){
    host = _adr;
    try{
      address = InetAddress.getByName(host);
      dsocket = new DatagramSocket();
    }
    catch(Exception e){
      println("artnet could not connect");
      exit();
    }
  }

  public void sendData(byte[] _data){
    byte[][] _universes = splitUniverses(_data);
    for(int i = 0; i < _universes.length; i++){
      sendUDP(makeArtNetPacket(_universes[i], i));
    }
  }


  public byte[][] splitUniverses(byte[] _data){

    int _universeCount = _data.length/510;
    int _ind = 0;
    byte[][] _universes = new byte[_universeCount][512];
    for(int u = 0; u < _universeCount; u++){ // temporary_plz_undo
      for(int i = 1; i < 510; i++){
        _ind = u*510+i;
        if(_ind < _data.length) _universes[u][i] = _data[_ind];
        else _universes[u][i] = 0;
      }
    }
    return _universes;
  }


  public byte[] makeArtNetPacket(byte[] _data, int _uni){
    //   boolean _drop = false;
    //   for(int i = 0; i < _data.length; i++){
    //       if(_data[i] != 0) _drop = true;
    //   }
    //   if(_drop) return null;
    long _size = _data.length;
    byte _packet[] = new byte[_data.length+18];
    _packet[0] = byte('A');
    _packet[1] = byte('r');
    _packet[2] = byte('t');
    _packet[3] = byte('-');
    _packet[4] = byte('N');
    _packet[5] = byte('e');
    _packet[6] = byte('t');
    _packet[7] = 0; //just a zero
    _packet[8] = 0; //opcode
    _packet[9] = 80; //opcode
    _packet[10] = 0; //protocol version
    _packet[11] = 14; //protocol version
    _packet[12] = 0; //sequence
    _packet[13] = 0; //physical (purely informative)
    _packet[14] = (byte)(_uni%16); //Universe lsb? http://www.madmapper.com/universe-decimal-to-artnet-pathport/
    _packet[15] = (byte)(_uni/16); //Universe msb?
    _packet[16] = (byte)((_size & 0xFF00) >> 8); //length msb
    _packet[17] = (byte)(_size & 0xFF); //length lsb

    for(int i = 0; i < _size; i++){
      _packet[i+18] = _data[i];
    }
    return _packet;
  }

  public void sendUDP(byte[] _data) {
      if(_data == null) return;
    DatagramPacket packet = new DatagramPacket(_data, _data.length,
        address, port);
    try{
      dsocket.send(packet);
    }
    catch(Exception e){
      println("failed to send");
      connect(host);
    }
  }
}
