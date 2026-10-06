shader_type canvas_item;


uniform vec2 speed;


void fragment () {
	vec2 uv = UV + TIME * speed;
	
	COLOR = texture(TEXTURE, uv);
}