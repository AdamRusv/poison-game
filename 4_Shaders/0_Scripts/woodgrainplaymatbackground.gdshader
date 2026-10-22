shader_type canvas_item;

// Colors
uniform vec4 light_color : source_color = vec4(0.95, 0.85, 0.75, 1.0);
uniform vec4 dark_color : source_color = vec4(0.75, 0.62, 0.49, 1.0);

// Pattern controls
uniform float ring_scale : hint_range(1.0, 20.0) = 4.4;
uniform float wave_scale : hint_range(1.0, 30.0) = 8.45;
uniform float random_scale : hint_range(1.0, 20.0) = 4.6;
uniform float noise_scale : hint_range(0.0, 0.1) = 0.03;

// Motion controls
uniform float speed : hint_range(0.0, 5.0) = 0.6;
uniform float spin_speed : hint_range(0.0, 2.0) = 0.2;
uniform float warp_intensity : hint_range(0.0, 2.0) = 0.5;

// Cutoff threshold between solid bands (0.0 to 1.0)
uniform float band_cutoff : hint_range(0.0, 1.0) = 0.5;

vec2 random(vec2 pos) {
	return fract(
		sin(
			vec2(
				dot(pos, vec2(12.9898, 78.233)),
				dot(pos, vec2(-148.998, -65.233))
			)
		) * 43758.5453
	);
}

float value_noise(vec2 pos) {
	vec2 p = floor(pos);
	vec2 f = fract(pos);

	float v00 = random(p + vec2(0.0, 0.0)).x;
	float v10 = random(p + vec2(1.0, 0.0)).x;
	float v01 = random(p + vec2(0.0, 1.0)).x;
	float v11 = random(p + vec2(1.0, 1.0)).x;

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(v00, v10, u.x), mix(v01, v11, u.x), u.y);
}

vec2 rotate_uv(vec2 uv, vec2 pivot, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	uv -= pivot;
	return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c) + pivot;
}

void fragment() {
	float t = TIME * speed;

	// Center and rotate UVs
	vec2 uv = rotate_uv(UV, vec2(0.5), TIME * spin_speed);

	// Sample noise from undisturbed UVs to prevent grid slicing/tearing
	vec2 noise_uv = uv * random_scale + vec2(t * 0.1, -t * 0.15);
	float n = value_noise(noise_uv);

	// Multi-frequency warp driven by trig waves and smooth noise
	vec2 warp;
	warp.x = sin(uv.y * wave_scale + t + n * 2.0) * warp_intensity;
	warp.y = cos(uv.x * wave_scale - t * 0.8 + n * 2.0) * warp_intensity;

	vec2 shift_uv = uv + warp;

	// Primary wave calculation
	float x = shift_uv.x + sin(shift_uv.y * wave_scale + t);
	float f = mod(x * ring_scale + random(UV).x * noise_scale, 1.0);

	// Sharp, solid transition with anti-aliasing to stop jagged seam artifacts
	float edge_width = fwidth(f) * 1.5;
	float stepped_f = smoothstep(band_cutoff - edge_width, band_cutoff + edge_width, f);

	COLOR = mix(light_color, dark_color, stepped_f);
}