mat2 mat2_Rotate(float angle) {
    return mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );
}


mat2 mat2_Scale(float x, float y) {
    return mat2(
        1.0 / x, 0.0,
        0.0, 1.0 / y
    );
}
mat2 mat2_Scale(vec2 xy) {
    return mat2_Scale(xy.x, xy.y);
}


mat2 mat2_Shear(float x, float y) {
    return mat2(
        1.0, -x,
        -y, 1.0
    );
}
mat2 mat2_Shear(vec2 xy) {
    return mat2_Shear(xy.x, xy.y);
}