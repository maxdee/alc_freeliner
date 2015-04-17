

class TemplateRenderer {


	RenderableTemplate event;

  SafeList<RenderMode> renderModes;
  SafeList<Repetition> repeaters;

  //graphics for rendering
  PGraphics canvas;

  //draw a solid or transparent 
  boolean trails;
  int trailmix;

	public TemplateRenderer(){
    canvas = createGraphics(width, height);
    canvas.smooth(0);
    canvas.ellipseMode(CENTER);
    trails = false;
    trailmix = 30;

    renderModes = new SafeList();
    renderModes.add(new PerSegment());
    renderModes.add(new Geometry());
    renderModes.add(new WrapLine());

    repeaters =  new SafeList();
    repeaters.add(new Single());
    repeaters.add(new EvenlySpaced());
	}

	public void update(ArrayList<RenderableTemplate> _toRender){
    canvas.beginDraw();
    if(trails) alphaBG(canvas);
    else canvas.clear();
    if(liquid){
      fill(255);
      rect(1024,0,1024,768);
    }

    if(_toRender.size() > 0)
      for(RenderableTemplate rt : _toRender)
        renderTemplate(rt);

    canvas.endDraw();
	}



  public void renderTemplate(RenderableTemplate _rt){
    _rt.setCanvas(canvas);
    FloatList flts = repeaters.get(_rt.getRepetitionMode()).getFloats(_rt);
    for(float flt : flts){
      _rt.setLerp(flt);
      renderModes.get(_rt.getRenderMode()).doRender(_rt);
    }
  }


  // add with potential
  public void tweakAngle(){
    int rotMode = event.getRotationMode();
    if(rotMode != 0) event.setAngleMod(event.getLerp()*TWO_PI*rotMode);
    else event.setAngleMod(0);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Effects
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void alphaBG(PGraphics _pg) {
    _pg.fill(0, 0, 0, trailmix);
    _pg.stroke(0, 0, 0, trailmix);
    _pg.rect(0, 0, width, height);
  }

  public boolean toggleTrails(){
    trails = !trails;
    return trails;
  }
  public int setTrails(int v){
    trailmix = numTweaker(v, trailmix);
    return trailmix;
  }

	public final PGraphics getCanvas(){
    return canvas;
  }
}
