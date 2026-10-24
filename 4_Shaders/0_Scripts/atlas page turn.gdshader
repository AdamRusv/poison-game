shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;
// Horizontal position of the spine in UV space. (Page starts on right)
uniform float spine_x : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float bend : hint_range(-2.0, 2.0, 0.01) = 0.8;
// Texture shown on the back of the page. It is attached to the page like the front, so it must be authored mirrored
// (horizontally flipped, in the right half like the front); the turn mirrors it back so it reads correctly on the left.
uniform sampler2D back_texture : hint_default_transparent, filter_nearest;
// How much the free edge grows taller as it lifts towards the camera. (0 gives no bend, max gives mega perspective, 0.05 - 0.12 is a good range)
uniform float perspective : hint_range(0.0, 0.5, 0.001) = 0.12;
// How dark the page gets when it is upright
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.35;

const int SEGMENTS = 48;

// Snaps a UV to the center of its texel so sampling is always nearest-neighbour, whatever filter the node uses.
vec2 snap_uv(vec2 uv, vec2 tex_size) {
	return (floor(uv * tex_size) + 0.5) / tex_size;
}

void fragment() {
	float angle = progress * PI;
	float page_w = 1.0 - spine_x;
	float bend_amt = bend * sin(angle);
	// Distance from the spine as a fraction of the page width (0 at spine, 1 at free edge).
	float target = (UV.x - spine_x) / page_w;

	vec4 col = vec4(0.0);
	float best_z = -1e9;
	float x0 = 0.0;
	float z0 = 0.0;

	for (int i = 0; i < SEGMENTS; i++) {
		float t0 = float(i) / float(SEGMENTS);
		float t1 = float(i + 1) / float(SEGMENTS);
		float theta = angle + bend_amt * (t0 + t1) * 0.5;
		float x1 = x0 + cos(theta) / float(SEGMENTS);
		float z1 = z0 + sin(theta) / float(SEGMENTS);

		float lo = min(x0, x1);
		float hi = max(x0, x1);
		if (target >= lo && target <= hi) {
			float f = hi > lo ? (target - x0) / (x1 - x0) : 0.0;
			float z = mix(z0, z1, f);

			if (z > best_z) {
				float t = mix(t0, t1, f);
				// The free edge comes towards the camera, so it looks taller than the spine edge.
				float scale_y = max(1.0 + perspective * z, 0.1);
				float v = 0.5 + (UV.y - 0.5) / scale_y;

				if (v >= 0.0 && v <= 1.0) {
					best_z = z;
					// Past vertical the back face is visible.
					vec2 page_uv = vec2(spine_x + t * page_w, v);
					col = cos(theta) < 0.0
						? texture(back_texture, snap_uv(page_uv, vec2(textureSize(back_texture, 0))))
						: texture(TEXTURE, snap_uv(page_uv, vec2(textureSize(TEXTURE, 0))));

					col.rgb *= 1.0 - shadow_strength * abs(sin(theta));
				}
			}
		}

		x0 = x1;
		z0 = z1;
	}

	COLOR = col;
}
