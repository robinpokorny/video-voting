'use strict';

require('./index.html');
require('./favicon.ico');
var Elm = require('./Main');

var DEMO_STATE = {"videos":[{"uri":"https://www.youtube.com/watch?v=rhV6hlL_wMc","votes":3,"id":0},{"uri":"https://www.youtube.com/watch?v=oHg5SJYRHA0","votes":5,"id":1},{"uri":"https://www.youtube.com/watch?v=C-u5WLJ9Yk4","votes":1,"id":2},{"uri":"https://www.youtube.com/watch?v=DqMFX91ToLw","votes":3,"id":3}],"uid":4,"field":""}

var storedState = localStorage.getItem('video-voting-state');
var startingState = storedState ? JSON.parse(storedState) : DEMO_STATE ;
var app =  Elm.embed(Elm.Main, document.getElementById('app'), { getStorage: startingState })
app.ports.setStorage.subscribe(function(state) {
    localStorage.setItem('video-voting-state', JSON.stringify(state));
});

