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

func _on_puzzle_cores_concluido():
	print("Puzzle de cores concluído!")
	puzzles_resolvidos += 1
	verificar_vitoria()

func _on_puzzle_quebra_cabeca_concluido():
	print("Puzzle de quebra-cabeça concluído!")
	puzzles_resolvidos += 1
	verificar_vitoria()

func verificar_vitoria():
	if puzzles_resolvidos >= total_puzzles:
		timer_ativo = false
		print("Parabéns! Todos os puzzles foram resolvidos!")
		# Aqui você pode adicionar uma tela de vitória ou carregar a próxima fase
