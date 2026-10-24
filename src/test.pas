program test;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.core.Console,
    DBASIC.&platform.Windowing,
    DBASIC.graphics.Graphics,
    DBASIC.graphics.Shader,
    DBASIC.graphics.VertexArray,
    DBASIC.graphics.VertexBuffer,
    dglOpenGL;

const
    verticesData: array[0..8] of single = (-0.5, -0.5, 0.0,
                                            0.0, 0.5, 0.0,
                                            0.5, -0.5, 0.0);

var
    vao: TVertexArray;
    vbo: TVertexBuffer;
    shader: TShader;
begin
    CreateWindow(800, 600, 'Winduh!');

    shader := LoadShader('shaders/default.vert', 'shaders/default.frag');

    vao := CreateVertexArray();
    BeginVertexArray(vao);

    vbo := CreateVertexBuffer(GL_ARRAY_BUFFER);
    BeginVertexBuffer(vbo);

    glBufferData(vbo.btype, length(verticesData) * sizeof(single), @verticesData, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(single), nil);
    glEnableVertexAttribArray(0);

    EndVertexBuffer(vbo);

    EndVertexArray();

    SetViewport(0, 0, GetWindowWidth(), GetWindowHeight());
    SetClearColor(0.3, 0.6, 0.9, 1.0);

    while not WindowShouldClose() do
    begin
        SetClearMask(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        Enable(0);

        // One whole draw call!
        BeginShader(shader);
        BeginVertexArray(vao);
        glEnableVertexAttribArray(0);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDisableVertexAttribArray(0);
        EndVertexArray();
        EndShader();

        PollEvents();
        SwapBuffers();
    end;
    DestroyVertexBuffer(vbo);
    DestroyVertexArray(vao);
    DestroyShader(shader);

    DestroyWindow();

    readln;
end.