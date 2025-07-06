extends Area2D

@export var slot_type: String = ""   # “Triangulo”, “Circulo” ou “Quadrado”
var filled: bool = false

func accepts(item: Node2D) -> bool:
	var it = item.item_type
	var result = it == slot_type
	print("[Slot] Teste: slot_type=", slot_type, ", item_type=", it, ", resultado=", result)
	return result

func snap_item(item: Node2D) -> void:
	print("[Slot] Snap: slot=", slot_type, ", item=", item.name)
	item.global_position = global_position
	filled = true
