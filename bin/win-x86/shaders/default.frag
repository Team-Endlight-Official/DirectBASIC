#version 330 core

in vec3 verts;

out vec4 OUT_COLOR;

void main()
{
    OUT_COLOR = vec4(verts.x + 0.5, verts.y + 0.5, verts.z + 0.5, 1.0);
}