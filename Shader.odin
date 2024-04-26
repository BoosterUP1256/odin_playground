package main

import "core:fmt"
import gl "vendor:OpenGL"

Shader :: struct {
	ID: u32
}

shader_create :: proc(vertexPath, fragmentPath: string) -> (Shader, bool) {
	program, good := gl.load_shaders_file(vertexPath, fragmentPath) 
	if !good {
		fmt.eprintln("Failed to compile GLSL program")
	}
	return Shader{ program }, good
}

shader_use :: proc(shader: Shader) {
	gl.UseProgram(shader.ID)
}

shader_setBool :: proc(shader: Shader, name: string, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(shader.ID, cstring(raw_data(name))), i32(value))
}

shader_setInt :: proc(shader: Shader, name: string, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(shader.ID, cstring(raw_data(name))), value)
}

shader_setFloat :: proc(shader: Shader, name: string, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(shader.ID, cstring(raw_data(name))), value)
}

shader_setFloat4 :: proc(shader: Shader, name: string, values: [4]f32) {
	gl.Uniform4f(gl.GetUniformLocation(shader.ID, cstring(raw_data(name))), values[0], values[1], values[2], values[3])
}

shader_delete :: proc(shader: Shader) {
	gl.DeleteProgram(shader.ID)
}
