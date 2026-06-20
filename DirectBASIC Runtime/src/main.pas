program main;

uses
    dbCore, dbMath3D, dbWindowing, dbFast3D, dbTexture2D, gl, glu, glfw, sysutils;

var
    window:             TWindowHandle;
    texture:            TTexture2DHandle;
    aspectRatio:        single;
    w, h:               cardinal;

    cube:               TFastMesh;
    camera:             TFastCamera;
    rotX, rotY:         single;
    posX, posY:         single;
    camRotX, camRotY:   single;

procedure PrintInfo();
begin
    writeln('Controls:');
    writeln('  W/S: Move Up/Down');
    writeln('  A/D: Move Left/Right');
    writeln('  F1: Enable Wireframe');
    writeln('  F2: Disable Wireframe');
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
    if IsKeyDown(window, GLFW_KEY_W) then
        posY := posY - 0.015
    else if IsKeyDown(window, GLFW_KEY_S) then
        posY := posY + 0.015
    else
        posY := posY + 0;

    if IsKeyDown(window, GLFW_KEY_A) then
        posX := posX - 0.015
    else if IsKeyDown(window, GLFW_KEY_D) then
        posX := posX + 0.015
    else
        posX := posX +0;

    if IsKeyDown(window, GLFW_KEY_RIGHT) then
        camRotY := camRotY - 0.015
    else if IsKeyDown(window, GLFW_KEY_LEFT) then
        camRotY := camRotY + 0.015
    else
        camRotY := camRotY + 0;
end;

begin
    writeln('DirectBASIC Runtime');
    PrintInfo;

    aspectRatio := 0;
    w := 800;
    h := 600;

    window := CreateWindow(w, h, 'Title!', WCI_330);
    
    MakeContextCurrent(window);
    SetWindowResizable(window, false);

    SetSwapInterval(1); // Enable V-Sync

    PrintGLInfo;

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);

    texture := LoadTexture2D('test.png');
    cube := CreateCubeFast(TVec3.Create(0, 0, 3.5), Vec3Zero, TVec3.Create(1, 1, 1));
    camera := CreateCameraFast(TVec3.Create(0, 0, 0), Vec3Zero, 45.0, 0.1, 100.0);

    SetClearColor(0.3, 0.6, 0.9, 1.0);
    SetViewport(0, 0, w, h);

    rotX := 0;
    rotY := 0;

    posX := 0;
    posY := 0;

    camRotX := 0;
    camRotY := 0;

    while WindowShouldClose(window) = false do
    begin
        SetClearMask(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

        rotX := rotX + 1.25;
        rotY := rotY + 1.25;

        camera.position.x := posX * 3;
        camera.position.z := posY * 3;
        camera.rotation.y := camRotY * 3 * 3;
        camera.rotation.x := camRotX * 3 * 3;

        BeginFast3D(w, h, camera);

        cube.rotation.x := rotX;
        cube.rotation.y := rotY;
        DrawFastMesh(cube, texture);

        HandleInput;
        ControlCamera;

        UpdateWindow(window);
        PollEvents;
        //sleep(16);
    end;

    DeleteTexture(texture);
    DestroyWindow(window);
    glfwTerminate;
    writeln('GLFW has been terminated!');

    readln;
end.