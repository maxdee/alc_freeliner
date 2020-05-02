/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-12-25
 */


class Looper /**tagtagtag**/{
	Synchroniser synchroniser;
	CommandProcessor commandProcessor;
	ArrayList<Loop> loops;
	int currentTimeDiv = 0;
	boolean recording;
	boolean lock = false;
	boolean primed;
	boolean overdub = false;
	float lastUnitInterval;
	Loop currentLoop;

	public Looper(){
		loops = new ArrayList<Loop>();
	}

	public void update(){
		float _time = synchroniser.getLerp(currentTimeDiv);
		ArrayList<String> _toex = new ArrayList<String>();
		if(loops.size() > 0){
			for(Loop _l : loops){
				_toex.addAll(_l.update(synchroniser.getLerp(_l.getDiv())));
			}
		}
		if(_toex.size() > 0){
			lock = true;
			for(String _str : _toex) commandProcessor.processCMD(_str);
			lock = false;
		}
		if(recording && currentLoop != null && !overdub){
			float _ha = synchroniser.getLerp(currentTimeDiv);
			_ha -= currentLoop.getOffset();
			if(_ha < 0.0) _ha += 1.0;
			if(_ha < lastUnitInterval) {
				recording = false;
				println("stopped loop");
			}
			lastUnitInterval = _ha;
		}
	}

	public void receive(String _cmd){
		// println(_cmd+"  "+lock+"   "+recording);
		if(lock) return;
		if(primed){
			currentLoop = new Loop(currentTimeDiv, synchroniser.getLerp(currentTimeDiv));
			loops.add(currentLoop);
			primed = false;
			recording = true;
		}
		if(recording){
			currentLoop.addCMD(_cmd, synchroniser.getLerp(currentTimeDiv));
		}
	}

	// inject
	public void inject(CommandProcessor _cp){
		commandProcessor = _cp;
	}
	public void inject(Synchroniser _sy){
		synchroniser = _sy;
	}

	public String setTimeDivider(int _v, int _max){
		if(_v == 0){
			primed = false;
			if(recording && overdub) {
				recording = false;
				return "stopped";
			}
			else if(loops.size() > 0) {
				loops.remove(loops.size()-1);
				return "delete";
			}
		}
		if(_v == -42 || _v == -3) {
			primed = false;
			return "stdb";
		}
		currentTimeDiv = numTweaker(_v, currentTimeDiv);
		if(currentTimeDiv >= _max) currentTimeDiv = _max - 1;
		if(currentTimeDiv >= 1) {
			primed = true;
			return "ready "+currentTimeDiv;
		}
		return "ready "+currentTimeDiv;
	}
}


class Loop /**tagtagtag**/{
	ArrayList<TimedCommand> commands;
	ArrayList<TimedCommand> queue;

	int timeDivider;
	float timeOffset;
	float lastUnit;

	public Loop(int _t, float _f){
		timeDivider = _t;
		timeOffset = _f;
		commands = new ArrayList<TimedCommand>();
		queue = new ArrayList<TimedCommand>();

		println("new Loop "+this);
	}

	public void addCMD(String _cmd, float _t){
		commands.add(new TimedCommand(_cmd, _t));
		println("adding "+_cmd);
	}

	public ArrayList<String> update(float _time){
		if(_time < lastUnit) reload();
		lastUnit = _time;
		ArrayList<String> _out = new ArrayList<String>();
		for(TimedCommand _cmd : commands){
			if(queue.contains(_cmd) && _cmd.getStamp() < _time){
				_out.add(_cmd.getCMD());
				queue.remove(_cmd);
			}
		}
		return _out;
	}

	private void reload(){
		if(commands.size() > 0){
			queue.addAll(commands);
		}
	}
	public int getDiv(){
		return timeDivider;
	}
	public float getOffset(){
		return timeOffset;
	}
}

// for now essentialy a time tagged cmd string
class TimedCommand /**tagtagtag**/{
	float timeStamp;
	String commandString;
	public TimedCommand(String _cmd, float _t){
		timeStamp = _t;
		commandString = _cmd;
	}
	public String getCMD(){
		return commandString;
	}
	public float getStamp(){
		return timeStamp;
	}
}
