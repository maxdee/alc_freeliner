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
	vec2 pos = vertTexCoord.st;
	float scal = u2/40.0;
	float div = (pow(u3,2)+0.1)*20.0;
  pos -= 0.5;

  pos.x /= scaler;
	if(fract(pos.x*div) > 0.5) pos.y -= scal;
  else pos.y += scal;

	if(fract(pos.y*div) > 0.5) pos.x += scal;
	else pos.x -= scal;
  pos.x *= scaler;
  pos += 0.5;

	vec4 col = texture2D(texture, pos);
 	//gl_FragColor = col * u1; // for praxis
 	gl_FragColor = col + texture2D(ppixels, pos) * u1;
}
