# level2.gd
extends Node2D

# Referências para os puzzles
@export var puzzle_formas : Node
@export var puzzle_cores: Node
@export var puzzle_quebra_cabeca: Node

# Timer
@onready var timer_label = $UI/TimerLabel
var tempo_inicial = 0.0
var tempo_maximo = 300.0  # 5 minutos em segundos
var timer_ativo = false

# Controle de puzzles resolvidos
var puzzles_resolvidos = 0
var total_puzzles = 3

func _ready():
	# Conecta os sinais dos puzzles
	puzzle_formas.puzzle_concluido.connect(_on_puzzle_formas_concluido)
	if puzzle_cores:
		puzzle_cores.puzzle_concluido.connect(_on_puzzle_cores_concluido)
	if puzzle_quebra_cabeca:
		puzzle_quebra_cabeca.puzzle_concluido.connect(_on_puzzle_quebra_cabeca_concluido)

	# Inicializa o timer
	iniciar_timer()
	# Desativa todos os puzzles inicialmente
	desativar_todos_puzzles()

	# Garante que o jogador da cena está na posição correta ao entrar na fase
	var jogador = get_node_or_null("Jogador")
	if jogador:
		# Se houver dados salvos, restaura a posição, senão usa a posição padrão da cena
		var data = null
		if typeof(Global) != TYPE_NIL and Global.has_method("get_player_state_for_level"):
			data = Global.get_player_state_for_level()
		if data and data.has("checkpoint_reached") and data["checkpoint_reached"] and data.has("position"):
			jogador.position = Vector2(data["position"]["x"], data["position"]["y"])
		else:
			jogador.position = Vector2(87.876, -408.553)

func _process(delta):
	if timer_ativo:
		tempo_inicial += delta
		atualizar_timer_display()
		
		# Verifica se o tempo acabou
		if tempo_inicial >= tempo_maximo:
			game_over()

func iniciar_timer():
	tempo_inicial = 0.0
	timer_ativo = true
	atualizar_timer_display()

func atualizar_timer_display():
	if timer_label:
		var minutos = int(tempo_inicial) / 60
		var segundos = int(tempo_inicial) % 60
		timer_label.text = "Tempo: %02d:%02d" % [minutos, segundos]

func desativar_todos_puzzles():
	# Desativa todos os puzzles no início
	if puzzle_formas:
		puzzle_formas.set_interacao(false)
	if puzzle_cores:
		puzzle_cores.set_interacao(false)
	if puzzle_quebra_cabeca:
		puzzle_quebra_cabeca.set_interacao(false)

func game_over():
	timer_ativo = false
	print("Tempo esgotado! Game Over!")
	# Aqui você pode adicionar uma tela de game over
	get_tree().reload_current_scene()

func _on_puzzle_formas_concluido():
	print("Puzzle de formas concluído!")
	puzzles_resolvidos += 1
	verificar_vitoria()

	# Checkpoint: se for o segundo puzzle resolvido, salva o progresso
	if puzzles_resolvidos == 2:
		_save_checkpoint()

func _on_puzzle_cores_concluido():
	print("Puzzle de cores concluído!")
	puzzles_resolvidos += 1
	verificar_vitoria()

	# Checkpoint: se for o segundo puzzle resolvido, salva o progresso
	if puzzles_resolvidos == 2:
		_save_checkpoint()

func _on_puzzle_quebra_cabeca_concluido():
	print("Puzzle de quebra-cabeça concluído!")
	puzzles_resolvidos += 1
	verificar_vitoria()

func verificar_vitoria():
	if puzzles_resolvidos >= total_puzzles:
		timer_ativo = false
		print("Parabéns! Todos os puzzles foram resolvidos!")
		# Aqui você pode adicionar uma tela de vitória ou carregar a próxima fase


# --- CHECKPOINT ---
func _save_checkpoint():
	var jogador = get_node_or_null("Jogador")
	if jogador:
		jogador.checkpoint_reached = true
		Global.fase_atual = 2
		Global.puzzle_atual = puzzles_resolvidos + 1
		Global.checkpoint_alcancado = true
		var save_data = jogador._get_current_state()
		if puzzle_formas and puzzle_formas.has_method("get_save_state"):
			save_data["puzzle_formas"] = puzzle_formas.get_save_state()
		if puzzle_cores and puzzle_cores.has_method("get_save_state"):
			save_data["puzzle_cores"] = puzzle_cores.get_save_state()
		if puzzle_quebra_cabeca and puzzle_quebra_cabeca.has_method("get_save_state"):
			save_data["puzzle_quebra_cabeca"] = puzzle_quebra_cabeca.get_save_state()
		Global.save_game_at_checkpoint(save_data)
		print("Checkpoint salvo na Fase 2!")

# --- RESTAURAÇÃO DE ESTADO AO CARREGAR ---

	# Restaura posição do jogador e estado dos puzzles se houver checkpoint
	_restore_from_checkpoint()

func _restore_from_checkpoint():
	var data = Global.get_player_state_for_level()
	if data and data.has("checkpoint_reached") and data["checkpoint_reached"]:
		var jogador = get_node_or_null("Jogador")
		if jogador and data.has("position"):
			jogador.position = Vector2(data["position"]["x"], data["position"]["y"])

		# Restaurar estado detalhado dos puzzles
		if puzzle_formas and data.has("puzzle_formas"):
			puzzle_formas.load_save_state(data["puzzle_formas"])
		if puzzle_cores and data.has("puzzle_cores"):
			puzzle_cores.load_save_state(data["puzzle_cores"])
		if puzzle_quebra_cabeca and data.has("puzzle_quebra_cabeca"):
			puzzle_quebra_cabeca.load_save_state(data["puzzle_quebra_cabeca"])

		# Atualiza contagem de puzzles resolvidos
		puzzles_resolvidos = int(data.get("shape_completed", false)) + int(data.get("number_completed", false)) + int(data.get("arrow_completed", false))
