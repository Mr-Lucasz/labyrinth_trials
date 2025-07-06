# jogador.gd
extends CharacterBody2D

@export var speed: float = 300.0
const HOLD_OFFSET: Vector2 = Vector2(0, -24)

# ——— Flags dos puzzles ———
var shape_completed: bool    = false
var number_completed: bool   = false
var arrow_completed: bool    = false
var all_completed_printed: bool = false


# ——— Puzzle numérico ———

var number_sequence := ["Numero2", "Numero3", "Numero1"]
var next_number_index := 0
var _last_number_index := -1

# ——— Proximidade e transportes ———
var nearby_item:  Node2D = null
var carried:      Node2D = null
var nearby_arrow: Node2D = null

# ——— Labels de mensagem ———
var message_label:       Label
var message_label_forma: Label
var message_label_seta:  Label
var message_label_finish:  Label

# ——— Orientações alvo das setas (em graus) ———
var arrow_targets := {
	"Seta1": 270,  # esquerda
	"Seta2":   0,  # cima
	"Seta3":  90   # direita
}

func _ready() -> void:
	$PickupDetector.body_entered.connect(_on_body_entered)
	$PickupDetector.body_exited.connect(_on_body_exited)

	message_label       = get_tree().current_scene.get_node_or_null("CanvasLayer/MessageLabel") as Label
	message_label_forma = get_tree().current_scene.get_node_or_null("CanvasLayerForma/MessageLabel") as Label
	message_label_seta  = get_tree().current_scene.get_node_or_null("CanvasLayerSetas/MessageLabel") as Label
	message_label_finish = get_tree().current_scene.get_node_or_null("CanvasLayerFinish/MessageLabel") as Label

	if message_label:
		message_label.visible = false
	if message_label_forma:
		message_label_forma.visible = false
	if message_label_seta:
		message_label_seta.visible = false
	if message_label_finish:
		message_label_finish.visible = false

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

	# Debug: mostra qual número está esperando (apenas quando muda)
	if not number_completed:
		if _last_number_index != next_number_index:
			print("[PuzzleNum] Esperado: ", number_sequence[next_number_index], " (índice: ", next_number_index, ")")
			_last_number_index = next_number_index

	# Botão para voltar ao menu principal (tecla ESC)
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_main_menu()

	# Verificação de conclusão dos puzzles
	if shape_completed and number_completed and arrow_completed:
		# Garante que labels antigos são escondidos
		var canvas_layer = get_tree().current_scene.get_node_or_null("CanvasLayer")
		var canvas_layer_forma = get_tree().current_scene.get_node_or_null("CanvasLayerForma")
		if canvas_layer:
			message_label = canvas_layer.get_node_or_null("MessageLabel") as Label
			if message_label:
				message_label.visible = false
		if canvas_layer_forma:
			message_label_forma = canvas_layer_forma.get_node_or_null("MessageLabel") as Label
			if message_label_forma:
				message_label_forma.visible = false


	if Input.is_action_just_pressed("ui_select"):
		if carried:
			_drop_item()
		elif nearby_item:
			_pick_item(nearby_item)
		elif nearby_arrow and not arrow_completed:
			_rotate_arrow(nearby_arrow)

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
	if body.is_in_group("pickable") and carried == null:
		nearby_item = body
	if body.is_in_group("arrow") and not arrow_completed:
		nearby_arrow = body

func _on_body_exited(body: Node) -> void:
	if body == nearby_item:
		nearby_item = null
	if body == nearby_arrow:
		nearby_arrow = null

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

	# Puzzle de formas
	if not shape_completed:
		for zone in get_tree().get_nodes_in_group("drop_zone"):
			if zone.global_position.distance_to(drop_pos) < 32 and zone.accepts(carried):
				zone.snap_item(carried)
				break
		if _check_shape_complete():
			_on_shape_completed()

	# Puzzle numérico
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
	carried     = null

func _rotate_arrow(arrow: Node2D) -> void:
	arrow.rotation_degrees = wrapf(arrow.rotation_degrees + 90.0, 0.0, 360.0)
	if arrow.has_node("Sprite2D"):
		var sp = arrow.get_node("Sprite2D") as Sprite2D
		var target = arrow_targets.get(arrow.name, -1)
		sp.modulate = Color(0,1,0) if int(arrow.rotation_degrees) == target else Color(1,1,1)
	if _check_arrows_complete():
		arrow_completed = true
		message_label_seta.text    = "Puzzle de setas concluído!"
		message_label_seta.visible = true
		_check_all_puzzles()

func _check_arrows_complete() -> bool:
	for name in arrow_targets.keys():
		var a = get_tree().current_scene.get_node("ArrowSlots/" + name) as Node2D
		if int(a.rotation_degrees) != arrow_targets[name]:
			return false
	return true

func _check_shape_complete() -> bool:
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if not zone.filled:
			return false
	return true

func _on_shape_completed() -> void:
	shape_completed = true

	message_label_forma.text    = "Puzzle de formas concluído!"
	message_label_forma.visible = true
	_check_all_puzzles()

func _check_number_complete() -> bool:
	return next_number_index >= number_sequence.size()

func _on_number_completed() -> void:
	number_completed = true

	message_label.text    = "Puzzle de números concluído!"
	message_label.visible = true
	_check_all_puzzles()

func _check_all_puzzles() -> void:
	if shape_completed and number_completed and arrow_completed and not all_completed_printed:		
		message_label_finish.text = "Parabéns! 🎉 Você concluiu os puzzles\ndessa fase, vá para os próximos\ndesafios por aqui"
		message_label_finish.visible = true
		all_completed_printed = true

func return_to_main_menu() -> void:
	print("Voltando ao menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
