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

vec2 rot(vec2 p, float a) {
	return vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}

void main(void) {
	vec2 pos = vertTexCoord.xy;
	float pix = 500.0*(-u2+1.0);
	pos = floor((pos)*pix)/pix;
	gl_FragColor = (texture2D(texture, pos)+texture2D(ppixels,pos))*u1;
}
