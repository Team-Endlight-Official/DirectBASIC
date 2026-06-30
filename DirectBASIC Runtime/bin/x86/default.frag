#version 330 core
in vec3 posColor;

out vec4 FRAG_RESULT;

void main()
{
    FRAG_RESULT = vec4(posColor.x + 0.5, posColor.y + 0.5, posColor.z + 0.5, 1.0);
}