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

// start the websocket with default adress on page load
window.onload = function (){
  socketPrompt();
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
    var mess = evt.data;
    var nfo = document.getElementById("infoline").innerHTML = mess;
  }
}

/*
 * /////////////////////////////////////////////////////////////
 * gui input!
 * /////////////////////////////////////////////////////////////
 */

document.getElementById("pickColor").onclick = function (){
  var _c = document.getElementById('colorPicker').value;
  socket.send('tw $ q 28');
  socket.send('tp color $ '+_c);
};

// gets called from eventListener
function cmdPrompt(e){
  if(e.keyCode == 13) {
    socket.send(document.getElementById("prompt").value);
    document.getElementById("prompt").value = "";
  }
}

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
document.addEventListener("contextmenu", function(e){
  e.preventDefault();
}, false);

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
  else socket.send('raw press '+kbdRules(e));

  //send keyPress to freeliner
}, false);


document.addEventListener("keyup", function(e) {
  // catch ctrlKey
  if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) e.preventDefault();
  // prevent default for tab key
  else if(e.keyCode == 9) e.preventDefault();
  //send keyRelease to freeliner
  socket.send('raw release '+kbdRules(e));
}, false);
