import http.*;

class GUIWebServer implements FreelinerConfig {

  SimpleHTTPServer server;

  public GUIWebServer(PApplet _parent){
    // // create a server
    if(SERVE_HTTP){
      SimpleHTTPServer.useIndexHtml = false;
      server = new SimpleHTTPServer(_parent, HTTPSERVER_PORT);
      // serveAppropriateFiles();
      server.serveAll("",sketchPath()+"/data/webgui");
    }
    else println("HTTP Webserver disabled!");
  }

  public void refreshFiles(){
    if(SERVE_HTTP){
      server.serveAll("",sketchPath()+"/data/webgui");
    }
  }
  // dosent work
  public void serveAppropriateFiles(){
    File _folder = new File(sketchPath()+"/data");
    File[] _files = _folder.listFiles();
    for (int i = 0; i < _files.length; i++) {
      String[] _file = split(_files[i].getName(), ".");
      if(_file.length > 1){
        // println(_files[i].getPath());
        if(_file[1].equals("html")) server.serve(_files[i].getPath());
        else if(_file[1].equals("css")) server.serve(_files[i].getPath());
        else if(_file[1].equals("json")) server.serve(_files[i].getPath());
        else if(_file[1].equals("js")) server.serve(_files[i].getPath());
        else if(_file[1].equals("jpg")) server.serve(_files[i].getPath());
      }
    }
  }
}
