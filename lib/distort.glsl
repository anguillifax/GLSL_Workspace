/*
DISTORT UTILITY
v1.1

Requirements
    Define PI Constant
    Define st vec2


Usage
    Call setupDistort() to apply effect.
        Function returns density at current point to render distortion rings effect.
        Function will set st vec2.
    All functions affected by distortion must use custom st vec2 instead of gl_FragCoord.xy

*/

// === CONFIG ===

const bool k_DistortEnabled = true;
const bool k_DistortDrawCenter = true;
const float k_DistortPeriod = 3.0;
const float k_DistortMaxRadius = 300.0;
const float k_DistortPower = 12.0;
const float k_DistortWidth = 23.0;


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
    float distortRadius = k_DistortMaxRadius * pow(mod(u_time / k_DistortPeriod, 1.0), 0.8);
    float fadeoff = 1.0 - pow(mouseDist / k_DistortMaxRadius, 8.0);

    // draw with no distortion applied
    st = gl_FragCoord.xy;

    if (k_DistortEnabled) {

        // draw rings
        float dd = 0.0;

        // outer rings
        dd += 0.2 * circleMask(u_mouse, distortRadius + k_DistortWidth * 0.8, 1.0);
        dd += 0.1 * circleMask(u_mouse, distortRadius + k_DistortWidth * 0.4, 1.0);

        // inner ring
        // dd += 0.06 * circleMask(u_mouse, distortRadius - k_DistortWidth * 0.6, 1.0);

        // center ring
        // dd += 0.3 * circleMask(u_mouse, distortRadius, 1.0);

        // fade out smoothly
        d = dd * fadeoff;

        // draw center point
        if (k_DistortDrawCenter) {
            float mpointRadius = 5.0 + 0.5 * sin(u_time / 4.0 * PI2);
            d += 0.2 * distort_SmoothFunc(mouseDist, mpointRadius);
        }

        // apply distortion
        st = distortTransform(u_mouse, distortRadius, k_DistortWidth, k_DistortPower * fadeoff);

    }

}