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


vec2 rot(vec2 p, float a) {
	return vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}

float random( vec2 p ) {
   // e^pi (Gelfond's constant)
   // 2^sqrt(2) (Gelfond–Schneider constant)
   vec2 r = vec2( 23.14069263277926, 2.665144142690225 );
 //return fract( cos( mod( 12345678., 256. * dot(p,r) ) ) ); // ver1
   return fract(cos(dot(p,r)) * 123456.); // ver2
}

void main(void) {
  vec2 pos = vertTexCoord.xy;
  vec4 col = texture2D(texture, pos);
	vec2 dis = pos;
	// dis.x = ((dis.x - 0.5)/5.0)+dis.x;
	// dis.y = ((dis.y - 0.5)/5.0)+dis.y;
	dis -= 0.5;
	dis = rot(dis, 0.04);
	dis += 0.5;
	vec4 tracers = texture2D(ppixels, dis);
	vec4 ref = vec4(0.0);
	if(mod(floor(dis.y * 768.0), 2) == 1)dis.x+=0.01;
	else dis.x-=0.01;
	ref = texture2D(ppixels, dis);
	tracers.a /= 1.01;
	if(ref.r > tracers.r) tracers = ref;
	col += tracers/1.02;
	//if(col.r < 0.01) col = vec4(0.0);
  gl_FragColor = col;
}
