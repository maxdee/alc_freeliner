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
 * TemplateList is a class that contains TweakableTemplate references
 * <p>
 * Add and remove TweakableTemplates
 * </p>
 *
 * @see TweakableTemplate
 */
class TemplateList {
  // TweakableTemplate references
  ArrayList<TweakableTemplate> templates;
  String tags = "";

  public TemplateList(){
    templates = new ArrayList();
  }

  public void updateString(){
    tags = "";
    for(TweakableTemplate _ten : templates){
      tags += _ten.getTemplateID();
    }
  }

  public void clear(){
    if(!templates.isEmpty()){
      templates.clear();
      tags = "";
    }
  }

  public void copy(TemplateList _tl){
    if(_tl == this) return;
    clear();
    if(_tl == null) return;
    if(_tl.getAll() == null) return;
    if(!_tl.getAll().isEmpty())
      for(TweakableTemplate tt : _tl.getAll())
        toggle(tt);
  }

  public void toggle(TweakableTemplate _te) {
    if(_te == null) return;
    if(!templates.remove(_te)) templates.add(_te);
    updateString();
  }

  public boolean contains(TweakableTemplate _te){
    return templates.contains(_te);
  }

  public ArrayList<TweakableTemplate> getAll(){
    if(templates.size() == 0) return null;
    else return templates;
  }

  public TweakableTemplate getIndex(int _index){
    if(_index < templates.size()) return templates.get(_index);
    else return null;
  }

  public String getTags(){
    return tags;
  }
}
