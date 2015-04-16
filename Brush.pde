// Basic class to make shape subclasses
abstract class Brush {
	final int BASE_SIZE = 20; // 20 pixel base size
  final int HALF_SIZE = BASE_SIZE/2; 
  PShape brushShape;

  Brush(){
    brushShape = generateShape();
  }

  // need to implement what kind of shape, 
  //shapes have a center of 0,0 and point upwards.
  abstract public PShape generateShape();

  public PShape getShape(float _sz){
  	return cloneShape(brushShape, _sz/BASE_SIZE, new PVector(0,0));
  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     Subclasses
///////
////////////////////////////////////////////////////////////////////////////////////

class PointBrush extends Brush {
  public PointBrush(){
  }

	public PShape generateShape(){
		PShape shp = createShape();
		shp.beginShape(POINTS);
		shp.vertex(0,0);
		shp.endShape();
		return shp;
	}
}

class LineBrush extends Brush {
  public LineBrush(){
    
  }
	public PShape generateShape(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

class ChevronBrush extends Brush {
  public ChevronBrush(){
    
  }
	public PShape generateShape(){
		PShape shp = createShape();
    shp.beginShape();
    shp.vertex(-HALF_SIZE, 0);
    shp.vertex(0, HALF_SIZE);
    shp.vertex(HALF_SIZE, 0);
    shp.endShape();
    return shp;
	}
}

class SquareBrush extends Brush {
  public SquareBrush(){
    
  }
	public PShape generateShape(){
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

class CustomBrush extends Brush {
  PShape sourceShape;

  public CustomBrush(){
    sourceShape = null;
  }

  public PShape generateShape(){
    if(sourceShape == null) return null;
    int vertexCount = sourceShape.getVertexCount();
    if(vertexCount > 0){
      int maxX = 0;
      float x = 0.0001;
      // check how wide the shape is
      for(int i = 0; i < vertexCount; i++){
        x = sourceShape.getVertex(i).x;
        if(x > maxX) maxX = int(x);
      }
      return cloneShape(sourceShape, BASE_SIZE/x, new PVector(0,0));
    }
    else return null;
  }
  
	public void setCustomShape(PShape _sourceShape){
    sourceShape = _sourceShape;
  }

}
