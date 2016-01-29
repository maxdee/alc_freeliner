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
	pos.x = (-(pos.x - 0.5)/((u2/3.0)*3.0))+pos.x;
	pos.y = (-(pos.y - 0.5)/((u2/3.0)*3.0))+pos.y;
	pos = -pos+vec2(1.0);
	gl_FragColor = texture2D(texture,vertTexCoord.xy)+texture2D(ppixels,pos)*(0.4+u1);
}

//if(distance(pos, vec2(0.5)) > u2) discard;
