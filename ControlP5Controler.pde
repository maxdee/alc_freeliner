


class ControlP5Controler implements FreelinerConfig{
  FreeLiner freeliner;
  ControlP5 cp5;

  public ControlP5Controler(ControlP5 _cp5, FreeLiner _fl){
    freeliner = _fl;
    cp5 = _cp5;

    Group colorGroup = cp5.addGroup("color")
                          .setPosition(10,100)
                          .setBackgroundHeight(256)
                          .setWidth(256)
                          .setBackgroundColor(0)
                          .setOpen(false)
                          .setLabel("color stuff");
    cp5.addColorWheel("colorWheel" , 10 , 10, 200)
       .setRGB(color(128,0,255))
       .setGroup(colorGroup);

    Group fileIO = cp5.addGroup("fileIO")
                      .setPosition(267, 100)
                      .setBackgroundHeight(256)
                      .setWidth(256)
                      .setBackgroundColor(0)
                      .setOpen(false)
                      .setLabel("filez");

    cp5.addButton("save")
       .setPosition(10,10)
       .setSize(30,10)
       .setGroup(fileIO);

    cp5.addButton("load")
       .setPosition(10,22)
       .setSize(30,10)
       .setGroup(fileIO);
  }

  void controlEvent(ControlEvent _ev){
    if(_ev.isGroup()) _ev.getGroup().bringToFront(); // dosent really work
    else {
      switch(_ev.getController().getName()){
        case("colorWheel"):
          freeliner.processCMD("tp color $ "+int(_ev.getValue()));
          break;
        case("save"):
          freeliner.queueCMD("tp save");
          freeliner.queueCMD("geom save");
          break;
        case("load"):
          freeliner.queueCMD("tp load");
          freeliner.queueCMD("geom load");
          break;
      }
    }
  }

  //groupManager.saveGroups(_fn.getAbsolutePath());
  //freeliner.canvasManager.generateMask();
  //groupManager.loadGroups(_fn.getAbsolutePath());
}
