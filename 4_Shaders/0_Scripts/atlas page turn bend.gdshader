shader_type canvas_item;

// 0 = page lying on the right, 0.5 = upright at the spine, 1 = lying flat on the left.
uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;
// Horizontal position of the spine in UV space. The turning page is the texture region to its right.
uniform float spine_x : hint_range(0.0, 1.0, 0.001) = 0.5;
// How much the free edge leads (positive) or trails (negative) the spine edge mid-turn.
uniform float bend : hint_range(-2.0, 2.0, 0.01) = 0.8;
// Darkening applied to the back of the page.
uniform float reverse_dark : hint_range(0.2, 1.0, 0.01) = 0.75;
// How much parts of the page closer to the camera look taller.
uniform float perspective : hint_range(0.0, 0.5, 0.001) = 0.12;
// How dark the page gets where it is turned edge-on to the camera.
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.35;

const int SEGMENTS = 48;

// The page is a curve whose angle changes linearly along its length: theta(t) = angle + bend * sin(angle) * t.
// It is walked in small segments, and the nearest segment that covers this pixel's x is drawn.
void fragment() {
	float angle = progress * PI;
	float page_w = 1.0 - spine_x;
	float bend_amt = bend * sin(angle);
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
				float scale_y = max(1.0 + perspective * z, 0.1);
				float v = 0.5 + (UV.y - 0.5) / scale_y;

				if (v >= 0.0 && v <= 1.0) {
					best_z = z;
					col = texture(TEXTURE, vec2(spine_x + t * page_w, v));

					float shade = 1.0 - shadow_strength * abs(sin(theta));
					if (cos(theta) < 0.0) {
						shade *= reverse_dark;
					}
					col.rgb *= shade;
				}
			}
		}

		x0 = x1;
		z0 = z1;
	}

	COLOR = col;
}
