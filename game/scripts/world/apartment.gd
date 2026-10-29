class_name Apartment
extends Node3D
## Meter-scale furnished apartment, built from original geometry and materials.
var objects: Array[Node3D] = []
var door: Node3D
var door_tween: Tween
var lamp: OmniLight3D
var sun: DirectionalLight3D
var environment: WorldEnvironment
var navigation: NavigationRegion3D
var mirror: MeshInstance3D
var mirror_view: SubViewport
var mirror_camera: Camera3D
var mirror_live_material: Material
var player_camera: Camera3D
var materials = {}
var low_quality = false

func mat(key: String, color: String, roughness: float = 0.8, metallic: float = 0.0) -> StandardMaterial3D:
	if materials.has(key):
		return materials[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = roughness
	m.metallic = metallic
	materials[key] = m
	return m

func block(label: String, size: Vector3, pos: Vector3, material: Material, solid: bool = true, parent: Node3D = null) -> MeshInstance3D:
	var mesh = BoxMesh.new()
	mesh.size = size
	var instance = MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = material
	var base: Node3D = parent if parent != null else navigation
	if solid:
		var body = StaticBody3D.new()
		body.name = label + "Body"
		body.position = pos
		base.add_child(body)
		var collider = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = size
		collider.shape = shape
		body.add_child(collider)
		body.add_child(instance)
	else:
		instance.position = pos
		base.add_child(instance)
	return instance

func cylinder(radius: float, height: float, pos: Vector3, material: Material, parent: Node3D = null) -> MeshInstance3D:
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	var item = MeshInstance3D.new()
	item.mesh = mesh
	item.material_override = material
	item.position = pos
	(parent if parent != null else navigation).add_child(item)
	return item

func interactive(kind: String, label: String, pos: Vector3) -> Node3D:
	var point = Node3D.new()
	point.position = pos
	point.set_meta("kind", kind)
	point.set_meta("label", label)
	add_child(point)
	objects.append(point)
	return point

func plant(pos: Vector3, scale_value: float = 1.0) -> void:
	cylinder(0.19 * scale_value, 0.35 * scale_value, pos + Vector3(0, 0.175 * scale_value, 0), mat("pot", "b48369"))
	cylinder(0.025, 0.9 * scale_value, pos + Vector3(0, 0.6 * scale_value, 0), mat("stem", "465d42"))
	for i in range(7):
		var angle = i * 2.4
		var mesh = SphereMesh.new()
		mesh.radius = 0.20
		mesh.height = 0.4
		var leaf = MeshInstance3D.new()
		leaf.mesh = mesh
		leaf.material_override = mat("leaf", "55705a")
		leaf.scale = Vector3(0.5, 0.18, 1.4) * scale_value
		leaf.position = pos + Vector3(cos(angle) * 0.18, (0.5 + i * 0.09) * scale_value, sin(angle) * 0.18)
		leaf.rotation = Vector3(0.2, angle, 0.4)
		navigation.add_child(leaf)

func text_sign(text: String, pos: Vector3, rotation_y: float = 0.0, size: int = 36) -> void:
	var label = Label3D.new()
	label.text = text
	label.position = pos
	label.rotation.y = rotation_y
	label.font_size = size
	label.pixel_size = 0.005
	label.modulate = Color("c6d5ce")
	label.outline_size = 0
	label.no_depth_test = false
	navigation.add_child(label)

func _ready() -> void:
	navigation = NavigationRegion3D.new()
	var navmesh = NavigationMesh.new()
	navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	navmesh.agent_radius = 0.5
	navmesh.agent_height = 2.0
	navmesh.agent_max_climb = 0.25
	navmesh.cell_size = 0.25
	navmesh.cell_height = 0.25
	navigation.navigation_mesh = navmesh
	add_child(navigation)
	build_lighting()
	build_shell()
	build_furniture()
	build_balcony()
	build_mirror()
	navigation.bake_navigation_mesh(false)

func build_lighting() -> void:
	environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("243d55")
	sky_mat.sky_horizon_color = Color("c4ada1")
	sky_mat.ground_horizon_color = Color("b0a3a3")
	sky_mat.ground_bottom_color = Color("404e5e")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c7d7df")
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-24, -60, 0)
	sun.light_color = Color("ffd8ad")
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60
	add_child(sun)
	for pos in [Vector3(2, 2.8, 2), Vector3(-4.5, 2.8, -3), Vector3(-4.5, 2.8, 3), Vector3(3.5, 2.8, -4)]:
		var light = OmniLight3D.new()
		light.position = pos
		light.omni_range = 7
		light.light_energy = 1.0
		light.light_color = Color("ffdfb8")
		add_child(light)
		if pos.x == 2:
			lamp = light
			lamp.shadow_enabled = true

func build_shell() -> void:
	var plaster = mat("plaster", "c6c0ac")
	var dark = mat("dark", "384c4e")
	var timber = mat("oak", "8a6850")
	var floor_mat = ShaderMaterial.new()
	floor_mat.shader = load("res://assets/wood.gdshader")
	block("OakFloor", Vector3(14, 0.2, 12), Vector3(0, -0.1, 0), floor_mat)
	block("BackWall", Vector3(14, 3.2, 0.18), Vector3(0, 1.6, -6), plaster)
	block("WestWall", Vector3(0.18, 3.2, 12), Vector3(-7, 1.6, 0), plaster)
	# East-facing windows are genuine openings with mullions and glass.
	block("WindowSill", Vector3(0.18, 0.75, 12), Vector3(7, 0.375, 0), plaster)
	block("WindowLintel", Vector3(0.18, 0.35, 12), Vector3(7, 3.025, 0), plaster)
	var glass = mat("glass", "b8d0da", 0.12, 0.1)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color.a = 0.12
	for z in [-5.9, -3.0, 0.0, 3.0, 5.9]:
		block("WindowMullion", Vector3(0.2, 2.2, 0.07), Vector3(7, 1.8, z), dark)
	for z in [-4.5, -1.5, 1.5, 4.5]:
		block("WindowGlass", Vector3(0.04, 2.08, 2.9), Vector3(7, 1.8, z), glass)
	block("FrontLeft", Vector3(9.2, 3.2, 0.18), Vector3(-2.4, 1.6, 6), plaster)
	block("FrontRight", Vector3(3.2, 3.2, 0.18), Vector3(5.4, 1.6, 6), plaster)
	block("FrontHeader", Vector3(1.6, 0.9, 0.18), Vector3(3, 2.75, 6), plaster)
	block("BedroomPartitionA", Vector3(0.16, 3.2, 2.3), Vector3(-2, 1.6, -4.85), plaster)
	block("BedroomPartitionB", Vector3(0.16, 3.2, 2.3), Vector3(-2, 1.6, -1.15), plaster)
	block("BedroomHeader", Vector3(0.16, 0.9, 1.4), Vector3(-2, 2.75, -3), plaster)
	block("BathroomPartitionA", Vector3(0.16, 3.2, 2.0), Vector3(-2, 1.6, 1), plaster)
	block("BathroomPartitionB", Vector3(0.16, 3.2, 2.6), Vector3(-2, 1.6, 4.7), plaster)
	block("BathroomHeader", Vector3(0.16, 0.9, 1.4), Vector3(-2, 2.75, 2.7), plaster)
	block("RoomDivider", Vector3(5, 3.2, 0.16), Vector3(-4.5, 1.6, 0), plaster)
	block("Ceiling", Vector3(14, 0.12, 12), Vector3(0, 3.26, 0), mat("ceiling", "c9c6b6"))
	for z in [-5.87, 5.87]:
		block("Skirting", Vector3(13.7, 0.12, 0.05), Vector3(0, 0.06, z), timber, false)
	door = Node3D.new()
	door.name = "BalconyDoor"
	door.position = Vector3(2.25, 0, 6)
	add_child(door)
	block("Door", Vector3(1.45, 2.28, 0.10), Vector3(0.725, 1.14, 0), dark, true, door)
	block("DoorInset", Vector3(1.1, 1.6, 0.04), Vector3(0.725, 1.3, -0.07), timber, false, door)
	block("DoorHandle", Vector3(0.22, 0.035, 0.06), Vector3(1.2, 1.03, -0.11), mat("brass", "c4af79", 0.25, 0.8), false, door)
	interactive("door", "Balkontür öffnen / schließen", Vector3(3, 1, 5.9))
	text_sign("THE BEGINNING", Vector3(0.2, 2.1, -5.88), 0, 48)
	text_sign("01  /  ANKOMMEN", Vector3(0.2, 1.8, -5.88), 0, 22)

func build_furniture() -> void:
	var fabric = mat("sofa", "516d68")
	var cream = mat("cream", "dfd4ba")
	var wood = mat("oak", "8a6850")
	var dark = mat("dark", "384c4e")
	# Living room: sectional, cushions, rug, books, table and side lamp.
	block("Rug", Vector3(4.2, 0.018, 3.6), Vector3(2.8, 0.015, 2.0), mat("rug", "b2967b"), false)
	block("SofaBase", Vector3(2.7, 0.38, 0.95), Vector3(2.8, 0.31, -0.05), fabric)
	block("SofaBack", Vector3(2.7, 0.65, 0.23), Vector3(2.8, 0.7, -0.47), fabric)
	for x in [1.45, 4.15]:
		block("SofaArm", Vector3(0.2, 0.54, 1.0), Vector3(x, 0.52, -0.02), fabric)
	for x in [1.9, 2.8, 3.7]:
		block("Cushion", Vector3(0.8, 0.18, 0.76), Vector3(x, 0.57, 0.0), mat("cushion", "809389"), false)
	block("ThrowPillow", Vector3(0.45, 0.42, 0.16), Vector3(1.85, 0.87, -0.19), mat("rust", "bd795f"), false).rotation.z = 0.18
	block("CoffeeTable", Vector3(1.6, 0.10, 0.8), Vector3(2.8, 0.52, 1.8), wood)
	for x in [2.15, 3.45]:
		for z in [1.55, 2.05]:
			block("TableLeg", Vector3(0.045, 0.45, 0.045), Vector3(x, 0.24, z), dark)
	block("Book", Vector3(0.28, 0.035, 0.36), Vector3(3.15, 0.59, 1.9), mat("book", "375b64"), false)
	cylinder(0.07, 0.10, Vector3(2.45, 0.63, 1.75), cream)
	interactive("sofa", "Auf dem Sofa zur Ruhe kommen", Vector3(2.8, 0.8, 0.6))
	# Desk and computer, with an emissive screen.
	block("Desk", Vector3(1.6, 0.1, 0.72), Vector3(0.1, 0.77, -5.3), wood)
	for x in [-0.6, 0.8]:
		block("DeskLeg", Vector3(0.06, 0.73, 0.6), Vector3(x, 0.36, -5.3), dark)
	block("Computer", Vector3(0.8, 0.5, 0.06), Vector3(0.1, 1.2, -5.4), dark)
	var screen = mat("screen", "70b2a6")
	screen.emission_enabled = true
	screen.emission = Color("62ab9b")
	screen.emission_energy_multiplier = 0.6
	block("Display", Vector3(0.72, 0.42, 0.01), Vector3(0.1, 1.2, -5.36), screen, false)
	block("MonitorStand", Vector3(0.1, 0.2, 0.1), Vector3(0.1, 0.9, -5.4), dark, false)
	block("Keyboard", Vector3(0.6, 0.025, 0.2), Vector3(0.1, 0.84, -5.03), dark, false)
	interactive("computer", "Computer · Tagebuch öffnen", Vector3(0.1, 1, -4.9))
	# Kitchen: lower cabinets, stone worktop, hob, sink, upper cabinets and fridge.
	var cabinet = mat("cabinet", "7a8e84")
	block("KitchenCabinets", Vector3(4.2, 0.85, 0.65), Vector3(4.2, 0.425, -5.5), cabinet)
	block("Worktop", Vector3(4.25, 0.06, 0.72), Vector3(4.2, 0.89, -5.48), cream)
	for x in [2.45, 3.3, 4.15, 5, 5.85]:
		block("CabinetSeam", Vector3(0.015, 0.72, 0.012), Vector3(x, 0.43, -5.168), dark, false)
		block("Handle", Vector3(0.24, 0.025, 0.035), Vector3(x + 0.34, 0.73, -5.13), dark, false)
	block("Hob", Vector3(0.8, 0.025, 0.48), Vector3(5.25, 0.94, -5.4), dark, false)
	for x in [5.05, 5.45]:
		for z in [-5.25, -5.55]:
			cylinder(0.095, 0.01, Vector3(x, 0.958, z), mat("metal", "899b9b", 0.2, 0.85))
	block("Sink", Vector3(0.65, 0.02, 0.44), Vector3(3.2, 0.932, -5.4), mat("metal", "899b9b", 0.2, 0.85), false)
	cylinder(0.022, 0.3, Vector3(3.2, 1.08, -5.65), mat("metal", "899b9b"))
	block("UpperCabinet", Vector3(3.2, 0.7, 0.38), Vector3(4.2, 2.0, -5.72), cabinet)
	block("Fridge", Vector3(0.85, 1.9, 0.75), Vector3(1.5, 0.95, -5.45), cream)
	block("Island", Vector3(1.7, 0.9, 0.8), Vector3(3.5, 0.45, -3.1), cabinet)
	block("IslandTop", Vector3(1.8, 0.06, 0.9), Vector3(3.5, 0.94, -3.1), cream)
	interactive("tea", "Tee zubereiten · Zeit verstreichen lassen", Vector3(3.5, 1, -2.5))
	# Bedroom, with bedside tables, bedding and wardrobe.
	block("BedFrame", Vector3(2.0, 0.3, 2.3), Vector3(-5.0, 0.25, -3.8), wood)
	block("Mattress", Vector3(1.9, 0.22, 2.2), Vector3(-5, 0.51, -3.8), cream)
	block("Duvet", Vector3(1.95, 0.16, 1.6), Vector3(-5, 0.68, -3.4), mat("linen", "b3bdb3"), false)
	for x in [-5.5, -4.5]:
		block("Pillow", Vector3(0.7, 0.17, 0.45), Vector3(x, 0.7, -4.55), cream, false)
	block("Headboard", Vector3(2.2, 1.0, 0.12), Vector3(-5, 0.7, -4.95), fabric)
	block("Nightstand", Vector3(0.55, 0.56, 0.55), Vector3(-6.4, 0.28, -4.4), wood)
	block("Wardrobe", Vector3(2, 2.5, 0.65), Vector3(-5.2, 1.25, -0.6), cabinet)
	block("Phone", Vector3(0.09, 0.014, 0.17), Vector3(-6.4, 0.575, -4.4), dark, false)
	interactive("phone", "Smartphone · Notizen und Erinnerungen", Vector3(-6.3, 0.9, -4.4))
	interactive("bed", "Ausruhen · eine Stunde überspringen", Vector3(-3.8, 0.7, -3.7))
	# Bathroom: tiled floor, shower, vanity, basin and toilet.
	block("TileFloor", Vector3(4.8, 0.025, 5.8), Vector3(-4.5, 0.015, 3), mat("tile", "99aaa6", 0.3), false)
	block("Vanity", Vector3(1.5, 0.85, 0.65), Vector3(-5.5, 0.425, 0.5), wood)
	block("Basin", Vector3(1.6, 0.12, 0.7), Vector3(-5.5, 0.91, 0.5), cream)
	cylinder(0.025, 0.25, Vector3(-5.5, 1.08, 0.28), mat("metal", "899b9b"))
	block("BathroomMirror", Vector3(1.5, 1.05, 0.03), Vector3(-5.5, 1.9, 0.14), mat("silver", "9dbabb", 0.05, 0.95), false)
	block("ShowerTray", Vector3(1.5, 0.12, 1.6), Vector3(-6, 0.06, 5), cream)
	block("ShowerGlass", Vector3(0.04, 2.2, 1.6), Vector3(-5.25, 1.22, 5), materials.glass)
	cylinder(0.03, 1.7, Vector3(-6.75, 1.1, 5), mat("metal", "899b9b"))
	block("ToiletBase", Vector3(0.45, 0.45, 0.65), Vector3(-3.2, 0.225, 5.1), cream)
	block("ToiletTank", Vector3(0.45, 0.65, 0.18), Vector3(-3.2, 0.5, 5.4), cream)
	# Lamps, plants, wall art and readable spatial accents.
	for pos in [Vector3(5.9, 0, 4.5), Vector3(-6.4, 0, -1.5), Vector3(6.2, 0, -2.7)]:
		plant(pos, 1.25)
	cylinder(0.2, 0.06, Vector3(5.5, 0.03, 0.2), dark)
	cylinder(0.025, 1.55, Vector3(5.5, 0.8, 0.2), mat("brass", "c4af79"))
	cylinder(0.3, 0.4, Vector3(5.5, 1.65, 0.2), cream)
	interactive("lamp", "Wohnzimmerlicht umschalten", Vector3(5.5, 1, 0.2))
	block("PictureFrame", Vector3(1.2, 1.5, 0.06), Vector3(-6.88, 1.9, -3.2), wood, false).rotation.y = PI / 2
	# Art on the internal wall, formed from layered geometric shapes.
	block("Artwork", Vector3(0.035, 1.0, 1.25), Vector3(-1.89, 1.85, -1.0), mat("art", "b77c63"), false)
	block("ArtworkStripe", Vector3(0.04, 0.16, 1.05), Vector3(-1.86, 1.9, -1.0), mat("artCream", "e3d2ad"), false)

func build_balcony() -> void:
	var stone = mat("stone", "7d8988")
	var metal = mat("railing", "354950", 0.4, 0.5)
	block("BalconyFloor", Vector3(6.2, 0.2, 3.2), Vector3(4, -0.1, 7.5), stone)
	for x in [0.95, 7.05]:
		block("SideRail", Vector3(0.06, 1.1, 3), Vector3(x, 0.55, 7.5), metal)
	block("FrontRail", Vector3(6.2, 0.06, 0.06), Vector3(4, 1.1, 9), metal)
	block("RailCollision", Vector3(6.2, 1.1, 0.04), Vector3(4, 0.55, 9), materials.glass)
	for i in range(16):
		block("Baluster", Vector3(0.025, 1.1, 0.025), Vector3(1.1 + i * 0.39, 0.55, 9), metal, false)
	plant(Vector3(1.5, 0, 8.4), 1.3)
	cylinder(0.42, 0.05, Vector3(5.6, 0.75, 7.7), mat("oak", "8a6850"))
	cylinder(0.04, 0.73, Vector3(5.6, 0.36, 7.7), metal)
	interactive("balcony", "Auf dem Balkon innehalten", Vector3(4, 1, 8.1))
	# A city backdrop, explicitly scenery, not an advertised playable district.
	block("CityGround", Vector3(110, 0.3, 110), Vector3(0, -3, 0), mat("ground", "515f5e"), false)
	var rng = RandomNumberGenerator.new()
	rng.seed = 28
	for i in range(22):
		var x = rng.randf_range(12, 45) if i < 11 else rng.randf_range(-35, 40)
		var z = rng.randf_range(-25, 35) if i < 11 else rng.randf_range(16, 40)
		var h = rng.randf_range(6, 19)
		var col = ["727d7b", "9a9084", "607378", "a08c7c"][i % 4]
		block("CityBuilding", Vector3(4, h, 5), Vector3(x, h / 2 - 3, z), mat("city%d" % (i % 4), col), false)
		for level in range(int(h / 2.5)):
			block("CityWindow", Vector3(3.4, 0.75, 0.03), Vector3(x, level * 2.5 - 0.5, z + 2.52), mat("cityWindow", "bcae84"), false)

func build_mirror() -> void:
	var frame_mat = mat("mirrorFrame", "b9a575", 0.2, 0.85)
	block("MirrorFrame", Vector3(0.10, 2.1, 1.0), Vector3(-1.84, 1.4, 0.85), frame_mat, false)
	mirror_view = SubViewport.new()
	mirror_view.size = Vector2i(512, 1024)
	mirror_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	mirror_view.world_3d = get_viewport().world_3d
	add_child(mirror_view)
	mirror_camera = Camera3D.new()
	mirror_camera.cull_mask = 1
	mirror_camera.near = 0.08
	mirror_view.add_child(mirror_camera)
	mirror_camera.current = true
	mirror = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(0.88, 1.98)
	mirror.mesh = quad
	mirror.layers = 2
	mirror.position = Vector3(-1.777, 1.4, 0.85)
	mirror.rotation.y = PI / 2
	var mirror_mat = StandardMaterial3D.new()
	mirror_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mirror_mat.albedo_texture = mirror_view.get_texture()
	mirror_mat.uv1_scale.x = -1
	mirror_mat.uv1_offset.x = 1
	mirror.material_override = mirror_mat
	mirror_live_material = mirror_mat
	add_child(mirror)
	interactive("mirror", "META ME · in den Spiegel schauen", Vector3(-1.5, 1, 0.85))

func apply_state(instant: bool = false) -> void:
	lamp.visible = State.data.lamp_on
	var angle = -PI * 0.52 if State.data.door_open else 0.0
	if is_instance_valid(door_tween):
		door_tween.kill()
	if instant:
		door.rotation.y = angle
	else:
		door_tween = create_tween()
		door_tween.tween_property(door, "rotation:y", angle, 0.6).set_trans(Tween.TRANS_SINE)

func _process(_delta: float) -> void:
	var hour = fmod(State.data.minutes / 60.0, 24)
	sun.rotation_degrees.x = -maxf(4.0, sin((hour - 6) / 12 * PI) * 70)
	sun.light_energy = maxf(0.05, sin((hour - 6) / 12 * PI)) * 1.8
	if player_camera != null and not low_quality:
		var source = player_camera.global_transform
		var p = source.origin
		p.x = 2 * mirror.position.x - p.x
		mirror_camera.global_position = p
		# Off-axis projection through the mirror rectangle. The near plane lies
		# on the mirror surface, so the wall behind it cannot occlude reflection.
		var distance = mirror.position.x - p.x
		if distance > 0.05:
			mirror_camera.look_at(p + Vector3.RIGHT, Vector3.UP)
			var offset = mirror.position - p
			mirror_camera.set_frustum(1.98, Vector2(offset.z, offset.y), distance + 0.02, 120)
