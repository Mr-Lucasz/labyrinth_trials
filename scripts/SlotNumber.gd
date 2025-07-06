extends Area2D

@export var slot_type: String = ""   # qual número este slot aceita
var filled: bool = false

func accepts(item: Node2D) -> bool:
	return item.item_type == slot_type

func snap_item(item: Node2D) -> void:
	item.global_position = global_position
	filled = true
