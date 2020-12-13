/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2020-09-01
 */

 import java.io.*;
 import java.nio.file.*;

class FreelinerProject {
    String fullPath = "";
    String projectName = "project";
    // windowed mode windowWidth and windowHeight
    int windowWidth = 1024;
    int windowHeight = 768;
    boolean fullscreen = false;
    boolean layers = true;
    int fullscreenDisplay = 2;
    int maxfps = 60;
    int smoothLevel = 2;
    boolean splash = true;
    // Rendering options
    color BACKGROUND_COLOR = #000000;
    int STROKE_CAP = ROUND;//PROJECT;//SQUARE; // or ROUND
    int STROKE_JOIN = ROUND;//MITER; // or BEVEL or ROUND
    boolean BRUSH_SCALING = false;

    // network
    int oscInPort = 6667;
    int oscOutPort = 6668;
    String oscOutIP = "127.0.0.1";
    boolean oscUseTCP = false;
    int websocketPort = 8025;
    boolean serveHTTP = true;
    int httpServerPort = 8000;

    // ui options

    boolean keyRepeat = true;
    int mouseDebounce = 100;
    // Mouse options
    int gridSize = 64;
    int lineToolFixedAngle = 30;
    int lineToolFixedLength = 128;
    // use scrollwheel as - +
    boolean scrollWheelTweaker = false;

    // GUI options
    int cursorSize = 15;
    int cursorGapSize = 10;
    int cursorStrokeWeight = 2;
    int guiTimeout = 10000;
    int guiFontSize = 20;
    int nodeSize = 5;
    int nodeColor = #989898;
    int nodeAlpha = 200;
    int nodeStrokeWeigth = 5;
    int previewLineStrokeWeight = 1;
    color previewLineColor = #ffffff;
    int previewLineAlpha = 200;

    color cursorColor = #FFFFFF;
    int cursorAlpha = 200;
    color cursorColorSnapped = #00FF00;
    int cursorAlphaSnapped = 255;
    boolean enableSnapeToLines = true;
    color guiTextColor = #FFFFFF;
    int guiTextAlpha = 200;
    color gridColor = #969696;//9696;
    int gridAlpha = 150;
    int gridStrokeWeight = 1;//9696;
    color lineSegmentColor = #BEBEBE;
    int lineSegmentAlpha = 150;
    int lineSegmentStrokeWeight = 1;
    color lineSegmentColorUnselected = #2D2D2D;
    int lineSegmentAlphaUnselected = 150;
    color arrowColor = #5D5D5D;
    int arrowAlpha = 150;


    boolean rotateCursorOnSnap = false;

    // Timing and stuff
    int tempo = 1300;
    int seqStepCount = 16;

    // generate documentation on startup, pretty much mandatory now.
    boolean DRAW_FIXTURE_ADDRESS = false;

    public FreelinerProject(){}

    boolean valideProjectFile = false;
    void loadLastProject(){
        String[] lastProjectPath = loadStrings(dataPath("last_project_path"));
        if(lastProjectPath != null){
            if(lastProjectPath.length > 0){
                valideProjectFile = loadProject(lastProjectPath[0]);
            }
        }
    }

    // either create directory, or just set the last project path.
    void setNewProjectPath(String _path){
        // check if it exists
        File f = new File(_path);
        if(f.isDirectory() != true){
            if(f.mkdirs()) {
                println("[project] created dir : "+_path);
            }
            else {
                println("[project] failed to create dir : "+_path);
            }
        }
        fullPath = _path;
        // now check which files are present, if none are create basic ones.
        XML _xml = null;
        try {
            _xml = loadXML(fullPath+"/config.xml");
        }
        catch (Exception e) {
        }
        // if no config file found, create all the basic files needed
        if(_xml == null) {
            println("[project] no config file, creating one : ");
            println(fullPath);
            // save a new config and add relevant directories
            saveConfig();
            makeDir(fullPath+"/shaders");
            makeDir(fullPath+"/images");
            makeDir(fullPath+"/fixtures");
        }
        // File defaultProject = new File(dataPath("default_project"));
        // copyFile(dataPath("defaultProject")+"/macros", fullPath+"/macros");
        String[] _dir = {fullPath};
        saveStrings(dataPath("last_project_path"), _dir);
    }

    void makeDir(String _dir){
        File f = new File(_dir);
        f.mkdirs();
    }
    // void copyFile(String src, String dst){
    //     println(src+"  "+dst);
    //     Path sourceFile = Paths.get(src);
    //     Path targetDir = Paths.get(dst);
    //     Path targetFile = targetDir.resolve(sourceFile.getFileName());
    //     try {
    //         Files.copy(sourceFile, targetFile);
    //     }
    //     catch (FileAlreadyExistsException ex) {
    //         println("----------- File already exists.");
    //     }
    //     catch (IOException ex) {
    //             println("----------- I/O Error when copying file");
    //     }
    // }

    // first thing that gets called when starting freeliner
    // pass a directory, exisiting or to be created
    // will only load the config portion
    boolean loadProject(String path){
        File f = new File(path);
        if(f.isDirectory()) {
            //extract project name
            fullPath = path;
            String[] splt = fullPath.split("/");
            projectName = splt[splt.length-1];
            println("[freeliner] loading project : "+projectName);
            XML _xml = null;
            try {
                _xml = loadXML(fullPath+"/config.xml");
            }
            catch (Exception e) {
                println("[config] ERROR could not load : \n" + path);
                return false;
            }
            loadConfigXML(_xml);
            return true;
        }
        else {
            return false;
        }
    }

    // saveConfig
    void saveConfig(){
        println("[project] saving config to : "+fullPath);
        XML _thing =  new XML("freeliner-data");
        _thing.addChild(makeXML());
        saveXML(_thing, fullPath+"/config.xml");
    }

    void loadConfigXML(XML _xml) {
        if(_xml == null) {
            println("[config] no config to load");
            return;
        }

        XML _config = _xml.getChild("config");
        if(_config == null) {
            println("[config] not a valid config file");
            return;
        }

        XML _renderConfig = _config.getChild("render");
        if(_renderConfig != null) {
            this.windowWidth = _renderConfig.getInt("windowWidth", this.windowWidth);
            this.windowHeight = _renderConfig.getInt("windowHeight", this.windowHeight);
            this.fullscreen = _renderConfig.getInt("fullscreen", this.fullscreen ? 1 : 0) == 1;
            this.fullscreenDisplay = _renderConfig.getInt("fullscreenDisplay", this.fullscreenDisplay);
            this.layers = _renderConfig.getInt("layers", this.layers ? 1 : 0) == 1;
            this.maxfps = _renderConfig.getInt("maxfps", this.maxfps);
            this.smoothLevel = _renderConfig.getInt("smoothLevel", this.smoothLevel);
            this.splash = _renderConfig.getInt("splash", this.splash ? 1 : 0) == 1;
            if(!this.splash) {
                println("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
                println("$$$  I see you disabled splash, consider donating $$$");
                println("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
            }
        }
        XML _networkConfig = _config.getChild("network");
        if(_networkConfig != null) {
            this.oscInPort = _renderConfig.getInt("oscInPort", this.oscInPort);
            this.oscOutPort = _renderConfig.getInt("oscOutPort", this.oscOutPort);
            this.oscOutIP = _renderConfig.getString("oscOutIP", this.oscOutIP);
            this.oscUseTCP = _renderConfig.getInt("oscUseTCP", this.oscUseTCP ? 1 : 0) == 1;
            this.websocketPort = _renderConfig.getInt("websocketPort", this.websocketPort);
            this.serveHTTP = _renderConfig.getInt("serveHTTP", this.serveHTTP ? 1 : 0) == 1;
            this.httpServerPort = _renderConfig.getInt("httpServerPort", this.httpServerPort);
        }

        XML _guiConfig = _config.getChild("gui");
        if(_guiConfig != null) {
            this.cursorSize = _guiConfig.getInt("cursorSize", this.cursorSize);
            this.cursorGapSize = _guiConfig.getInt("cursorGapSize", this.cursorGapSize);
            this.cursorStrokeWeight = _guiConfig.getInt("cursorStrokeWeight", this.cursorStrokeWeight);
            this.guiTimeout = _guiConfig.getInt("guiTimeout", this.guiTimeout);
            this.guiFontSize = _guiConfig.getInt("guiFontSize", this.guiFontSize);
            this.nodeSize = _guiConfig.getInt("nodeSize", this.nodeSize);
            this.nodeColor = strToCol(_guiConfig.getString("nodeColor", hex(this.nodeColor)));
            this.nodeAlpha = _guiConfig.getInt("nodeAlpha", this.nodeAlpha);
            this.nodeStrokeWeigth = _guiConfig.getInt("nodeStrokeWeigth", this.nodeStrokeWeigth);

            this.previewLineStrokeWeight = _guiConfig.getInt("previewLineStrokeWeight", this.previewLineStrokeWeight);
            this.previewLineColor = strToCol(_guiConfig.getString("previewLineColor", hex(this.previewLineColor)));
            this.previewLineAlpha = _guiConfig.getInt("previewLineAlpha", this.previewLineAlpha);
            this.cursorColor = strToCol(_guiConfig.getString("cursorColor", hex(this.cursorColor)));
            this.cursorAlpha = _guiConfig.getInt("cursorAlpha", this.cursorAlpha);
            this.cursorColorSnapped = strToCol(_guiConfig.getString("cursorColorSnapped", hex(this.cursorColorSnapped)));
            this.cursorAlphaSnapped = _guiConfig.getInt("cursorAlphaSnapped", this.cursorAlphaSnapped);
            this.enableSnapeToLines = _guiConfig.getInt("enableSnapeToLines", this.enableSnapeToLines ? 1 : 0) == 1;
            this.guiTextColor = strToCol(_guiConfig.getString("guiTextColor", hex(this.guiTextColor)));
            this.guiTextAlpha = _guiConfig.getInt("guiTextAlpha", this.guiTextAlpha);
            this.gridColor = strToCol(_guiConfig.getString("gridColor", hex(this.gridColor)));
            this.gridAlpha = _guiConfig.getInt("gridAlpha", this.gridAlpha);
            this.gridStrokeWeight = _guiConfig.getInt("gridStrokeWeight", this.gridStrokeWeight);
            this.lineSegmentColor = strToCol(_guiConfig.getString("lineSegmentColor", hex(this.lineSegmentColor)));
            this.arrowColor = strToCol(_guiConfig.getString("arrowColor", hex(this.arrowColor)));
            this.arrowAlpha = _guiConfig.getInt("arrowAlpha", this.arrowAlpha);
            this.lineSegmentColor = strToCol(_guiConfig.getString("lineSegmentColor", hex(this.lineSegmentColor)));
            this.lineSegmentColorUnselected = strToCol(_guiConfig.getString("lineSegmentColorUnselected", hex(this.lineSegmentColorUnselected)));
            this.lineSegmentAlpha = _guiConfig.getInt("lineSegmentAlpha", this.lineSegmentAlpha);
            this.lineSegmentAlphaUnselected = _guiConfig.getInt("lineSegmentAlphaUnselected", this.lineSegmentAlphaUnselected);

            this.rotateCursorOnSnap = _guiConfig.getInt("rotateCursorOnSnap", this.rotateCursorOnSnap ? 1 : 0) == 1;
        }

    }

    color strToCol(String _hex) {
        return unhex(_hex.replaceAll("#","FF").toUpperCase());
    }

    XML makeXML(){
        XML _config = new XML("config");

        XML _renderConfig = _config.addChild("render");
        _renderConfig.setInt("windowWidth", this.windowWidth);
        _renderConfig.setInt("windowHeight", this.windowHeight);
        _renderConfig.setInt("fullscreen", this.fullscreen ? 1 : 0);
        _renderConfig.setInt("fullscreenDisplay", this.fullscreenDisplay);
        _renderConfig.setInt("layers", this.layers ? 1 : 0);
        _renderConfig.setInt("maxfps", this.maxfps);
        _renderConfig.setInt("smoothLevel", this.smoothLevel);
        _renderConfig.setInt("splash", this.splash ? 1 : 0);

        XML _networkConfig =  _config.addChild("network");
        _networkConfig.setInt("oscInPort", this.oscInPort);
        _networkConfig.setInt("oscOutPort", this.oscOutPort);
        _networkConfig.setString("oscOutIP", this.oscOutIP);
        _networkConfig.setInt("oscUseTCP", this.oscUseTCP ? 1 : 0);
        _networkConfig.setInt("websocketPort", this.websocketPort);
        _networkConfig.setInt("serveHTTP", this.serveHTTP ? 1 : 0);
        _networkConfig.setInt("httpServerPort", this.httpServerPort);

        XML _guiConfig = _config.addChild("gui");
        _guiConfig.setInt("cursorSize", this.cursorSize);
        _guiConfig.setInt("cursorGapSize", this.cursorGapSize);
        _guiConfig.setInt("cursorStrokeWeight", this.cursorStrokeWeight);
        _guiConfig.setInt("guiTimeout", this.guiTimeout);
        _guiConfig.setInt("guiFontSize", this.guiFontSize);
        _guiConfig.setInt("nodeSize", this.nodeSize);
        _guiConfig.setString("nodeColor", hex(this.nodeColor));
        _guiConfig.setInt("nodeAlpha", this.nodeAlpha);
        _guiConfig.setInt("nodeStrokeWeigth", this.nodeStrokeWeigth);

        _guiConfig.setInt("previewLineStrokeWeight", this.previewLineStrokeWeight);
        _guiConfig.setString("previewLineColor", hex(this.previewLineColor));
        _guiConfig.setInt("previewLineAlpha", this.previewLineAlpha);
        _guiConfig.setString("cursorColor", hex(this.cursorColor));
        _guiConfig.setInt("cursorAlpha", cursorAlpha);
        _guiConfig.setString("cursorColorSnapped", hex(this.cursorColorSnapped));
        _guiConfig.setInt("cursorAlphaSnapped", cursorAlphaSnapped);
        _guiConfig.setInt("enableSnapeToLines", enableSnapeToLines ? 1 : 0);
        _guiConfig.setString("guiTextColor", hex(this.guiTextColor));
        _guiConfig.setInt("guiTextAlpha", guiTextAlpha);
        _guiConfig.setString("gridColor", hex(this.gridColor));
        _guiConfig.setInt("gridAlpha", gridAlpha);
        _guiConfig.setInt("gridStrokeWeight", gridStrokeWeight);
        _guiConfig.setString("lineSegmentColor", hex(this.lineSegmentColor));
        _guiConfig.setString("arrowColor", hex(this.arrowColor));
        _guiConfig.setInt("arrowAlpha", arrowAlpha);
        _guiConfig.setString("lineSegmentColor", hex(this.lineSegmentColor));
        _guiConfig.setInt("rotateCursorOnSnap", rotateCursorOnSnap ? 1 : 0);

        return _config;
    }
}
