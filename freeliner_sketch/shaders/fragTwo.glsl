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
const float scaler = 768.0/1024.0;


vec2 rot(vec2 p, float a) {
	return vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}

//vec2(0.5614,0.3252)
void main(void) {
	vec2 pos = vertTexCoord.xy;
  vec4 col = texture2D(texture, pos);
	vec2 dis = pos;
	// shrink or expand
	dis.x = (sign(u3-0.5)*(dis.x - 0.5)/(u2*200.0))+dis.x;
	dis.y = (sign(u3-0.5)*(dis.y - 0.5)/(u2*200.0))+dis.y;
	// make copy
	vec2 das = vec2(dis);
	dis -= 0.5;//58;
	dis = rot(dis,(u4)/4.0);// (u4-0.5)/2.0);
	dis += 0.5;//442;

	vec4 tracers = texture2D(ppixels, dis);

	das -= 0.5;
	das = rot(das,(-u4)/4.0);// (u4-0.5)/2.0);
	das += 0.5;

	tracers = mix(tracers, texture2D(ppixels, das), 0.5);

	col += tracers*u1;
  gl_FragColor = col;
}

//if(distance(pos, vec2(0.5)) > u2) discard;
