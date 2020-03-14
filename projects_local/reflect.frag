#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define PI2 6.28318530718
#define DEG_TO_RAD (PI / 180.0)
#define RAD_TO_DEG (180.0 / PI)

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 uv;
vec2 st;

const float k_SmoothDist = 3.0;

float shape_Circle(in vec2 center, in float radius) {
    return smoothstep(radius, radius - k_SmoothDist, distance(st, center));
}

float line_Circle(in vec2 center, in float radius, in float width) {
    float d = distance(st, center);
    float innerRadius = radius - 0.5 * width;
    float outerRadius = radius + 0.5 * width;
    return smoothstep(innerRadius, innerRadius + k_SmoothDist, d) - 
           smoothstep(outerRadius - k_SmoothDist, outerRadius, d);
}


/*
Manipulate the st position vec2 to mirror across plane defined by center and normal.

^
| y
|
|
|
o-------->  normal
       x

o is center

*/
void setupReflection(in vec2 center, in vec2 normal) {

    float xdist = dot(gl_FragCoord.xy, normal) - dot(center, normal);
    
    vec2 dv = center + normal - center;
    vec2 vnorm = vec2(-dv.y, dv.x);
    float ydist = dot(gl_FragCoord.xy, vnorm) - dot(center, vnorm);

    if (xdist > 0.0) {
        st = vec2(xdist, ydist);
    } else {
        st = vec2(-xdist, ydist);
    }

}

void drawAxes(inout vec3 color) {
    // x axis
    if (distance(st.y, 0.0) < 1.0) {
        color = vec3(1.0, 0.0, 0.0);
    }
    // y axis
    if (distance(st.x, 0.0) < 1.0) {
        color = vec3(0.0, 1.0, 0.0);
    }
}

// Oscillate between [angleCenter - halfExtents, angleCenter + halfExtents] using sine.
float oscillate(in float angleCenter, in float halfExtents, in float t) {
    return halfExtents * sin(t) + angleCenter;
}

// Oscillate a unit vector in a pendulum-like motion where angleCenter = 0 is to the right.
vec2 oscillateVec2(in float angleCenter, in float halfExtents, in float t) {
    float a = oscillate(angleCenter, halfExtents, t);
    return vec2(cos(a), sin(a));
}

void main() {
    vec2 reflectCenter = u_mouse;
    vec2 reflectNormal = oscillateVec2(0.0, 2.0 * DEG_TO_RAD, u_time * PI2 / 2.0);
    reflectNormal = vec2(1.0, 0.0);

    st = gl_FragCoord.xy;
    setupReflection(reflectCenter, reflectNormal);

    vec3 color = vec3(0.0);

    float radius = 50.0;
    float ypos = abs(sin(u_time * PI2 / 2.0));
    float d = line_Circle(vec2(120.0 + sin(u_time * PI2 / 2.0) * 100.0, radius + 80.0 * ypos), radius - 4.7, 10.0);

    vec2 uv_Actual = gl_FragCoord.xy / u_resolution;
    color = mix(vec3(0.0), vec3(uv_Actual.x, uv_Actual.y, 1.0), d);

    drawAxes(color);

    gl_FragColor = vec4(color, 1.0);

}