#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;


vec2 rot(vec2 p, float a) {
	return vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}

void main(void) {
  vec2 pos = vertTexCoord.xy;
  //vec4 notCol = (texture2D(texture, pos, 0.5) * vertColor)/1.0001;
  //vec2 pos = rot(vertTexCoord.xy,sin(vertTexCoord.x-0.5)*3.14156);
  // if(fract(vertTexCoord.x*8.0) >0.5) pos.x = -vertTexCoord.x + 1.0;
  // pos = rot(notCol.xy,sin(vertTexCoord.x-0.5)*3.14156);
  // if(pos.x >0.5) pos.x = -pos.x + 1.0;
  // if(vertTexCoord.y >0.5) pos.y = -vertTexCoord.y + 1.0;
  // vec4 col = (texture2D(texture, pos, 0.5) * vertColor)/1.0001;
  // col.rg = rot(col.gb*pos, 0.2)*pos*tan(pos.x)*(pos.y*20.0);
  vec4 col texture2D(texture, pos, 0.5);
  gl_FragColor = col;
}
