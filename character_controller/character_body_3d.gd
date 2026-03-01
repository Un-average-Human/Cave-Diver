extends CharacterBody3D


@onready var short_collision: CollisionShape3D = $short_collision
@onready var tall_collision: CollisionShape3D = $tall_collision
@onready var animation_player: AnimationPlayer = $neck/hands/AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"
var triggered: bool = false
@onready var monster_animation_player: AnimationPlayer = $"../big_scary_monster/AnimationPlayer"
@onready var monster_walk_animation_player_2: AnimationPlayer = $"../big_scary_monster/AnimationPlayer2"
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var SPEED := 5.0
const JUMP_VELOCITY := 4.5
var SENSITIVITY := 0.01

@onready var neck: Node3D = $neck
@onready var camera: Camera3D = $neck/Camera3D
@onready var hands: Node3D = $neck/hands
@onready var spooky_monster_noise: AudioStreamPlayer3D = $"../spooky_monster_noise"
@onready var wet_steps_sfx: AudioStreamPlayer3D = $"../wet_steps/wet_steps_sfx"
@onready var steps_sfx: AudioStreamPlayer = $steps
@onready var crouching_steps_sfx: AudioStreamPlayer = $crouching_steps
var is_crouched := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(40))
	
	if Input.is_action_just_pressed("C"):
		var tween = create_tween()
		var camera_tween = create_tween()
		if is_crouched == false:
			
			is_crouched = true
			
			#hands
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(hands, "position:z", -1.3, 1)
			
			#camera
			camera_tween.set_trans(Tween.TRANS_CUBIC)
			camera_tween.tween_property(camera, "position:y", -0.7, 0.5)
			
			#speed
			SPEED = 2.5
			
			#collision
			short_collision.disabled = false
			tall_collision.disabled = true
			
		elif is_crouched == true and !ray_cast_3d.is_colliding():
			
			is_crouched = false
			
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(hands, "position:z", 1.3, 1)
			
			#camera
			camera_tween.set_trans(Tween.TRANS_CUBIC)
			camera_tween.tween_property(camera, "position:y", 0.4, 0.5)
			
			#speed
			SPEED = 5
			
			#collision
			short_collision.disabled = true
			tall_collision.disabled = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if is_crouched == true and velocity.length() > 0:
		animation_player.play("hands")
	if  is_crouched == false or velocity.length() <= 0:
		if animation_player.is_playing():
			animation_player.stop(false)


	if is_crouched and velocity.length() > 0:
		if not crouching_steps_sfx.playing:
			crouching_steps_sfx.play()
	elif !is_crouched or velocity.length() <= 0:
		if crouching_steps_sfx.playing:
			crouching_steps_sfx.stop()
	if !is_crouched and velocity.length() > 0:
		if not steps_sfx.playing:
			steps_sfx.play()
	elif is_crouched or velocity.length() <= 0:
		if steps_sfx.playing:
			steps_sfx.play()

	move_and_slide()



func _on_sound_trigger_body_entered(body: Node3D) -> void:
	if body == self and triggered == false:
		audio_stream_player_3d.play()
		triggered = true
		await get_tree().create_timer(10).timeout
		triggered = false


func _on_scare_trigger_body_entered(body: Node3D) -> void:
	if body == self:
		spooky_monster_noise.play()
		monster_animation_player.play("Armature_002Action")
		monster_walk_animation_player_2.play("movement")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		get_tree().change_scene_to_file("res://start.tscn")


func _on_wet_steps_body_entered(body: Node3D) -> void:
	if body == self and triggered == false:
		wet_steps_sfx.play()
		triggered = true
