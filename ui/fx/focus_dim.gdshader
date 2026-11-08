shader_type canvas_item;
// Dialogue focus (ui.md 3.3): the world dims in coarse pixel bands around a lit spot on the speaker,
// plus a floor shade under the dialogue box so its text always reads. No blur, no full-screen blanket.
uniform vec2 rect_size = vec2(480.0, 270.0);
uniform vec2 center = vec2(240.0, 110.0);
uniform float radius = 96.0;
uniform float softness = 120.0;
uniform float strength = 0.5;
uniform float floor_from = 150.0;
uniform float floor_strength = 0.45;
uniform float bands = 6.0;
uniform vec4 tint : source_color = vec4(0.03, 0.02, 0.06, 1.0);

void fragment() {
	vec2 px = floor(UV * rect_size);
	vec2 d = (px - center) * vec2(1.0, 1.25);
	float k = smoothstep(radius, radius + softness, length(d)) * strength;
	float f = smoothstep(floor_from, rect_size.y, px.y) * floor_strength;
	float a = max(k, f);
	a = floor(a * bands * 2.0 + 0.5) / (bands * 2.0);
	COLOR = vec4(tint.rgb, a);
}
