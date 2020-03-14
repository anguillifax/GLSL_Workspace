float random(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453123);
}

float random(float pos) {
    return random(vec2(pos, 0.0));
}