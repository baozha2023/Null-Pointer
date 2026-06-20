shader_type canvas_item;

uniform float width : hint_range(0.0, 16.0) = 0.0;
uniform vec4 outline_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // Gold
uniform float brightness : hint_range(0.0, 3.0) = 1.0;

void fragment() {
    float max_alpha = texture(TEXTURE, UV).a;
    vec2 size = TEXTURE_PIXEL_SIZE * width;
    
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, 0.0)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, -size.y)).a);
    
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, -size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, -size.y)).a);
    
    vec4 base_color = texture(TEXTURE, UV);
    base_color.rgb *= brightness; // Apply brightness pulse to original sprite
    
    vec4 final_color = mix(outline_color, base_color, base_color.a);
    COLOR = vec4(final_color.rgb, max(base_color.a, max_alpha * outline_color.a));
}
