// for VJ BunBun, happy birthday!
// with love, VJ userZero

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
float ranger(float _f){
	if(_f>1.0)return _f-1.0;
	else if(_f<0.0) return _f+1.0;
	else return _f;
}
void main(void) {
	vec2 pos = vertTexCoord.xy;
	vec4 col = texture2D(texture, pos);

	pos-=0.5;
	pos = rot(pos, (u3-0.5)*3.1456);
	pos *= (u3/2.0)+1.0;
	pos+=0.5;

	float amount = log(0.9+(u2/2.0));
	if(pos.x > 0.5) pos.x -= amount*sign(u4-0.5);
	else pos.x += amount*sign(u4-0.5);
	if(pos.y > 0.5) pos.y += amount;
	else pos.y -= amount;

	// pos.x = ranger(pos.x);
	// pos.y = ranger(pos.y);

	col += texture2D(ppixels, pos)*u1;
	if(pos.x < 0.0 || pos.x >1.0) col = vec4(vec3(0.0),1.0);
	else if(pos.y < 0.0 || pos.y >1.0) col = vec4(vec3(0.0),1.0);

  gl_FragColor = col;
}
