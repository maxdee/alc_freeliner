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


/**
 * RenderList is a class that contains renderer tags (capital chars)
 * <p>
 * Add and remove renderers
 * </p>
 *
 * @see Renderer
 */

class RenderList{
  ArrayList<CharObject> tags;
  int tagsCount = 0;

/**
 * Create an new RenderList
 */
	public RenderList(){
		tags = new ArrayList();
	}


/**
 * Toggle a renderer tag from the list
 * @param  renderer tag char (capital letter)
 */
  public void toggle(char _tag) {
    if(has(_tag)){
      for(int i = 0; i < tagsCount; i++){
        if(tags.get(i).get() == _tag){
          tags.remove(i);
          tagsCount--;
        }
      }
    }
    else {
      tags.add(new CharObject(_tag));
      tagsCount++;
    }
  }


/**
 * Check if list has tag
 * @param  renderer tag char (capital letter)
 */
  public boolean has(char c){
  	if(tagsCount > 0){
      for(int i = 0; i < tagsCount; i++){
        if(tags.get(i).get() == c){
          return true;
        }
      }
    }
    return false;
  }

/**
 * Clear the list
 */
  public void clear(){
  	tags.clear();
    tagsCount = 0;
  }

/**
 * Returns a string of the list
 * @return string
 */
  public final String getString(){
  	String s = " ";
  	if(tagsCount > 0){
      for(int i = 0; i < tagsCount; i++){
        s+= tags.get(i).get();
      }
    }
    return s;
  }
  
/**
 * Returns first tag
 * @return char
 */
  public final char getFirst(){
    if(tagsCount > 0) return tags.get(0).get();
    else return '_';
  }
}



/**
 * A char class to use chars in arrayLists
 * @see RenderList
 */
class CharObject{
	char chr;

	public CharObject(char _c){
		chr = _c;
	}

  public void set(char _c){
    chr = _c;
  }

	public char get(){
		return chr;
	}
}


