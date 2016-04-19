// A lightweight javascript gui for freeliner!


// fetch the info
setInterval(function() { if(connected) socket.send('fetch infoweb'); }, 100);

/*
 * /////////////////////////////////////////////////////////////
 * webSocket!
 * /////////////////////////////////////////////////////////////
 */
var socket;
var connected = 0;

// start the websocket
window.onload = function (){
  socket = new WebSocket('ws://localhost:8025/freeliner');
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

// send a keyPress to freeliner
function socketSendKeyPress(_event){
  socket.send('raw press '+kbdRules(_event));
}
// send a keyRelease to freeliner
function socketSendKeyReleased(_event) {
  socket.send('raw release '+kbdRules(_event));
}

// some keys returned weird codes, fix em here.
function kbdRules(_event){
  if(_event.keyCode == 13) return 10;
  else if(_event.keyCode == 173) return 45;
  else return _event.keyCode;
}

// prevent keyboard default behaviors, for ctrl-_ tab
document.addEventListener("keydown", function(e) {
  if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
    e.preventDefault();
  }
  else if(e.keyCode == 9) e.preventDefault(); // prevent default for alt key
  //send keyPress to freeliner
  socketSendKeyPress(e);
}, false);

document.addEventListener("keyup", function(e) {
  if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
    e.preventDefault();
  }
  else if(e.keyCode == 9) e.preventDefault(); // prevent default for alt key
  //send keyRelease to freeliner
  socketSendKeyReleased(e);
}, false);
