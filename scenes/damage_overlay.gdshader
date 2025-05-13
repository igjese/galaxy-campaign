shader_type canvas_item;

uniform sampler2D hull_texture;
uniform vec2 hull_offset;

void fragment() {
    // Get alpha of the hull underneath this pixel
    vec2 hull_uv = (SCREEN_UV - hull_offset);
    vec4 hull_color = texture(hull_texture, hull_uv);

    // Only show crack pixel if hull has alpha > 0
    vec4 crack = texture(TEXTURE, UV);
    if (hull_color.a < 0.1) {
        discard;
    }

    COLOR = crack;
}
