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
	vec4 reg = texture2D(texture,pos);

	pos.x = ((pos.x - 0.5)/(u2))+pos.x/8.0;
	pos.y = ((pos.y - 0.5)/(u2))+pos.y/8.0;

	vec4 col = texture2D(texture,pos);
	pos = cos(pos+(col.rb*(u4*100.0)));

	col = texture2D(texture,pos);

	pos = rot(pos, u3-0.5);
	col += texture2D(ppixels,pos)*u1;
	gl_FragColor = col+reg*u1;
}
