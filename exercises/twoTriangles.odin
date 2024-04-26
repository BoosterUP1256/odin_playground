package main

import "core:fmt"

import glfw "vendor:glfw"
import gl "vendor:OpenGL"

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

vertexShaderSource := `#version 330 core
layout (location = 0) in vec3 aPos;
void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}`

fragmentShaderSource := `#version 330 core
out vec4 FragColor;
void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}`

fragmentShaderSource_b := `#version 330 core
out vec4 FragColor;
void main()
{
    FragColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);
}`

main :: proc() {
    glfw.Init()
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
    if window == nil {
        fmt.println("Failed to create GLFW window")
        glfw.Terminate()
    }
    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    
    shaderProgram_b, program_ok := gl.load_shaders_source(vertexShaderSource, fragmentShaderSource_b)
    if !program_ok {
        fmt.eprintln("Failed to create GLSL program")
        return
    }

    shaderProgram, program_ok_2 := gl.load_shaders_source(vertexShaderSource, fragmentShaderSource)
    if !program_ok_2 {
        fmt.eprintln("Failed to create GLSL program")
        return
    }

    vertices_a := []f32{
        -0.9, -0.5, 0.0,
        -0.0, -0.5, 0.0,
        -0.45, 0.5, 0.0,
    }

    vertices_b := []f32{
        0.0, -0.5, 0.0,
        0.9, -0.5, 0.0,
        0.45, 0.5, 0.0,  
    }

    // Generate Buffers
    VBO, VAO: [2]u32
    gl.GenVertexArrays(2, raw_data(VAO[:]))
    gl.GenBuffers(2, raw_data(VBO[:]))

    // First Triangle Setup
    gl.BindVertexArray(VAO[0])
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO[0])
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices_a)*size_of(vertices_a[0]), raw_data(vertices_a), gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindVertexArray(VAO[1])
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO[1])
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices_b)*size_of(vertices_b[0]), raw_data(vertices_b), gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    for !glfw.WindowShouldClose(window) {
        processInput(window)

        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shaderProgram)

        // draw first triangle
        gl.BindVertexArray(VAO[0])
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        // draw second triangle
        gl.UseProgram(shaderProgram_b)
        gl.BindVertexArray(VAO[1])
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }

    gl.DeleteVertexArrays(2, raw_data(VAO[:]))
    gl.DeleteBuffers(2, raw_data(VBO[:]))
    gl.DeleteProgram(shaderProgram)

    glfw.Terminate()
}

processInput :: proc "c" (window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
    gl.Viewport(0, 0, width, height)
}
