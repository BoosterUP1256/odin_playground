package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import linalg "core:math/linalg"

import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

g_zoom: f32 = 0.2

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

	//shaderProgram, program_ok := gl.load_shaders_source(vertexShaderSource, fragmentShaderSource)
	//if !program_ok {
	//    fmt.eprintln("Failed to create GLSL program")
	//    return
	//}

	// Generate Texture box image
	texture1: u32
	gl.GenTextures(1, &texture1)
	gl.BindTexture(gl.TEXTURE_2D, texture1)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// load box image
	width, height, nrChannels: i32
	data: ^u8 = stbi.load("container.jpg", &width, &height, &nrChannels, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.eprintln("Failed to load texture Box")
	}
	stbi.image_free(data)

	// Generate texture for face image
	texture2: u32
	gl.GenTextures(1, &texture2)
	gl.BindTexture(gl.TEXTURE_2D, texture2)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// load face image
	stbi.set_flip_vertically_on_load(1)
	data = stbi.load("awesomeface.png", &width, &height, &nrChannels, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.eprintln("Failed to load texture Face")
	}
	stbi.image_free(data)


	program, ok := shader_create("shader.vs", "shader.fs")
	if !ok {
		fmt.eprintln("Failed to create GLSL program")
		return
	}

	vertices := []f32 {
		// positions      // colors        // texture coords
		0.5,
		0.5,
		0.0,
		1.0,
		0.0,
		0.0,
		1.0,
		1.0, // top right
		0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0,
		1.0,
		0.0, // bottom right
		-0.5,
		-0.5,
		0.0,
		0.0,
		0.0,
		1.0,
		0.0,
		0.0, // bottom left
		-0.5,
		0.5,
		0.0,
		1.0,
		1.0,
		0.0,
		0.0,
		1.0, // top left
	}

	indices := []u32{0, 1, 3, 1, 2, 3}

	VBO, VAO, EBO: u32
	gl.GenVertexArrays(1, &VAO)
	gl.GenBuffers(1, &VBO)
	gl.GenBuffers(1, &EBO)

	gl.BindVertexArray(VAO)

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(vertices),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(indices[0]),
		raw_data(indices),
		gl.STATIC_DRAW,
	)

	// position attribute
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	// color attribute
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	// texture attribute
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
	gl.EnableVertexAttribArray(2)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	gl.BindVertexArray(0)

	// rotate and scale
	trans := glsl.identity(glsl.mat4)
	trans *= glsl.mat4Rotate(glsl.vec3{0.0, 0.0, 1.0}, glsl.radians_f32(90.0))
	trans *= glsl.mat4Scale(glsl.vec3{0.5, 0.5, 0.5})

	for !glfw.WindowShouldClose(window) {
		processInput(window)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		//gl.UseProgram(shaderProgram)
		shader_use(program)
		shader_setInt(program, "texture1", 0)
		shader_setInt(program, "texture2", 1)
		shader_setFloat(program, "zoom", g_zoom)
		// TODO: make set mat functions
		transformLoc := gl.GetUniformLocation(program.ID, "transform")
		gl.UniformMatrix4fv(transformLoc, 1, gl.FALSE, &trans[0, 0])

		timeValue := glfw.GetTime()
		greenValue := f32((math.sin_f64(timeValue) / 2.0) + 0.5)
		//vertexColorLocation := gl.GetUniformLocation(shaderProgram, "ourColor")
		//gl.Uniform4f(vertexColorLocation, 0.0, greenValue, 0.0, 1.0)
		//shader_setFloat4(program, "ourColor", {0.0, greenValue, 0.0, 1.0})
		//shader_setFloat(program, "offset", 0.25)
		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, texture1)
		gl.ActiveTexture(gl.TEXTURE1)
		gl.BindTexture(gl.TEXTURE_2D, texture2)

		gl.BindVertexArray(VAO)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &VAO)
	gl.DeleteBuffers(1, &VBO)
	gl.DeleteBuffers(1, &EBO)
	//gl.DeleteProgram(shaderProgram)
	shader_delete(program)

	glfw.Terminate()
}

processInput :: proc "c" (window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	} else if glfw.GetKey(window, glfw.KEY_UP) == glfw.PRESS {
		g_zoom += 0.0001
	} else if glfw.GetKey(window, glfw.KEY_DOWN) == glfw.PRESS {
		g_zoom -= 0.0001
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
}
