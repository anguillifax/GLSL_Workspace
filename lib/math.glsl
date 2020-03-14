// Clamp a value between [0, 1]
float clamp01(float value) {
    return clamp(0.0, 1.0, value);
}

// vec2 clamp01(vec2 value) {
//     return clamp(0.0, 1.0, value);
// }

// Round value to the nearest boundary.
float round(float value, float boundary) {
    return floor(value / boundary + 0.5) * boundary;
}


// Return the right hand normal between begin and end
vec2 getNormal(vec2 begin, vec2 end) {
    vec2 v = normalize(end - begin);
    return vec2(v.y, -v.x);
}


// Given a number between [0, 2*PI], return an output between [0, 1].
float norm_sin(float t) {
    return 0.5 * sin(t) + 0.5;
}


// Remap a value between [fromLower, fromUpper] to [toLower, toUpper]
float remap(float t, float fromLower, float fromUpper, float toLower, float toUpper) {
	return (t - fromLower) / (fromUpper - fromLower) * (toUpper - toLower) + toLower;
}


// Returns curve __/*\_ for [0, 1] where * is at stop position.
float smoothstepPulse(float lower, float upper, float stop, float t) {
    float c = (upper - lower) * stop + lower;
    return smoothstep(lower, c, t) - smoothstep(c, upper, t);
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