/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2015-07-22
 */


class FreelinerLED extends FreeLiner{
	// enable LEDsystem
	final boolean LED_MODE = false;
	FreeLEDing freeLED;

	public FreelinerLED(PApplet _pa, String _file){
		super(_pa);
		// init the subclass of freeLEDing
	  freeLED = new FreeLEDing();
	  //freeLED = new OctoLEDing(_pa, "/dev/tty0");
	  //freeLED = new FastLEDing(_pa, "/dev/ttyACM0");
	  // load a ledmap file
	  freeLED.parseLEDfile("userdata/"+_file);
	}

	void update(){
		super.update();
	  // parse the graphics
	  freeLED.parseGraphics(getCanvas());
	  // draw the LED statuses
		//freeLED.drawLEDstatus(_pg);
	  // output to whatever
	  freeLED.output();
	  // draw the LED map
	  image(freeLED.getMap(),0,0);
		//
	}
}
