/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



/**
 * Mode is a abstract class for colorModes, renderModes...
 * Added to facilitate auto documentation.
 *
 */



abstract class Mode implements FreelinerConfig{
  String name = "mode";
  String description = "abstract";

  public Mode(){}


  public void setName(String _name){
    name = _name;
  }

  public void setDescrition(String _d){
    description = _d;
  }


  public String getName(){
    return name;
  }

  public String getDescription(){
    return description;
  }
}
