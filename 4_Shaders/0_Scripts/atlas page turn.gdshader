shader_type canvas_item;

// 0 = page lying on the right, 0.5 = standing upright at the spine, 1 = lying flat on the left.
uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;
// Horizontal position of the spine in UV space. The turning page is the texture region to its right.
uniform float spine_x : hint_range(0.0, 1.0, 0.001) = 0.5;
// Darkening applied to the back of the page (once it has passed vertical).
uniform float reverse_dark : hint_range(0.2, 1.0, 0.01) = 0.75;
// How much the free edge grows taller as it lifts towards the camera.
uniform float perspective : hint_range(0.0, 0.5, 0.001) = 0.12;
// How dark the page gets when it is upright.
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.35;

void fragment() {
	float angle = progress * PI;
	float page_w = 1.0 - spine_x;
	float c = cos(angle);

	vec4 col = vec4(0.0);

	// Edge-on pages have no visible width.
	if (abs(c) > 0.001) {
		// Distance from the spine as a fraction of the page width (0 at spine, 1 at free edge).
		float u = (UV.x - spine_x) / (page_w * c);

		if (u >= 0.0 && u <= 1.0) {
			// The free edge comes towards the camera, so it looks taller than the spine edge.
			float scale_y = 1.0 + perspective * sin(angle) * u;
			float v = 0.5 + (UV.y - 0.5) / scale_y;

			if (v >= 0.0 && v <= 1.0) {
				col = texture(TEXTURE, vec2(spine_x + u * page_w, v));

				float shade = 1.0 - shadow_strength * sin(angle);
				if (c < 0.0) {
					shade *= reverse_dark;
				}
				col.rgb *= shade;
			}
		}
	}

	COLOR = col;
}
