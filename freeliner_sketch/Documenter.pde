/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-04-01
 */

// for detecting fields
import java.lang.reflect.Field;


/**
 * The FreelinerCommunicator handles communication with other programs over various protocols.
 */
class Documenter implements FreelinerConfig {
    ArrayList<ArrayList<Mode>> docBuffer;
    ArrayList<String> sections;
    PrintWriter markDown;
    XML freelinerModes;
    IntDict modeLimits;

    JSONObject freelinerJSON;
    JSONObject modesJSON;

    /**
     * Constructor
     */
    public Documenter() {
        docBuffer = new ArrayList();
        sections = new ArrayList();
        // sections.add("First");
        freelinerJSON = new JSONObject();
        modesJSON = new JSONObject();

        freelinerModes = new XML("freelinerModes");
        modeLimits = new IntDict();
        markDown = createWriter(sketchPath()+"/data/doc/autodoc.md");
        markDown.println("Generated on "+year()+"/"+month()+"/"+day()+" with freeliner version "+VERSION);
    }

    /**
     * Add a array of "modes", their associated key, and their section name.
     * @param Mode[] array of modes to be added to doc.
     * @param char key associated with mode slection (q for stroke color)
     * @param String section name (ColorModes)
     */
    void documentModes(Mode[] _modes, char _key, Mode _parent, String _section) {
        if(!hasSection(_section)) {
            sections.add(_section);
            addModesToMarkDown(_modes,_key,_parent);
            storeLimits(_key, _modes.length);
            addModesToJSON(_modes,_key,_parent);
        }
    }

    void storeLimits(char _k, int _n) {
        String _key = str(_k);
        if(modeLimits.hasKey(_key)) {
            if(modeLimits.get(_key) < _n) modeLimits.set(_key, _n);
        }
        else modeLimits.add(_key, _n);
    }

    /**
     * As many things get instatiated we need to make sure we only add a section once
     * @param String sectionName
     */
    boolean hasSection(String _section) {
        for(String _s : sections) {
            if(_section.equals(_s)) return true;
        }
        return false;
    }

    public void doDocumentation(KeyMap _km) {

        // documentKeysMarkDown();
        // markDown.flush();
        // markDown.close();

        keyMapToJSON(_km);
        keyMapToMarkDown(_km);
        // addConfigToJSON();
        // miscInfoJSON();
        freelinerJSON.setJSONObject("modes", modesJSON);
        saveJSONObject(freelinerJSON, sketchPath()+"/data/webgui/freelinerData.json");
        println("**** Documentation Updated ****");
        markDown.flush();
        markDown.close();
    }

    // void miscInfoJSON(){
    //   // int _index = 0;
    //   JSONArray stuffArray = new JSONArray();
    //   JSONObject misc = new JSONObject();
    //   misc.setString("ip", getIP());
    //   stuffArray.append(misc);
    //   freelinerJSON.setJSONArray("misc", stuffArray);
    // }
    //
    // String getIP(){
    //   return Server.ip();
    // }

    // add modes to JSON data
    void addModesToJSON(Mode[] _modes, char _key, Mode _parent) {
        // int _index = 0;
        JSONArray modeArray = new JSONArray();
        for(Mode _m : _modes) {
            println(_m.getName());
            JSONObject mode = new JSONObject();
            mode.setInt("index", _m.getIndex());
            mode.setString("key", str(_key));
            mode.setString("name", _m.getName());
            mode.setString("description", _m.getDescription());
            modeArray.append(mode);
        }
        if(_key == 'a') modesJSON.setJSONArray(str(_key)+"_b"+_parent.getIndex(), modeArray);
        else modesJSON.setJSONArray(str(_key), modeArray);
    }

    void addConfigToJSON() {
        Dummy  _dum = new Dummy();
        Field[] fields = _dum.getClass().getFields();
        for(Field _f : fields) {
            try {
                // if(_f.getType().equals(int.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
                // else if(_f.getType().equals(boolean.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
                // else if(_f.getType().equals(String.class)) javaScript.println("var "+_f.getName()+" = '"+_f.get(_dum)+"';");
            }
            catch (Exception _e) {
                println("Documenter : Field not reflected "+_f);
            }
        }
    }

    public void keyMapToJSON(KeyMap _km) {
        JSONArray jsonKeyMap = new JSONArray();
        for(ParameterKey _pk : _km.getKeyMap()) {
            if(_pk != null) {
                JSONObject _jspk = new JSONObject();
                _jspk.setInt("ascii", int(_pk.getKey()));
                _jspk.setString("key", str(_pk.getKey()));
                _jspk.setInt("type", _pk.getType());
                _jspk.setString("name", _pk.getName());
                _jspk.setString("cmd", _pk.getCMD());
                _jspk.setInt("max", _pk.getMax());
                _jspk.setString("description", _pk.getDescription());
                jsonKeyMap.append(_jspk);
            }
        }
        freelinerJSON.setJSONArray("keys", jsonKeyMap);
    }

    void addModesToMarkDown(Mode[] _modes, char _key, Mode _parent) {
        // markDown.println("| "+_key+" |  for : "+_parent.getName()+" | Description |");
        // markDown.println("|:---:|---|---|");
        // int _index = 0;
        // for(Mode _m : _modes){
        //   markDown.println("| `"+_index+"` | "+_m.getName()+" | "+_m.getDescription()+" |");
        //   _index++;
        // }
        // markDown.println(" ");
    }


    /**
     * Creates markdown for keyboard shortcuts!
     */
    void keyMapToMarkDown(KeyMap _km) {
        String[] typeStrings = {"action","on off","on off + value","value","value","value","action", "macro"};
        // print keyboard type, osx? azerty?
        markDown.println("### keys ###");
        markDown.println("| key | parameter | type | description | cmd |");
        markDown.println("|:---:|---|---|---|---|");
        for(ParameterKey _pk : _km.getKeyMap()) {
            if(_pk != null) {
                int _k = (int)_pk.getKey();
                String _ctrlkey = (_k >= 65 && _k <=90) ? "ctrl-"+char(_k+32) : str(_pk.getKey());
                markDown.println("| `"+_ctrlkey+"` | "+
                                 _pk.getName()+" |"+
                                 typeStrings[_pk.getType()]+" |"+
                                 _pk.getDescription()+" | `"+
                                 _pk.getCMD()+"` |");
            }
        }
        markDown.println(" ");
    }
}


class Dummy implements FreelinerConfig {
    public Dummy() {}
}
