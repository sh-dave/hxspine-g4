#version 450

// in vec2 a_position;
in vec4 a_position;
in vec4 a_color;
uniform mat4 u_projTrans;
out vec4 v_color;

void main () {
	v_color = a_color;
	// gl_Position = u_projTrans * vec4(a_position, 0, 0);
	gl_Position = u_projTrans * a_position;
}
