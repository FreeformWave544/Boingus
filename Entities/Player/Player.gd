extends RigidBody3D
class_name Player

var move_force := 25.0
var jump_impulse := 8.0
var floor_normal := Vector3.UP
var sensitivity := 0.01

func _ready() -> void: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and gravity_scale > 0.0:
		$YawPivot.rotate_y(-event.relative.x * sensitivity)
		$YawPivot/PitchPivot.rotate_x(-event.relative.y * sensitivity)
		$YawPivot/PitchPivot.rotation.x = clamp($YawPivot/PitchPivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not $FloorDetector.is_colliding(): return
	var input_dir := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	var dir := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir != Vector3.ZERO: apply_central_force(dir * move_force)
	if Input.is_action_just_pressed("ui_accept"):
		jump()

func jump():
	var jumpForce = jump_impulse - $MeshInstance3D.mesh.height
	while Input.is_action_pressed("ui_accept"):
		if $MeshInstance3D.mesh.height <= 0.0: await get_tree().process_frame ; continue
		jumpForce += 0.01
		$MeshInstance3D.mesh.height = max($MeshInstance3D.mesh.height - 0.01, 0.0)
		$CollisionShape3D.shape.height = $MeshInstance3D.mesh.height
		$MeshInstance3D.position.y -= 0.01
		$CollisionShape3D.position.y = $MeshInstance3D.position.y
		await get_tree().process_frame
	while ($MeshInstance3D.mesh.height <= 0.9) or ($MeshInstance3D.position.y >= 0.1):
		$MeshInstance3D.mesh.height = lerp($MeshInstance3D.mesh.height, 1.0, 0.2)
		$CollisionShape3D.shape.height = $MeshInstance3D.mesh.height
		$MeshInstance3D.position.y = lerp($MeshInstance3D.position.y, 0.0, 0.2)
		$CollisionShape3D.position.y = $MeshInstance3D.position.y
		await get_tree().process_frame
	if $FloorDetector.is_colliding(): apply_central_impulse(transform.basis * Vector3.UP * jumpForce)

func win():
	gravity_scale = 0.0
	$YawPivot/PitchPivot/Camera3D.fov = 100
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	for i in range(100): $YawPivot.rotate_y(50.0) ; await get_tree().process_frame
