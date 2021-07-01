extends Spatial


export var text := "" setget set_text
export var use_parent_name := false


onready var parent := get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if use_parent_name:
		parent.connect("renamed", self, "_node_renamed")
	
	$Control/Username.text = parent.name
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var pos = global_transform.origin
	var cam = get_tree().get_root().get_camera()
	var screen_pos = cam.unproject_position(pos)
	
	$Control.set_position( Vector2(screen_pos.x - $Control.rect_size.x/2, screen_pos.y - $Control.rect_size.y/2) )
	


func set_text(value):
	
	text = value
	$Control/Label.text = value
	


func _node_renamed():
	
	$Control/Username.text = parent.name
	
