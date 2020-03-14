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

float smoothFunc(in float distance, in float width) {
	return 1.0 - pow(clamp(0.0, 1.0, abs(distance) / width), 2.0);
}

float gradientMaskRounded(in vec2 start, in vec2 stop, in float width, out float t_mix) {
    
    vec2 dvn = normalize(stop - start);
    float veclength = length(stop - start);

	vec2 wnorm = vec2(dvn.y, -dvn.x);
	float wdist = dot(gl_FragCoord.xy, wnorm) - dot(start, wnorm);

	vec2 lnorm = normalize(stop - start);
    float ldist = dot(gl_FragCoord.xy, lnorm) - dot(start, lnorm);

    t_mix = clamp(0.0, 1.0, ldist / veclength);

    if (0.0 < ldist && ldist < veclength) {
        return smoothFunc(wdist, width);
    } else {

        float sdist = distance(gl_FragCoord.xy, start);
        float edist = distance(gl_FragCoord.xy, stop);
        if (sdist < width) {
            return smoothFunc(sdist, width);
        } else if (edist < width) {
            return smoothFunc(edist, width);
        } else {
            return 0.0;
        }

    }

}

void blendGradient(in vec2 startNormalized, in vec2 stopNormalized, in float width, in vec3 startColor, in vec3 stopColor, inout vec3 color) {
    float t = 0.0;
    float d = gradientMaskRounded(startNormalized * u_resolution, stopNormalized * u_resolution, width, t);

    color = mix(color, mix(startColor, stopColor, t), d);
}

void main() {

    st = gl_FragCoord.xy;
    uv = st / u_resolution;

    float t_mix = 0.0;


    vec3 color = vec3(0.0);

    color = mix(vec3(0.227,0.191,0.431), vec3(0.4431, 0.5608, 0.8784), uv.y);

    blendGradient(vec2(0.750,0.400), vec2(0.650,1.000), 150.0, vec3(0.970,0.322,0.144), vec3(1.000,0.914,0.682), color);
    blendGradient(vec2(0.180,0.830), vec2(0.650,1.000), 120.0, vec3(0.943,0.949,0.970), vec3(1.000,0.914,0.682), color);
    blendGradient(vec2(0.0, 0.6), vec2(0.980,0.780), 180.0, vec3(0.953,0.902,0.697), vec3(1.000,0.617,0.351), color);
    blendGradient(vec2(0.400,0.420), vec2(0.770,0.650), 80.0, vec3(0.980,0.630,0.487), vec3(0.840,0.563,0.259), color);
    
    const float sunRadius = 30.0;
    float sundist = distance(gl_FragCoord.xy, vec2(0.750,0.290) * u_resolution);
    if (sundist < sunRadius) {
        color = mix(color, vec3(1.000,0.555,0.411), 1.0 - pow(sundist / sunRadius, 8.0));
    }
    
    gl_FragColor = vec4(color, 1.0);

}














