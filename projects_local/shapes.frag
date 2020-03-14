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

const float k_SmoothDist = 3.0;

float clamp01(float value) {
    return clamp(0.0, 1.0, value);
}

float shape_Rect2p(in vec2 corner1, in vec2 corner2) {
    vec2 minc = min(corner1, corner2);
    vec2 maxc = max(corner1, corner2);
    vec2 lower = smoothstep(minc, minc + vec2(k_SmoothDist), st);
    vec2 upper = smoothstep(maxc, maxc - vec2(k_SmoothDist), st);
    return lower.x * lower.y * upper.x * upper.y;
}

float shape_RectCE(in vec2 center, in vec2 extents) {
    vec2 lower = smoothstep(center - extents, center - extents + vec2(k_SmoothDist), st);
    vec2 upper = smoothstep(center + extents, center + extents - vec2(k_SmoothDist), st);
    return lower.x * lower.y * upper.x * upper.y;
}

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

// Round value to the nearest boundary.
float round(float value, float boundary) {
    return floor(value / boundary + 0.5) * boundary;
}

float shape_Gear(in vec2 center, in float radius, in float offsetRadius, in float width, in float spacing, in float adjAngle) {
    vec2 pos = st - center;
    float angle = atan(pos.y, pos.x);

    float a = round(angle, spacing);

    float holeDist = distance(st, center + offsetRadius * vec2(cos(a), sin(a)));

    return
        smoothstep(width - k_SmoothDist, width, holeDist) * 
        smoothstep(radius, radius - k_SmoothDist, length(pos));

}

// region Distort Utility

/*
DISTORT UTILITY
Version 1.1

Requirements
    define PI Constant
    define st vec2


Usage
    Call setupDistort() to apply effect.
        Function returns density at current point to render distortion rings effect.
        Function will set st vec2.
    All functions affected by distortion must use custom st vec2 instead of gl_FragCoord.xy

*/

// === CONFIG ===

const bool k_distortEnabled = false;
const bool k_distortDrawCenter = true;
const float k_distortPeriod = 3.0;
const float k_distortMaxRadius = 300.0;
const float k_distortPower = 12.0;
const float k_distortWidth = 23.0;


// === FUNCTIONS ===

// Function that defines smoothing feathering.
float distort_SmoothFunc(in float distance, in float width) {
	return 1.0 - pow(clamp(0.0, 1.0, abs(distance) / width), 8.0);
}

// Returns the density for a circular ring.
float circleMask(vec2 center, float radius, float width) {
	float d = distance(st, center);

	if (radius - width <= d && d <= radius + width) {
		return distort_SmoothFunc(d - radius, width);
	} else {
		return 0.0;
	}

}

// Returns the density for a circular ring.
vec2 distortTransform(in vec2 center, in float radius, in float width, in float power) {
	float d = distance(gl_FragCoord.xy, center);

	if (radius - width <= d && d <= radius + width) {
        // distortAmount = effectPower * (cos from [-pi/2, +pi2]) ^ (steepen by x^3)
        float p = power * pow(cos(PI / 2.0 * (d - radius) / width), 3.0);
        // offsetPosition = pixelPosition - distortAmount * outwardRadial_UnitVector
		return gl_FragCoord.xy - p * normalize(gl_FragCoord.xy - center);
	} else {
		return gl_FragCoord.xy;
	}

}

void setupDistort(inout float d) {

    // setup variables
    float mouseDist = distance(gl_FragCoord.xy, u_mouse);
    float distortRadius = k_distortMaxRadius * pow(mod(u_time / k_distortPeriod, 1.0), 0.8);
    float fadeoff = 1.0 - pow(mouseDist / k_distortMaxRadius, 8.0);

    // draw with no distortion applied
    st = gl_FragCoord.xy;

    if (k_distortEnabled) {

        // draw rings
        float dd = 0.0;

        // outer rings
        dd += 0.2 * circleMask(u_mouse, distortRadius + k_distortWidth * 0.8, 1.0);
        dd += 0.1 * circleMask(u_mouse, distortRadius + k_distortWidth * 0.4, 1.0);

        // inner ring
        // dd += 0.06 * circleMask(u_mouse, distortRadius - k_distortWidth * 0.6, 1.0);

        // center ring
        // dd += 0.3 * circleMask(u_mouse, distortRadius, 1.0);

        // fade out smoothly
        d = dd * fadeoff;

        // draw center point
        if (k_distortDrawCenter) {
            float mpointRadius = 5.0 + 0.5 * sin(u_time / 4.0 * PI2);
            d += 0.2 * distort_SmoothFunc(mouseDist, mpointRadius);
        }

        // apply distortion
        st = distortTransform(u_mouse, distortRadius, k_distortWidth, k_distortPower * fadeoff);

    }

}

// endregion

void main() {

    float d = 0.0;
    vec3 color = vec3(0.0);
    setupDistort(d);
    uv = st / u_resolution;

    float time = u_time * PI2 / 2.0;

    vec2 centerv = vec2(0.5) * u_resolution;

    float dd = 0.0;
    dd += shape_Gear(vec2(0.5, 0.5) * u_resolution, 150.0, 80.0, 30.0, PI2 / 6.0, u_time);

    d += clamp01(dd);

    color = mix(vec3(0), vec3(uv.x, uv.y, 1.0), clamp(0.0, 1.0, d));

    gl_FragColor = vec4(color, 1.0);

}