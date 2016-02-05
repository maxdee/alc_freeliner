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
		vec2 pos = vertTexCoord.st;
	 float scal = 40.0;
	 float div = (pow(u3,2)+0.1)*30.0;
	 if(fract(pos.x*div) > 0.5) pos.y+=u2/scal;
	 else pos.y-=u2/scal;
	 if(fract(pos.y*div) > 0.5) pos.x+=u2/scal;
	 else pos.x-=u2/scal;

	 gl_FragColor = texture2D(texture, pos) * u1;
}
