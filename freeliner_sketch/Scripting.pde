
import javax.script.ScriptEngineManager;
import javax.script.ScriptEngine;
import javax.script.ScriptException;

import javax.script.Invocable;
import javax.script.Compilable;
import javax.script.CompiledScript;
// struct of data needed to make stuff happen.
// public class DataBroker{
//     public int beat()
// }

// tw ABC q #beat%5

class ScriptHandler{
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("Nashorn");
    CompiledScript globals;
    CompiledScript compiled;
    String exp;
    String cmd;
    ArrayList<String> cmdBuffer;
    // add commands

    public ScriptHandler(String s){
        // cmd = split(s,'#')[0];
        // exp = split(s,'#')[1];
        engine.put("width", width);
        engine.put("height", height);
        evalJS(engine, "function r(v){return Math.random()*v}");
        evalJS(engine, "function s(v){return Math.sin(v)}");
        evalJS(engine, "function i(v){return Math.round(v)}");
        evalJS(engine, "function cmd(a){return String(a)}")


        // globals = compileJS(engine, "w = "+width+", h = "+height);
        compiled = compileJS(engine,"cmd("+s+")");// exp);
        cmdBuffer = new ArrayList<String>();
    }

    public void evaluate(int beat, float time){
        engine.put("time", time);
        engine.put("beat", beat);

        // double res = (double)runJS(compiled);
        String c = (String)runJS(compiled);
        // int r = (int)(res);
        println(c);//cmd+" "+r);
        cmdBuffer.add(c);//cmd+""+r);
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
        throw new RuntimeException(cause);
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
        throw new RuntimeException(cause);
    }
}

static final Object runJS
    (final CompiledScript compiled) {
    try {
        return compiled.eval();
    }
    catch (final ScriptException cause) {
        PApplet.println(cause);
        throw new RuntimeException(cause);
    }
}
