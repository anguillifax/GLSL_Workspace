#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define PI2 6.28318530718

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 uv;
vec2 st;

void main() {

    st = gl_FragCoord.xy;
    uv = st / u_resolution;

    vec3 color = vec3(uv.x, uv.y, 1.0);

    gl_FragColor = vec4(color, 1.0);

}