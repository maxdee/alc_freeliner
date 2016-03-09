


class ControlP5Controler implements FreelinerConfig{
  FreeLiner freeliner;
  ControlP5 cp5;

  final int WIDGET_HEIGHT = 12;
  final int WIDGET_WIDTH = 30;
  final int PADDING = 4;

  public ControlP5Controler(ControlP5 _cp5, FreeLiner _fl){
    freeliner = _fl;
    cp5 = _cp5;


    initFileGroup(PADDING, 40);
    initColorGroup(PADDING*4+WIDGET_WIDTH, 40);
    initShaderGroup(600, 40);

    // nice!!
    cp5.printControllerMap();
  }

  void initFileGroup(int _x, int _y){
    Group fileIO = cp5.addGroup("fileIO")
                      .setPosition(_x, _y)
                      .setBackgroundHeight(128)
                      .setWidth(WIDGET_WIDTH+PADDING*2)
                      .setBackgroundColor(0)
                      .setOpen(true)
                      .setLabel("filez");

    cp5.addButton("save")
       .setPosition(PADDING, PADDING)
       .setSize(WIDGET_WIDTH, WIDGET_HEIGHT)
       .setGroup(fileIO);

    cp5.addButton("load")
       .setPosition(PADDING, WIDGET_HEIGHT+PADDING*2)
       .setSize(WIDGET_WIDTH, WIDGET_HEIGHT)
       .setGroup(fileIO);
  }

  void initShaderGroup(int _x, int _y){
      Group shaderGUI = cp5.addGroup("shaderz")
                           .setPosition(_x,_y)
                           .setBackgroundHeight(256)
                           .setWidth(256)
                           .setBackgroundColor(0)
                           .setOpen(true);

      cp5.addButton("enable")
         //.setLabel("enable shaders")
         .setPosition(PADDING,PADDING)
         .setSize(WIDGET_WIDTH, WIDGET_HEIGHT)
         .setGroup(shaderGUI);

      cp5.addRadioButton("shaderSelect")
         //.setLabel("shaders")
         .setPosition(PADDING, WIDGET_HEIGHT+PADDING*2)
         .setSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
         .setItemsPerRow(4)
         .addItem("0", 0)
         .addItem("1", 1)
         .addItem("2", 2)
         .addItem("3", 3)
         .setGroup(shaderGUI);
    int _faderHeight = 120;
     cp5.addSlider("u1")
        .setPosition(PADDING, 2*WIDGET_HEIGHT+PADDING*3)
        .setSize(WIDGET_HEIGHT,_faderHeight)
        .setRange(0, 1)
        .setGroup(shaderGUI);

    cp5.addSlider("u2")
       .setPosition(2*PADDING+WIDGET_HEIGHT, 2*WIDGET_HEIGHT+PADDING*3)
       .setSize(WIDGET_HEIGHT,_faderHeight)
       .setRange(0, 1)
       .setGroup(shaderGUI);

    cp5.addSlider("u3")
        .setPosition(3*PADDING+WIDGET_HEIGHT*2, 2*WIDGET_HEIGHT+PADDING*3)
        .setSize(WIDGET_HEIGHT,_faderHeight)
        .setRange(0, 1)
        .setGroup(shaderGUI);
    cp5.addSlider("u4")
      .setPosition(4*PADDING+WIDGET_HEIGHT*3, 2*WIDGET_HEIGHT+PADDING*3)
      .setSize(WIDGET_HEIGHT,_faderHeight)
      .setRange(0, 1)
      .setGroup(shaderGUI);
  }



  // ControlP5 group with color things
  void initColorGroup(int _x, int _y){
    int _wheelSize = 200;
    Group colorGroup = cp5.addGroup("color")
                          .setPosition(_x, _y)
                          .setBackgroundHeight(256)
                          .setWidth(_wheelSize+PADDING*2)
                          .setBackgroundColor(0)
                          .setOpen(true)
                          .setLabel("color stuff");
    cp5.addColorWheel("colorWheel" , PADDING , PADDING, _wheelSize)
       .setRGB(color(128,0,255))
       .setGroup(colorGroup);
  }


  void controlEvent(ControlEvent _ev){
      if(_ev.isGroup()){
        println(_ev.getGroup().getName());
        switch(_ev.getGroup().getName()){
          case("shaderSelect"):
            shaderSelect(_ev);
            break;
          }
      }
      else {
        println(_ev.getController().getName());
        switch(_ev.getController().getName()){
          case("colorWheel"):
            freeliner.queueCMD("tp color $ "+int(_ev.getController().getValue()));
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
          case("u1"):
            setUni(0, _ev.getController().getValue());
            break;
          case("u2"):
            setUni(1, _ev.getController().getValue());
            break;
          case("u3"):
            setUni(2, _ev.getController().getValue());
            break;
          case("u4"):
            setUni(3, _ev.getController().getValue());
            break;
          }
      }
  }

  private void shaderSelect(ControlEvent _ev){
    for(int i = 0; i<_ev.getGroup().getArrayValue().length; i++)
      if(_ev.getGroup().getArrayValue()[i] == 1)
        freeliner.queueCMD("post shader "+i);
  }

  private void setUni(int _ind, float _val){
    freeliner.getCanvasManager().getSelectedShader().setUniforms(_ind, _val);
  }

  //groupManager.saveGroups(_fn.getAbsolutePath());
  //freeliner.canvasManager.generateMask();
  //groupManager.loadGroups(_fn.getAbsolutePath());
}


// class FilePicker
