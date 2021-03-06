class_name AbstractCannon
extends Spatial


signal fired
signal reloaded


var BULLET_SCENE = preload("res://scenes/objects/Bullet/Bullet.tscn")


export var speed := 80.0 setget set_speed
export var fire_rate : int = 6 setget set_fire_rate
export var fire_delay := 0.0 setget set_fire_delay

export var damage := 1 setget set_damage

onready var muzzle = $Skin/Muzzle


var cannon_owner : Node


var max_range : float = 0.0
var fire_ready := true


var proj_velocity : Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.max_range = Balistic.max_range(speed, 9.8, 0.0)
	
	set_fire_rate(fire_rate)
	set_fire_delay(fire_delay)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_in_range(target_position : Vector3, _target_velocity := Vector3.ZERO) -> bool:
	
	var target_dir := (self.global_transform.origin - target_position).normalized()
	
	if target_dir.dot( self.global_transform.basis.z ) < 0.8:
		#print("> not aligned")
		return false
	
	if self.global_transform.origin.distance_squared_to(target_position) > max_range * max_range:
		#print("> too far")
		return false
	#print("> ok")
	return true
	


func fire(target_position : Vector3, target_velocity := Vector3.ZERO) -> bool:
	
	if not fire_ready:
		return false
	
	fire_ready = false
	$ReloadTimer.start()
	
	proj_velocity = Balistic.solve_ballistic_arc_velocity(
		muzzle.global_transform.origin,
		speed,
		target_position,
		target_velocity
	)
	
	if Vector3.ZERO.is_equal_approx(proj_velocity):
		print("no fire solution found")
		return false
	
	
	proj_velocity += Vector3(
		rand_range(-0.5, 0.5),
		rand_range(-0.5, 0.5),
		rand_range(-0.5, 0.5)
	)
	
	if fire_delay > 0.0:
		$FireDelay.start()
	else:
		_on_fire_delayed()
	
	return true


func _on_fire_delayed():
	
	if Vector3.ZERO.is_equal_approx(proj_velocity):
		print("no fire solution found")
		return false
	
	var bullet : RigidBody = BULLET_SCENE.instance()
	var peer_id := Network.get_self_peer_id()
	bullet.set_network_master( peer_id )
	bullet.name = "%s_%d_%d" % [bullet.name, peer_id, randi()]
	
	bullet.get_node("DamageSource").source = cannon_owner
	bullet.get_node("DamageSource").damage = damage
	
	bullet.transform.origin = muzzle.global_transform.origin
	bullet.apply_central_impulse(proj_velocity)
	
	Spawner.spawn(bullet)
	
	bullet.damage_source.source = cannon_owner
	bullet.damage_source.damage = damage
	
	if Network.enabled:
		rpc("rpc_fire")
	else:
		rpc_fire()


func set_speed(value):
	speed = max(1, value)
	self.max_range = Balistic.max_range(speed, 9.8, 0.0)

func set_fire_rate(value):
	
	if value:
		if value is String:
			fire_rate = value.to_int()
		else:
			fire_rate = value
		$ReloadTimer.wait_time = 60.0 / fire_rate


func set_fire_delay(value):
	fire_delay = value
	if fire_delay > 0.0:
		$FireDelay.wait_time = fire_delay


func set_damage(value):
	if value:
		if value is String:
			damage = value.to_int()
		else:
			damage = value


func _on_ReloadTimer_timeout():
	
	fire_ready = true
	emit_signal("reloaded")


remotesync func rpc_fire():
	#$Particles.restart()
	#$Particles.emitting = true
	$FireSound.pitch_scale = rand_range(0.8, 1.2)
	#$FireSound.play()
	
	$AnimationPlayer.play("fire")
	
	emit_signal("fired")
