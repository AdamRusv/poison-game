shader_type canvas_item;

uniform highp float move_speed = 7.0;
uniform highp float shape_size = 2.5;

uniform highp vec4 color_1 : source_color = vec4(0, 0, 0, 1.0);
uniform highp vec4 color_2 : source_color = vec4(0, 0, 0, 1.0);
uniform highp vec4 color_3 : source_color = vec4(0, 0, 0, 1.0);


vec4 effect(vec2 screen_size, vec2 screen_coords) {
    highp vec2 uv = (
        screen_coords
        - 0.5 * screen_size
    ) / length(screen_size);

    uv *= 12.0;

    highp float movement = TIME * move_speed;
    highp vec2 uv2 = vec2(uv.x + uv.y);

    for (int i = 0; i < 3; i++) {
        uv2 += sin(max(uv.x, uv.y)) + uv;

        uv += 0.35 * vec2(
            cos(
                5.1123314
                + 0.353 * uv2.y
                + movement * 0.131121
            ),
            sin(
                uv2.x
                - 0.113 * movement
            )
        );

        uv -= 0.35 * (
            cos(uv.x + uv.y)
            - sin(uv.x * 0.711 - uv.y)
        );
    }

    highp vec2 shape_uv = uv / shape_size;

    highp float horizontal_shapes = cos(
        shape_uv.x * 2.0
        + movement * 0.025
    );

    highp float vertical_shapes = cos(
        shape_uv.y * 2.0
        - movement * 0.018
    );

    highp float diagonal_shapes = sin(
        (shape_uv.x + shape_uv.y) * 1.25
        + movement * 0.012
    );

    highp float shape_value =
        horizontal_shapes
        + vertical_shapes
        + diagonal_shapes * 0.45;

    // Divide the pattern into three solid-color regions.
    highp float middle_mask = step(-0.35, shape_value);
    highp float upper_mask = step(0.65, shape_value);

    highp vec4 final_color = color_3;
    final_color = mix(final_color, color_2, middle_mask);
    final_color = mix(final_color, color_1, upper_mask);

    return final_color;
}


void fragment() {
    COLOR *= effect(TEXTURE_PIXEL_SIZE, UV);
}