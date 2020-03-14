#ifdef GL_ES
precision mediump float;
#endif

#define PI_TWO 1.570796326794897
#define PI 3.141592653589793
#define TWO_PI 6.283185307179586

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec2 u_trails[10];

vec2 uv;
vec2 st;

#include "lib/color.glsl"
#include "lib/math.glsl"
#include "lib/shapes.glsl"
#include "lib/random.glsl"
#include "lib/matrix.glsl"

#line 24

const float k_LineHeight = 10.0;
const float k_LineSpacing = 3.0;
const float k_CellSpacing = 1.0;

void main() {

    st = gl_FragCoord.xy + 0.3 * u_trails[3];
    uv = st / u_resolution;

    vec3 color = vec3(uv.x, uv.y, 1.0);

    float d = 1.0;

    if (mod(st.y, k_LineHeight + k_LineSpacing) < k_LineHeight) {

        float heightY = floor(st.y / (k_LineHeight + k_LineSpacing));
        float randval = random(vec2(heightY, random(heightY)));
        float width = 1.0 + 6.0 * randval;
        float translateSpeed = mix(20.0, 200.0, pow(random(heightY + 13.16), (0.3 + randval) * 3.0));

        float posx = floor((st.x - translateSpeed * u_time) / (width + k_CellSpacing));
        float cutoff = mix(0.1, 0.94, pow(sin(random(heightY) / PI_TWO), 0.7));
        if (random(posx) < cutoff) {
            d = mix(0.6, 0.03, cutoff);
        }
    }

    st = gl_FragCoord.xy;
    float pulse = 2.0 * sin(u_time * TWO_PI / 2.0);

    float d_circle = line_Circle(u_mouse, 40.0 + pulse, 13.0 + 0.8 * pulse);
    d_circle += line_Circle(u_mouse, 53.0 + 1.6 * pulse, 6.0 + 0.1 * 1.6 * pulse);

    st = (gl_FragCoord.xy - u_mouse) * mat2_Rotate(u_time * TWO_PI / 40.0) + u_mouse;
    float effects = 0.0;

    const int maxPoints = 3;
    for (int i = 0; i < maxPoints; ++i) {
        float a = float(i) * TWO_PI / float(maxPoints) - PI / 6.0;
        vec2 p1 = u_mouse + (66.0 + 1.6 * pulse) * vec2(cos(a), sin(a));
        effects = max(effects, shape_Triangle(p1, 9.0, a));
        p1 = u_mouse + (66.0 + 1.6 * pulse) * vec2(cos(a), sin(a));
        vec2 off = -vec2(cos(a), sin(a));
        effects = max(effects, line_Round(p1 + 10.0 * off, p1 + 40.0 * off, 2.6));
        a += PI;
        p1 = u_mouse + (62.0 + 1.6 * pulse) * vec2(cos(a), sin(a));
        effects = max(effects, shape_Triangle(p1, 7.0, a));
    }
    
    vec3 FG = vec3(0.7529, 0.2118, 0.0);
    vec3 base = mix(FG, IVORY, d);
    gl_FragColor = vec4(mix(base, vec3(0.3137, 0.0, 0.0), 0.9 * max(d_circle, effects)), 1.0);

}