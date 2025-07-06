extends Area2D

@export var slot_type: String = ""   # “Triangulo”, “Circulo” ou “Quadrado”
var filled: bool = false

func accepts(item: Node2D) -> bool:
	var it = item.item_type        # pega diretamente a variável exportada
	print("[Slot.accepts] slot_type=", slot_type, " item_type=", it)
	return it == slot_type

func snap_item(item: Node2D) -> void:
	print("[Slot] snap_item chamado em ", slot_type, " com item ", item.name)
	item.global_position = global_position
	filled = true
