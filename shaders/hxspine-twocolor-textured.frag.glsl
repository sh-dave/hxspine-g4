#version 450

in vec4 v_light;
in vec4 v_dark;
in vec2 v_texCoords;
uniform sampler2D u_texture;
out vec4 fragColor;

void main () {
	vec4 texColor = texture(u_texture, v_texCoords);
	fragColor.a = texColor.a * v_light.a;
	fragColor.rgb = ((texColor.a - 1.0) * v_dark.a + 1.0 - texColor.rgb) * v_dark.rgb + texColor.rgb * v_light.rgb;
}
