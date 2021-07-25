class_name Inventory
extends Node



export var max_slot := 24

var items : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if items.empty():
		items = Dictionary()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func has_item(slot_id : int):
	
	return items.has(slot_id)
	


func add_item(slot_id : int, item : Dictionary):
	
	if items.has(slot_id):
		if items[slot_id].item_id == item.item_id:
			#items[slot_id].quantity += item.quantity
			change_quantity(slot_id, items[slot_id].quantity + item.quantity)
	else:
		items[slot_id] = item
		print("[%s] Add item [%d]" % [name, slot_id], item)


func get_item(slot_id : int) -> Dictionary:
	
	return items[slot_id]
	


func remove_item(slot_id : int):
	
	items.erase(slot_id)
	print("[%s] Remove item [%d]" % [name, slot_id])


func get_quantity(slot_id : int) -> int:
	if items.has(slot_id):
		return items[slot_id].quantity
	return 0


func change_quantity(slot_id : int, quantity : int):
	if items.has(slot_id):
		items[slot_id].quantity = quantity
		print("[%s] Change quantity [%d] : " % [name, slot_id], quantity)
