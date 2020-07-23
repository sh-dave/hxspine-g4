#version 450

// in vec2 a_position;
in vec4 a_position;
in vec4 a_color;
in vec2 a_texCoords;
uniform mat4 u_projTrans;
out vec4 v_color;
out vec2 v_texCoords;

void main () {
	v_color = a_color;
	v_texCoords = a_texCoords;
	// gl_Position = u_projTrans * vec4(a_position, 0, 0);
	gl_Position = u_projTrans * a_position;
}
