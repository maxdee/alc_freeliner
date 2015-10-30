/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.3
 * @since     2014-12-01
 */

class XMLTemplate extends Template{
  public XMLTemplate(){

  }

  public XML getXML(){
    XML _tpXML = new XML("template");
    _tpXML.setInt("renderMode", renderMode);
    _tpXML.setInt("segmentMode", segmentMode);
    _tpXML.setInt("animationMode", animationMode);
    _tpXML.setInt("strokeMode", strokeMode);
    _tpXML.setInt("fillMode", fillMode);
    _tpXML.setInt("strokeAlpha", strokeAlpha);
    _tpXML.setInt("fillAlpha", fillAlpha);
    _tpXML.setInt("rotationMode", rotationMode);
    _tpXML.setInt("easingMode", easingMode);
    _tpXML.setInt("reverseMode", reverseMode);
    _tpXML.setInt("repetitionMode", repetitionMode);
    _tpXML.setInt("repetitionCount", repetitionCount);
    _tpXML.setInt("beatDivider", beatDivider);
    _tpXML.setInt("strokeWidth", strokeWidth);
    _tpXML.setInt("brushSize", brushSize);
    _tpXML.setInt("brushMode", brushMode);
    _tpXML.setInt("enablerMode", enablerMode);
    //String _name = str(renderMode)+str(segmentMode)+str(animationMode)+str(strokeMode)+str(fillMode)
    //_tpXML.setString("name", _name);
    return _tpXML;
  }

  public void loadXML(XML _tpXML){
    renderMode = _tpXML.getInt("renderMode");
    segmentMode = _tpXML.getInt("segmentMode");
    animationMode = _tpXML.getInt("animationMode");
    strokeMode = _tpXML.getInt("strokeMode");
    fillMode = _tpXML.getInt("fillMode");
    strokeAlpha = _tpXML.getInt("strokeAlpha");
    fillAlpha = _tpXML.getInt("fillAlpha");
    rotationMode = _tpXML.getInt("rotationMode");
    easingMode = _tpXML.getInt("easingMode");
    reverseMode = _tpXML.getInt("reverseMode");
    repetitionMode = _tpXML.getInt("repetitionMode");
    repetitionCount = _tpXML.getInt("repetitionCount");
    beatDivider = _tpXML.getInt("beatDivider");
    strokeWidth = _tpXML.getInt("strokeWidth");
    brushSize = _tpXML.getInt("brushSize");
    brushMode = _tpXML.getInt("brushMode");
    enablerMode = _tpXML.getInt("enablerMode");
  }
}
