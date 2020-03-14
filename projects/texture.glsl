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

uniform sampler2D u_tex0; // textures/sylveon.png
uniform sampler2D u_tex1; // textures/cat.png



void main() {

    st = gl_FragCoord.xy;
    uv = st / u_resolution;

    vec3 color = vec3(uv.x, uv.y, 1.0);

    vec4 tcolor0 = texture2D(u_tex0, uv);
    vec4 tcolor1 = texture2D(u_tex1, uv);

    gl_FragColor = vec4(tcolor0.rgb + tcolor1.rgb, max(tcolor0.a, tcolor1.a));

}