


class ControlP5Controler implements FreelinerConfig{
  FreeLiner freeliner;
  ControlP5 cp5;

  public ControlP5Controler(ControlP5 _cp5, FreeLiner _fl){
    freeliner = _fl;
    cp5 = _cp5;

    Group colorGroup = cp5.addGroup("color")
                          .setPosition(10,100)
                          .setBackgroundHeight(256)
                          .setWidth(200)
                          .setBackgroundColor(0)
                          .setOpen(false)
                          .setLabel("color stuff");
    cp5.addColorWheel("colorWheel" , 10 , 10, 200)
       .setRGB(color(128,0,255))
       .setGroup(colorGroup);

    Group fileIO = cp5.addGroup("fileIO")
                      .setPosition(214, 100)
                      .setBackgroundHeight(128)
                      .setWidth(128)
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

    Group shaderGUI = cp5.addGroup("shaderz")
                         .setPosition(267+128+4,100)
                         .setBackgroundHeight(256)
                         .setWidth(256)
                         .setBackgroundColor(0)
                         .setOpen(false);

    cp5.addButton("enable")
       .setPosition(10,10)
       .setSize(30,10)
       .setGroup(shaderGUI);

   cp5.addRadioButton("shaderSelect")
       .setPosition(10,22)
       .setSize(10,10)
       .setItemsPerRow(4)
       .addItem("0",0)
       .addItem("1",1)
       .addItem("2",2)
       .addItem("3",3)
       .setGroup(shaderGUI);;

  }

  void controlEvent(ControlEvent _ev){
    if(_ev.isGroup()) _ev.getGroup().bringToFront(); // dosent really work
    else {
      println(_ev.getController().getName());
      switch(_ev.getController().getName()){
        case("colorWheel"):
          freeliner.queueCMD("tp color $ "+int(_ev.getValue()));
          break;
        case("save"):
          freeliner.queueCMD("tp save");
          freeliner.queueCMD("geom save");
          break;
        case("load"):
          freeliner.queueCMD("tp load");
          freeliner.queueCMD("geom load");
          break;
        case("enable"):
          freeliner.queueCMD("post shader -3");
          break;
        case("shaderSelect"):
          freeliner.queueCMD("post shader "+int(_ev.getValue()));
          break;
      }
    }
  }

  //groupManager.saveGroups(_fn.getAbsolutePath());
  //freeliner.canvasManager.generateMask();
  //groupManager.loadGroups(_fn.getAbsolutePath());
}


// class FilePicker
