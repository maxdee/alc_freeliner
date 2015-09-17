/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */

/**
 * Abstract class for brushes.
 * Brushes are PShapes drawn along segments
 */
abstract class Brush {
  // Size to generate brushes
	final int BASE_SIZE = 20;
  final int HALF_SIZE = BASE_SIZE/2;
  // The brush
  PShape brushShape;
  PShape scaledBrush;
  float scaledBrushSize;

  /**
   * Constructor, generates the shape
   */
  Brush(){
    brushShape = generateBrush();
    scaledBrush = brushShape;
    scaledBrushSize = BASE_SIZE;
  }

  /**
   * Needs to implement the making of the brush
   * The PShape has a center of 0,0 and points upwards.
   * @return PShape of the brush
   */
  abstract public PShape generateBrush();

  /**
   * Brush accessor
   * Makes a copy of the brush scaled by scalar.
   * @param RenderableTemplate for brush size scaling
   * @return PShape of the brush
   */
  public PShape getShape(RenderableTemplate _rt){
    // only clone if the size changed
    if(abs(_rt.getScaledBrushSize() - scaledBrushSize) > 0.5){
      scaledBrushSize = _rt.getScaledBrushSize();
      scaledBrush = cloneShape(brushShape, scaledBrushSize/BASE_SIZE, new PVector(0,0));
    }
  	return scaledBrush;
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Subclasses, kept in the same file because too many files.
///////
////////////////////////////////////////////////////////////////////////////////////

/**
 * A brush that is just a point.
 */
class PointBrush extends Brush {
  public PointBrush(){
  }

	public PShape generateBrush(){
		PShape shp = createShape();
		shp.beginShape(POINTS);
    shp.vertex(0,0);
		shp.endShape();
		return shp;
	}
}

/**
 * A brush that is a perpendicular line.
 */
class LineBrush extends Brush {
  public LineBrush(){

  }
	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

/**
 * Chevron brush >>>>
 */
class ChevronBrush extends Brush {
  public ChevronBrush(){

  }
	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(0, HALF_SIZE);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

/**
 * Square shaped brush
 */
class SquareBrush extends Brush {
  public SquareBrush(){

  }
	public PShape generateBrush(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(0, HALF_SIZE);
    shp.vertex(HALF_SIZE, 0);
    shp.vertex(0, -HALF_SIZE);
    shp.vertex(-HALF_SIZE, 0);
    shp.endShape(CLOSE);
    return shp;
	}
}

/**
 * Custom brush, a brush that is the segments of group.
 */
class CustomBrush extends Brush {
  /**
   * Constructor will generate a null shape.
   */
  public CustomBrush(){
  }

  /**
   * Takes the sourceShape and makes the brush
   */
  public PShape generateBrush(){
    scaledBrushSize = 1;
    return null;
  }

  public PShape getShape(RenderableTemplate _rt){

    if(abs(_rt.getScaledBrushSize() - this.scaledBrushSize) > 0.5 || scaledBrush == null){
      //println(_rt.getScaledBrushSize() - scaledBrushSize);
      scaledBrushSize = _rt.getScaledBrushSize();
      scaledBrush = cloneShape( _rt.getCustomShape(), scaledBrushSize/BASE_SIZE, new PVector(0,0));
    }
    if(scaledBrush == null){
      PShape empty = createShape();
      empty.beginShape();
      empty.endShape(CLOSE);
      return empty;
    }
    return scaledBrush;
  }
}


/**
 * Circle shaped brush
 */
class CircleBrush extends Brush {
  public CircleBrush(){

  }
  public PShape generateBrush(){
    PShape shp =  createShape(ELLIPSE, -HALF_SIZE, -HALF_SIZE, BASE_SIZE, BASE_SIZE);
    return shp;
  }
}

/**
 * Triangle shaped brush
 */
class TriangleBrush extends Brush {
  public TriangleBrush(){

  }
  public PShape generateBrush(){
    float hght = sqrt(sq(BASE_SIZE)+pow(HALF_SIZE,2));
    PShape shp = createShape(TRIANGLE, -HALF_SIZE, 0,
                                       HALF_SIZE, 0,
                                       0, BASE_SIZE*pow(3, 1/3.0)/2);
    return shp;
  }
}


/**
 * X shaped brush
 */
class XBrush extends Brush {
  public XBrush(){

  }
  public PShape generateBrush(){
    PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, -HALF_SIZE);
    shp.vertex(HALF_SIZE, HALF_SIZE);
    shp.vertex(-HALF_SIZE, HALF_SIZE);
    shp.vertex(HALF_SIZE, -HALF_SIZE);
    shp.endShape();
    return shp;
  }
}

/**
 * Sprinkles
 */
class SprinkleBrush extends Brush {
  public SprinkleBrush(){}
  // dosent apply here...
  public PShape generateBrush(){
    PShape shp = createShape();
    shp.beginShape(LINES);
    shp.vertex(-HALF_SIZE, -HALF_SIZE);
    shp.vertex(HALF_SIZE, HALF_SIZE);
    shp.endShape();
    return shp;
  }

  private PShape generateSprinkles(float _sz){
    PShape shp = createShape();
    shp.beginShape(POINTS);
    PVector pnt;
    PVector cent = new PVector(0,0);
    float half = _sz/2.0;
    for(int i = 0; i < _sz*3; i++){
      pnt = new PVector(random(_sz) - (half), random(_sz) - (half));
      if(cent.dist(pnt) < half) shp.vertex(pnt.x, pnt.y);
    }
    shp.endShape();
    return shp;
  }

  public PShape getShape(RenderableTemplate _rt){
    return generateSprinkles(_rt.getScaledBrushSize());
  }
}
