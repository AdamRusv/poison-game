shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

/* ── Toggles ── */
uniform bool enableVignette		= true;
uniform bool enableBloom		= true;
uniform bool enableChromAb		= true;
uniform bool enableColorGrade	= true;

/* ── Vignette ── */
uniform float vignetteRadius	: hint_range(0.0, 1.5) = 1.05;	// >1 pushes corners darker
uniform float vignetteSoftness	: hint_range(0.0, 1.0) = 0.45;
uniform float vignetteStrength	: hint_range(0.0, 1.0) = 0.22;

/* ── Bloom (uses mip levels of screen) ── */
uniform float bloomStrength		: hint_range(0.0, 1.0) = 0.2;
uniform float bloomMipLevel		: hint_range(0.0, 6.0) = 3.5;	// higher = blurrier (depends on RT size)

/* ── Chromatic aberration ── */
uniform float abAmount			: hint_range(0.0, 4.0) = 0.65;	// in pixels at screen edge

const vec3 lift				= vec3(0.02, 0.01, 0.03);		// shadows
const vec3 gamma				= vec3(1.0, 1.0, 1.0);			// midtones (1.0 = neutral)
const vec3 gain				= vec3(1.04, 1.02, 1.05);		// highlights

/* ── Helpers ── */
float hash21(vec2 p) {
	// Simple hash for grain (stable and cheap)
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

vec3 apply_lift_gamma_gain(vec3 c, vec3 L, vec3 G, vec3 A) {
	// Clamp to avoid NANs on pow
	c = clamp(c + L, 0.0, 1.0);
	// Gamma: pow per channel (avoid 0 by max with tiny epsilon)
	c = pow(max(c, vec3(1e-4)), 1.0 / max(G, vec3(1e-4)));
	c *= A;
	return c;
}

void fragment() {
	// Base sample
	vec2 uv = SCREEN_UV;
	vec4 src = texture(SCREEN_TEXTURE, uv);
	
	if (src == vec4(0, 0, 0, 1)){
		COLOR = vec4(0);
	}
	else{
	
	// === Chromatic aberration (subtle) ===
	vec3 col = src.rgb;
	if (enableChromAb && abAmount > 0.0) {
		// Convert abAmount in pixels → UV units using TEXTURE_PIXEL_SIZE (vec2)
		vec2 px = TEXTURE_PIXEL_SIZE;
		// radial direction from center
		vec2 dc = uv - vec2(0.5, 0.5);
		float dist = length(dc);
		vec2 dir = dist > 0.0 ? dc / dist : vec2(0.0, 0.0);
		// scale shift with distance to edges
		float shift_px = abAmount * dist;						// pixels
		vec2 shift_uv = dir * shift_px * px;					// to UV
		float lod0 = 0.0;

		float r  = textureLod(SCREEN_TEXTURE, uv + shift_uv, lod0).r;
		float g  = textureLod(SCREEN_TEXTURE, uv,           lod0).g;
		float b  = textureLod(SCREEN_TEXTURE, uv - shift_uv, lod0).b;
		col = vec3(r, g, b);
	}

	// === Bloom via lower mip level ===
	if (enableBloom && bloomStrength > 0.0) {
		vec3 blur = textureLod(SCREEN_TEXTURE, uv, bloomMipLevel).rgb;
		// soft additive bloom, tempered by highlight energy from src
		float energy = clamp(max(max(src.r, src.g), src.b), 0.0, 1.0);
		col = mix(col, col + blur * energy, bloomStrength);
	}

	// === Color grading (lift/gamma/gain) ===
	if (enableColorGrade) {
		col = apply_lift_gamma_gain(col, lift, gamma, gain);
	}

	// === Vignette ===
	if (enableVignette && vignetteStrength > 0.0) {
		// distance from center normalized to fit aspect
		vec2 centered = (uv - vec2(0.5, 0.5));
		// correct for aspect ratio
		float aspect = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;	// width / height in pixels
		centered.x *= aspect;
		float d = length(centered);
		// smooth falloff
		float inner = vignetteRadius * (1.0 - vignetteSoftness);
		float outer = vignetteRadius;
		float v = smoothstep(inner, outer, d);
		col *= (1.0 - vignetteStrength * v);
	}

	// Output (preserve original alpha)
	COLOR = vec4(col, src.a);
}}
