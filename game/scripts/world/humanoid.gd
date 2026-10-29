class_name Humanoid
extends Node3D
## Original procedural character: articulated limbs, breath, gaze and conversation gestures.
var legs: Array[Node3D] = []
var arms: Array[Node3D] = []
var head: Node3D
var body: Node3D
var phase = 0.0
var speaking = false
var mood = 0.0
var skin_material: StandardMaterial3D
var outfit_material: StandardMaterial3D
var hair_material: StandardMaterial3D

func material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat

func part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var item = MeshInstance3D.new()
	item.mesh = mesh
	item.material_override = mat
	item.position = pos
	item.scale = size
	parent.add_child(item)
	return item

func capsule(radius: float, height: float) -> CapsuleMesh:
	var mesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 4
	return mesh

func sphere(radius: float) -> SphereMesh:
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 16
	mesh.rings = 8
	return mesh

func setup(skin: Color, outfit: Color, hair: Color) -> void:
	skin_material = material(skin)
	outfit_material = material(outfit)
	hair_material = material(hair)
	var pants = material(Color("283442"))
	var shoes = material(Color("e3e2d8"))
	body = Node3D.new()
	add_child(body)
	part(body, capsule(0.22, 0.64), Vector3(0, 1.21, 0), outfit_material, Vector3(1, 1, 0.65))
	part(body, capsule(0.18, 0.30), Vector3(0, 0.91, 0), pants, Vector3(1.2, 1, 0.8))
	for side in [-1, 1]:
		var leg = Node3D.new()
		leg.position = Vector3(side * 0.115, 0.92, 0)
		body.add_child(leg)
		part(leg, capsule(0.085, 0.82), Vector3(0, -0.40, 0), pants)
		part(leg, capsule(0.095, 0.24), Vector3(0, -0.84, -0.04), shoes, Vector3(0.9, 0.6, 1.7))
		legs.append(leg)
		var arm = Node3D.new()
		arm.position = Vector3(side * 0.265, 1.43, 0)
		body.add_child(arm)
		part(arm, capsule(0.075, 0.40), Vector3(0, -0.18, 0), outfit_material)
		part(arm, capsule(0.055, 0.32), Vector3(0, -0.48, 0), skin_material)
		arms.append(arm)
	part(body, capsule(0.07, 0.17), Vector3(0, 1.55, 0), skin_material)
	head = Node3D.new()
	head.position.y = 1.70
	body.add_child(head)
	part(head, sphere(0.155), Vector3.ZERO, skin_material, Vector3(0.88, 1.17, 0.94))
	part(head, sphere(0.16), Vector3(0, 0.075, 0.025), hair_material, Vector3(0.98, 0.75, 1.0))
	for side in [-1, 1]:
		part(head, sphere(0.021), Vector3(side * 0.056, 0.015, -0.132), material(Color("f3eee3")), Vector3(1.1, 0.65, 0.5))
		part(head, sphere(0.010), Vector3(side * 0.056, 0.015, -0.142), material(Color("263f43")))
		part(head, capsule(0.009, 0.04), Vector3(side * 0.056, 0.052, -0.13), hair_material).rotation.z = PI / 2
	part(head, sphere(0.023), Vector3(0, -0.015, -0.146), skin_material, Vector3(0.6, 1, 1))
	part(head, capsule(0.006, 0.045), Vector3(0, -0.065, -0.133), material(Color("87504a"))).rotation.z = PI / 2

func animate(delta: float, speed: float) -> void:
	phase += delta * (8.5 if speed > 0.1 else 1.6)
	var stride = minf(speed / 3.0, 1.2)
	for i in range(2):
		var sign_value = 1.0 if i == 0 else -1.0
		legs[i].rotation.x = lerpf(legs[i].rotation.x, sin(phase) * 0.55 * stride * sign_value, minf(delta * 12, 1))
		arms[i].rotation.x = -legs[i].rotation.x * 0.7
		arms[i].rotation.z = sign_value * (0.04 + mood * 0.16)
	if speaking and speed < 0.1:
		arms[1].rotation.x = -0.35 + sin(phase * 2) * 0.16
		arms[1].rotation.z = -0.20
	body.position.y = sin(phase * 2) * (0.018 if stride > 0.1 else 0.004)
	head.rotation.z = sin(phase * 0.6) * 0.015
	head.rotation.x = -mood * 0.10

func recolor(avatar: Dictionary) -> void:
	skin_material.albedo_color = Color(avatar.skin)
	outfit_material.albedo_color = Color(avatar.outfit)
	hair_material.albedo_color = Color(avatar.hair)
