/* Main function, uniforms & utils */
#ifdef GL_ES
    precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359
#define PI2 6.28318530718

vec2 uv;
vec2 st;

// region Util

// Given a number between [0, 1], return an output between [0, 1].
float norm_sin(float t) {
  return 0.5 * sin(t * 2.0 * 3.14159) + 0.5;
}

// Function that defines smoothing feathering.
float smoothFunc(in float distance, in float width) {
	return 1.0 - pow(clamp(0.0, 1.0, abs(distance) / width), 8.0);
}

float lineMaskRounded(in vec2 start, in vec2 stop, in float width) {
	vec2 dv = normalize(stop - start);
	vec2 normal = vec2(dv.y, -dv.x);
	
	float dist = dot(st, normal) - dot(start, normal);
	
	vec2 inNormal = normalize(stop - start);
	
	float startDist = dot(st, inNormal) - dot(start, inNormal);
	float stopDist = dot(st, -inNormal) - dot(stop, -inNormal);
	if (startDist > 0.0 && stopDist > 0.0) {
		// inside line segment
		return smoothFunc(dist, width);
	} else if (startDist < 0.0) {
		// start cap
		return smoothFunc(distance(st, start), width);
	} else if (stopDist < 0.0) {
		// stop cap
		return smoothFunc(distance(st, stop), width);
	} else {
		// outside
		return 0.0;
	}

}

// Returns the density for a circular ring.
float circleMask(vec2 center, float radius, float width) {
	float d = distance(st, center);

	if (radius - width <= d && d <= radius + width) {
		return smoothFunc(d - radius, width);
	} else {
		return 0.0;
	}

}

// Returns the density for a circular ring.
vec2 distortTransform(in vec2 center, in float radius, in float width, in float power) {
	float d = distance(gl_FragCoord.xy, center);

	if (radius - width <= d && d <= radius + width) {
        float p = power * pow(cos(PI / 2.0 * (d - radius) / width), 3.0);
		return gl_FragCoord.xy - p * normalize(gl_FragCoord.xy - center);
	} else {
		return gl_FragCoord.xy;
	}

}

// endregion

const float k_distortPeriod = 1.0;
const float k_distortMaxRadius = 300.0;

void main() {

    float mouseDist = distance(gl_FragCoord.xy, u_mouse);
    float distortRadius = k_distortMaxRadius * pow(mod(u_time / k_distortPeriod, 1.0), 0.8);
    float distortFactor = 1.0 - pow(mouseDist / k_distortMaxRadius, 8.0);

    float d = 0.0;
    
    st = gl_FragCoord.xy;


    // region DRAW SHAPES WITHOUT DISTORTION

    float dd = 0.0;
    dd += 0.2 * circleMask(u_mouse, distortRadius, 1.0);
    dd += 0.1 * circleMask(u_mouse, distortRadius - 10.0, 1.0);
    dd *= distortFactor;

    float mpointRadius = 5.0 + 0.5 * sin(u_time / 4.0 * PI2);
    d += 0.2 * smoothFunc(mouseDist, mpointRadius);

    d += dd;

    // endregion



    // APPLY DISTORTION
    st = distortTransform(u_mouse, distortRadius, 23.0, 16.0 * distortFactor);

    

    // region DRAW SHAPES WITH DISTORTION

    d += lineMaskRounded(vec2(0.2, 0.5) * u_resolution, vec2(0.5, 0.7) * u_resolution, 8.0);
    d += lineMaskRounded(vec2(0.4, 0.9) * u_resolution, vec2(0.8, 0.67) * u_resolution, 8.0);
    d += lineMaskRounded(vec2(0.1, 0.1) * u_resolution, vec2(0.8, 0.4) * u_resolution, 8.0);
    d += circleMask(vec2(0.5, 0.3) * u_resolution, 100.0, 7.0);

    // endregion
    

    
    vec3 color = mix(vec3(0.102, 0.0941, 0.0941), vec3(0.9608, 0.9529, 0.9333), d);

    gl_FragColor = vec4(color, 1.0);
}