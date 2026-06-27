program main;

uses
    dbCore, dbMath3D, dbWindowing, dbCore3D, dbFast3D, dbTexture2D, gl, glu, glfw, sysutils;

var
    window:             TWindowHandle;
    texture:            TTexture2DHandle;
    aspectRatio:        single;
    w, h:               cardinal;

    cube:               TFastMesh;
    camera:             TFastCamera;
    rotX, rotY:         single;
    posX, posY:         single;

procedure PrintInfo();
begin
    writeln('Controls:');
    writeln('  W/S: Move Up/Down');
    writeln('  A/D: Move Left/Right');
    writeln('  Q/E: Move Down/Up');
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

procedure ControlCamera();
begin
    if IsKeyDown(window, GLFW_KEY_A) then
        posX := posX - 0.015
    else if IsKeyDown(window, GLFW_KEY_D) then
        posX := posX + 0.015
    else
        posX := posX + 0;

    if IsKeyDown(window, GLFW_KEY_W) then
        posY := posY + 0.015
    else if IsKeyDown(window, GLFW_KEY_S) then
        posY := posY - 0.015
    else
        posY := posY + 0;
end;

begin
    writeln('DirectBASIC Runtime');
    PrintInfo;

    aspectRatio := 0;
    w := 800;
    h := 600;

    window := CreateWindow(w, h, 'Title!', WCI_330);
    
    MakeContextCurrent(window);
    SetWindowResizable(window, true);

    SetSwapInterval(1); // Enable V-Sync

    PrintGLInfo;

    EnableDepthTest;
    SetDepthFunc(0);
    EnableTexture2D;
    EnableCullFace;
    glCullFace(GL_FRONT);
    EnableLighting;

    texture := LoadTexture2D('test.png');

    camera := CreateCameraFast(TVec3.Create(0, 0, 0), Vec3Zero, 50.0, 0.1, 100.0);
    cube := CreateCubeFast(TVec3.Create(0, 0, 4), Vec3Zero, Vec3One);

    SetClearColor(0.3, 0.6, 0.9, 1.0);
    SetViewport(0, 0, w, h);

    rotX := 0;
    rotY := 0;

    posX := 0;
    posY := 0;

    while WindowShouldClose(window) = false do
    begin
        SetClearMask(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

        rotX := rotX + 1.25;
        rotY := rotY + 1.25;

        // Callback converted to if statement :D
        if WasWindowResized(window) then
        begin
            w := GetWindowWidth(window);
            h := GetWindowHeight(window);
            aspectRatio := single(w) / single(h);
            SetViewport(0, 0, w, h);
        end;

        Begin3DFast(w, h, camera);

        SetMaterialSpecularFast(0, 0.5, 0.8, 1.0, 1.0);
        SetMaterialShininessFast(0, 32.0);
        DrawMeshFast(cube, texture);      
        SetRotationFast(cube, rotX, rotY, 0);
        SetPositionFast(cube, posX, posY, 4);

        End3DFast;

        HandleInput;
        ControlCamera;

        UpdateWindow(window);
        PollEvents;
        //sleep(16);
    end;

    DeleteTexture2D(texture);

    DestroyWindow(window);
    glfwTerminate;
    writeln('GLFW has been terminated!');

    readln;
end.