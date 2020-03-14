#version 100

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

uniform vec2 u_trails[10];

#define PI_TWO 1.570796326794897
#define PI 3.141592653589793
#define TWO_PI 6.283185307179586

vec2 st;

#include "lib/shapes.glsl"
#include "lib/math.glsl"

#line 23

uniform sampler2D u_texture_0;
uniform sampler2D u_texture_1;
uniform vec2 u_tex0_size;

vec4 blend_Normal(in vec4 top, in vec4 bottom) {
    return vec4(mix(bottom.rgb, top.rgb, top.a), clamp01(top.a + bottom.a));
}

void main() {
    
    st = gl_FragCoord.xy;
    
    vec4 color4 = vec4(0.0);

    vec2 lowerLeft = vec2(30.0);
    float scale = 0.6 + 0.01 * sin(u_time * TWO_PI / 1.0);
    vec2 upperLeft = lowerLeft + scale * u_tex0_size;

    if (all(lessThanEqual(lowerLeft, st)) && all(lessThanEqual(st, upperLeft))) {
        color4 = texture2D(u_texture_1, (st - lowerLeft) / (scale * u_tex0_size));
    }
    
    float d = 0.0;
    for (int i = 0; i < 10; i++) {
        float p = float(i) / 10.0;
        float radius = (1.0 - p) * 20.0;
        if (distance(st, u_trails[i]) < radius) {
            d = max(d, (0.8 - 0.3 * p) * shape_Circle(u_trails[i], radius));
        }
    }
    d = max(d, shape_Circle(u_mouse, 5.0));
    vec3 color = vec3(d);


    gl_FragColor = blend_Normal(color4, vec4(color, 1.0));
}