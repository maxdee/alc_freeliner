// A lightweight javascript gui for freeliner!


// fetch the info at 100 ms intervals
setInterval(function() { if(connected) socket.send('fetch-ws infoline');}, 200);

/*
 * /////////////////////////////////////////////////////////////
 * webSocket!
 * /////////////////////////////////////////////////////////////
 */
var socket;
var connected = 0;
var DEFAULT_WEBSOCKET_ADDR = 'ws://localhost:8025/freeliner';
var guiWindow;
// start the websocket with default adress on page load
window.onload = function (){
  loadKeys();
  makeTemplateSelector();
  socketPrompt();
  // updateGuiParams();
}

function socketPrompt() {
    var _addr = prompt("connect to", DEFAULT_WEBSOCKET_ADDR);
    if (_addr != null) connectSocket(_addr);
    else connectSocket(DEFAULT_WEBSOCKET_ADDR);
}

// connect to a websocket
function connectSocket(_adr){
  socket = new WebSocket(_adr);
  connected = 0;
  socket.onopen = function() {
    console.log("Socket has been opened!");
    connected = 1;
  }
  socket.onmessage = function (evt) {
    // var mess =
    parseInfo(evt.data);
    // var nfo = document.getElementById("infoline").innerHTML = mess;
  }
  if(connected == 0) document.getElementById("infoline").innerHTML = "could not connect";
}

function parseInfo(_info){
  var _splt = _info.split(" ",1);
  if(_splt[0] == "info") setInfo(_info);
  else if(_splt[0] == "seq") setSeqTags(_info);
  else if(_splt[0] == "template") setTemplateStat(_info);
  else console.log("Received ? :"+_info);
}

function setTemplateStat(_info){
  var _parts = _info.split(" ");
  var _keys = _parts.slice(2);
  for(var i in _keys){
    var _kv = _keys[i].split("-");
    var _id = _kv[0]+"_KEY";
    var _div = document.getElementById(_id);
    if(_div) _div.firstElementChild.value = parseInt(_kv[1]);
  }
}

/*
 * /////////////////////////////////////////////////////////////
 * gui input!
 * /////////////////////////////////////////////////////////////
 */
var selectedTemplate = '_';
function makeTemplateSelector(){
  var _table = document.getElementById("templateSelector");
  var _row = _table.insertRow(0);
  for(var i = 65; i <= 90; i++){
    var _cell = _row.insertCell(i-65);
    _cell.innerHTML = String.fromCharCode(i);
    _cell.setAttribute("class", "tpCell");
  }
  _table.onclick = function(e){selectTemplateCell(e)};
  document.getElementById("alphabetWidget").appendChild(_table);
}

function selectTemplateCell(_event){
  _event = _event || window.event;
  var _target = _event.srcElement || _event.target;
  if(_target.className != 'tpCell') return;
  var _table = document.getElementById("templateSelector").getElementsByTagName('td');
  var _cell;
  for(_cell in _table){
    _table[_cell].className = "tpCell";
  }
  _target.className = "tpSelected";
  selectTemplate(_target.innerHTML);
}

function selectTemplate(_tag){
  selectedTemplate = _tag;
  // socket.send("fetch-ws template "+selectedTemplate);
  // socket.send("hid press 27 27"); // unselect
  // socket.send("hid press 15 15");
  // socket.send("hid press "+_tag.charCodeAt(0)+" "+_tag.charCodeAt(0));
  // socket.send("hid release 15 15");
  socket.send("fetch-ws template "+selectedTemplate);
}


// iterate over the keyMap provided by freeliner
function loadKeys(){
  var i;
  for ( i = 0; i < 255; i++) {
    if(typeof keyMap[i] != 'undefined'){
      (function(_param) {
        setTimeout(function() {
          addKey(_param);
        }, 0);
      })(keyMap[i]);
    }
  }
  setTimeout(function() { updateMenus(); }, 200);
}

// add a parameterKey configuration
function addKey(_param){
  // console.log("adding "+_param["name"]);
  var _input;
  if(_param["type"] == 0){
    _input = document.createElement("input");
    _input.setAttribute("id", _param["key"]+"_BUTTON");
    _input.setAttribute("type", "button");
    _input.setAttribute("name", _param["desc"]);
    _input.setAttribute("innerHTML", _param["name"]);
  }
  else if(_param["type"] == 1){
    _input = document.createElement("input");
    _input.setAttribute("id", _param["key"]+"_CHECKBOX");
    _input.setAttribute("type", "checkbox");
    _input.setAttribute("name", _param["desc"]);
  }
  else if(_param["type"] == 2){
    _input = document.createElement("input");
    _input.setAttribute("type", "number");
    _input.setAttribute("min", 0);
    _input.setAttribute("max", _param["max"]);
    _input.setAttribute("id", _param["key"]+"_NUM");
  }
  else if(_param["type"] == 3){
    _input = document.createElement("input");
    _input.setAttribute("type", "number");
    _input.setAttribute("min", 0);
    _input.setAttribute("max", _param["max"]);
    _input.setAttribute("id", _param["key"]+"_NUM");
  }
  else if(_param["type"] == 4){
    _input = document.createElement("input");
    _input.setAttribute("type", "range");
    _input.setAttribute("min", 0);
    _input.setAttribute("max", _param["max"]);
    _input.setAttribute("id", _param["key"]+"_NUM");
  }
  else  if(_param["type"] == 5){
    _input = document.createElement("select");
    _input.setAttribute("id", _param["key"]+"_SELECT");
    _input.setAttribute("title", _param["desc"]);
    _input.setAttribute("class", "selecta");
  }

  // _input.setAttribute("class", "selecta");
  if(typeof _input == 'undefined') return;
  var _cb = function(){
    var _v = _input.value;
    var _cmd = _param["cmd"].replace("$", selectedTemplate)+" "+_v;
    socket.send(_cmd);
  }
  if(_param["type"] == 0) _input.onclick = _cb;
  else if(_param["type"] == 4) _input.oninput = _cb;
  else if(_param["type"] == 5) _input.onchange = _cb;
  else _input.onchange = _cb;


  var _wrapper = document.getElementById(_param["key"]+"_KEY");
  var _name;
  var _k = _param["key"].charCodeAt(0);
  if(_k >= 65 && _k <= 90) {
    _name = document.createTextNode("(ctrl-"+_param["key"]+")"+_param["name"]);
  }
  else _name = document.createTextNode("("+_param["key"]+")"+_param["name"]);
  if(_wrapper != null){
    _wrapper.appendChild(_name);
    _wrapper.appendChild(_input);
    _wrapper.setAttribute("title", _param["desc"]);
  }
}

function updateMenus(){
  var i;
  for(i = 0; i < 255; i++) updateParam(keyMap[i]);
}

function updateParam(_param){
  if(_param == null) return;
  if(_param["max"] >= 127) return;

  var _key = _param["key"];
  var _id = _param["key"]+"_SELECT";
  var _select = document.getElementById(_id);
  // console.log(_id+" "+_select);
  if(_select == null) return;

  if(_key == 'f') _key = 'q';
  removeOptions(_select);
  for(var i = 0; i < _param["max"]; i++){
    var _option = document.createElement("option");
    _option.text = window[_key+i+"_NAME"];
    _option.value = i;
    _select.add(_option);
  }
}

function removeOptions(selectbox){
  var i;
  for(i=selectbox.options.length-1;i>=0;i--) selectbox.remove(i);
}
// document.getElementById("renderMode").setAttribute("max", RENDER_MODE_COUNT);
// document.getElementById("renderMode").onchange = function (){
//   socket.send('tw $ b '+document.getElementById("renderMode").value);
// }
//
// document.getElementById("renderLayer").setAttribute("max", MAX_RENDER_LAYER_COUNT);
// document.getElementById("renderLayer").onchange = function (){
//   socket.send('tw $ p '+document.getElementById("renderLayer").value);
// }
// if(RENDERING_PIPELINE == 0) document.getElementById("renderLayer").disabled = true;
//


function setInfo(_info){
  document.getElementById("infoline").innerHTML = _info.replace('info', '');
}

function setSeqTags(tags){
  var _steps = tags.replace('webseq /', '').split('/');
  for(var i = 0; i < _steps.length; i++){
    document.getElementById('step'+i).innerHTML = _steps[i];
  }
}

function labelStep(i, s){
  document.getElementById('step'+i).innerHTML = _steps[i];
}


document.getElementById("openRef").onclick = function (){
  socket.send('geom webref');
  window.open("reference.png", "geometry reference", "width=1000,height=700");
}


document.getElementById("fileInput").onchange = function (){
  var _file = document.getElementById('fileInput').value;
  socket.send('geom load '+_file);
}

document.getElementById("strokePicker").onchange = function (){
  var _c = document.getElementById("strokePicker").value;
  socket.send('tw $ q 28');
  socket.send('tp color $ '+_c);
};

document.getElementById("fillPicker").onchange = function (){
  var _c = document.getElementById("fillPicker").value;
  socket.send('tw $ f 28');
  socket.send('tp color $ '+_c);
};

// gets called from eventListener
function cmdPrompt(e){
  if(e.keyCode == 13) {
    socket.send(document.getElementById("prompt").value);
    document.getElementById("prompt").value = "";
  }
}
//
document.getElementById("shaderSelect0").onclick = function(){
  socket.send("post shader 0");
};
document.getElementById("shaderSelect1").onclick = function(){
  socket.send("post shader 1");
};
document.getElementById("shaderSelect2").onclick = function(){
  socket.send("post shader 2");
};
document.getElementById("shaderSelect3").onclick = function(){
  socket.send("post shader 3");
};
document.getElementById("shaderFader0").oninput = function(){
  socket.send("post shader 0 "+(document.getElementById("shaderFader0").value/100.0));
};
document.getElementById("shaderFader1").oninput = function(){
  socket.send("post shader 1 "+(document.getElementById("shaderFader1").value/100.0));
};
document.getElementById("shaderFader2").oninput = function(){
  socket.send("post shader 2 "+(document.getElementById("shaderFader2").value/100.0));
};
document.getElementById("shaderFader3").oninput = function(){
  socket.send("post shader 3 "+(document.getElementById("shaderFader3").value/100.0));
};
/*
 * /////////////////////////////////////////////////////////////
 * mouse section!
 * /////////////////////////////////////////////////////////////
 */

// prevent rightclick context menu
// document.addEventListener("contextmenu", function(e){
//   e.preventDefault();
// }, false);



/*
 * /////////////////////////////////////////////////////////////
 * keyboard section!
 * /////////////////////////////////////////////////////////////
 */

// some keys returned weird codes, fix em here.
function kbdRules(_event){
  if(_event.keyCode == 13) return 10;
  else if(_event.keyCode == 173) return 45;
  else return _event.keyCode;
}

// prevent keyboard default behaviors, for ctrl-_ tab
document.addEventListener("keydown", function(e) {
  // catch ctrlKey
  if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) e.preventDefault();
  // prevent default for tab key
  else if(e.keyCode == 9) e.preventDefault();
  if (document.activeElement == document.getElementById("prompt")) cmdPrompt(e);
  else socket.send('hid press '+kbdRules(e)+" "+e.key);

  //send keyPress to freeliner
}, false);

document.addEventListener("keyup", function(e) {
  // catch ctrlKey
  if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) e.preventDefault();
  // prevent default for tab key
  else if(e.keyCode == 9) e.preventDefault();
  //send keyRelease to freeliner
  socket.send('hid release '+kbdRules(e)+" "+e.key);
}, false);
