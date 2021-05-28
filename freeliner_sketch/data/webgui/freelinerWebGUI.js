// A lightweight(?) javascript gui for freeliner!

// globals
var sendCMD, cmdPrompt, flData, selectedTemplate, selectedLayer, selectedLayerType, availableFiles;
// the selected template is the template selected by clicking on the alphabetWidget
selectedTemplate = '_';
selectedLayer = 'none';
selectedLayerType = 'none';


/*
 * /////////////////////////////////////////////////////////////
 * main or whatever
 * /////////////////////////////////////////////////////////////
 */

// fetch the info at 200 ms intervals
setInterval(function() {
    actualySendCMD('fetch-ws infoline');
}, 200);

window.onload = function () {
    // if(typeof InstallTrigger == 'undefined') setInfo("browser not supported, plz use firefox or ?");
}

/*
 * /////////////////////////////////////////////////////////////
 * webSocket!
 * /////////////////////////////////////////////////////////////
 */

function sendCMD(_cmd) {
    actualySendCMD(_cmd);
    // display it!
    document.getElementById("logline").innerHTML = _cmd;
}

// make a function to send commands through a websocket
actualySendCMD = (function () {
    var socket, _addr, DEFAULT_WEBSOCKET_ADDR;
    DEFAULT_WEBSOCKET_ADDR = 'ws://' + window.location.hostname + ':8025/freeliner';
    _addr = prompt("connect to", DEFAULT_WEBSOCKET_ADDR);
    if (_addr != null) socket = makeSocket(_addr);
    else socket = makeSocket(DEFAULT_WEBSOCKET_ADDR);
    return function (_cmd) {
        if(socket.readyState) {
            socket.send(_cmd);
            // console.log(_cmd);
        }
        else setInfo("start freeliner and refresh to connect");
    }
})();

// make a websocket
function makeSocket(_adr) {
    var socket = new WebSocket(_adr);
    socket.onopen = function() {
        populateGUI();
    }
    socket.onmessage = function (evt) {
        parseInfo(evt.data);
    }
    return socket;
}

/*
 * /////////////////////////////////////////////////////////////
 * Freeliner feedback
 * /////////////////////////////////////////////////////////////
 */

// the callback for incoming commands
function parseInfo(_info) {
    var _splt = _info.split(" ",1);
    if(_splt[0] == "info") setInfo(_info);
    else if(_splt[0] == "seq") setSeqTags(_info);
    else if(_splt[0] == "template") setTemplateStat(_info);
    else if(_splt[0] == "layers") parseLayerInfo(_info);
    else if(_splt[0] == "files") parseAvailableFiles(_info);

    else console.log("Received ? :"+_info);
}

// load parameters of template into interface
function setTemplateStat(_info) {
    var _keys, _kv, _id, _div, _aVal;
    _keys = _info.split(" ").slice(2);
    for(var i in _keys) {
        _kv = _keys[i].split("-");
        _id = _kv[0]+"_KEY";
        _div = document.getElementById(_id);
        if(_div) _div.lastChild.value = parseInt(_kv[1]);
    }
    // update animation menu
    _div = document.getElementById("a_KEY");
    _aVal = _div.firstElementChild.value;
    updateKeyMenu('a');//xxx
    _div.lastChild.value = _aVal;
}

function parseAvailableFiles(_info) {
    availableFiles = _info.split(" ").slice(1);
    // console.log(availableFiles);
}

/*
 * /////////////////////////////////////////////////////////////
 * Interface loading
 * /////////////////////////////////////////////////////////////
 */

// called when the socket opens, this way we get fresh info from freeliner
function populateGUI() {
    loadJSON(function(response) {
        flData = JSON.parse(response);
        actualySendCMD("fetch-ws files");
        makeTemplateSelector();
        // creates appropriate input elements for keys present in html
        loadKeys();
        // loads options into menus
        updateMenus();
        // add callbacks to other misc
        otherInputCallbacks();
        popupCallbacks();
        shaderSliderCallbacks();
        colorsCallbacks();
        updateLayerStack();
    });
}


// fetch json data
function loadJSON(callback) {
    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', 'freelinerData.json', true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
        if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
        }
    };
    xobj.send(null);
}

// makes a table with the alphabet, used to select a single template to edit with the gui features
function makeTemplateSelector() {
    var _table, _row, _cell;
    _table = document.getElementById("templateSelector");
    _row = _table.insertRow(0);
    // to test
    _cell = _row.insertCell();
    _cell.innerHTML = "*";
    _cell.setAttribute("title", "ALL THE TEMPLATES");
    _cell.setAttribute("class", "tpCell");
    // to test
    _cell = _row.insertCell();
    _cell.innerHTML = "$";
    _cell.setAttribute("title", "MANUALY SELECTED");
    _cell.setAttribute("class", "tpCell");
    var i;
    for(i = 65; i <= 90; i++) {
        _cell = _row.insertCell(i-65);
        _cell.innerHTML = String.fromCharCode(i);
        _cell.setAttribute("class", "tpCell");
    }
    _table.onclick = function(e) {
        selectTemplateCell(e)
    };
    document.getElementById("alphabetWidget").appendChild(_table);
}

// alphabetWidget callback, parses event to figure out which cell is clicked, then selects template
function selectTemplateCell(_event) {
    var _target, _table, _cell;
    _event = _event || window.event;
    _target = _event.srcElement || _event.target;
    if(_target.className != 'tpCell') return;
    _table = document.getElementById("templateSelector").getElementsByTagName('td');
    // make all not highligted
    for(_cell in _table) {
        _table[_cell].className = "tpCell";
    }
    // highlight selected
    _target.className = "tpSelected";
    selectTemplate(_target.innerHTML);
}
// actual selects a template
function selectTemplate(_tag) {
    selectedTemplate = _tag;
    actualySendCMD("fetch-ws template "+selectedTemplate);
}

// iterate over the keyMap provided by freeliner
function loadKeys() {
    var i, _keys;
    _keys = flData["keys"];
    for(i in _keys) {
        (function(_keyConfig) {
            setTimeout(function() {
                addKey(_keyConfig);
            }, 0);
        })(_keys[i]);
    }
    setTimeout(function() {
        updateMenus();
    }, 0);
}

// add a parameterKey configuration
function addKey(_keyConfig) {
    // create a appropriate input element
    var _input = makeInputForKey(_keyConfig);
    if(typeof _input == 'undefined') return;
    // make input element callback
    var _cb, _v, _cmd
    // the general callback for input
    _cb = function() {
        _v = _input.value;
        _cmd = _keyConfig["cmd"].replace("$", selectedTemplate)+" "+_v;
        sendCMD(_cmd);
        // maybe sendCMD animation menu
        if(_keyConfig["key"]=="b") {
            updateKeyMenu('a');// xxx
        }
    }
    // connect callback to appropriate event
    if(_keyConfig["type"] == 0) _input.onclick = _cb;
    else if(_keyConfig["type"] == 4) _input.oninput = _cb;
    else if(_keyConfig["type"] == 5) _input.onchange = _cb;
    else _input.onchange = _cb;

    // now add the input to the appropriate div wrapper
    var _wrapper, _name, _k;
    _wrapper = document.getElementById(_keyConfig["key"]+"_KEY");
    _name;
    _k = _keyConfig["key"].charCodeAt(0);
    // if capital letter, is a control-key option
    if(_k >= 65 && _k <= 90) {
        _name = document.createElement("span");
        _name.innerHTML = "(ctrl-"+_keyConfig["key"]+")"+_keyConfig["name"];
    }
    else {
        _name = document.createElement("span");
        _name.innerHTML = "("+_keyConfig["key"]+")"+_keyConfig["name"];
    }
    if(_wrapper != null) {
        _wrapper.appendChild(_name);
        _wrapper.appendChild(_input);
        _wrapper.setAttribute("title", _keyConfig["description"]);
    }
}

// create a input elements according to a specific type
function makeInputForKey(_keyConfig) {
    var _input;
    if(_keyConfig["type"] == 0) {
        _input = document.createElement("input");
        _input.setAttribute("id", _keyConfig["key"]+"_BUTTON");
        _input.setAttribute("type", "button");
        _input.setAttribute("name", _keyConfig["description"]);
        _input.setAttribute("innerHTML", _keyConfig["name"]);
    }
    else if(_keyConfig["type"] == 1) {
        _input = document.createElement("input");
        _input.setAttribute("id", _keyConfig["key"]+"_CHECKBOX");
        _input.setAttribute("type", "checkbox");
        _input.setAttribute("name", _keyConfig["description"]);
    }
    else if(_keyConfig["type"] == 2) {
        _input = document.createElement("input");
        _input.setAttribute("type", "number");
        _input.setAttribute("min", 0);
        _input.setAttribute("max", _keyConfig["max"]);
        _input.setAttribute("id", _keyConfig["key"]+"_NUM");
    }
    else if(_keyConfig["type"] == 3) {
        _input = document.createElement("input");
        _input.setAttribute("type", "number");
        _input.setAttribute("min", 0);
        _input.setAttribute("max", _keyConfig["max"]);
        _input.setAttribute("id", _keyConfig["key"]+"_NUM");
    }
    else if(_keyConfig["type"] == 4) {
        _input = document.createElement("input");
        _input.setAttribute("type", "range");
        _input.setAttribute("min", 0);
        _input.setAttribute("max", _keyConfig["max"]);
        _input.setAttribute("id", _keyConfig["key"]+"_NUM");
    }
    else  if(_keyConfig["type"] == 5) {
        _input = document.createElement("select");
        _input.setAttribute("id", _keyConfig["key"]+"_SELECT");
        _input.setAttribute("title", _keyConfig["description"]);
        _input.setAttribute("class", "selecta");
    }
    return _input;
}

// populate the menus according to options
function updateMenus() {
    var i, _keys;
    _keys = flData["keys"];
    for(i in _keys) {
        if(_keys[i]["type"] == 5) updateKeyMenu(_keys[i]["key"]);
    }
}

// update a input select element with corresponding modes
function updateKeyMenu(_key) {
    var _id, _select, _val;
    _id = _key+"_SELECT";
    _select = document.getElementById(_id);
    // key might not be in html
    if(_select == null) return;
    _val = _select.value;
    // fill has same options as stroke
    if(_key == 'f') _key = 'q';
    // clear the menu
    removeOptions(_select);
    var i, _modeArray, _option, _bValue;
    if(_key == 'a') {
        _bValue = document.getElementById("b_KEY").lastChild.value;
        _modeArray = flData["modes"]["a_b"+_bValue];
    }
    else _modeArray = flData["modes"][_key];

    for(i in _modeArray) {
        _option = document.createElement("option");
        _option.text = _modeArray[i]["name"];
        _option.value = _modeArray[i]["index"];
        _option.title = _modeArray[i]["description"];
        _select.add(_option);
    }
    _select.value = _val;
}

// clear a select
function removeOptions(selectbox) {
    var i;
    for(i=selectbox.options.length-1; i>=0; i--) selectbox.remove(i);
}
// set the infoline at the top
function setInfo(_info) {
    document.getElementById("infoline").innerHTML = _info.replace('info', '');
}

/*
 * /////////////////////////////////////////////////////////////
 * LayerLoading
 * /////////////////////////////////////////////////////////////
 */

function updateLayerStack() {
    actualySendCMD("fetch-ws layers");
}



function parseLayerInfo(_info) {
    var _layerStack;
    _layerStack = document.getElementById("layerStack");
    // clear old
    while (_layerStack.hasChildNodes()) {
        _layerStack.removeChild(_layerStack.lastChild);
    }
    // parse
    _layers = _info.split(" ").slice(1);
    for(var i in _layers) {
        _params = _layers[i].split("-");
        // console.log(_params);
        if(_params != "")
            _layerStack.appendChild(makeLayerDiv(_params));
    }
}

function makeLayerDiv(_params) {
    var _layerDiv;
    _layerDiv = document.createElement("div");
    _layerDiv.id = _params[0];
    _layerDiv.className = "layerwidget";
    if(_params[0] == selectedLayer) {
        _layerDiv.className = "selectedLayerWidget";
    }
    _layerDiv.innerHTML = _params[0];
    if(_params[1] == "mergeLayer") {
        _layerDiv.innerHTML = "^^^ "+_params[0]+" ^^^";
        _layerDiv.style.backgroundColor = "#800067";
    }
    else if(_params[1] == "shaderLayer") {
        _layerDiv.innerHTML = "~~~ "+_params[0]+" ~~~";
        // _layerDiv.style.backgroundColor = "#290A6C";
    }
    else if(_params[1] == "renderLayer" || _params[1] == "tracerLayer") {
        _layerDiv.innerHTML = "vvv "+_params[0]+" vvv";
        // _layerDiv.style.backgroundColor = "#39148B";
    }
    // enable checkbox
    _layerDiv.appendChild(layerEnableCheckBox(_params));
    _layerDiv.appendChild(layerDeleteButton(_params));
    _layerDiv.appendChild(layerOptionList(_params));
    _layerDiv.onclick = function() {
        selectedLayer = _params[0];
        selectedLayerType = _params[1];
        updateLayerStack();
    }
    // _layerDiv.title = description
    return _layerDiv;
}

function layerOptionList(_params) {
    var _input, _fileType, i;
    _input = document.createElement("select");
    _input.type = "select";
    _input.title = "select file to load";
    _input.style = "float: right;   background-color:#0E0E0E; color: #98A7FF;";

    for(i = 4; i < _params.length; i++) {
        _option = document.createElement("option");
        _option.text = _params[i];
        _input.add(_option);
    }
    // _params[3] is selected option
    _input.value = _params[3];
    _input.onchange = function () {
        sendCMD("layer "+_params[0]+" option "+_input.value);
    }
    return _input;
}

function layerEnableCheckBox(_params) {
    var _input = document.createElement("input");
    _input.type = "checkbox";
    _input.title = "enable/disable layer";
    _input.style = "float: right;";

    if(_params[2] == 1) _input.checked="checked";
    _input.onclick = function () {
        if(_input.checked) sendCMD("layer "+_params[0]+" enable 1");
        else sendCMD("layer "+_params[0]+" enable 0");
    }
    return _input;
}

function layerDeleteButton(_params) {
    var _input = document.createElement("input");
    _input.type = "button";
    _input.title = "delete a layer";
    _input.style = "float: right;";
    _input.value = "X";

    _input.onclick = function () {
        var r = confirm("delete layer "+_params[0]);
        if(r) {
            sendCMD("layer "+_params[0]+" delete");
            updateLayerStack();
        }
    }
    return _input;
}

/*
 * /////////////////////////////////////////////////////////////
 * Sequencer callbacks
 * /////////////////////////////////////////////////////////////
 */

// set sequncer tags...
function setSeqTags(tags) {
    var _steps = tags.replace('webseq /', '').split('/');
    for(var i = 0; i < _steps.length; i++) {
        document.getElementById('step'+i).innerHTML = _steps[i];
    }
}

function labelStep(i, s) {
    document.getElementById('step'+i).innerHTML = _steps[i];
}

/*
 * /////////////////////////////////////////////////////////////
 * Other widget callbacks
 * /////////////////////////////////////////////////////////////
 */
function popupCallbacks() {
    var _element;
    _element = document.getElementById("configureDisplay");
    if(!_element) return;
    _element.onclick = function () {
        document.getElementById("configPopup").style.display = 'block';
    }

    _element = document.getElementById("saveConfig");
    if(_element) _element.onclick = function () {
        var _width, _height, _fullscreen, _display, _pipeline;
        _width = document.getElementById("configWidth").value;
        _height = document.getElementById("configHeight").value;
        if(_width > 10) sendCMD("config width "+_width);
        if(_height > 10) sendCMD("config height "+_height);

        _fullscreen = 0;
        if(document.getElementById("fullscreenCheckBox").checked) _fullscreen = 1;
        sendCMD("config fullscreen "+ _fullscreen);

        _pipeline = 1;
        if(document.getElementById("pipelineCheckBox").checked) _pipeline = 0;
        sendCMD("config pipeline "+ _pipeline);

        _display = 1;
        if(document.getElementById("fullscreenType").value == "displaySpan") _display = 0;
        else if(document.getElementById("fullscreenType").value == "displayOne") _display = 1;
        else if(document.getElementById("fullscreenType").value == "displayTwo") _display = 2;
        sendCMD("config display "+ _display);
        document.getElementById("configPopup").style.display = 'none';
        sendCMD("fl save");
        alert("restart freeliner!");

    }
    _element = document.getElementById("cancelConfig");
    if(_element) _element.onclick = function () {
        document.getElementById("configPopup").style.display = 'none';
    }
}


function shaderSliderCallbacks() {
    var _element, i;
    for(i = 0; i < 8; i++){
        _element = document.getElementById("slider"+i);
        _element.oninput = makeShaderCMD(_element, i);
    }
}

function makeShaderCMD(_element, _index){
    return function() {
        if(selectedLayer != "none" && selectedLayerType == "shaderLayer"){
            sendCMD("layer "+selectedLayer+" uniforms "+_index+" "+(_element.value / 255));
        }
    }
}

function colorsCallbacks() {
    var _element, i;
    for(i = 0; i < 12; i++){
        _element = document.getElementById("colorPicker"+i);
        _element.oninput = makeColorCMD(_element, i);
    }
    for(i = 0; i < 2; i++){
        _element = document.getElementById("twoColor"+i);
        _element.oninput = twocallback(_element, i);
    }
}

function twocallback(_element, index) {
    return function() {
        var p, i;//, p3, p4, p5, p6;
        for(i = 0; i < 6; i++){
            p =  document.getElementById("colorPicker"+(index+i*2));
            p.value = _element.value;
            p.oninput();
        }
    }
}


function makeColorCMD(_element, _index){
    return function() {
        var _c = _element.value;
        sendCMD('colors set '+_index+' '+_c);
    }
}

function otherInputCallbacks() {
    var _element;

    _element = document.getElementById("openRef");
    if(_element) _element.onclick = function () {
        sendCMD('geom webref');
        window.open("referenceImage.html", "geometry reference", "width=1000,height=700");
    }

    _element = document.getElementById("refreshfiles");
    if(_element) _element.onclick = function () {
        actualySendCMD('fetch-ws files');
    }

    _element = document.getElementById("fileInput")
    if(_element) _element.onchange = function () {
        var _file = document.getElementById('fileInput').value;
        sendCMD('geom load '+_file);
    }

    _element = document.getElementById("strokePicker");
    if(_element) _element.oninput = function () {
        var _c = document.getElementById("strokePicker").value;
        sendCMD('tw '+selectedTemplate+' q 27');
        sendCMD('tp stroke '+selectedTemplate+' '+_c);
    }

    _element = document.getElementById("fillPicker");
    if(_element) _element.oninput = function () {
        var _c = document.getElementById("fillPicker").value;
        sendCMD('tw '+selectedTemplate+' f 28');
        sendCMD('tp fill '+selectedTemplate+' '+_c);
    }

    _element = document.getElementById("interfaceColor");
    if(_element) _element.onchange = function () {
        var _c = document.getElementById("interfaceColor").value;
        document.body.style.background = _c;
    }


    _element = document.getElementById("makeLayerButton");
    if(_element) _element.onclick = function () {
        var _name, _type;
        _name = document.getElementById("layerNameInput").value;
        _type = document.getElementById("layerTypeSelect").value;
        sendCMD("layer "+_name+" "+_type);
        updateLayerStack();
    }
    _element = document.getElementById("layerUpButton");
    if(_element) _element.onclick = function () {
        sendCMD("layer "+selectedLayer+" swap -1");
        updateLayerStack();
    }
    _element = document.getElementById("layerDownButton");
    if(_element) _element.onclick = function () {
        sendCMD("layer "+selectedLayer+" swap 1");
        updateLayerStack();
    }
}



// gets called from eventListener
// function cmdPrompt(e){
//   console.log(e.keyCode);
//   if(e.keyCode == 13) {
//     sendCMD(document.getElementById("prompt").value);
//     document.getElementById("prompt").value = "";
//   }
//   else if(e.keyCode == 38){
//     document.getElementById("prompt").value = cmdHistory[cmdHistory.length-1];
//   }
//   else if(e.keyCode == 40){
//
//   }
// }

cmdPrompt = (function () {
    var cmdIndex, cmdHistory, cmdPrompt;
    cmdHistory = ["no previous cmd"];
    prompt = document.getElementById("prompt");
    return function (e) {
        if(e.keyCode == 13) {
            sendCMD(prompt.value);
            cmdHistory.push(prompt.value);
            prompt.value = "";
            cmdIndex = 0;
        }
        else if(e.keyCode == 38) {
            cmdIndex++;
            if(cmdIndex >= cmdHistory.length) cmdIndex = cmdHistory.length-1;
            prompt.value = cmdHistory[cmdHistory.length-1];
            prompt.value = cmdHistory[cmdHistory.length - cmdIndex];
        }
        else if(e.keyCode == 40) {
            cmdIndex--;
            if(cmdIndex < 1) cmdIndex = 1;
            prompt.value = cmdHistory[cmdHistory.length - cmdIndex];
        }
    }
})();

//
scriptPrompt = (function () {
    var cmdIndex, scrptHist, scriptPrompt;
    scrptHist = ["no previous cmd"];
    prompt = document.getElementById("scripting");
    return function (e) {
        if(e.keyCode == 13) {
            sendCMD("oneliner "+prompt.value);
            scrptHist.push(prompt.value);
            // prompt.value = "";
            cmdIndex = 0;
        }
        else if(e.keyCode == 38) {
            cmdIndex++;
            if(cmdIndex >= scrptHist.length) cmdIndex = scrptHist.length-1;
            prompt.value = scrptHist[scrptHist.length-1];
            prompt.value = scrptHist[scrptHist.length - cmdIndex];
        }
        else if(e.keyCode == 40) {
            cmdIndex--;
            if(cmdIndex < 1) cmdIndex = 1;
            prompt.value = scrptHist[scrptHist.length - cmdIndex];
        }
    }
})();

/*
 * /////////////////////////////////////////////////////////////
 * mouse section!
 * /////////////////////////////////////////////////////////////
 */

// prevent rightclick context menu
// document.addEventListener("contextmenu", function(e){
//   e.preventDefault();
// }, false);


function blurAll() {
// var tmp = document.createElement("input");
// document.body.appendChild(tmp);
// tmp.focus();
// document.body.removeChild(tmp);
}


/*
 * /////////////////////////////////////////////////////////////
 * keyboard section!
 * /////////////////////////////////////////////////////////////
 */

// some keys returned weird codes, fix em here.
function kbdRules(_event) {
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
    else if(e.keyCode == 17) e.preventDefault();
    // else if(e.keyCode == 84) e.preventDefault();
    // console.log(e.keycode);
    if (document.activeElement == document.getElementById("prompt")) cmdPrompt(e);
    // if (document.activeElement == document.getElementById("scripting")) scriptPrompt(e);
    else if (document.activeElement != document.getElementById("layerNameInput")) {
        blurAll();
        actualySendCMD('hid press '+kbdRules(e)+" "+e.key);
    }

    //send keyPress to freeliner
}, false);

// window.addEventListener("keydown", function(e) {
//     // catch ctrlKey
//     if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) e.preventDefault();
//     // prevent default for tab key
//     else if(e.keyCode == 9) e.preventDefault();
//     else if(e.keyCode == 17) e.preventDefault();
//     else if(e.keyCode == 84) e.preventDefault();
//     // console.log(e.keycode);
//     if (document.activeElement == document.getElementById("prompt")) cmdPrompt(e);
//     // if (document.activeElement == document.getElementById("scripting")) scriptPrompt(e);
//     else if (document.activeElement != document.getElementById("layerNameInput")) {
//         blurAll();
//         actualySendCMD('hid press '+kbdRules(e)+" "+e.key);
//     }
//     //send keyPress to freeliner
// }, false);


document.addEventListener("keyup", function(e) {
    // catch ctrlKey
    if ((navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) e.preventDefault();
    // prevent default for tab key
    else if(e.keyCode == 9) e.preventDefault();
    //send keyRelease to freeliner
    actualySendCMD('hid release '+kbdRules(e)+" "+e.key);
}, false);

// autofocus on ranges for scroll wheel action
document.addEventListener("mouseover", function(e){
    if(e.target.type == "range") {
        e.target.focus();
    }
});
