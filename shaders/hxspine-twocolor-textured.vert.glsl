#version 450

// in vec2 a_position;
in vec4 a_position;
in vec4 a_color;
in vec4 a_color2;
in vec2 a_texCoords;
uniform mat4 u_projTrans;
out vec4 v_light;
out vec4 v_dark;
out vec2 v_texCoords;

void main () {
	v_light = a_color;
	v_dark = a_color2;
	v_texCoords = a_texCoords;
	// gl_Position = u_projTrans * vec4(a_position, 0, 0);
	gl_Position = u_projTrans * a_position;
}
