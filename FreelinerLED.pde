/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2015-07-22
 */


class FreelinerLED extends FreeLiner{
	// enable LEDsystem
	final boolean LED_MODE = false;
	FreeLEDing freeLED;
	boolean showLEDmap = true;

	public FreelinerLED(PApplet _pa, String _file){
		super(_pa);
		// init the subclass of freeLEDing
	  //freeLED = new FreeLEDing();
	  freeLED = new OctoLEDing(_pa, "/dev/ttyACM0");//rfcomm0");
		String portName = Serial.list()[0];
	  //freeLED = new FastLEDing(_pa, "/dev/ttyACM0");
	  // load a ledmap file
	  freeLED.parseLEDfile("userdata/"+_file);
		showLEDmap = true;
	}

	public void reParse(){
		freeLED.parseLEDfile("userdata/nye.xml");
		showLEDmap = true;
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
	  if(showLEDmap) image(freeLED.getMap(),0,0);
		//
	}

	public void toggleExtraGraphics(){
		showLEDmap = !showLEDmap;
	}
	public FreeLEDing getLEDsystem(){
		return freeLED;
	}
}
