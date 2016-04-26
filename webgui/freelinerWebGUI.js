// A lightweight javascript gui for freeliner!


// fetch the info at 100 ms intervals
setInterval(function() { if(connected) socket.send('fetch infoweb');}, 100);

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
  socketPrompt();
  updateMenus();
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
  else if(_splt[0] == "webseq") setSeqTags(_info);
}

/*
 * /////////////////////////////////////////////////////////////
 * gui input!
 * /////////////////////////////////////////////////////////////
 */
function setupMenus(){
  menuCallbacks('b');
}

var i, menu_keys = ['a', 'b', 'e','f','h','i','j','o','p','q','r','u','v'];
for ( i = 0; i < menu_keys.length; i++) {
  (function(_key) {
    setTimeout(function() {
      // alert(color);
      document.getElementById(_key+"_key").onchange = function(){
        var _v = document.getElementById(_key+"_key").value;
        console.log('tw $ '+_key+' '+_v);
        socket.send('tw $ '+_key+' '+_v);
      }
      updateParam(_key);
    }, i);
  })(menu_keys[i]);
}



function updateMenus(){
  updateParam('b');
  updateParam('v');
}
// window[a1_NAME_ParentMode]
function updateParam(_key){
  var _select = document.getElementById(_key+"_key");
  if(_key == 'f') _key = 'q';
  removeOptions(_select);
  for(var i = 0; i < window[_key+"_MAX"]; i++){
    var _option = document.createElement("option");
    _option.text = window[_key+i+"_NAME"];
    _option.value = i;
    _select.add(_option);
  }
}


function removeOptions(selectbox){
  var i;
  for(i=selectbox.options.length-1;i>=0;i--)
  {
    selectbox.remove(i);
  }
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

// document.getElementById("seq").onclick = function (e){
//   var _step = e.target.id;
//   _step = _step.replace('step', '');
//   console.log(_step);
//   socket.send("seq toggle $ "+_step);
//   socket.send("fetch webseq");
// }

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
// document.getElementById("shaderSelect0").onclick = function(){
//   socket.send("post shader 0");
// };
// document.getElementById("shaderSelect1").onclick = function(){
//   socket.send("post shader 1");
// };
// document.getElementById("shaderSelect2").onclick = function(){
//   socket.send("post shader 2");
// };
// document.getElementById("shaderSelect3").onclick = function(){
//   socket.send("post shader 3");
// };
// document.getElementById("shaderFader0").oninput = function(){
//   socket.send("post shader 0 "+(document.getElementById("shaderFader0").value/100.0));
// };
// document.getElementById("shaderFader1").oninput = function(){
//   socket.send("post shader 1 "+(document.getElementById("shaderFader1").value/100.0));
// };
// document.getElementById("shaderFader2").oninput = function(){
//   socket.send("post shader 2 "+(document.getElementById("shaderFader2").value/100.0));
// };
// document.getElementById("shaderFader3").oninput = function(){
//   socket.send("post shader 3 "+(document.getElementById("shaderFader3").value/100.0));
// };
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
