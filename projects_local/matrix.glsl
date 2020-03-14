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

#include "lib/math.glsl"
#include "lib/shapes.glsl"
#include "lib/matrix.glsl"

#line 18


vec2 transform(vec2 pos, mat2 m) {
    return (pos - u_resolution * 0.5) * m + u_resolution * 0.5;
}


void main() {

    mat2 mrot = mat2_Rotate(radians(30.0));

    float scale = 1.0 + 0.2 * sin(u_time * PI2 / 8.0);
    scale = 1.2;
    mat2 mscale = mat2_Scale(scale, scale);

    mat2 mshear = mat2_Shear(0.3, 0.0);

    mat2 m = mshear * mrot;
    bool toggle = (u_mouse / u_resolution).x < 0.5;
    if (toggle) {
        m = mrot * mshear;
    }

    st = gl_FragCoord.xy * m;
    k_ShapeSmoothDist /= scale; 

    uv = st / u_resolution;

    vec2 uv_real = gl_FragCoord.xy / u_resolution;
    vec3 color = vec3(uv_real.x, uv_real.y, 1.0);

    float d = 0.0;

    d = shape_Rect2p(vec2(0.1, 0.1) * u_resolution, vec2(0.2, 0.2) * u_resolution);

    st = gl_FragCoord.xy;

    d += 0.4 * shape_Rect2p(vec2(0.1, 0.1) * u_resolution, vec2(0.2, 0.2) * u_resolution);
    if (toggle && st.y < 3.0) {
        d = 0.3;
    }

    color *= d;

    gl_FragColor = vec4(color, 1.0);

}