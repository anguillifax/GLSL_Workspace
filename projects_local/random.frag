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

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

void main() {

    st = gl_FragCoord.xy;
    uv = st / u_resolution;

    vec3 color = vec3(uv.x, uv.y, 1.0);

    color = mix(vec3(0.0), color, random(uv));

    gl_FragColor = vec4(color, 1.0);

}