/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

class Enabler extends Mode{
	public Enabler(){}
	public Enabler(int _ind){
		modeIndex = _ind;
		name = "loop";
		description = "always render";
	}

	public boolean enable(RenderableTemplate _rt){
		return true;
	}
}

class Disabler extends Enabler{
	public Disabler(int _ind){
		modeIndex = _ind;
		name = "Disabler";
		description = "Never render";
	}

	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}

// something for triggerable but not from the seq
class Triggerable extends Enabler{
	public Triggerable(int _ind){
		modeIndex = _ind;
		name = "Triggerable";
		description = "only render if triggered";
	}
	public boolean enable(RenderableTemplate _rt){
		return false;
	}
}

class EveryX extends Enabler{
	public EveryX(int _ind){
		modeIndex = _ind;
		name = "EveryX";
		description = "happens every x, set by miscValue";
	}
	public boolean enable(RenderableTemplate _rt){
		int _ha = _rt.getMiscValue();
		if(_ha < 1) _ha = 1;
		return (_rt.getBeatCount()%_ha == 1);
	}
}

class RandomEnabler extends Enabler{
	public RandomEnabler(int _ind){
		modeIndex = _ind;
		name = "RandomEnabler";
		description = "Maybe render";
	}
	public boolean enable(RenderableTemplate _rt){
		if(_rt.getRandomValue()%6 == 1) return true;
		else return false;
	}
}


class SweepingEnabler extends Enabler{
	final float DIST = 200.0;//float(width)/4.0;
	public SweepingEnabler(int _ind){
		modeIndex = _ind;
		name = "SweepingEnabler";
		description = "render per geometry from left to right";
	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x + DIST/2.0;
		float tracker = _rt.getUnitInterval()*float(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}

class SwoopingEnabler extends Enabler{
	final float DIST = 200.0;//float(width)/4.0;
	public SwoopingEnabler(int _ind){
		modeIndex = _ind;
		name = "SwoopingEnabler";
		description = "render per geometry from right to left";
	}
	public boolean enable(RenderableTemplate _rt){
		float pos = _rt.getSegmentGroup().getCenter().x - DIST/2.0;
		float tracker = (-_rt.getUnitInterval()+1)*float(width);
		float diff = pos - tracker;
		if(diff < DIST && diff > 0){
			//println();
			_rt.setUnitInterval(diff/DIST);
			return true;
		}
		else return false;
	}
}

class StrobeEnabler extends Enabler{
	public StrobeEnabler(){}
	public StrobeEnabler(int _ind){
		modeIndex = _ind;
		name = "strobe enable";
		description = "very crunchy render, affected by miscValue";
	}

	public boolean enable(RenderableTemplate _rt){
		return (random(20+_rt.getMiscValue()) < 10);
	}
}

// class MetaEnabler extends Enabler{
// 	final float DIST = 200.0;//float(width)/4.0;
//
// 	public MetaEnabler(){}
// 	public MetaEnabler(int _ind){
// 		modeIndex = _ind;
// 		name = "meta enable";
// 		description = "use other template with meta mode to enable through movement";
// 	}
//
// 	public boolean enable(RenderableTemplate _rt){
// 		float pos = _rt.getSegmentGroup().getCenter().x - DIST/2.0;
// 		float tracker = (-_rt.getUnitInterval()+1)*float(width);
// 		float diff = pos - tracker;
// 		if(diff < DIST && diff > 0){
// 			//println();
// 			_rt.setUnitInterval(diff/DIST);
// 			return true;
// 		}
// 		else return false;
// 	}
// }

//
class MarkerEnabler extends Enabler{
	// final float DIST = 200.0;//float(width)/4.0;
	int warnCount = 0;
	public MarkerEnabler(){
	}
	public MarkerEnabler(int _ind){
		modeIndex = _ind;
		name = "MarkerEnabler";
		description = "Use meta points to enablestuff";
	}
	public boolean enable(RenderableTemplate _rt){
		PositionMarker _marker = null;
		Template linked = _rt.getLinkedTemplate();
		if(linked == null){
			println("[meta-freelining] WARNING : template "+_rt.getTemplateID()+" has no linked template");
			return false;
		}
		for(PositionMarker _m : linked.getMetaPoisitionMarkers()){
			if(_m != null){
				_marker = _m;
			}
		}
		if(_marker == null){
			println("[meta-freelining] WARNING : template "+linked.getTemplateID()+
					" has no position to provide to template "+_rt.getTemplateID()
				);
		}
		else {
			println("yes: "+_marker.pos);
			PVector _center = _rt.getSegmentGroup().getCenter();
			float _s = float(_marker.size);
			float _d = _marker.pos.dist(_center) - _s;
			if(_d < _s && _d > 0){
				_rt.setUnitInterval(_d/_s);
				return true;
			}
		}
		return false;
	}
}
