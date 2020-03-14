#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define PI2 6.28318530718

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


const float gradientDebugSplit = 0.03;

vec3 gradientMap(float t) {
    
    const int n = 6;
    
    float points[n];
    points[0] = 0.0;
    points[1] = 0.164;
    points[2] = 0.392;
    points[3] = 0.648;
    points[4] = 0.800;
    points[5] = 1.0;
    
    vec3 colors[n];
    colors[0] = vec3(0.0);
    colors[1] = vec3(0.200,0.088,0.270);
    colors[2] = vec3(0.700,0.368,0.521);
    colors[3] = vec3(0.965,0.562,0.497);
	colors[4] = vec3(0.965,0.882,0.712);
    colors[5] = vec3(1.0);
    
    if (t < points[0]) return colors[0];
    if (t > points[n - 1]) return colors[n - 1];
    
    for (int i = 0; i < n - 1; ++i) {
        if (points[i] <= t && t <= points[i + 1]) {
            // t = smoothstep(points[i], points[i + 1], t);
            t = (t - points[i]) / (points[i + 1] - points[i]);
            return mix(colors[i], colors[i + 1], t);
        }
    }
    
    return vec3(0.0);
}

float plot(vec2 st, float pct) {
  return smoothstep( pct-0.02, pct, st.y) - smoothstep( pct, pct+0.02, st.y);
}

// Given a number between [0, 1], return an output between [0, 1].
float norm_sin(float t) {
    return 0.5 * sin(t * 2.0 * 3.14159) + 0.5;
}

float func(float x) {
    float t = (u_mouse.x / u_resolution.x);
    
    return 1.0 - pow(abs(sin(x * 0.5 * PI)), 1.328);
}

float getRipple(vec2 center, float width) {
    float d = 8.0 * distance(gl_FragCoord.xy / u_resolution, center) - 0.5 * u_time;
    float t = 2.0 * mod(d, width) / width;
    if (t > 1.0) {
        t = 2.0 - t;
    }
    return t;
}

float distanceDamp(vec2 center, float fadeoff) {
    return pow(1.0 - clamp(0.0, 1.0, distance(gl_FragCoord.xy / u_resolution, center) / fadeoff), 1.8);
}

float avg(float a, float b) {
    return (a + b) * 0.5;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    
    float x = st.x;
    
    vec2 point = vec2(0.3, norm_sin(u_time * 0.3));
    vec2 point2 = vec2(0.7, 1.0 - point.y);
    
	float y = func(mix(-1.0, 1.0, x));
    
    
    
    // BEGIN DRAWING REGION
    
    // vec3 color = vec3(y);
    // if (st.y > gradientDebugSplit) {
    //     color = gradientMap(y);
    // }
    // if (st.y > gradientDebugSplit && st.y < gradientDebugSplit + 0.01) {
    //     color *= 0.3;
    // }

    // float pct = plot(st,y);
    // color = (1.0-pct)*color+pct * mix(1. - color, vec3(1.0), .8);
	
    const int count = 5;
        
    float t = 0.0;
    
    float radius = 0.5;
    
    for (int i = 0; i < count; ++i) {
        
        float time = u_time * PI / 2.0;
        time += float(i) * PI2 / float(count);
        vec2 center = radius * vec2(cos(time), sin(time)) / 2.0 + 0.5;
        
        t += distanceDamp(center, 0.15);
    }
    
    radius = mix(0.1, 2.0 * radius, norm_sin(u_time * 0.5));
    
    for (int i = 0; i < count; ++i) {
        
        float time = -u_time * PI / 2.0 * 2.0;
        time += (float(i) + 0.2) * PI2 / float(count);
        vec2 center = radius * vec2(cos(time), sin(time)) / 2.0 + 0.5;
        
        t += distanceDamp(center, 0.2 + 0.1 * radius);
    }
    
    t += 0.1 * step(0.99, 1.0 - distance(st, vec2(0.5)));
    
    vec3 color = gradientMap(t);
    gl_FragColor = vec4(color, 1.0);
    
}