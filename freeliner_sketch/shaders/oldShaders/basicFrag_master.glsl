#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform sampler2D ppixels;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

// use these, but not here...
uniform float u1;
uniform float u2;
uniform float u3;
uniform float u4;

void main(void) {
	gl_FragColor = texture2D(texture, vertTexCoord.st)/u1;
}
