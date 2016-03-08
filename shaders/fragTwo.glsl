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

uniform float u1;
uniform float u2;
uniform float u3;
uniform float u4;
uniform float u5;

void main() {
    vec2 pos = vertTexCoord.st;
    vec4 col = vec4(0.0);
    //squish X
    pos.x -= 0.5;
    pos.x/=(768.0/1024.0);
    pos.x += 0.5;
		vec4 ref = texture2D(texture, vertTexCoord.st);
    if(pos.y > 0.5) pos.y += ref.g;
    else if(pos.y < 0.5) pos.y -= ref.g;

    //if(abs(pos.y-0.5)<0.01) col = vec4(1.0);

    float mover = fract(u5*10.0);
    float dst = distance(pos, vec2(0.5));
    if(abs(dst-u2) < (u3/10.0)) col = vec4(pos.x,ref.b,1.0,1.0);//vec4(0.0, 0.0, 1.0, 1.0);
    //else if(abs(dst-u2) > 0.01) col = vec4(vec3(0.0),1.0);
    //col += texture2D(texture, pos)*u1;
    gl_FragColor = col;
}
