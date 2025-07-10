# jogador.gd
extends CharacterBody2D

@export var speed: float = 300.0 # Player movement speed.

const HOLD_OFFSET: Vector2 = Vector2(0, -24)

var player_name: String = ""
# ——— Flags dos puzzles ———
var shape_completed: bool = false
var number_completed: bool = false
var arrow_completed: bool = false
var all_completed_printed: bool = false # Prevents multiple "congrats" messages.

# --- Checkpoint ---
var checkpoint_reached: bool = false

# --- Cronômetro para Ranking ---
var start_time: float = 0.0


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
	# --- Setup Inicial ---
	_initialize_from_global_state()
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

	# --- ATALHO DE DEBUG PARA TESTAR RANKING ---
	# Pressione '9' para completar a fase instantaneamente
	if OS.is_debug_build() and Input.is_action_just_pressed("debug_complete"):
		_force_complete_and_rank()


	if Input.is_action_just_pressed("ui_select"):
		if carried:
			_drop_item()
		elif nearby_item:
			_pick_item(nearby_item)
		# só roda setas se não tiver nenhum pickable por perto
		elif nearby_arrow and not arrow_completed and nearby_item == null:
			_rotate_arrow(nearby_arrow)


func _initialize_from_global_state():
	# Carrega o estado do jogo a partir do singleton Global.
	# Isso centraliza a lógica de save/load e simplifica o jogador.
	var data = Global.get_player_state_for_level()
	
	shape_completed = data.get("shape_completed", false)
	number_completed = data.get("number_completed", false)
	arrow_completed = data.get("arrow_completed", false)
	next_number_index = data.get("next_number_index", 0)
	checkpoint_reached = data.get("checkpoint_reached", false)
	all_completed_printed = data.get("all_completed_printed", false)
	start_time = data.get("start_time", Time.get_unix_time_from_system())
	
	var start_pos = data.get("position", null)
	if start_pos:
		position = Vector2(start_pos["x"], start_pos["y"])
	
	print("Jogador inicializado para '%s' com %d puzzles completos." % [Global.player_nickname, data.get("puzzles_completados", 0)])
	_update_puzzle_visuals()

# Atualiza o estado visual dos puzzles baseado nos valores carregados
func _update_puzzle_visuals() -> void:
	# Atualizar o estado visual do puzzle de formas se estiver completo
	if shape_completed and message_label_forma:
		message_label_forma.text = "Puzzle de formas concluído!"
		message_label_forma.visible = true
	
	# Atualizar o estado visual do puzzle de números se estiver completo
	if number_completed and message_label:
		message_label.text = "Puzzle de números concluído!"
		message_label.visible = true
	
	# Atualizar o estado visual do puzzle de setas se estiver completo
	if arrow_completed and message_label_seta:
		message_label_seta.text = "Puzzle de setas concluído!"
		message_label_seta.visible = true
		
	# Verificar se todos os puzzles estão concluídos
	if shape_completed and number_completed and arrow_completed and message_label_finish:
		message_label_finish.text = "Parabéns! 🎉 Você concluiu os puzzles\ndessa fase, vá para os próximos\ndesafios por aqui"
		message_label_finish.visible = true
		
	# Atualizar os itens físicos nos puzzles, isso precisa ser implementado
	# conforme o design específico da sua cena

func _get_current_state() -> Dictionary:
	# Coleta todos os dados relevantes do jogador em um dicionário para salvar.
	return {
		"shape_completed": shape_completed,
		"number_completed": number_completed,
		"arrow_completed": arrow_completed,
		"next_number_index": next_number_index,
		"checkpoint_reached": checkpoint_reached,
		"all_completed_printed": all_completed_printed,
		"position": { "x": position.x, "y": position.y },
		"start_time": start_time
	}

func _handle_movement(_delta: float) -> void:
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
	# ——— Impede pegar formas já concluídas ———
	if shape_completed and item.item_type in ["Triangulo", "Circulo", "Quadrado"]:
		return
	# ——— Impede pegar números já concluídos ———
	if number_completed and item.item_type in ["Numero1", "Numero2", "Numero3"]:
		return
	# ——— Impede interagir com setas já concluídas ———
	if arrow_completed and item.is_in_group("arrow"):
		return

	if carried != null:
		_drop_item()
		
	carried = item
	item.get_parent().remove_child(item)
	add_child(item)
	item.position = HOLD_OFFSET
	if item.has_node("CollisionShape2D"):
		item.get_node("CollisionShape2D").disabled = true

func _drop_item() -> void:
	# 1) calcula posição de drop e faz reparent seguro
	var drop_pos = to_global(carried.position)
	remove_child(carried)
	get_tree().current_scene.add_child(carried)
	carried.global_position = drop_pos
	if carried.has_node("CollisionShape2D"):
		carried.get_node("CollisionShape2D").disabled = false

	# 2) tenta o puzzle de FORMAS (só se ainda não concluído e se o item for uma forma)
	if not shape_completed and carried.item_type in ["Triangulo", "Circulo", "Quadrado"]:
		for zone in get_tree().get_nodes_in_group("drop_zone"):
			if zone.global_position.distance_to(drop_pos) < 32:
				# encontrou uma zona de forma próxima
				if zone.accepts(carried):
					zone.snap_item(carried)
					if _check_shape_complete():
						_on_shape_completed()
				# pare de tentar qualquer outro puzzle
				nearby_item = null
				carried = null
				return

	# 3) tenta o puzzle de NÚMEROS (só se não concluído e se for um número)
	if not number_completed and carried.item_type.begins_with("Numero"):
		for zone in get_tree().get_nodes_in_group("drop_zone_number"):
			if zone.global_position.distance_to(drop_pos) < 32:
				var expected = number_sequence[next_number_index]
				if carried.item_type == expected and zone.accepts(carried):
					zone.snap_item(carried)
					next_number_index += 1
					if _check_number_complete():
						_on_number_completed()
				# pare aqui também
				nearby_item = null
				carried = null
				return

	# 4) se chegou aqui, não entrou em nenhum slot: solta “no chão” onde largou
	nearby_item = null
	carried = null


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

	# ➡️ protege contra rotações acidentais posteriores
	nearby_arrow = null

func _check_arrows_complete() -> bool:
	for arrow_name in arrow_targets.keys():
		var a = get_tree().current_scene.get_node("ArrowSlots/" + arrow_name) as Node2D
		if int(a.rotation_degrees) != arrow_targets[arrow_name]:
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

func _check_all_puzzles(return_to_menu := false) -> void:
	var completed_count = int(shape_completed) + int(number_completed) + int(arrow_completed)
	if completed_count == 2 and not checkpoint_reached:
		_on_checkpoint_reached()
	if shape_completed and number_completed and arrow_completed and not all_completed_printed:
		message_label_finish.text = "Parabéns! 🎉 Você concluiu os puzzles\ndessa fase, vá para os próximos\ndesafios por aqui"
		message_label_finish.visible = true
		# Salva a pontuação no ranking
		var final_time = Time.get_unix_time_from_system() - start_time
		Global.add_score(Global.player_nickname, final_time)
		all_completed_printed = true
		if return_to_menu:
			await get_tree().process_frame
			return_to_main_menu()

func _on_checkpoint_reached() -> void:
	checkpoint_reached = true
	if message_label:
		message_label.text = "Checkpoint alcançado! Progresso salvo."
		message_label.visible = true
	# Delega o salvamento para o Global, enviando o estado atual do jogador.
	Global.save_game_at_checkpoint(_get_current_state())
	print("Checkpoint salvo para %s" % Global.player_nickname)

func return_to_main_menu() -> void:
	print("Voltando ao menu principal...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

func _force_complete_and_rank() -> void:
	# Evita registrar o score múltiplas vezes
	if all_completed_printed:
		return

	print("DEBUG: Forçando conclusão da fase para teste de ranking.")
	shape_completed = true
	number_completed = true
	arrow_completed = true
	_check_all_puzzles(true) # Chama a função que calcula o tempo, salva o score e volta ao menu
