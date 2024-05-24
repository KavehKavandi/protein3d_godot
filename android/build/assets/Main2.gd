# Main.gd
extends Node

var atoms = []

func _ready():
	for i in range(5):
		var atom = preload("res://AtomMeshInstance.gd").new()
		atom.mesh = SphereMesh.new()
		atom.mesh.material = StandardMaterial3D.new()
		atom.mesh.material.albedo_color = Color.BLUE
		atom.position = Vector3(i * 2, 0, 0)
		atom.name = "Atom" + str(i + 1)
		add_child(atom)
		atoms.append(atom)
		
		# Connect the custom signal to the function
		atom.connect("input_event", _on_atom_clicked)

func _on_atom_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Atom clicked!")
		var clicked_position = get_viewport().get_camera().project_ray_origin(event.position)
		for atom in atoms:
			if atom.get_aabb().has_point(atom.to_local(clicked_position)):
				print("Clicked on:", atom.name)
				break
