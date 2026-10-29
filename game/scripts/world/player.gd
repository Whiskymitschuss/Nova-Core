class_name MetaPlayer
extends CharacterBody3D
var pivot: Node3D
var arm: SpringArm3D
var camera: Camera3D
var model: Humanoid
var enabled = false
var sensitivity = 0.0025
var foot_clock = 0.0
var footsteps: AudioStreamPlayer3D
var touch_move = Vector2.ZERO
var touch_sprint = false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collider = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.26
	capsule.height = 1.78
	collider.shape = capsule
	collider.position.y = 0.91
	add_child(collider)
	model = Humanoid.new()
	model.setup(Color(State.data.avatar.skin), Color(State.data.avatar.outfit), Color(State.data.avatar.hair))
	add_child(model)
	pivot = Node3D.new()
	pivot.position.y = 1.45
	add_child(pivot)
	arm = SpringArm3D.new()
	arm.spring_length = 3.3
	arm.margin = 0.18
	arm.collision_mask = 1
	arm.add_excluded_object(get_rid())
	var probe = SphereShape3D.new()
	probe.radius = 0.16
	arm.shape = probe
	arm.rotation.x = -0.22
	pivot.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 68
	camera.near = 0.08
	arm.add_child(camera)
	footsteps = AudioStreamPlayer3D.new()
	footsteps.stream = preload("res://assets/step.wav")
	footsteps.volume_db = -15
	add_child(footsteps)

func _unhandled_input(event: InputEvent) -> void:
	if enabled and event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative)

func look(relative: Vector2) -> void:
	if not enabled:
		return
	pivot.rotation.y -= relative.x * sensitivity
	arm.rotation.x = clampf(arm.rotation.x - relative.y * sensitivity, -0.65, 0.35)

func move_direction(input: Vector2, sprint: bool, delta: float) -> void:
	var direction = pivot.global_basis * Vector3(input.x, 0, input.y)
	direction.y = 0
	direction = direction.limit_length(1.0)
	var speed = 4.2 if sprint else 2.5
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * 16)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * 16)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = -0.1
	move_and_slide()
	if direction.length() > 0.1:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-direction.x, -direction.z), minf(delta * 12, 1))
	model.animate(delta, Vector2(velocity.x, velocity.z).length())
	if direction.length() > 0.1 and is_on_floor():
		foot_clock += delta
		if foot_clock > (0.30 if sprint else 0.45):
			foot_clock = 0
			footsteps.pitch_scale = randf_range(0.9, 1.12)
			if AudioServer.get_driver_name() != "Dummy":
				footsteps.play()

func _physics_process(delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back") if enabled else Vector2.ZERO
	if enabled and touch_move.length() > input.length():
		input = touch_move
	move_direction(input, enabled and (Input.is_action_pressed("sprint") or touch_sprint), delta)

func restore_position() -> void:
	var p = State.data.position
	position = Vector3(p[0], p[1], p[2])
	velocity = Vector3.ZERO
	pivot.rotation.y = State.data.yaw
	arm.rotation.x = State.data.pitch
	model.recolor(State.data.avatar)

func capture_state() -> void:
	State.data.position = [position.x, position.y, position.z]
	State.data.yaw = pivot.rotation.y
	State.data.pitch = arm.rotation.x
