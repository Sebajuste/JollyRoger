class_name AbstractShip
extends RigidBody


var CRATE_SCENE = preload("res://scenes/objects/Crate/Crate.tscn")


signal destroyed


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5

export var rudder_force := 10.0
export var sail_force := 10.0

export var selectable := true setget set_selectable
export var drop_inventory := true
export var drop_equipment := true

onready var float_manager = $FloatManager
onready var damage_stats := $DamageStats
onready var rudder : Position3D = $Rudder
onready var cannons = $Cannons
onready var flag = $Flag
onready var sticker := $Sticker3D

onready var inventory := $Inventory
onready var equipment := $Equipment

var rudder_position := 0.0 setget set_rudder_position
var sail_position := 0.0 setget set_sail_position

var alive := true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in float_manager.get_children():
		if child is WaterFloater:
			child.water_drag = water_drag
			child.water_angular_drag = water_angular_drag
			child.depth_before_submerged = depth_before_submerged
			child.displacement_amount = displacement_amount
	
	set_selectable(selectable)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	
	if float_manager.is_in_water() and alive:
		add_torque(
			-self.transform.basis.y * rudder_position * rudder_force
		)
		add_central_force( -self.transform.basis.z * sail_position * sail_force)
	
	if Vector3.UP.dot( global_transform.basis.y ) < 0.0:
		if not Network.enabled or is_network_master():
			var hit := Hit.new($DamageStats.health)
			$DamageStats.take_damage(hit)
	
	
	if global_transform.origin.y < -200.0:
		queue_free()
	


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncShip.integrate_forces(state)
	


func set_rudder_position(value):
	
	rudder_position = clamp(value, -1.0, 1.0)
	


func set_sail_position(value):
	
	sail_position = clamp(value, 0.0, 1.0)
	


func set_selectable(value):
	
	selectable = value
	$SelectArea.input_ray_pickable = value
	


func _drop():
	
	if (not drop_equipment or not equipment.has_items()) and (not drop_inventory or not inventory.has_items()):
		print("no items to drop")
		return
	
	var crate = CRATE_SCENE.instance()
	
	var dir := Vector3(
		rand_range(-1, 1),
		0,
		rand_range(-1, 1)
	).normalized()
	
	var crate_pos := global_transform.origin + dir*10 + dir*randf()*10
	crate.transform.origin = crate_pos
	
	Spawner.spawn(crate)
	
	if drop_equipment and equipment.has_items():
		var keys = equipment.items.keys()
		for key_index in range(keys.size()):
			var item_slot = keys[key_index]
			var item = equipment.items[item_slot]
			var crate_index : int = crate.inventory.get_free_slot()
			if crate_index != -1:
				equipment.remove_item(item_slot)
				crate.inventory.add_item(crate_index, item)
			else:
				break
	
	if drop_inventory and inventory.has_items():
		var keys = inventory.items.keys()
		for key_index in range(keys.size()):
			var item_slot = keys[key_index]
			var item = inventory.items[item_slot]
			var crate_index : int = crate.inventory.get_free_slot()
			if crate_index != -1:
				inventory.remove_item(item_slot)
				crate.inventory.add_item(crate_index, item)
			else:
				break
		
	



func _on_DamageStats_health_changed(_new_value, _old_value):
	pass # Replace with function body.


func _on_DamageStats_health_depleted():
	
	if sticker:
		sticker.visible = false
	
	$SinkTween.interpolate_method($FloatManager, "set_displacement_amount",
		displacement_amount, 0.0, 60.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()
	
	alive = false
	_drop()
	emit_signal("destroyed")
