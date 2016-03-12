/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-03-11
 */


 // ADD TRANSLATION LAYER

/**
 * Something that acts on a PGraphics.
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */


 class Layer implements FreelinerConfig{
   String name;
   PGraphics canvas;

   public Layer(){
     name = "basicLayer";
     canvas = null;
   }

   public void beginDrawing(){
     if(canvas != null){
       canvas.beginDraw();
       canvas.clear();
       canvas.fill(255);
       canvas.text(getName(), getName().charAt(0),100);
     }
   }

   public void endDrawing(){
     if(canvas != null) canvas.endDraw();
   }

   public PGraphics getCanvas(){
     return canvas;
   }

   public void setName(String _n){
     name = _n;
   }

   public String getName(){
     return name;
   }
 }

 class RenderLayer extends Layer{
   public RenderLayer(){
     canvas = createGraphics(width,height,P2D);
     canvas.beginDraw();
     canvas.background(0);
     canvas.endDraw();
   }
 }

class TracerLayer extends RenderLayer{
  int trailmix = 30;
  public TracerLayer(){
    super();
  }
  public void beginDrawing(){
    if(canvas != null){
      canvas.beginDraw();
      canvas.fill(BACKGROUND_COLOR, trailmix);
      canvas.stroke(BACKGROUND_COLOR, trailmix);
      canvas.stroke(1);
      canvas.rect(0,0,width,height);
      canvas.text(getName(), getName().charAt(0),100);
    }
  }
}

class ShaderLayer extends RenderLayer{
  PShader shader;
}
