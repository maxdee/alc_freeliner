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
 * RenderList is a class that contains renderer references
 * <p>
 * Add and remove renderers
 * </p>
 *
 * @see Renderer
 */
class RenderList {
  // renderer references
  ArrayList<Renderer> renderers;
  String tags = "";

  public RenderList(){
    //things = new ArrayList();
    renderers = new ArrayList();
  }

  public void updateString(){
    tags = "";
    for(Renderer _rn : renderers){
      tags += _rn.getID();
    }
  }

  public void clear(){
    if(renderers.size() > 0){
      renderers.clear();
      tags = "";
    }
  }

  public void toggle(Renderer _r) {
    if(_r == null) return;
    if(!renderers.remove(_r)) renderers.add(_r);
    updateString();
  }

  public boolean contains(Renderer _r){
    return renderers.contains(_r);
  }

  public ArrayList<Renderer> getAll(){
    if(renderers.size() == 0) return null;
    else return renderers;
  }

  public Renderer getIndex(int _index){
    if(_index < renderers.size()) return renderers.get(_index);
    else return null;
  }

  public String getTags(){
    return tags;
  }
}
