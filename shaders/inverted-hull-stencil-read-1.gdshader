shader_type spatial;
render_mode cull_front, unshaded, depth_test_disabled;
stencil_mode read, compare_greater, 1;

const vec3 ORIGIN = vec3(0.0, 0.0, 0.0);

uniform float outline_size = 0.05;
uniform vec4 outline_color : source_color = vec4(1, 1, 1, 1);

void vertex() {
	vec4 clip_before = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	float ndc_per_pixel = 2.0 / VIEWPORT_SIZE.y;
	float pixel_size_world = ndc_per_pixel * clip_before.w;
	float offset = outline_size * pixel_size_world;

	VERTEX += VERTEX * offset;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
