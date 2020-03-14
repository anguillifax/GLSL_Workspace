/*
SHAPES
v1.1

Requirements
    Define st vec2

Usage
    Shape functions return density [0, 1] at given point
    Shapes begin with shape_
    Lines begin with line_
    Adjust k_SmoothDist to change smoothing amount

*/

#ifndef TWO_PI
#define TWO_PI 6.283185307179586
#endif

float k_SmoothDist = 2.0;

// region Shapes

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

// Shorthand for shape_Circle with radius of 5
float shape_Point(in vec2 center) {
    return shape_Circle(center, 5.0);
}

float shape_SemiCircle(vec2 point1, vec2 dir, float width) {
    float d = smoothstep(width, width - k_SmoothDist, distance(st, point1));

    float dista = dot(st, dir) - dot(dir, point1);
    if (dista < k_SmoothDist) {
        d *= smoothstep(0.0, k_SmoothDist, dista);
    }
    return d;
}

// endregion

// region Regular Polygons

float shape_Triangle(vec2 center, float radius, float angle) {
    const int sides = 3;

    float sideDist = radius * cos(TWO_PI / float(sides) / 2.0);
    float d = 1.0;

    for (int i = 0; i < sides; ++i) {
        float ang = float(i) * TWO_PI / float(sides) + angle;
        vec2 norm = -vec2(cos(ang), sin(ang));
        float dist = dot(st - center, norm);
        d *= smoothstep(sideDist, sideDist - k_SmoothDist, dist);

    }
    return d;
}

float shape_Pentagon(vec2 center, float radius, float angle) {
    const int sides = 5;

    float sideDist = radius * cos(TWO_PI / float(sides) / 2.0);
    float d = 1.0;

    for (int i = 0; i < sides; ++i) {
        float ang = float(i) * TWO_PI / float(sides) + angle;
        vec2 norm = -vec2(cos(ang), sin(ang));
        float dist = dot(st - center, norm);
        d *= smoothstep(sideDist, sideDist - k_SmoothDist, dist);

    }
    return d;
}

float shape_Hexagon(vec2 center, float radius, float angle) {
    const int sides = 5;

    float sideDist = radius * cos(TWO_PI / float(sides) / 2.0);
    float d = 1.0;

    for (int i = 0; i < sides; ++i) {
        float ang = float(i) * TWO_PI / float(sides) + angle;
        vec2 norm = -vec2(cos(ang), sin(ang));
        float dist = dot(st - center, norm);
        d *= smoothstep(sideDist, sideDist - k_SmoothDist, dist);

    }
    return d;
}

// Create an n-sided regular polygon. Sides argument must be const expression. Output density is stored in ngon_out float.
#define shape_Ngon(center, radius, angle, sides) { if (sides < 3) { ngon_out = 0.0; } else { float sideDist = (radius) * cos(TWO_PI / float(sides) / 2.0); float d = 1.0; for (int i = 0; i < (sides); ++i) {  float ang = float(i) * TWO_PI / float(sides) + (angle);  vec2 norm = -vec2(cos(ang), sin(ang));  float dist = dot(st - (center), norm);  d *= smoothstep(sideDist, sideDist - k_SmoothDist, dist); } ngon_out = d; } }
// ^ supremely cursed function ^

// endregion

// region Lines

float line_Edge(vec2 point1, vec2 point2, float width) {
    float len = length(point2 - point1);
    vec2 normAlong = normalize(point2 - point1);
    vec2 normPerp = vec2(normAlong.y, - normAlong.x);

    float distp = abs(dot(st, normPerp) - dot(normPerp, point1));
    float dista = dot(st, normAlong) - dot(normAlong, point1);

    return
        smoothstep(width, width - k_SmoothDist, distp) *
        (smoothstep(0.0, k_SmoothDist, dista) - smoothstep(len - k_SmoothDist, len, dista));
}

float line_Round(vec2 point1, vec2 point2, float width) {
    float len = length(point2 - point1);
    vec2 normAlong = normalize(point2 - point1);
    vec2 normPerp = vec2(normAlong.y, - normAlong.x);

    float distp = abs(dot(st, normPerp) - dot(normPerp, point1));
    float dista = dot(st, normAlong) - dot(normAlong, point1);

    if (dista < 0.0) {
        return smoothstep(width, width - k_SmoothDist, distance(st, point1));
    } else if (dista > len) {
        return smoothstep(width, width - k_SmoothDist, distance(st, point2));
    } else {
        return smoothstep(width, width - k_SmoothDist, distp);
    }
}

float line_Circle(in vec2 center, in float radius, in float width) {
    float d = distance(st, center);
    float innerRadius = radius - 0.5 * width;
    float outerRadius = radius + 0.5 * width;
    return smoothstep(innerRadius, innerRadius + k_SmoothDist, d) - 
           smoothstep(outerRadius - k_SmoothDist, outerRadius, d);
}

// endregion