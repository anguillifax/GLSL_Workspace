// Greyscale

#define WHITE vec3(1.0)
#define GREY vec3(0.5)
#define BLACK vec3(0.0)
#define DIMGREY vec3(0.1)

// Pure Hues

#define PRED vec3(1.0, 0.0, 0.0)
#define PGREEN vec3(0.0, 1.0, 0.0)
#define PBLUE vec3(0.0, 0.0, 1.0)

#define PYELLOW vec3(1.0, 1.0, 0.0)
#define PCYAN vec3(0.0, 1.0, 1.0)
#define PMAGENTA vec3(1.0, 0.0, 1.0)

#define YELLOW vec3(1.0, 0.8667, 0.1216)
#define ORANGE vec3(0.9255, 0.2941, 0.1373)
#define RED vec3(0.8863, 0.0824, 0.0824)
#define MAGENTA vec3(0.8196, 0.2039, 0.4118)
#define BLUE vec3(0.1529, 0.3804, 0.8745)
#define CYAN vec3(0.1882, 0.7373, 0.8745)
#define GREEN vec3(0.4078, 0.8863, 0.1294)

#define IVORY vec3(1.0, 0.9, 0.8)
#define SUNSET vec3(0.9, 0.3, 0.3)
#define NAVY vec3(0.0, 0.1, 0.2)


// functions

vec3 mixDensityUV(vec3 base, float d) {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    return mix(base, 0.96 * vec3(uv.x, uv.y, 1.0), d);
}