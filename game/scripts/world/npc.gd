class_name MetaNPC
extends CharacterBody3D
var agent: NavigationAgent3D
var model: Humanoid
var talking = false
var enabled = false
var target_index = 0
var wait_time = 2.0
var targets = [Vector3(4.3, 0, 0.85), Vector3(4.8, 0, -3.7), Vector3(0.4, 0, -1), Vector3(4.8, 0, 4.8)]
var player: MetaPlayer

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	var collision = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.92
	add_child(collision)
	model = Humanoid.new()
	model.setup(Color("a57255"), Color("bb7960"), Color("302a29"))
	add_child(model)
	agent = NavigationAgent3D.new()
	agent.path_desired_distance = 0.25
	# Recast's baked floor is 0.3 m above physical feet at this voxel size.
	# Without compensation an agent can stall at a waypoint above its origin.
	agent.path_height_offset = 0.3
	agent.target_desired_distance = 0.35
	agent.radius = 0.35
	add_child(agent)
	var nameplate = Label3D.new()
	nameplate.text = "MARA"
	nameplate.font_size = 36
	nameplate.pixel_size = 0.003
	nameplate.modulate = Color("c8e8dd")
	nameplate.position.y = 2.12
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	if talking and is_instance_valid(player):
		var to_player = player.global_position - global_position
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-to_player.x, -to_player.z), minf(delta * 4, 1))
	elif enabled and NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) > 0:
		wait_time -= delta
		if wait_time <= 0:
			if agent.is_navigation_finished():
				target_index = (target_index + 1) % targets.size()
				agent.target_position = targets[target_index]
				wait_time = 5.0
			else:
				direction = agent.get_next_path_position() - global_position
				direction.y = 0
				direction = direction.normalized()
	velocity.x = direction.x * 0.65
	velocity.z = direction.z * 0.65
	velocity.y = -0.1 if is_on_floor() else velocity.y - 18 * delta
	move_and_slide()
	if direction.length() > 0.05:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-direction.x, -direction.z), minf(delta * 6, 1))
	model.speaking = talking
	model.mood = State.data.emotions.anger
	model.animate(delta, direction.length() * 0.65)

func restore_state() -> void:
	var p = State.data.npc_position
	position = Vector3(p[0], p[1], p[2])
	target_index = int(State.data.npc_target)
	agent.target_position = targets[target_index]

func capture_state() -> void:
	State.data.npc_position = [position.x, position.y, position.z]
	State.data.npc_target = target_index
