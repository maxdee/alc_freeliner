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
//vec2(0.5614,0.3252)

void main(void) {
  vec2 pos = vertTexCoord.xy;
	// if(pos.x < 0.3125) pos.x += 0.6;
	vec4 center = texture2D(texture, pos);
	pos.x -= 0.3125;
	vec4 left = texture2D(texture, pos);
	pos.x += 0.625;
	vec4 right = texture2D(texture, pos);

	gl_FragColor = center+left+right;
}
