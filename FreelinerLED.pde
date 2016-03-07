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

	String ledMapFile;

	public FreelinerLED(PApplet _pa, String _file){
		super(_pa);
		ledMapFile = "userdata/"+_file;
		// pick your led system
		if(LED_SYSTEM == 1) freeLED = new FastLEDing(_pa, LED_SERIAL_PORT);
		else if(LED_SYSTEM == 2) freeLED = new OctoLEDing(_pa, LED_SERIAL_PORT);
		else freeLED = new FreeLEDing();
		
	  freeLED.parseLEDfile(ledMapFile);
		showLEDmap = true;
	}

	public void reParse(){
		freeLED.parseLEDfile(ledMapFile);
		showLEDmap = true;
	}

	void update(){
		super.update();
	  // parse the graphics
	  freeLED.parseGraphics(getCanvas());
	  // output to whatever
	  freeLED.output();
	  // draw the LED map
	  if(showLEDmap) image(freeLED.getMap(),0,0);
	}

	public void toggleExtraGraphics(){
		showLEDmap = !showLEDmap;
	}

	public FreeLEDing getLEDsystem(){
		return freeLED;
	}

}
