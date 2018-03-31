/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */



/**
 * Manage segmentGroups!
 *
 */
class GroupManager implements FreelinerConfig{

    // guess we will add this too.
    TemplateManager templateManager;
    //manages groups of points
    ArrayList<SegmentGroup> groups;
    ArrayList<SegmentGroup> sortedGroups;

    int groupCount = 0;
    //selects groups to control, -1 for not selected
    int selectedIndex;
    int lastSelectedIndex;
    int snappedIndex;
    int snapDist = 15;
    // list of PVectors that are snapped
    ArrayList<PVector> snappedList;
    Segment snappedSegment;

    ArrayList<Segment> commandSegments;

    int testChannel = -1;
    int ledStart = 0;

    /**
     * Constructor, inits default values
     */
    public GroupManager() {
        groups = new ArrayList();
        sortedGroups = new ArrayList();

        snappedList = new ArrayList();
        groupCount = 0;
        selectedIndex = -1;
        lastSelectedIndex = -1;
        snappedIndex = -1;
        snappedSegment = null;
        // first group for gui text
        newGroup();
        // second group for reference group
        newGroup();
        // reselect group 0 to begin
        selectedIndex = 0;
        commandSegments = null;
    }


    public void inject(TemplateManager _tm) {
        templateManager = _tm;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     should not be here but whatever
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public int setTestChannel(int _i) {
        if(testChannel == 0 && _i == -2) testChannel = -1;
        else testChannel = numTweaker(_i, testChannel);
        return testChannel;
    }

    public void setChannel(){
        if(getSnappedSegment() == null){
            ledStart = testChannel;
            println("start = "+ledStart);
        }
        else{
            println("end = "+ledStart);
            setText("/led "+ledStart+" "+testChannel);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Actions
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Create a new group.
     */
    public int newGroup() {
        groups.add(new SegmentGroup(groupCount));
        selectedIndex = groupCount;
        groupCount++;
        sortGeometry();
        return selectedIndex;
    }

    /**
     * Tab the focus through groups.
     * @param boolean reverse direction (shift+tab)
     */
    public void tabThrough(boolean _shift) {
        if(!isFocused()) selectedIndex = lastSelectedIndex;
        else if (_shift) selectedIndex--;
        else selectedIndex++;
        selectedIndex = wrap(selectedIndex, groupCount-1);
        // update ref.
        if(getSelectedGroup() != null)
            setReferenceGroupTemplateList(getSelectedGroup().getTemplateList());

    }

    /**
     * Add an other renderer to all groups who have the first renderer.
     * @param renderer to add
     * @param renderer to match
     */
    public void groupAddTemplate(TweakableTemplate _toMatch, TweakableTemplate _toAdd) {
        if(groups.size() > 0 && _toAdd != null && _toMatch != null) {
            for (SegmentGroup sg : groups) {
                TemplateList _tl = sg.getTemplateList();
                if(_tl != null)
                    if(_tl.contains(_toMatch))
                        _tl.toggle(_toAdd);
            }
        }
    }

    /**
     * Similar to groupAddTemplate, but a direct swap.
     * @param Template to swap
     * @param renderer to swap with
     */
    public void groupSwapTemplate(TweakableTemplate _a, TweakableTemplate _b) {
        if(groups.size() > 0 && _a != null && _b != null) {
            for (SegmentGroup sg : groups) {
                TemplateList tl = sg.getTemplateList();
                if(tl != null) {
                    if(tl.contains(_a) || tl.contains(_b)) {
                        tl.toggle(_a);
                        tl.toggle(_b);
                    }
                }
            }
        }
    }

    public void toggleTemplate(TweakableTemplate _tp, int _ind) {
        SegmentGroup _sg = getGroup(_ind);
        if(_sg != null && _tp != null) _sg.getTemplateList().toggle(_tp);
    }

    /**
     * Snap puts all the PVectors that are near the position given into a arrayList.
     * The snapDist can be adjusted like anything else.
     * It returns the place it snapped to to adjust cursor.
     * @param PVector of the cursor
     * @return PVector where it snapped.
     */
    public PVector snap(PVector _pos) {
        PVector snap = new PVector(0, 0);
        snappedList.clear();
        snappedIndex = -1;
        snappedSegment = null;
        ArrayList<Segment> segs;
        for (int i = 0; i < groupCount; i++) {
            segs = groups.get(i).getSegments();
            // check if snapped to center
            if(_pos.dist(groups.get(i).getCenter()) < snapDist) {
                snappedList.add(groups.get(i).getCenter());
                snap = groups.get(i).getCenter();
                snappedIndex = i;
            }
            for(Segment seg : segs) {
                if(_pos.dist(seg.getPointA()) < snapDist) {
                    snappedList.add(seg.getPointA());
                    snap = seg.getPointA();
                    snappedIndex = i;
                } else if(_pos.dist(seg.getPointB()) < snapDist) {
                    snappedList.add(seg.getPointB());
                    snap = seg.getPointB();
                    snappedIndex = i;
                } else if (_pos.dist(seg.getMidPoint()) < snapDist) {
                    snappedSegment = seg;
                    snap = seg.getMidPoint();
                    snappedIndex = i;
                }
            }
        }
        if (snappedIndex != -1) {
            if(selectedIndex == -1) lastSelectedIndex = snappedIndex;
            return snap;// snappedList.get(0);
        } else return _pos;
    }


    public void unSnap() {
        snappedList.clear();
        snappedIndex = -1;
        snappedSegment = null;
    }
    /**
     * Nudge all PVectors of the snappedList.
     * If the snapped list is empty and we are focused on a group, nudge the segmentStart.
     * @param boolean verticle/horizontal
     * @param int direction (1 or -1)
     * @param boolean nudge 10X more
     */
    public void nudger(Boolean axis, int dir, boolean _shift) {
        PVector ndg = new PVector(0, 0);
        if(_shift) dir*=10;
        if (axis) ndg.set(dir, 0);
        else ndg.set(0, dir);
        if(snappedList.size()>0) {
            for(PVector _pv : snappedList) {
                _pv.add(ndg);
            }
            //setCenter(center);
            reCenter();
        } else if(isFocused()) getSelectedGroup().nudgeSegmentStart(ndg);
    }

    public void drag(PVector _pos) {
        if(snappedList.size()>0) {
            for(PVector _pv : snappedList) {
                _pv.set(_pos);
            }
            //setCenter(center);
            reCenter();
        }
    }

    private void reCenter() {
        for(SegmentGroup sg : groups) {
            if(sg.isCentered()) sg.placeCenter(sg.getCenter());
            sg.updateGeometry();
            //else sg.placeCenter(sg.getSegmentStart());
        }
    }

    private void deleteSegment() {
        if(snappedSegment == null || getSelectedGroup() == null) return;
        getSelectedGroup().deleteSegment(snappedSegment);
        snappedSegment = null;
        snappedIndex = -1;
    }

    private void hideSegment() {
        if(snappedSegment == null) return;
        snappedSegment.toggleHidden();
    }


    public int geometryPriority(SegmentGroup _sg, int _v) {
        if(_sg == null) return 0;
        int _ha = _sg.tweakPriority(_v);
        sortGeometry();
        return _ha;
    }

    public int geometryPriority(int _order){
        SegmentGroup _sg = getSelectedGroup();
        if(_sg != null){
            return geometryPriority(_sg, _order);
        }
        return 0;
    }

    public int geometryPriority(int _geom, int _order){
        SegmentGroup _sg = getGroup(_geom);
        if(_sg != null){
            return geometryPriority(_sg, _order);
        }
        return 0;
    }

    public int geometryPriority(String _tags, int _order){
        ArrayList<TweakableTemplate> _temps = templateManager.getTemplates(_tags);
        // println(_tags+" "+_temps.size());
        int _val = 0;
        if(_temps == null){
            return geometryPriority(_order);
        }
        else if(_temps.size() == 0){
            return geometryPriority(_order);
        }
        else {
            for(SegmentGroup _sg : groups){
                TemplateList _list = _sg.getTemplateList();
                for(TweakableTemplate _tp : _temps){
                    if(_list.contains(_tp)){
                        _val = geometryPriority(_sg, _order);
                    }
                }
            }
        }
        return _val;
    }

    public void sortGeometry(){
        sortedGroups.clear();
        int _level = 0;
        while(sortedGroups.size() < groups.size()){
            for(SegmentGroup _sg : groups){
                if(_sg.getPriority() == _level){
                    sortedGroups.add(_sg);
                }
            }
            _level++;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     CMD segments
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    public void updateCmdSegments() {
        commandSegments = new ArrayList<Segment>();
        ArrayList<Segment> _segs;
        for(SegmentGroup _sg : groups) {
            if(!_sg.isEmpty()) {
                _segs = _sg.getSegments();
                if(_segs.get(0).getText().equals("/cmd")) {
                    for(Segment _seg : _segs)
                        commandSegments.add(_seg);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Save and load
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    // argumentless
    public void saveGroups() {
        saveGroups("geometry.xml");
    }

    public void saveGroups(String _fn) {
        XML groupData = new XML("groups");
        for(SegmentGroup grp : groups) {
            groupData.setInt("width", width);
            groupData.setInt("height", height);

            if(grp.isEmpty()) continue;
            XML xgroup = groupData.addChild("group");
            xgroup.setInt("ID", grp.getID());
            xgroup.setString("text", grp.getText());

            if(grp.getID() == 0) xgroup.setString("type", "gui");
            else if(grp.getID() == 1) xgroup.setString("type", "ref");
            else xgroup.setString("type", "map");

            xgroup.setFloat("centerX", grp.getCenter().x);
            xgroup.setFloat("centerY", grp.getCenter().y);
            xgroup.setInt("centered", int(grp.isCentered()));
            xgroup.setString("tags", grp.getTemplateList().getTags());
            for(Segment seg : grp.getSegments()) {
                XML xseg = xgroup.addChild("segment");
                xseg.setFloat("aX",seg.getPointA().x);
                xseg.setFloat("aY",seg.getPointA().y);
                xseg.setFloat("bX",seg.getPointB().x);
                xseg.setFloat("bY",seg.getPointB().y);
                // for leds and such
                xseg.setString("txt",seg.getText());
            }
            saveXML(groupData, dataPath(PATH_TO_GEOMETRY)+"/"+_fn);
        }
    }

    public void loadGeometry() {
        loadGeometry("geometry.xml");
    }

    public void loadGeometry(String _file) {
        String[] _fn = split(_file, '.');
        if(_fn.length < 2) println("I dont know what kind of file this is : "+_file);
        else if(_fn[1].equals("svg")) loadGeometrySVG(_file);
        else if(_fn[1].equals("xml")) loadGeometryXML(_file);
    }

    // what a mess what a mess
    // we cant have that we cant have that
    // clean it up clean it up
    public void loadGeometryXML(String _fn) {
        XML file;
        try {
            file = loadXML(dataPath(PATH_TO_GEOMETRY)+"/"+_fn);
        } catch (Exception e) {
            println(_fn+" cant be loaded");
            return;
        }
        int sourceWidth = file.getInt("width");
        int sourceHeight = file.getInt("height");
        // println("ahhahah "+sourceWidth+ " "+sourceHeight);

        XML[] groupData = file.getChildren("group");
        PVector posA = new PVector(0,0);
        PVector posB = new PVector(0,0);
        PVector _offset = new PVector(0,0);
        if(sourceWidth != 0 && sourceHeight != 0) {
            _offset.sub(new PVector(sourceWidth/2, sourceHeight/2));
            _offset.add(new PVector(width/2, height/2));
        }
        for(XML xgroup : groupData) {

            if(xgroup.getString("type").equals("gui")) selectedIndex = 0;
            else if(xgroup.getString("type").equals("ref")) selectedIndex = 1;
            else newGroup();

            XML[] xseg = xgroup.getChildren("segment");
            Segment _seg;
            for(XML seg : xseg) {
                posA.set(seg.getFloat("aX"), seg.getFloat("aY"));
                posB.set(seg.getFloat("bX"), seg.getFloat("bY"));
                posA.add(_offset);
                posB.add(_offset);
                _seg = new Segment(posA.get(), posB.get());
                _seg.setText(seg.getString("txt"));
                getSelectedGroup().addSegment(_seg);
            }
            getSelectedGroup().mouseInput(LEFT, posB);
            // //getSelectedGroup().setNeighbors();
            // getSelectedGroup().updateGeometry();
            posA.set(xgroup.getFloat("centerX"), xgroup.getFloat("centerY"));
            posA.add(_offset);
            String _tags = xgroup.getString("tags");
            if(_tags.length()>0) {
                for(int i = 0; i < _tags.length(); i++) {
                    getSelectedGroup().getTemplateList().toggle(templateManager.getTemplate(_tags.charAt(i)));
                }
            }
            String _txt = xgroup.getString("text");
            if(_txt != null) getSelectedGroup().setText(_txt);
            // bug with centering? seems ok...
            //println(getSelectedGroup().sortedSegments.size());
            if(abs(posA.x - getSelectedGroup().getSegment(0).getPointB().x) > 2) getSelectedGroup().placeCenter(posA);
            if(!boolean(xgroup.getInt("centered"))) getSelectedGroup().unCenter();
        }
    }

    ///////////////////////// SVG

    public void loadGeometrySVG(String _fn) {
        PShape _shp;
        try {
            _shp = loadShape(dataPath(PATH_TO_VECTOR_GRAPHICS)+"/"+_fn);
        } catch (Exception e) {
            println(_fn+" cant be loaded");
            println(dataPath(PATH_TO_VECTOR_GRAPHICS)+"/"+_fn);
            return;
        }
        // PVector _offset = getInkscapeTransform(sketchPath()+"/data/userdata/"+_fn);
        PVector _offset = new PVector(0,0);
        _offset.sub(new PVector(_shp.width/2, _shp.height/2));
        _offset.add(new PVector(width/2, height/2));
        addSvgShapes(_shp, _offset.get());
    }

    // recursively add children
    int haha = 0;
    void addSvgShapes(PShape _shp, PVector _offset) {
        for(PShape _child : _shp.getChildren()) {
            if(_child.getVertexCount() != 0)
                if(_child.getFamily() == PShape.PATH)
                    if(_child.getKind() == 0)// && (haha++)%8 == 1)
                        shapeToGroup(_child, _offset);

            if(_child.getChildCount() != 0) addSvgShapes(_child, _offset);
        }
    }

    void shapeToGroup(PShape _shp, PVector _offset) {
        newGroup();
        println("------------addingShape with "+_shp.getVertexCount()+" vertices------------");
        Segment _seg;
        ArrayList<PVector> _vertices = new ArrayList();
        PVector posA = new PVector(0,0);
        PVector posB = new PVector(0,0);


//int[] getVertexCodes()[]
        for(int i = 0; i < _shp.getVertexCount()-1; i++) {
            // if(_shp.getVertexCodes()[i] == BREAK){
            //     println("BREAK");
            // }
            // else{
                posA = _shp.getVertex(i).get();
                posB = _shp.getVertex(i+1).get();
                posA.add(_offset);
                posB.add(_offset);
                _vertices.add(posA);
                _seg = new Segment(posA.get(), posB.get());
                getSelectedGroup().addSegment(_seg);
                print(posA.x+","+posA.y+" to "+posB.x+","+posB.y);
            // }
        }
        _vertices.add(posB);

        if(_shp.isClosed()) {
            posA = posB.get();
            posB = _shp.getVertex(0).get();
            posB.add(_offset);
            _seg = new Segment(posA.get(), posB.get());
            getSelectedGroup().addSegment(_seg);
            // getSelectedGroup().placeCenter(posB);
        }
        //place center
        getSelectedGroup().placeCenter(shapeCenter(_vertices));
        if(!_shp.isClosed()) getSelectedGroup().unCenter();
        getSelectedGroup().getTemplateList().toggle(templateManager.getTemplate('Z'));
        println();
    }

    PVector shapeCenter(ArrayList<PVector> _vertices) {
        PVector _adder = new PVector(0,0);
        for(PVector _pv : _vertices) _adder.add(_pv);
        _adder.div(_vertices.size());
        return _adder;
    }

    // inkscape had an annoying transform thing
    PVector getInkscapeTransform(String _fn) {
        PVector _offset = new PVector(0,0);
        XML _xml = loadXML(_fn);
        for(XML _child : _xml.getChildren()) {
            String _tf = _child.getString("transform");
            if(_tf != null) {
                String[] _splt = split(_tf, "(");
                if(_splt[0].equals("translate")) {
                    _tf = _splt[1].replaceAll("\\)", "");
                    String[] _xy = split(_tf, ',');
                    _offset.set(stringFloat(_xy[0]), stringFloat(_xy[1]));
                }
            }
        }
        return _offset;
    }


    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Modifiers
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Unselect selected group
     */
    public void unSelect() {
        lastSelectedIndex = selectedIndex;
        selectedIndex = -1;
    }

    /**
     * Adjust the snapping distance.
     * @param int adjustement to make
     * @return int new value
     */
    public int setSnapDist(int _i) {
        snapDist = numTweaker(_i, snapDist);
        return snapDist;
    }

    public void setText(int _grp, int _seg, String _txt) {
        SegmentGroup group = getGroup(_grp);
        if(group == null) return;
        Segment seg = group.getSegment(_seg);
        if(seg == null) return;
        seg.setText(_txt);
        updateCmdSegments();
    }

    public void setText(int _grp, String _txt) {
        SegmentGroup group = getGroup(_grp);
        if(group == null) return;
        group.setText(_txt);
        updateCmdSegments();
    }

    public void setText(String _txt) {
        if(getSnappedSegment() != null) getSnappedSegment().setText(_txt);
        else if(getSelectedGroup() != null) getSelectedGroup().setText(_txt);
        updateCmdSegments();

    }

    public void setReferenceGroupTemplateList(TemplateList _tl) {
        groups.get(1).setTemplateList(_tl);
    }

    public boolean toggleCenterPutting() {
        if(!isFocused()) return false;
        else return getSelectedGroup().toggleCenterPutting();
    }

    public void setGeomCenter(int _geom, int _x, int _y){
        SegmentGroup _sg = getGroup(_geom);
        if(_sg != null){
            _sg.placeCenter(new PVector(_x, _y, 0));
        }
    }
    //
    public void addSegment(int _geom, int _ax, int _ay, int _bx, int _by){
        SegmentGroup _sg = getGroup(_geom);
        if(_sg != null){
            _sg.addSegment(new PVector(_ax, _ay, 0), new PVector(_bx, _by));
        }
        else {
            for(int i = groupCount-1; i < _geom; i++){
                newGroup();
            }
            _sg = getGroup(groupCount-1);
            _sg.addSegment(new PVector(_ax, _ay, 0), new PVector(_bx, _by));
        }
    }

    public void clear(int _i){
        SegmentGroup _sg = getGroup(_i);
        if(_sg != null){
            _sg.clear();
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ///////
    ///////     Accessors
    ///////
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * Get renderList of the selected group, null if no group selected.
     * @return renderList
     */
    public TemplateList getTemplateList() {
        SegmentGroup _sg = getSelectedGroup();
        if(_sg != null) {
            if(_sg.getID() == 1) return null; // to prevent ref group from getting templates, could do it for the gui too.
            else return _sg.getTemplateList();
        } else return null;
    }

    /**
     * Check if a group is focused
     * @return boolean
     */
    boolean isFocused() {
        // if(!focused) return false;
        if(snappedIndex != -1 || selectedIndex != -1) return true;
        else return false;
    }

    /**
     * Get the selectedGroupIndex, will return -1 if nothing selected, used by gui
     * @return int index
     */
    public int getSelectedIndex() {
        return selectedIndex;
    }

    /**
     * Get the selectedGroup, or the snapped one, or null
     * @return SegmentGroup
     */
    public SegmentGroup getSelectedGroup() {
        if(snappedIndex != -1 && selectedIndex == -1) return groups.get(snappedIndex);
        else if(selectedIndex != -1 && selectedIndex <= groupCount) return groups.get(selectedIndex);
        else return null;
    }

    /**
     * Get the previously selected group, or null
     * Used to set the previously selected group as a renderer's custom shape.
     * @return SegmentGroup
     */
    public SegmentGroup getLastSelectedGroup() {
        if(lastSelectedIndex != -1 ) return groups.get(lastSelectedIndex);
        else return null;
    }

    /**
     * Get a specific group
     * @return SegmentGroup
     */
    public SegmentGroup getGroup(int _i) {
        if(_i >= 0 && _i < groupCount) return groups.get(_i);
        else return null;
    }

    /**
     * Get all the groups
     * @return SegmentGroup
     */
    public ArrayList<SegmentGroup> getGroups() {
        return groups;
    }

    public ArrayList<SegmentGroup> getSortedGroups() {
        return sortedGroups;
    }


    /**
     * Get groups with a certain template
     * @return SegmentGroup arrayList
     */
    public ArrayList<SegmentGroup> getGroups(TweakableTemplate _tp) {
        ArrayList<SegmentGroup> _groups = new ArrayList();
        for(SegmentGroup _sg : groups) {
            if(_sg.getTemplateList().contains(_tp)) _groups.add(_sg);
        }
        return _groups;
    }



    /**
     * Get the snappedSegment
     * @return Segment
     */
    public Segment getSnappedSegment() {
        return snappedSegment;
    }

    /**
     * Get the last point of a group
     * @return SegmentGroup
     */
    public PVector getPreviousPosition() {
        if (isFocused()) return getSelectedGroup().getLastPoint();
        else return new PVector(width/2, height/2, 0);
    }

    public ArrayList<Segment> getCommandSegments() {
        return commandSegments;
    }
}
