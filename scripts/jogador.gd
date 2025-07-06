extends CharacterBody2D

@export var speed: float = 300.0
const HOLD_OFFSET: Vector2 = Vector2(0, -24)

var shape_completed: bool = false
var number_completed: bool = false

var number_sequence := ["Numero2", "Numero3", "Numero1"]
var next_number_index := 0

var nearby_item: Node2D = null
var carried: Node2D = null

var message_label: Label
var message_label_forma: Label

func _ready() -> void:
	$PickupDetector.body_entered.connect(_on_body_entered)
	$PickupDetector.body_exited.connect(_on_body_exited)
	message_label = get_tree().current_scene.get_node("CanvasLayer/MessageLabel") as Label
	message_label_forma = get_tree().current_scene.get_node("CanvasLayerForma/MessageLabel") as Label
	message_label.visible = false
	message_label_forma.visible = false

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	
	# Debug: mostra qual número está esperando
	if not number_completed:
		print("Próximo número esperado: ", number_sequence[next_number_index], " (índice: ", next_number_index, ")")
	
	# Botão para voltar ao menu principal (tecla ESC)
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_main_menu()
	
	if shape_completed and number_completed:
		return

	if Input.is_action_just_pressed("ui_select"):
		if carried:
			_drop_item()
		elif nearby_item:
			_pick_item(nearby_item)

func _handle_movement(delta: float) -> void:
	var iv = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()
	velocity = iv * speed
	move_and_slide()
	_update_animation(iv)

func _update_animation(iv: Vector2) -> void:
	if iv == Vector2.ZERO:
		$AnimatedSprite2D.play("parado_frente")
	elif abs(iv.x) > abs(iv.y):
		var anim = "andando_ladoR" if iv.x > 0 else "andando_ladoL"
		$AnimatedSprite2D.play(anim)
	else:
		var anim = "parado_costa" if iv.y < 0 else "parado_frente"
		$AnimatedSprite2D.play(anim)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("pickable") or carried != null:
		return

	if number_completed and body.has_method("get") and body.get("item_type") in number_sequence:
		return
		
	nearby_item = body

func _on_body_exited(body: Node) -> void:
	if body == nearby_item:
		nearby_item = null

func _pick_item(item: Node2D) -> void:
	carried = item
	item.get_parent().remove_child(item)
	add_child(item)
	item.position = HOLD_OFFSET
	if item.has_node("CollisionShape2D"):
		item.get_node("CollisionShape2D").disabled = true

func _drop_item() -> void:
	var drop_pos = to_global(carried.position)

	remove_child(carried)
	get_tree().current_scene.add_child(carried)
	carried.global_position = drop_pos
	if carried.has_node("CollisionShape2D"):
		carried.get_node("CollisionShape2D").disabled = false

	if not shape_completed:
		for zone in get_tree().get_nodes_in_group("drop_zone"):
			if zone.global_position.distance_to(drop_pos) < 32 and zone.accepts(carried):
				zone.snap_item(carried)
				break
		if _check_shape_complete():
			_on_shape_completed()

	if not number_completed:
		for zone in get_tree().get_nodes_in_group("drop_zone_number"):
			if zone.global_position.distance_to(drop_pos) < 32:
				var expected = number_sequence[next_number_index]
				if carried.item_type == expected and zone.accepts(carried):
					zone.snap_item(carried)
					next_number_index += 1
					if _check_number_complete():
						_on_number_completed()
				else:
					carried.global_position = drop_pos + Vector2(0,16)
				break

	nearby_item = null
	carried = null

func _check_shape_complete() -> bool:
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if not zone.filled:
			return false
	return true

func _on_shape_completed() -> void:
	shape_completed = true
	message_label_forma.text    = "Puzzle de formas concluído!"
	message_label_forma.visible = true

func _check_number_complete() -> bool:
	return next_number_index >= number_sequence.size()

func _on_number_completed() -> void:
	number_completed = true
	message_label.text    = "Puzzle de Numeros concluído!"
	message_label.visible = true

func return_to_main_menu() -> void:
	print("Voltando ao menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
