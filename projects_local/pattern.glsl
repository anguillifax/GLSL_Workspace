#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI_TWO 1.570796326794897
#define PI 3.141592653589793
#define TWO_PI 6.283185307179586
#define PI2 TWO_PI

vec2 st;
vec2 uv;

#include "lib/color.glsl"
#include "lib/math.glsl"
#include "lib/shapes.glsl"
#include "lib/repeat.glsl"
#include "lib/matrix.glsl"
#include "lib/distort.glsl"

#line 24

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

vec2 _transformSize;
vec2 transformPos(vec2 v) {
    return (v - 0.5 * _transformSize) * mat2_Rotate(u_time - length(gl_FragCoord.xy / u_resolution)) + 0.5 * _transformSize;
}

void main() {

    float d = 0.0;
    setupDistort(d);

    vec3 color = BLACK;
    vec2 size;
    vec2 pos;
    float repeat_out;

    size = vec2(40.0);

    // if (mod(gl_FragCoord.y, 2.0 * size.y) < size.y) {
    //     pos = gl_FragCoord.xy - vec2(0.5 * size.x, 0.0);
    // } else {
    //     pos = gl_FragCoord.xy;
    // }


    // if (any(lessThan(pos, vec2(1.0)))) {
    //     color = DIMGREY;
    // }


    _transformSize = size;
    REPEAT_BOX_T(size, st, 1, 1, transformPos,
        line_Round(0.1 * size, 0.9 * size, 8.0))
    color = mix(color, ORANGE, repeat_out);
    
    color = mix(color, ORANGE, d);

    gl_FragColor = vec4(color, 1.0);

}