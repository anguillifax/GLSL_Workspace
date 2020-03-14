// Draw the x and y axes for custom st position transformation.
void drawAxes(inout vec3 color) {
    // x axis
    if (distance(st.y, 0.0) < 1.0) {
        color = vec3(1.0, 0.0, 0.0);
    }
    // y axis
    if (distance(st.x, 0.0) < 1.0) {
        color = vec3(0.0, 1.0, 0.0);
    }
}