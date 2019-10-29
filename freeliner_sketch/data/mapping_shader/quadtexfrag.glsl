#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec3 vertTexCoord;

void main() {
    vec2 pos = vertTexCoord.st / vertTexCoord.p;
    pos.y = 1.0 - pos.y;
    // pos.x = 1.0 - pos.x;
    gl_FragColor = texture2D(texture, pos) * vertColor;
}
