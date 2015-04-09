/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */


// the data structure shared between a SegmentGroup and Renderer
class RenderEvent {
	int groupId;

	int randomNum;
	int largeRandom;

	int beatCount;
	float timeStamp;

	boolean direction;
	
	public RenderEvent(int _id){
		groupId = _id;
		beatCount = -1;
		//println("newgrd "+_id);
	}

	public void init(float _ts){
		timeStamp = _ts;
		//println(timeStamp);
		beatCount++;
		setRandomNum((int)random(100));
    setLargeRan((int)random(10000));
	}

	public float getLerp(float _lrp){
		if(_lrp > timeStamp) return _lrp - timeStamp;
		else return (_lrp+1)-timeStamp; // _lrp < timestamp
	}

	public void setRandomNum(int _rn){
 		randomNum = _rn;
 	}

 	public void setLargeRan(int _lr){
 		largeRandom = _lr;
 	}

	public int getID(){
		return groupId;
	}

	public int getBeatCount(){
		return beatCount;
	}

 	public int getLargeRan(){
 		return largeRandom;
 	}


	public int getRandomNum(){
		return randomNum;
	}
}