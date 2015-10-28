/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */

class OSClistener implements OscEventListener{

  FreeLiner freeliner;

  public OSClistener(PApplet _pa, FreeLiner _fl){
    // osc setup
    freeliner = _fl;

  }

  public void oscStatus(OscStatus theStatus){}

  void oscEvent(OscMessage theOscMessage) {  /* check if theOscMessage has the address pattern we are looking for. */
    // tweak parameters
    if(theOscMessage.checkAddrPattern("/freeliner/tweak")) {
      /* check if the typetag is the right one. */
      if(theOscMessage.checkTypetag("ssi")) {
        /* parse theOscMessage and extract the values from the osc message arguments. */
        String tags = theOscMessage.get(0).stringValue();
        char kay = theOscMessage.get(1).stringValue().charAt(0);
        int val = theOscMessage.get(2).intValue();
        freeliner.keyboard.oscDistribute(tags, kay, val);
      }
    }
    // trigger animations
    else if(theOscMessage.checkAddrPattern("/freeliner/trigger")) {
      /* check if the typetag is the right one. */
      if(theOscMessage.checkTypetag("s")) {
        String tags = theOscMessage.get(0).stringValue();
        freeliner.templateManager.oscTrigger(tags, -1);
      }
      if(theOscMessage.checkTypetag("si")) {
        String tags = theOscMessage.get(0).stringValue();
        freeliner.templateManager.oscTrigger(tags, theOscMessage.get(1).intValue());
      }
    }
    // enable diable and set intencity of trails
    else if(theOscMessage.checkAddrPattern("/freeliner/trails")) {
      /* check if the typetag is the right one. */
      if(theOscMessage.checkTypetag("i")) {
        /* parse theOscMessage and extract the values from the osc message arguments. */
        int tval = theOscMessage.get(0).intValue();
        freeliner.oscSetTrails(tval);
      }
    }
    // change the colors in the userPallette
    else if(theOscMessage.checkAddrPattern("/freeliner/pallette")){
      if(theOscMessage.checkTypetag("iiii")){
        int _index = theOscMessage.get(0).intValue();
        int _r = theOscMessage.get(1).intValue();
        int _g = theOscMessage.get(2).intValue();
        int _b = theOscMessage.get(3).intValue();
        setUserPallette(_index, color(_r, _g, _b));
      }
    }
    // set the custom color
    else if(theOscMessage.checkAddrPattern("/freeliner/color")) {
      /* check if the typetag is the right one. */
      if(theOscMessage.checkTypetag("siiii")) {
        /* parse theOscMessage and extract the values from the osc message arguments. */
        String tags = theOscMessage.get(0).stringValue();
        color col = color(
          theOscMessage.get(1).intValue(),
          theOscMessage.get(2).intValue(),
          theOscMessage.get(3).intValue(),
          theOscMessage.get(4).intValue());
        freeliner.templateManager.setCustomColor(tags, col);
      }
    }
    else if(theOscMessage.checkAddrPattern("/freeliner/text")){
      /* check if the typetag is the right one. */
      if(theOscMessage.checkTypetag("iis")) {
        /* parse theOscMessage and extract the values from the osc message arguments. */
        int grp = theOscMessage.get(0).intValue();
        int seg = theOscMessage.get(1).intValue();
        String txt = theOscMessage.get(2).stringValue();
        freeliner.groupManager.setText(grp, seg, txt);
      }
    }
    else if(theOscMessage.checkAddrPattern("/freeliner/rawkey")){
      if(theOscMessage.checkTypetag("sii")) {
        char k = theOscMessage.get(0).stringValue().charAt(0);
        int kc = theOscMessage.get(1).intValue();
        int rel = theOscMessage.get(2).intValue();
        if(rel == 1) freeliner.getKeyboard().processKey(k, kc);
        else if(rel == 0) freeliner.getKeyboard().processRelease(k, kc);
      }
    }
  }

  void setUserPallette(int _i, color _c){
    if(_i >= 0 && _i < PALLETTE_COUNT) userPallet[_i] = _c;
  }
}
