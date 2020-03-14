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

// region Util

// Remap a value between [fromLower, fromUpper] to [toLower, toUpper]
float remap(float t, float fromLower, float fromUpper, float toLower, float toUpper) {
	return (t - fromLower) / (fromUpper - fromLower) * (toUpper - toLower) + toLower;
}

// Function that defines smoothing feathering.
float smoothFunc(float distance, float width) {
	return 1.0 - pow(clamp(0.0, 1.0, abs(distance) / width), 1.2);
}

// Returns the point density at a given screen pixel. 0.0 is empty, 1.0 is full.
float pointMask(vec2 point, float radius) {
	float d = distance(st, point);
	if (d < radius) {
		return smoothFunc(d, radius);
	} else {
		return 0.0;
	}
}

// Returns the line density at given screen pixel. 0.0 is empty, 1.0 is full. Rounds endcaps.
float lineMaskRounded(vec2 start, vec2 stop, float width) {
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

// endregion

float circleMask(vec2 center, float radius, float width) {
	float d = distance(st, center);

	if (radius - width <= d && d <= radius + width) {
		return smoothFunc(d - radius, width);
	} else {
		return 0.0;
	}

}

float getPingDensity(in float t) {
	return 0.4 * sin(pow(clamp(0.0, 1.0, t), 1.7) * PI);
}

float radarPing(vec2 center, float radius, float pingWidth, float progress) {
	float dist = distance(st, center);
	if (dist <= radius * progress && dist > max(0.0, radius * progress - pingWidth)) {
		return getPingDensity(progress) * (1.0 - (radius * progress - dist) / pingWidth);
	}
	return 0.0;
}

const float k_width = 2.0;

float easeExpoIn(float t) {
	return (t == 0.0) ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}

float getLoopTime(in float progressTime, in float cooldown, in float offset) {
	float m = mod(u_time + offset, progressTime + cooldown);
	if (m <= progressTime) {
		return m / progressTime;
	} else {
		return 0.0;
	}
}

const int k_circularPingCount = 4;

float getPingTime(in int offset) {
	return 1.0 - cos(getLoopTime(float(k_circularPingCount), 0.4, float(offset)) * PI / 2.0);
}

float getRotateMask(in vec2 center, in float curAngle) {
	float a = atan(st.y - center.y, st.x - center.x);
	float a2 = mod(a - curAngle, PI2) / PI2;
	return clamp(0.0, 1.0, max(0.0, remap(pow(a2, 2.0), 0.3, 1.0, 0.0, 1.0)));
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

const float k_distortPeriod = 2.0;
const float k_distortMaxRadius = 300.0;

void main() {

    st = gl_FragCoord.xy;
	uv = gl_FragCoord.xy / u_resolution;
    vec2 res = u_resolution;

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
    if (mouseDist < mpointRadius) {
        d += 0.3;
    }

    d += dd;

    // endregion



    // APPLY DISTORTION
    st = distortTransform(u_mouse, distortRadius, 23.0, 16.0 * distortFactor);






    vec3 color = vec3(0.0706, 0.0824, 0.0863);

	float radius = 200.0 + 2.0 * sin(u_time * PI2 / 8.0);

    float t = PI2 * mod(u_time / 4.0, 1.0);
    vec2 point = radius * vec2(cos(t), sin(t));
    
    vec2 center = vec2(0.5, 0.5) * res;
    
	for (int i = 0; i < k_circularPingCount; ++i) {
		d += 0.4 * radarPing(center, radius, 30.0, getPingTime(i));
	}

	d += lineMaskRounded(center, center + point, k_width);
	if (distance(st, center) < radius) {
		float x = 0.3 * pow(getRotateMask(center, t), 1.5);
		if (mod(gl_FragCoord.x, 4.0) < 2.3 && mod(gl_FragCoord.y, 4.0) < 2.3) {
			x = 1.1 * x + 0.02;
		}
		d += x;
	}

	d += circleMask(center, radius, k_width);
	d += 0.4 * circleMask(center, 0.66 * radius, k_width);
	d += 0.2 * circleMask(center, 0.33 * radius, k_width);

	d = 2.0 * pow(d, 1.8);

	int sx = int(mod(st.x, 4.0));
	int sy = int(mod(st.y, 4.0));
	if (sx == 0 && sy == 0) {
		d += 0.09;
	} else if (sx == 1 && sy == 1) {
		d += 0.03;
	} else if (sx == 2 && sy == 1) {
		d += 0.06;
	}


    color = mix(color, vec3(0.2941, 1.0, 0.2), d);

    gl_FragColor = vec4(color, 1.0);

}