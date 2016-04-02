


class Documenter implements FreelinerConfig{
  ArrayList<ArrayList<Mode>> docBuffer;
  ArrayList<String> sections;
  PrintWriter output;

  public Documenter(){
    docBuffer = new ArrayList();
    sections = new ArrayList();
    sections.add("First");
    output = createWriter("autodoc.md");
  }

  void addDoc(Mode[] _modes, char _key, String _section){
    if(!hasSection(_section)){
      sections.add(_section);
      ArrayList<Mode> _buff = new ArrayList();
      for(Mode _m : _modes) _buff.add(_m);
      docBuffer.add(_buff);
    }
  }

  boolean hasSection(String _section){
    for(String _s : sections)
      if(_s.equals(_section)) return true;
    return false;
  }

  void outputDoc(){
    for(ArrayList<Mode> _section : docBuffer){
      addDocToFile(_section);
    }
    output.flush();
    output.close();
    println("Saved doc to : "+"autodoc.md");
  }

  void addDocToFile(ArrayList<Mode> _modes){
    output.println("| Modes for : |");
    int _index = 0;
    for(Mode _m : _modes){
      output.println("| "+_index+" | "+_m.getName()+" | "+_m.getDescription()+" |");
      _index++;
    }
  }

}
