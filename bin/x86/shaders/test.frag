#version 330 core

in vec3 vertexColor;

out vec4 FRAG_RESULT;

void main()
{
    FRAG_RESULT = vec4(vertexColor, 1.0);
}