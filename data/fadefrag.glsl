#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform float fadeforce;
varying vec4 vertColor;
varying vec4 vertTexCoord;

// void main() {
// 	vec4 col = texture2D(texture, vertTexCoord.st);

// 	gl_FragColor = max(col.rgb - fadeforce, vec3(0.0)), 0.0);
// }


//  FUNCTIONAL CHUNCK

void main() {
	vec4 col = texture2D(texture, vertTexCoord.st);
	float newA = col.a - fadeforce;
	col.a = clamp(newA, 0.0, 1.0);
	gl_FragColor = col;
}