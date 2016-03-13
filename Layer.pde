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
   boolean enabled;
   PGraphics canvas;

   public Layer(){
     name = "basicLayer";
     enabled = true;
     canvas = null;
   }

   public PGraphics apply(PGraphics _pg){
     return _pg;
   }

   public void beginDrawing(){
     if(canvas != null){
       canvas.beginDraw();
       canvas.clear();
     }
   }

   public void endDrawing(){
     if(canvas != null) canvas.endDraw();
   }

   public void loadFile(String _file){}

   public PGraphics getCanvas(){
     return canvas;
   }

   public void setName(String _n){
     name = _n;
   }

   public boolean useLayer(){
     return enabled;
   }

   public String getName(){
     return name;
   }
 }

// actualy has a PGraphics
class RenderLayer extends Layer{
   public RenderLayer(){
     canvas = createGraphics(width,height,P2D);
     canvas.beginDraw();
     canvas.background(0);
     canvas.endDraw();
   }
   public PGraphics apply(PGraphics _pg){
     if(!enabled) return _pg;
     if(_pg == null) return canvas;
     _pg.beginDraw();
     _pg.image(canvas,0,0);
     _pg.endDraw();
     return _pg;
   }
 }

// tracer
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
      canvas.stroke(10);
      canvas.noStroke();
      canvas.rect(0,0,width,height);
    }
  }
  public int setTrails(int _v){
    trailmix = numTweaker(_v, trailmix);
    return trailmix;
  }
}

class MergeLayer extends RenderLayer{
  public MergeLayer(){
    super();
    name = "MergeLayer";
  }
  public PGraphics apply(PGraphics _pg){
    canvas.image(_pg,0,0);
    return null;
  }
}

/**
 * For fragment shaders!
 */
class ShaderLayer extends RenderLayer{
  PShader shader;
  String fileName;

  // uniforms to control shader params
  float[] uniforms;

  public ShaderLayer(){
    enabled = true;
    name = "ShaderLayer";
    shader = null;
    uniforms = new float[]{0.5, 0.5, 0.5, 0.5};
  }

  public PGraphics apply(PGraphics _pg){
    if(shader == null) return _pg;
    if(!enabled) return _pg;
    try {
      canvas.shader(shader);
    }
    catch(RuntimeException _e){
      println("shader no good");
      canvas.resetShader();
      return _pg;
    }
    passUniforms();
    canvas.beginDraw();
    canvas.image(_pg,0,0);
    canvas.endDraw();
    canvas.resetShader();
    return canvas;
  }

  public void loadFile(String _file){
    fileName = _file;
    name = _file;//_splt[_splt.length];
    reloadShader();
  }

  public void reloadShader(){
    try{
      shader = loadShader(fileName);
      println("Loaded shader "+fileName);
    }
    catch(Exception _e){
      println("Could not load shader... "+fileName);
      println(_e);
      shader = null;
    }
  }

  public boolean isNull(){
    return (shader == null);
  }

  public void setUniforms(int _i, float _val){
    uniforms[_i % 4] = _val;
  }

  public void passUniforms(){
    shader.set("u1", uniforms[0]);
    shader.set("u2", uniforms[1]);
    shader.set("u3", uniforms[2]);
    shader.set("u4", uniforms[3]);
  }
}

// class ResetShaderLayer extends Layer{
//   public ResetShaderLayer(){
//     name = "ResetShader";
//   }
//   public PGraphics apply(PGraphics _pg){
//     if(!enabled) return _pg;
//     _pg.resetShader();
//     return _pg;
//   }
// }
