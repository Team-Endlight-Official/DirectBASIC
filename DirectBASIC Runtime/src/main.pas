program main;

uses
    dbInit, dbCore, dbMath3D, dbWindowing, dbCore3D, dbFast3D, dbBase3D, dbUnsafe3D, dbShader, dbTexture2D, dglOpenGL, glfw, sysutils;

var
    window:             TWindowHandle;
    shader:             TShaderHandle;
    vao:                TVertexContainerHandle;
    aspectRatio:        single;
    w, h:               cardinal;

    vertices:           array of GLfloat;

procedure PrintInfo();
begin
    writeln('Controls:');
    writeln('  F1: Enable Wireframe');
    writeln('  F2: Disable Wireframe');
    writeln('  ESC: Close Window');
end;

procedure HandleInput();
begin
    // Handle escape key to close window
    if IsKeyDown(window, GLFW_KEY_ESCAPE) then
        CloseWindow(window);

    if IsKeyDown(window, GLFW_KEY_F1) then
        EnableWireframe;
    
    if IsKeyDown(window, GLFW_KEY_F2) then
        DisableWireframe;
end;

begin
    PrintInfo;

    aspectRatio := 0;
    w := 800;
    h := 600;

    window := CreateWindow(w, h, 'Title!', WCI_330);
    MakeContextCurrent(window);
    Initialize3D;

    SetWindowResizable(window, true);
    EnableVSync;

    PrintGLInfo;

    EnableDepthTest;
    EnableTexture2D;
    EnableCullFace;
    EnableLighting;

    SetDepthFunc(0);
    SetCullFace(0);

    SetLength(vertices, 9);
    vertices[0] := -0.5;
    vertices[1] := -0.5;
    vertices[2] := -0.5;

    vertices[3] := 0.0;
    vertices[4] := 0.5;
    vertices[5] := -0.5;

    vertices[6] := 0.5;
    vertices[7] := -0.5;
    vertices[8] := -0.5;

    shader := LoadShader('default.vert', 'default.frag');

    vao := CreateVertexContainer;
    AddBuffer(vao, 0, length(vertices) * sizeof(vertices), @vertices[0], 0);
    writeln(length(vertices) * sizeof(vertices));
    BuildVertexContainer(vao);

    SetClearColor(0.3, 0.6, 0.9, 1.0);
    SetViewport(0, 0, w, h);

    while WindowShouldClose(window) = false do
    begin
        SetClearMask(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

        // Callback converted to if statement :D
        if WasWindowResized(window) then
        begin
            w := GetWindowWidth(window);
            h := GetWindowHeight(window);
            aspectRatio := single(w) / single(h);
            SetViewport(0, 0, w, h);
        end;

        BeginShader(shader);
        DrawPrimitive(vao);
        EndShader;

        HandleInput;

        UpdateWindow(window);
        PollEvents;
        //sleep(16);
    end;

    DeleteVertexContainer(vao);
    DeleteShader(shader);

    DestroyWindow(window);
    glfwTerminate;
    writeln('GLFW has been terminated!');

    readln;
end.