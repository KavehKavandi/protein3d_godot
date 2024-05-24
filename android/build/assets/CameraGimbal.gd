extends Node3D

@export var rotation_speed = PI / 2
@export var max_zoom = 3.0
@export var min_zoom = 0.0
@export var zoom_speed = 0.09

@export var invert_x = false
@export var invert_y = false

var mouse_sensitivity = 0.005
var zoom = 2


func _process(delta):
	get_input_keyboard(delta)
	scale = lerp(scale, Vector3.ONE * zoom, zoom_speed)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("cam_rotate_right_mouse_click"):
		if event.relative.x != 0:
			var dir = 1 if invert_x else -1
			rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
		if event.relative.y != 0:
			var dir = 1 if invert_y else -1
			var y_rotation = clamp(event.relative.y, -30, 30)
			$InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)
	
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)


func get_input_keyboard(delta):
	var y_rotation = 0
	if Input.is_action_pressed("cam_rotate_right"):
		y_rotation -= 1
	if Input.is_action_pressed("cam_rotate_left"):
		y_rotation += 1
	rotate_object_local(Vector3.UP, y_rotation * rotation_speed * delta)
	
	var x_rotation = 0
	if Input.is_action_pressed("cam_rotate_up"):
		x_rotation -= 1
	if Input.is_action_pressed("cam_rotate_down"):
		x_rotation += 1
	$InnerGimbal.rotate_object_local(Vector3.RIGHT, x_rotation * rotation_speed * delta)
	
