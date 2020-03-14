/*
REPEAT

Requirements
    transformFunc function header: vec2 XX(vec2 input);

Usage
    Header: REPEAT_BOX_T(vec2 size, vec2 basepos, const int repeatX, const int repeatY, Func<vec2, vec2> transformFunc, Action<float> func)
    Header: REPEAT_BOX(vec2 size, vec2 basepos, const int repeatX, const int repeatY, Action<float> func)

*/

#define _REPEAT_INNER_T(dx, dy, size, transformFunc, func) st = transformFunc((pos) + (size) * vec2(float(dx), float(dy))); d = max(d, func); 

// Repeat a density mask within a given box. Wraps repeatX by repeatY times. Writes to float repeat_out.
#define REPEAT_BOX_T(size, basepos, repeatX, repeatY, transformFunc, func) { vec2 prev_st = st; vec2 pos = mod(basepos, size); st = pos; float d = 0.0; _REPEAT_INNER_T(0, 0, size, transformFunc, func); for (int x = 0; x <= (repeatX); ++x) { for (int y = 0; y <= (repeatY); ++y) { if (x == 0 && y == 0) continue; _REPEAT_INNER_T(x, y, size, transformFunc, func) _REPEAT_INNER_T(-x, y, size, transformFunc, func) _REPEAT_INNER_T(x, -y, size, transformFunc, func) _REPEAT_INNER_T(-x, -y, size, transformFunc, func) } } repeat_out = d; st = prev_st; }

#define REPEAT_BOX(size, basepos, repeatX, repeatY, func) REPEAT_BOX_T(size, basepos, repeatX, repeatY, , func)


#define _REPEAT_INNER_O(dx, dy, size, offset, transformFunc, func) st = transformFunc((pos) - (size) * vec2(float(dx), float(dy))) - (offset) * vec2(float(dx), float(dy)); d = max(d, func);

#define REPEAT_BOX_O(size, basepos, offset, repeatX, repeatY, transformFunc, func) { vec2 prev_st = st; vec2 pos = mod(basepos, size); st = pos; float d = 0.0; _REPEAT_INNER_O(0, 0, size, offset, transformFunc, func); for (int x = 0; x <= (repeatX); ++x) { for (int y = 0; y <= (repeatY); ++y) { if (x == 0 && y == 0) continue; _REPEAT_INNER_O(x, y, size, offset, transformFunc, func) _REPEAT_INNER_O(-x, y, size, offset, transformFunc, func) _REPEAT_INNER_O(x, -y, size, offset, transformFunc, func) _REPEAT_INNER_O(-x, -y, size, offset, transformFunc, func) } } repeat_out = d; st = prev_st; }



// RAW CODE
/*

#define _REPEAT_INNER_T(dx, dy, size, transformFunc, func)
st = transformFunc((pos) + (size) * vec2(float(dx), float(dy)));
d = max(d, func);


#define REPEAT_BOX_T(size, basepos, repeatX, repeatY, transformFunc, func)
{
    vec2 prev_st = st;

    vec2 pos = mod(basepos, size);
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

/*

#define _REPEAT_INNER_O(dx, dy, size, offset, transformFunc, func)
st = transformFunc((pos) + (size) * vec2(float(dx), float(dy))) - (offset);
d = max(d, func);


#define REPEAT_BOX_O(size, basepos, offset, repeatX, repeatY, transformFunc, func)
{
    vec2 prev_st = st;

    vec2 pos = mod(basepos, size);
    st = pos;

    float d = 0.0;

    _REPEAT_INNER_O(0, 0, size, offset, transformFunc, func);

    for (int x = 0; x <= (repeatX); ++x) {
        for (int y = 0; y <= (repeatY); ++y) {
            if (x == 0 && y == 0) continue;

            _REPEAT_INNER_O(x, y, size, offset, transformFunc, func)
            _REPEAT_INNER_O(-x, y, size, offset, transformFunc, func)
            _REPEAT_INNER_O(x, -y, size, offset, transformFunc, func)
            _REPEAT_INNER_O(-x, -y, size, offset, transformFunc, func)
        }
    }

    repeat_out = d;

    st = prev_st;
}

*/