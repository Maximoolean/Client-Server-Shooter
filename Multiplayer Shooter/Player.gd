extends CharacterBody3D

# Create a signal we can test for in our other script
signal health_changed(health_value)

# Declare objects as variables
@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/gun/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D

# Declare variables
var health = 3
const SPEED = 10.0
const JUMP_VELOCITY = 12.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0


# Setup player id
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


# Setup the camera and lock the mouse to center
func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	
# Handle shooting and move the camera
func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	# Keep the camera rotated on the mouse position
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	# Allow the player to "shoot"
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
		play_shoot_effects.rpc()
		# Send a raycast to apply damage to the object it hits if possible
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
			

# Handle Updates that happen every frame such as movement
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# Switch between the gun animations given the current action
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
	
	move_and_slide()


# Handle multiplayer animation effects
@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()


# Handle the damage for players hit by the raycast
@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)


# Play the idle animation when the shooting animatino finishes
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
