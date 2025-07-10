extends Node2D

signal puzzle_concluido

@export var sequencia_correta: Array[String] = ["vermelho", "amarelo", "verde"]
var sequencia_atual: Array[String] = []
var puzzle_resolvido: bool = false

# Referências aos nós
@onready var botao_a = $BotoesContainer/BotaoVermelho
@onready var botao_b = $BotoesContainer/BotaoAmarelo
@onready var botao_c = $BotoesContainer/BotaoVerde
@onready var pino_vermelho = $PinosContainer/PinoVermelho
@onready var pino_amarelo = $PinosContainer/PinoAmarelo
@onready var pino_verde = $PinosContainer/PinoVerde
@onready var feedback_posicao_1 = $FeedbackSprite
@onready var feedback_posicao_2 = $FeedbackSprite2
@onready var feedback_posicao_3 = $FeedbackSprite3

func _ready():
	# Conecta os botões (Area2D)
	botao_a.input_event.connect(_on_botao_a_input_event)
	botao_b.input_event.connect(_on_botao_b_input_event)
	botao_c.input_event.connect(_on_botao_c_input_event)
	
	# Inicializa o puzzle
	resetar_puzzle()

func _on_botao_a_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not puzzle_resolvido:
			adicionar_cor("vermelho")

func _on_botao_b_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not puzzle_resolvido:
			adicionar_cor("amarelo")

func _on_botao_c_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not puzzle_resolvido:
			adicionar_cor("verde")

func adicionar_cor(cor: String):
	if sequencia_atual.size() >= 3:
		return
	
	sequencia_atual.append(cor)
	var posicao_atual = sequencia_atual.size() - 1
	
	# Mostra o pino correspondente à cor
	mostrar_pino(cor)
	
	# Mostra o feedback correspondente à posição
	mostrar_feedback_posicao(posicao_atual)
	
	# Se preencheu todos os furos, verifica a solução
	if sequencia_atual.size() == 3:
		verificar_solucao()

func mostrar_pino(cor: String):
	var pino_sprite: Sprite2D
	
	match cor:
		"vermelho":
			pino_sprite = pino_vermelho
		"amarelo":
			pino_sprite = pino_amarelo
		"verde":
			pino_sprite = pino_verde
	
	if pino_sprite:
		pino_sprite.visible = true

func mostrar_feedback_posicao(posicao: int):
	var feedback_sprite: Sprite2D
	
	match posicao:
		0:
			feedback_sprite = feedback_posicao_1
		1:
			feedback_sprite = feedback_posicao_2
		2:
			feedback_sprite = feedback_posicao_3
	
	if feedback_sprite:
		feedback_sprite.visible = true

func verificar_solucao():
	if sequencia_atual == sequencia_correta:
		# Solução correta!
		puzzle_resolvido = true
		
		# Mostra feedback de sucesso (frame 0) em todas as posições
		feedback_posicao_1.frame = 0
		feedback_posicao_2.frame = 0
		feedback_posicao_3.frame = 0
		
		print("Puzzle resolvido!")
		emit_signal("puzzle_concluido")
	else:
		# Solução incorreta
		# Mostra feedback de falha (frame 1) em todas as posições
		feedback_posicao_1.frame = 1
		feedback_posicao_2.frame = 1
		feedback_posicao_3.frame = 1
		
		print("Sequência incorreta. Tentando novamente...")
		# Aguarda um tempo e reseta
		await get_tree().create_timer(1.5).timeout
		resetar_puzzle()

func resetar_puzzle():
	sequencia_atual.clear()
	
	# Esconde todos os pinos
	pino_vermelho.visible = false
	pino_amarelo.visible = false
	pino_verde.visible = false
	
	# Esconde todos os feedbacks
	feedback_posicao_1.visible = false
	feedback_posicao_2.visible = false
	feedback_posicao_3.visible = false

func set_interacao(ativo: bool):
	if puzzle_resolvido:
		return
	
	botao_a.input_pickable = ativo
	botao_b.input_pickable = ativo
	botao_c.input_pickable = ativo
	
	if not ativo:
		resetar_puzzle()
