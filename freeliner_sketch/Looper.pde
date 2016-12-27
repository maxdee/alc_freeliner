/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-12-25
 */


class Looper implements FreelinerConfig{
	Synchroniser synchroniser;
	CommandProcessor commandProcessor;
	ArrayList<Loop> loops;
	int currentTimeDiv = 0;
	boolean recording;
	boolean primed;
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
			for(String _str : _toex) commandProcessor.queueCMD(_str);
		}
	}

	public void receive(String _cmd){
		if(primed){
			currentLoop = new Loop(currentTimeDiv, synchroniser.getLerp(currentTimeDiv));
			loops.add(currentLoop);
			primed = false;
			recording = true;
		}
		if(recording){
			float _ha =   synchroniser.getLerp(currentTimeDiv) - currentLoop.getOffset();
			if(_ha < 0.0) _ha += 1.0;
			currentLoop.addCMD(_cmd, _ha);
			if(_ha < lastUnitInterval) recording = false;
			lastUnitInterval = _ha;
		}
	}

	// inject
	public void inject(CommandProcessor _cp){
		commandProcessor = _cp;
	}
	public void inject(Synchroniser _sy){
		synchroniser = _sy;
	}

	public int setTimeDivider(int _v, int _max){
		if(_v == -42) _v = currentTimeDiv;
		currentTimeDiv = numTweaker(_v, currentTimeDiv);
		if(currentTimeDiv >= _max) currentTimeDiv = _max - 1;
		if(currentTimeDiv > 1) primed = true;
		if(currentTimeDiv == 0){
			primed = false;
			if(loops.size() > 0) loops.remove(loops.size()-1);
		}
		return currentTimeDiv;
	}
}


class Loop implements FreelinerConfig{
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
class TimedCommand implements FreelinerConfig{
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
