/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

 class TemplateTeam {
     String name;
     ArrayList<Template> templates;

     TemplateTeam(String _name){
         name = _name;
         templates = new ArrayList();
     }

     void addTemplate(Template _tp){
         templates.add(_tp);
     }

     void addTemplates(ArrayList<Template> _tps){
         for(Template _tp : _tps){
             Template _new = new Template();
             _new.copy(_tp);
             templates.add(_new);
         }
     }

     String getName(){
         return name;
     }

     ArrayList<Template> getTemplates(){
         return templates;
     }
 }

/**
 * Manage all the templates
 *
 */
class TemplateManager {
    //selects templates to control
    TemplateList templateList;

    //templates all the basic templates
    ArrayList<Template> templates;
    ArrayList<TemplateTeam> templateTeams;

    Template copyedTemplate;
    final int N_TEMPLATES = 26;

    // events to render
    ArrayList<RenderableTemplate> eventList;
    ArrayList<RenderableTemplate> loops;
    // synchronise things
    Synchroniser sync;
    Sequencer sequencer;
    GroupManager groupManager;

    public TemplateManager() {
        sync = new Synchroniser();
        sequencer = new Sequencer();
        templateList = new TemplateList();
        loops = new ArrayList();
        eventList = new ArrayList();
        templateTeams = new ArrayList();
        copyedTemplate = null;
        init();
        groupManager = null;
    }

    public void inject(GroupManager _gm) {
        groupManager = _gm;
    }

    private void init() {
        templates = new ArrayList();
        for (int i = 0; i < N_TEMPLATES; i++) {
            Template te = new Template(char(65+i));
            templates.add(te);
        }
    }

    // update the render events
    public void update() {
        sync.update();
        sequencer.update(sync.getPeriodCount());
        trigger(sequencer.getStepList());
        //println("tags "+sequencer.getStepList().getTags());
        // check for events?
        // set the unitinterval/beat for all templates
        syncTemplates(loops);
        syncTemplates(eventList);
        ArrayList<RenderableTemplate> toKill = new ArrayList();
        synchronized(eventList) {
            ArrayList<RenderableTemplate> _safe = new ArrayList(eventList);
            for(RenderableTemplate _tp : _safe) {
                if(_tp == null) return;
                if(((KillableTemplate) _tp).isDone()) toKill.add(_tp);
            }
            if(toKill.size()>0) {
                for(RenderableTemplate _rt : toKill) {
                    eventList.remove(_rt);
                }
            }
        }
    }

    // synchronise renderable templates lists
    private void syncTemplates(ArrayList<RenderableTemplate> _tp) {
        ArrayList<RenderableTemplate> lst = new ArrayList<RenderableTemplate>(_tp);
        int beatDv = 1;
        if(_tp.size() > 0) {
            for (RenderableTemplate rt : lst) {
                // had a null pointer here...
                if(rt == null) continue; // does this fix?
                beatDv = rt.getBeatDivider();
                rt.setUnitInterval(sync.getLerp(beatDv));
                rt.setBeatCount(sync.getPeriod(beatDv));
                rt.setRawBeatCount(sync.getPeriod(0));
            }
        }
    }

    /**
     * Makes sure there is a renderable template for all the segmentGroup / Template pairs.
     * @param ArrayList<SegmentGroup>
     */
    public void launchLoops() {
        ArrayList<SegmentGroup> _groups = groupManager.getSortedGroups();
        if(_groups.size() == 0) return;
        ArrayList<RenderableTemplate> toKeep = new ArrayList();

        //check to add new loops
        for(SegmentGroup sg : _groups) {
            ArrayList<Template> tmps = sg.getTemplateList().getAll();
            if(tmps != null) {
                for(Template te : tmps) {
                    RenderableTemplate rt = getByIDandGroup(loops, te.getTemplateID(), sg);
                    if(rt != null) toKeep.add(rt);
                    else toKeep.add(loopFactory(te, sg));
                }
            }
        }
        loops = toKeep;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Event Factory
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // set size as per scalar
    public RenderableTemplate loopFactory(Template _te, SegmentGroup _sg) {
        return new RenderableTemplate(_te, _sg);
    }

    // set size as per scalar
    public RenderableTemplate eventFactory(Template _te, SegmentGroup _sg) {
        RenderableTemplate _rt = new KillableTemplate(_te, _sg);
        ((KillableTemplate) _rt).setOffset(sync.getLerp(_rt.getBeatDivider()));
        return _rt;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Playing functions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////
    // trigger but catch with synchroniser
    public void trigger(char _c) {
        Template _tp = getTemplate(_c);
        if(_tp == null) return;
        trigger(_tp);
        // sync.templateInput(_tp);
    }

    public void trigger(Template _tp) {
        if(_tp == null) return;
        _tp.launch(); // increments the launchCount
        // get groups with template
        ArrayList<SegmentGroup> _groups = groupManager.getGroups(_tp);
        if(_groups.size() > 0) {
            for(SegmentGroup _sg : _groups) {
                eventList.add(eventFactory(_tp, _sg));
            }
        }
    }

    // trigger a letter + group
    public void trigger(char _c, int _id) {
        SegmentGroup _sg = groupManager.getGroup(_id);
        if(_sg == null) return;
        Template _tp = getTemplate(_c);
        if(_tp == null) return;
        _tp.launch();
        eventList.add(eventFactory(_tp, _sg));
    }

    // trigger a templateList, in this case via the
    public void trigger(TemplateList _tl) {
        if(_tl == null) return;
        ArrayList<Template> _tp = _tl.getAll();
        if(_tp == null) return;
        if(_tp.size() > 0) {
            for(Template tw : _tp) {
                if(tw.getEnablerMode() != 3) trigger(tw); // check if is in the right enabler mode
            }
        }
    }

    // osc trigger many things and gps
    public void oscTrigger(String _tags, int _gp) {
        for(int i = 0; i < _tags.length(); i++) {
            if(_gp != -1) trigger(_tags.charAt(i), _gp);
            else trigger(_tags.charAt(i));
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Select all the templates in order to tweak them all. Triggered by ctrl-a
     */
    public void focusAll() {
        templateList.clear();
        for (Template r_ : templates) {
            templateList.toggle(r_);
        }
    }

    /**
     * unSelect templates
     */
    public void unSelect() {
        templateList.clear();
    }

    /**
     * toggle template selection
     */
    public void toggle(char _c) {
        templateList.toggle(getTemplate(_c));
    }

    /**
     * Copy a template and maybe paste it automaticaly. Triggered by ctrl-c with 2 templates selected.
     */
    public void copyTemplate() {
        Template toCopy = templateList.getIndex(0);
        Template pasteInto = templateList.getIndex(1);
        copyTemplate(toCopy, pasteInto);
    }

    // for ABCD (A->BCD)
    public void copyTemplate(String _tags) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() == 1) copyTemplate(_tmps.get(0), null);
        else {
            for(int i = 1; i < _tmps.size(); i++) {
                copyTemplate(_tmps.get(0), _tmps.get(i));
            }
        }
    }

    public void copyTemplate(Template _toCopy, Template _toPaste) {
        copyedTemplate = _toCopy;
        if(copyedTemplate != null && _toPaste != null) _toPaste.copyParameters(copyedTemplate);
    }

    /**
     * Paste a previously copyed template into an other
     */
    public void pasteTemplate() {
        pasteTemplate(templateList.getTags());
    }

    public void pasteTemplate(String _tags) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() == 1) pasteTemplate(_tmps.get(0));
        else
            for(int i = 0; i < _tmps.size(); i++)
                pasteTemplate(_tmps.get(i));
    }

    public void pasteTemplate(Template _pasteInto) {
        if(copyedTemplate != null && _pasteInto != null) _pasteInto.copyParameters(copyedTemplate);
    }

    /**
     * Toggle a template for groups matching first template
     */
    public void groupAddTemplate() {
        groupAddTemplate(templateList.getTags());
    }

    public void groupAddTemplate(String _tags) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() < 2) return;
        else
            // for(int i = 1; i < ; i++)
            groupAddTemplate(_tmps.get(0), _tmps.get(1));
    }

    public void groupAddTemplate(Template _a, Template _b) {
        if(_a != null && _b !=null) groupManager.groupAddTemplate(_a, _b);
    }

    /**
     * Swap Templates (AB), swaps their related geometry also
     */
    public void swapTemplates(String _tags) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        if(_tmps.size() < 2) return;
        else swapTemplates(_tmps.get(0), _tmps.get(1));
    }

    // might remove the copy? not sure.
    public void swapTemplates(Template _a, Template _b) {
        Template _c = new Template();
        _c.copyParameters(_a);
        _a.copyParameters(_b);
        _b.copyParameters(_c);
        groupSwapTemplate(_a, _b);
    }

    public void groupSwapTemplate(Template _a, Template _b) {
        if(_a != null && _b !=null) groupManager.groupSwapTemplate(_a, _b);
    }

    /**
     * ResetTemplate
     */
    public void resetTemplate() {
        resetTemplate(templateList.getTags());
    }

    public void resetTemplate(String _tags) {
        if(_tags == null) return;
        else if(_tags.length() > 0) {
            ArrayList<Template> _tps = getTemplates(_tags);
            if(_tps != null) for(Template _tp : _tps) _tp.reset();
        }
    }
    /**
     * Set a template's custom color, this is done with OSC.
     */
    public void setCustomStrokeColor(String _tags, color _c) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        for(Template _tp : _tmps) {
            if(_tp != null) _tp.setCustomStrokeColor(_c);
        }
    }

    public void setCustomFillColor(String _tags, color _c) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps == null) return;
        for(Template _tp : _tmps) {
            if(_tp != null) _tp.setCustomFillColor(_c);
        }
    }

    /**
     * Link Templates (AB)
     */
    public void linkTemplates(String _tags) {
        ArrayList<Template> _tmps = getTemplates(_tags);
        if(_tmps.size() < 2) return;
        else linkTemplates(_tmps.get(0), _tmps.get(1));
    }

    public void linkTemplates(Template _tp, Template _link) {
        if(_tp != null && _link != null) {
            _tp.setLinkTemplate(_link);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Saving and loading to bank
    ///////
    ////////////////////////////////////////////////////////////////////////////////////


    public void loadTemplateTeam(String _key, String _tags){
        ArrayList<Template> _templates = getTemplates(_tags);
        TemplateTeam _team = getTemplateTeam(_key);
        if(_team != null && _templates != null){
            ArrayList<Template> _teamTemplates =_team.getTemplates();
            if(_teamTemplates != null){
                if(_teamTemplates.size() == _templates.size()){
                    for(int i = 0; i < _templates.size(); i++){
                        // println("load template team "+i);
                        groupManager.groupRemoveTemplate(_templates.get(i));
                        _templates.get(i).copyParameters(_teamTemplates.get(i));
                        groupManager.addTemplateToGroups(_templates.get(i));
                    }
                }
            }
        }
    }

    public TemplateTeam getTemplateTeam(String _key){
        if(templateTeams.size() > 0){
            for(TemplateTeam _team : templateTeams){
                if(_team.getName().equals(_key)) return _team;
            }
        }
        return null;
    }

    public void saveTemplateTeam(String _tags, String _key){
        println("saving template team "+_tags+" "+_key);
        ArrayList<Template> _templates = getTemplates(_tags);
        if(_templates == null) return;
        TemplateTeam _team = new TemplateTeam(_key);
        _team.addTemplates(_templates);
        templateTeams.add(_team);
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Saving and loading with XML
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public XML getXML() {
        XML _xmlTemplates = new XML("templates");
        for(Template _tp : templates) {
            templateToXML(_tp, _xmlTemplates);
        }
        XML colors =  _xmlTemplates.addChild("pallette");
        for(int i = 0; i < PALLETTE_COUNT; i++) {
            String tk = "p"+i;
            colors.addChild(tk).setInt("color", userPallet[i]);
        }
        return _xmlTemplates;
    }

    public void templateToXML(Template _tp, XML _xml){
        if(_tp == null) return;
        XML _tmp = _xml.addChild("template");
        _tmp.setString("ID", str(_tp.getTemplateID()));
        _tmp.setInt("renderMode", _tp.getRenderMode());
        _tmp.setInt("segmentMode", _tp.getSegmentMode());
        _tmp.setInt("animationMode", _tp.getAnimationMode());
        _tmp.setInt("interpolateMode", _tp.getInterpolateMode());
        _tmp.setInt("strokeMode", _tp.getStrokeMode());
        _tmp.setInt("fillMode", _tp.getFillMode());
        _tmp.setInt("strokeAlpha", _tp.getStrokeAlpha());
        _tmp.setInt("fillAlpha", _tp.getFillAlpha());
        _tmp.setInt("rotationMode", _tp.getRotationMode());
        _tmp.setInt("easingMode", _tp.getEasingMode());
        _tmp.setInt("reverseMode", _tp.getReverseMode());
        _tmp.setInt("repetitionMode", _tp.getRepetitionMode());
        _tmp.setInt("repetitionCount", _tp.getRepetitionCount());
        _tmp.setInt("beatDivider", _tp.getBeatDivider());
        _tmp.setInt("strokeWidth", _tp.getStrokeWeight());
        _tmp.setInt("brushSize", _tp.getBrushSize());
        _tmp.setInt("miscValue", _tp.getMiscValue());
        _tmp.setInt("enablerMode", _tp.getEnablerMode());
        _tmp.setInt("renderLayer", _tp.getRenderLayer());

        _tmp.setInt("customStroke", _tp.getCustomStrokeColor());
        _tmp.setInt("customFill", _tp.getCustomFillColor());
        String _l = "";
        String _t = "";
        if(_tp.getLinkedTemplate() != null) _l += _tp.getLinkedTemplate().getTemplateID();
        if(_tp.getTranslationTemplate() != null) _t += _tp.getTranslationTemplate().getTemplateID();

        _tmp.setString("linkedTemplate", _l);
        _tmp.setString("translationTemplate", _t);

        XML _geoms = _tmp.addChild("groups");
        for( int i = 0; i < _tp.getGeometries().size(); i++){
            XML _g = _geoms.addChild("g");
            _g.setInt("id", _tp.getGeometries().get(i));
        }
    }


    public void loadTemplatesXML(XML _xml) {
        XML[] _templateData = _xml.getChildren("template");
        if(_templateData.length == 0) return;
        Template _tmp;
        for(XML _tp : _templateData) {
            _tmp = getTemplate(_tp.getString("ID").charAt(0));
            xmlToTemplate(_tp, _tmp);
        }

        XML pal =  _xml.getChild("pallette");
        for(int i = 0; i < PALLETTE_COUNT; i++) {
            String tk = "p"+i;
            userPallet[i] = pal.getChild(tk).getInt("color");
        }
    }

    void xmlToTemplate(XML _templateData, Template _tp){
        if(_tp == null || _templateData == null) return;
        _tp.setRenderMode(_templateData.getInt("renderMode"), 50000);
        _tp.setSegmentMode(_templateData.getInt("segmentMode"), 50000);
        _tp.setAnimationMode(_templateData.getInt("animationMode"), 50000);
        _tp.setInterpolateMode(_templateData.getInt("interpolateMode"), 50000);
        _tp.setStrokeMode(_templateData.getInt("strokeMode"), 50000);
        _tp.setFillMode(_templateData.getInt("fillMode"), 50000);
        _tp.setStrokeAlpha(_templateData.getInt("strokeAlpha"), 50000);
        _tp.setFillAlpha(_templateData.getInt("fillAlpha"), 50000);
        _tp.setRotationMode(_templateData.getInt("rotationMode"), 50000);
        _tp.setEasingMode(_templateData.getInt("easingMode"), 50000);
        _tp.setReverseMode(_templateData.getInt("reverseMode"), 50000);
        _tp.setRepetitionMode(_templateData.getInt("repetitionMode"), 50000);
        _tp.setRepetitionCount(_templateData.getInt("repetitionCount"), 50000);
        _tp.setBeatDivider(_templateData.getInt("beatDivider"), 50000);
        _tp.setStrokeWidth(_templateData.getInt("strokeWidth"), 50000);
        _tp.setBrushSize(_templateData.getInt("brushSize"), 50000);
        _tp.setMiscValue(_templateData.getInt("miscValue"), 50000);
        _tp.setEnablerMode(_templateData.getInt("enablerMode"), 50000);
        _tp.setRenderLayer(_templateData.getInt("renderLayer"), 50000);
        _tp.setCustomStrokeColor(_templateData.getInt("customStroke"));
        _tp.setCustomFillColor(_templateData.getInt("customFill"));

        String _linked = _templateData.getString("linkedTemplate");
        String _translated = _templateData.getString("translationTemplate");

        if(_linked.length() > 0){
            _tp.setLinkTemplate(getTemplate(_linked.charAt(0)));
        }
        if(_translated.length() > 0){
            _tp.setTranslationTemplate(getTemplate(_translated.charAt(0)));
        }

        XML _grps = _templateData.getChild("groups");
        if(_grps != null){
            for(XML _grp : _grps.getChildren("g")){
                _tp.addGeometry(_grp.getInt("id"));
            }
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Setting custom shapes
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // set a decorator's shape
    private void setCustomShape(SegmentGroup _sg) {
        if(_sg == null) return;
        ArrayList<Template> temps = _sg.getTemplateList().getAll();

        if(_sg.getShape() == null) return;

        PShape sourceShape = cloneShape(_sg.getShape(), 1.0, _sg.getCenter());
        //println("Setting customShape of "+temp.getTemplateID()+" with a shape of "+sourceShape.getVertexCount()+" vertices");

        int vertexCount = sourceShape.getVertexCount();
        if(vertexCount > 0) {
            // store the widest x coordinate
            float maxX = 0.0001;
            float minX = -0.0001;
            float mx = 0;
            float mn = 0;
            // check how wide the shape is to scale it to the BASE_SIZE
            for(int i = 0; i < vertexCount; i++) {
                mx = sourceShape.getVertex(i).x;
                mn = sourceShape.getVertex(i).y;
                if(mx > maxX) maxX = mx;
                if(mn < minX) minX = mn;
            }
            // return a brush scaled to the BASE_SIZE
            float baseSize = (float)new PointBrush(0).BASE_BRUSH_SIZE;
            PShape cust = cloneShape(sourceShape, baseSize/(maxX+abs(minX)), new PVector(0,0));
            if(temps != null)
                for(Template temp : temps)
                    if(temp != null)
                        temp.setCustomShape(cust);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Mutators
    ///////
    ////////////////////////////////////////////////////////////////////////////////////


    public ArrayList<Template> getActive() {
        ArrayList active = new ArrayList();
        for(Template _t : loops) {
            active.add(getTemplate(_t.getTemplateID()));
        }
        return active;
    }

    public ArrayList<Template> getInactive() {
        ArrayList copy = new ArrayList(templates);
        for(Template _t : loops) {
            copy.remove(getTemplate(_t.getTemplateID()));
        }
        return copy;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public Synchroniser getSynchroniser() {
        return sync;
    }

    public Sequencer getSequencer() {
        return sequencer;
    }

    public ArrayList<RenderableTemplate> getLoops() {
        return loops;
    }

    public ArrayList<RenderableTemplate> getEvents() {
        return eventList;
    }

    public boolean isFocused() {
        return templateList.getIndex(0) != null;
    }

    public Template getTemplate(char _c) {
        if(_c >= 'A' && _c <= 'Z') return templates.get(int(_c)-'A');
        else return null;
    }

    public RenderableTemplate getByIDandGroup(ArrayList<RenderableTemplate> _tps, char _id, SegmentGroup _sg) {
        for(RenderableTemplate tp : _tps) {
            if(tp.getTemplateID() == _id && tp.getSegmentGroup() == _sg) return tp;
        }
        return null;
    }

    public TemplateList getTemplateList() {
        return templateList;
    }

    public ArrayList<Template> getTemplates() {
        return templates;
    }

    public ArrayList<Template> getSelected() {
        ArrayList<Template> _tmps = new ArrayList();
        if(templateList.getAll() == null) return null;
        if(templateList.getAll().size() == 0) return null;
        for(Template _tw : templateList.getAll()) {
            if(_tw != null) _tmps.add(_tw);
        }
        return _tmps;
    }

    public ArrayList<Template> getGroupTemplates() {
        TemplateList _tl = groupManager.getTemplateList();
        if(_tl == null) return null;
        return _tl.getAll();
    }

    // a fancier accessor, supports "ANCD" "*" "$" "$$"
    public ArrayList<Template> getTemplates(String _tags) {
        if(_tags.length() < 1) return null;
        ArrayList<Template> _tmps = new ArrayList();
        if(_tags.length() == 0) return null;
        else if(_tags.charAt(0) == '$') {
            if(_tags.length() > 1) return getGroupTemplates();
            else return getSelected();
        } else if(_tags.charAt(0) == '*') return getTemplates();
        else {
            for(int i = 0; i < _tags.length(); i++) {
                Template _tw = getTemplate(_tags.charAt(i));
                // println(_tw);
                if( _tw != null) _tmps.add(_tw);
            }
        }
        return _tmps;
    }

}
