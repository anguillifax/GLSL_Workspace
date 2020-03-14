#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI_TWO 1.570796326794897
#define PI 3.141592653589793
#define TWO_PI 6.283185307179586

vec2 st;
vec2 uv;

#include "lib/color.glsl"
#include "lib/math.glsl"
#include "lib/shapes.glsl"
#include "lib/repeat.glsl"

#line 22

void tesselate(vec2 size, bool alternate, vec2 offset) {
    vec2 pos = gl_FragCoord.xy - offset;
    if (alternate && mod(pos.y, size.y * 2.0) > size.y) {
        st = mod(pos + vec2(size.x * 0.5, 0.0), size);
    } else {
        st = mod(pos, size);
    }
}

void pasta() {

    vec2 offset = vec2(u_time / 9.0);

    vec3 color = vec3(0.1137, 0.0902, 0.1137);
    vec2 sizeMult = vec2(1.0, 0.5);
    vec2 size;

    size = vec2(30.0) * sizeMult;
    tesselate(size, true, offset * size);
    color = mix(color, vec3(0.2863, 0.2353, 0.1569), line_Circle(0.5 * size, 4.0, 6.0));

    size = vec2(70.0) * sizeMult;
    tesselate(size, true, offset * size);
    color = mix(color, vec3(0.8588, 0.7412, 0.5647), line_Circle(0.5 * size, 9.0, 12.0));

    size = vec2(120.0) * sizeMult;
    tesselate(size, true, offset * size);
    color = mix(color, vec3(0.1686, 0.0392, 0.0392), shape_Circle(0.5 * size, 15.0));
    color = mix(color, ORANGE, line_Circle(0.5 * size, 20.0, 16.0));

    gl_FragColor = vec4(color, 1.0);

}

vec2 transformPos(vec2 v) {
    return v * mat2(1.0, 0.5 * sin(u_time * 2.0), 0.0, 1.0);
}

void main() {

    vec3 color = BLACK;
    vec2 size;
    vec2 pos;
    float repeat_out;

    // size = vec2(70.0);
    // pos = gl_FragCoord.xy - vec2(u_time * 100.0 / 8.0);
    // pos = gl_FragCoord.xy;

    // REPEAT_BOX(size, pos, line_Circle(vec2(0.3) * size, 30.0, 20.0))
    // color = mix(color, ORANGE, 0.3 * repeat_out);

    size = vec2(40.0, 80.0);
    pos = gl_FragCoord.xy;

    float t = u_time * TWO_PI / 3.0;
    // vec2 cpos = 30.0 * vec2(cos(t), sin(t)) + 0.5 * size;
    vec2 cpos = 0.5 * size;

    REPEAT_BOX_T(size, pos, vec2(u_time * 0.0), 2, 2, transformPos,
        shape_Circle(cpos, 30.0 + 2.0 * sin(u_time * TWO_PI / 1.3)) - shape_Circle(cpos, 8.0))
    color = mix(color, ORANGE, repeat_out);

    gl_FragColor = vec4(color, 1.0);

}