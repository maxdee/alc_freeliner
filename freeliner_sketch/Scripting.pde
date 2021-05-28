
import javax.script.ScriptEngineManager;
import javax.script.ScriptEngine;
import javax.script.ScriptException;

import javax.script.Invocable;
import javax.script.Compilable;
import javax.script.CompiledScript;

// struct of data needed to make stuff happen.
// public class DataBroker{
//     public int beat
//     public float unitinterval
// }

// tw ABC q #beat%5

class ScriptHandler{
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("Nashorn");
    CompiledScript globals;
    // CompiledScript compiledOneLiner;
    CompiledScript compiledScriptFile;
    String exp;
    String cmd;
    ArrayList<String> expressionList;
    ArrayList<String> cmdBuffer;
    int frameCounter = 0;
    FileWatcher scriptFile;
    // ScriptEngineFactory sef;
    int beatTracker = 0;
    boolean validScriptfile = false;
    boolean newBeat = false;
    boolean newEdit = false;
    public ScriptHandler(PApplet _pa){
        engine.put("width", width);
        engine.put("height", height);
        evalJS(engine, "function r(v){return Math.random()*v}");
        evalJS(engine, "function s(v){return Math.sin(v)}");
        evalJS(engine, "function i(v){return Math.round(v)}");
        evalJS(engine, "function cmd(a){return String(a)}");
        // evalJS(engine, "var PApplet = Java.type('processing.core.PApplet');");
        // engine.put("pa", _pa);
        // evalJS(engine, "function println(s){pa.println(s);}");
        // sef = engine.getFactory();
        cmdBuffer = new ArrayList<String>();
        scriptFile = new FileWatcher();
    }

    // public void setOneLiner(String s){
    //     compiledOneLiner = compileJS(engine,"cmd("+s+")");// exp);
    // }

    public void updateScriptVariables(int beat, float time){
        engine.put("time", time);
        if(beatTracker != beat){
            beatTracker = beat;
            engine.put("beat", beat);
            newBeat = true;
        }
        else {
            newBeat = false;
        }
        engine.put("millis", millis());
        if(scriptFile.hasChanged()){
            String[] lines = loadStrings(projectConfig.fullPath+"/script.js");
            String l = join(lines, "\n");
            //  :S :S
            if(l.length() > 2) validScriptfile = true;
            else validScriptfile = false;
            evalJS(engine, l);
            newEdit = true;
        }
    }

    public void evaluate(){
        // if(compiledOneLiner != null){
        //     String c = (String)runJS(compiledOneLiner);
        //     addCommand(c);
        // }
        if(validScriptfile && true){
            frameCounter++;
            String c = "";
            if(frameCounter%3 == 0){
                c = (String)evalJS(engine, "onFrame();");
                addCommand(c);
            }
            // println(c);
            if(newBeat){
                String b = (String)evalJS(engine, "onBeat();");
                // shady hack, we should check on pilation
                if(c == null || b == null) validScriptfile =false;
                if(newEdit){
                    newEdit = false;
                    println("----- scrpt output :");
                    println("onFrame(); -> "+c);
                    println("onBeat(); -> "+b);
                }
                addCommand(b);
                newBeat = false;
            }
        }

    }
    public void addCommand(String s){
        if(s != null){
            if(s.length() > 2){
                cmdBuffer.add(s);
                // println("[scripting] "+s);
            }
        }
    }
    public void setScriptFile(String s){
        scriptFile = new FileWatcher(s);
        scriptFile.setDelay(500);
    }
}

@ SafeVarargs static final Object evalJS
    (final ScriptEngine js, final String... statements) {
    final String expression = PApplet.join(statements, PConstants.ENTER);

    try {
        return js.eval(expression);
    }
    catch (final ScriptException cause) {
        PApplet.println(cause);
        System.err.println(expression);
        // throw new RuntimeException(cause);
        return null;
    }
}

@ SafeVarargs static final CompiledScript compileJS
  (final ScriptEngine engine, final String... statements) {
    final String expression = PApplet.join(statements, PConstants.ENTER);
    try {
        return ((Compilable) engine).compile(expression);
    }
    catch (final ScriptException cause) {
        PApplet.println(cause);
        System.err.println(expression);
        // throw new RuntimeException(cause);
        return null;
    }
}

static final Object runJS
    (final CompiledScript compiled) {
    try {
        return compiled.eval();
    }
    catch (final ScriptException cause) {
        PApplet.println(cause);
        // throw new RuntimeException(cause);
        return null;
    }
}
