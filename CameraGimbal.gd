extends Node3D

var rotation_speed = PI / 2
var max_zoom = 3.0
var min_zoom = 0.0
var zoom_speed = 0.09

var invert_x = false
var invert_y = false

var mouse_sensitivity = 0.005
var touch_sensitivity = 0.005
var zoom = 2
var zoom_sensitivity = 10

var events = {}
var last_drag_distance = 0


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
	if event.is_action_pressed("cam_zoom_in") or event.is_action_pressed("cam_zoom_out"):
		zoom = clamp(zoom, min_zoom, max_zoom)
	
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			if event.relative.x != 0:
				var dir = 1 if invert_x else -1
				rotate_object_local(Vector3.UP, dir * event.relative.x * touch_sensitivity)
			if event.relative.y != 0:
				var dir = 1 if invert_y else -1
				var y_rotation = clamp(event.relative.y, -30, 30)
				$InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_rotation * touch_sensitivity)		
		elif events.size() == 2:
			var events_keys = events.keys()
			var position_a = events[events_keys[0]].position
			var position_b = events[events_keys[1]].position
			var drag_distance = position_a.distance_to(position_b)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				zoom = (zoom + zoom_speed) if drag_distance < last_drag_distance else (zoom - zoom_speed)
				zoom = clamp(zoom, min_zoom, max_zoom)
				last_drag_distance = drag_distance


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
