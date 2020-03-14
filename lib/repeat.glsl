
// Repeat a density mask within a given box. Wraps repeatX by repeatY times. Writes to float repeat_out.
#define _REPEAT_INNER(dx, dy) st = pos + size * vec2(float(dx), float(dy)); d = max(d, func);

#define REPEAT_BOX(size, basepos, offset, repeatX, repeatY, func) { vec2 prev_st = st; vec2 pos = mod((basepos) - (offset), size); st = pos; float d = 0.0; _REPEAT_INNER(0.0, 0.0, func); for (int x = 0; x <= (repeatX); ++x) { for (int y = 0; y <= (repeatY); ++y) { if (x == 0 && y == 0) continue; _REPEAT_INNER(x, y, func) _REPEAT_INNER(-x, y, func) _REPEAT_INNER(x, -y, func) _REPEAT_INNER(-x, -y, func) } } repeat_out = d; st = prev_st; }


// Same as above, but applies transform func after modulo.

#define _REPEAT_INNER_T(dx, dy, size, transformFunc, func) st = transformFunc((pos) + (size) * vec2(float(dx), float(dy))); d = max(d, func); 

#define REPEAT_BOX_T(size, basepos, offset, repeatX, repeatY, transformFunc, func) { vec2 prev_st = st; vec2 pos = mod((basepos) - (offset), size); st = pos; float d = 0.0; _REPEAT_INNER_T(0, 0, size, transformFunc, func); for (int x = 0; x <= (repeatX); ++x) { for (int y = 0; y <= (repeatY); ++y) { if (x == 0 && y == 0) continue; _REPEAT_INNER_T(x, y, size, transformFunc, func) _REPEAT_INNER_T(-x, y, size, transformFunc, func) _REPEAT_INNER_T(x, -y, size, transformFunc, func) _REPEAT_INNER_T(-x, -y, size, transformFunc, func) } } repeat_out = d; st = prev_st; }

// RAW CODE
/*

#define _REPEAT_INNER_T(dx, dy, size, transformFunc, func)
st = transformFunc((pos) + (size) * vec2(float(dx), float(dy)));
d = max(d, func);


#define REPEAT_BOX_T(size, basepos, offset, repeatX, repeatY, transformFunc, func)
{
    vec2 prev_st = st;

    vec2 pos = mod((basepos) - (offset), size);
    st = pos;

    float d = 0.0;

    _REPEAT_INNER_T(0, 0, size, transformFunc, func);

    for (int x = 0; x <= (repeatX); ++x) {
        for (int y = 0; y <= (repeatY); ++y) {
            if (x == 0 && y == 0) continue;

            _REPEAT_INNER_T(x, y, size, transformFunc, func)
            _REPEAT_INNER_T(-x, y, size, transformFunc, func)
            _REPEAT_INNER_T(x, -y, size, transformFunc, func)
            _REPEAT_INNER_T(-x, -y, size, transformFunc, func)
        }
    }

    repeat_out = d;

    st = prev_st;
}

*/