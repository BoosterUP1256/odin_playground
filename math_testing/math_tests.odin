package math_tests

import "core:fmt"

doMath :: proc() {
	fmt.println("math is being done!!!")

	// SOA Data Types
	Vector3 :: struct {
		x, y, z: f32,
	}

	// An array of structure Vector3
	N :: 2
	v_aos: [N]Vector3
	v_aos[0].x = 1
	v_aos[0].y = 4
	v_aos[0].z = 9

	fmt.println(len(v_aos))
	fmt.println(v_aos[0])
	fmt.println(v_aos[0].x)
	fmt.println(&v_aos[0].x)

	v_aos[1] = {0, 3, 4}
	v_aos[1].x = 2
	fmt.println(v_aos[1])
	fmt.println(v_aos)

	v_soa: #soa[n]Vector3
}
