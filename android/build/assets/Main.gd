extends Node

var last_atom = null

var atoms = []
var atom_connectivities = []

const atom_default_color = Color.DARK_BLUE
const atoms_colors = {
	"H": Color.WHITE,
	"O": Color.RED,
	"N": Color.BLUE,
	"C": Color.CYAN,
	"S": Color.YELLOW,
	"P": Color.TAN,
	"ZN": Color.SILVER,
	"ZR": Color.SILVER,
}

const connection_default_color = Color.DARK_BLUE
const connection_of_CONECT_default_color = Color.DARK_GREEN

var atoms_positions_min_max = {
	"max_x": -1000.0,
	"min_x": 1000.0,
	"max_y": -1000.0,
	"min_y": 1000.0,
	"max_z": -1000.0,
	"min_z": 1000.0,
}

func _on_start_button_pressed():
	$UserInterfaceStart.hide()
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var pdbUrl = "https://files.rcsb.org/download/%s.pdb" % $UserInterfaceStart/ProteinCode.text
	http_request.request_completed.connect(self._http_request_completed)
	var res = http_request.request(pdbUrl)
	if res != OK:
		push_error("An error occurred in the HTTP request.")


func _http_request_completed(result, response_code, headers, body):
	if response_code == 200:
		atoms.append({"name": "Ter0", "position": Vector3(0, 0, 0)})
		$UserInterface/ProteinLabel.text = $UserInterfaceStart/ProteinCode.text
		
		var lines = body.get_string_from_utf8().split("\n")
		
		for line in lines:
			if line.begins_with("ATOM") or line.begins_with("HETATM"):
				var atom_name = line.substr(12, 4).strip_edges()
				var atom_number = line.substr(7, 4).strip_edges().to_int()
				var x = line.substr(30, 8).strip_edges().to_float()
				var y = line.substr(38, 8).strip_edges().to_float()
				var z = line.substr(46, 8).strip_edges().to_float()

				var atom_position = Vector3(x, y, z)

				update_atoms_positions_min_max(x, y, z)

				var atom = MeshInstance3D.new()
				atom.mesh = SphereMesh.new()
				atom.mesh.material = StandardMaterial3D.new()
				var atom_color = atom_default_color
				if atoms_colors.has(atom_name.capitalize()):
					atom_color = atoms_colors[atom_name.capitalize()]
				atom.mesh.material.albedo_color = atom_color
				atom.position = atom_position
				atom.name = "Atom" + str(atom_number)
				
				add_child(atom)
				
				atoms.append({"name": "Atom" + str(atom_number), "position": atom_position})
				
				if last_atom != null and !line.begins_with("HETATM"):
					var atom_a_position = last_atom.position
					var atom_b_position = atom.position
					var distance = atom_a_position.distance_to(atom_b_position)
					if distance < 3:
						var connection = MeshInstance3D.new()
						connection.mesh = CylinderMesh.new()
						connection.mesh.top_radius = 0.15
						connection.mesh.bottom_radius = 0.15
						connection.mesh.material = StandardMaterial3D.new()
						connection.mesh.material.albedo_color = connection_default_color
						connection.name = last_atom.name + "To" + atom.name
						add_child(connection)
						connection.position = midpoint(atom_a_position, atom_b_position)
						connection.mesh.height = distance
						connection.look_at(atom_b_position, Vector3(0, 1, 0))
						connection.rotate_object_local(Vector3(1,0,0), -PI/2)
				last_atom = atom
				
			elif line.begins_with("TER"):
				last_atom = null
				var atom_number = line.substr(7, 4).strip_edges().to_int()
				atoms.append({"name": "Ter" + str(atom_number), "position": Vector3(0, 0, 0)})
				
			elif line.begins_with("CONECT"):
				last_atom = null
				var conect_data = []
				for i in range(6, len(line), 5):
					var atom_index = line.substr(i, 5).strip_edges()
					if atom_index != "":
						conect_data.append(atom_index.to_int())
				atom_connectivities.append(conect_data)
		
		for atom_connectivitie in atom_connectivities:
			var connected_atom_a = atoms[atom_connectivitie[0]]
			for i in range(1,atom_connectivitie.size()):
				var connected_atom_b = atoms[atom_connectivitie[i]]
				var atom_a_position = connected_atom_a["position"]
				var atom_b_position = connected_atom_b["position"]
				var distance = atom_a_position.distance_to(atom_b_position)
				var connection = MeshInstance3D.new()
				connection.mesh = CylinderMesh.new()
				connection.mesh.top_radius = 0.15
				connection.mesh.bottom_radius = 0.15
				connection.mesh.material = StandardMaterial3D.new()
				connection.mesh.material.albedo_color = connection_of_CONECT_default_color
				connection.name = connected_atom_a.name + "Conect" + connected_atom_b.name
				add_child(connection)
				connection.position = midpoint(atom_a_position, atom_b_position)
				connection.mesh.height = distance
				connection.look_at(atom_b_position, Vector3(0, 1, 0))
				connection.rotate_object_local(Vector3(1,0,0), -PI/2)
		
		$CameraGimbal.position.x = midpoint(atoms_positions_min_max["min_x"], atoms_positions_min_max["max_x"])
		$CameraGimbal.position.y = midpoint(atoms_positions_min_max["min_y"], atoms_positions_min_max["max_y"])
		$CameraGimbal.position.z = midpoint(atoms_positions_min_max["min_z"], atoms_positions_min_max["max_z"]) + 5
	else:
		print("Failed to download PDB file. Response code: ", response_code)
		$UserInterface/ProteinLabel.text = "Failed to download PDB file."
	$UserInterface/BackButton.disabled = false


func midpoint(a, b):
	return (a + b) / 2


func update_atoms_positions_min_max(x, y, z):
	if x > atoms_positions_min_max["max_x"]: atoms_positions_min_max["max_x"] = x
	if x < atoms_positions_min_max["min_x"]: atoms_positions_min_max["min_x"] = x
	if y > atoms_positions_min_max["max_y"]: atoms_positions_min_max["max_y"] = y
	if y < atoms_positions_min_max["min_y"]: atoms_positions_min_max["min_y"] = y
	if z > atoms_positions_min_max["max_z"]: atoms_positions_min_max["max_z"] = z
	if z < atoms_positions_min_max["min_z"]: atoms_positions_min_max["min_z"] = z


func _on_back_button_pressed():
	get_tree().reload_current_scene()
