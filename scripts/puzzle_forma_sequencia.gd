# puzzle_forma_sequencia.gd
extends Node2D

signal puzzle_concluido

@onready var pecas_container = $Pieces
@onready var slots_container = $GridSlots
var interacao_ativa = true # Começa ativo para o puzzle poder ser jogado

func _ready():
	# Desativa a interação no início, para ser ativada por proximidade
	set_interacao(false) 
	
	# Conecta o sinal de cada peça a uma função de verificação
	for peca in pecas_container.get_children():
		peca.peca_solta.connect(_on_peca_solta)

func _on_peca_solta(peca):
	# Sempre que uma peça é solta, verificamos o estado do puzzle
	verificar_solucao()

func verificar_solucao():
	var pecas_corretas = 0
	var total_pecas_nos_slots = 0
	
	# Percorre todos os 9 slots
	for slot in slots_container.get_children():
		var feedback_sprite = slot.get_node("FeedbackSprite")
		
		# Verifica se existe uma peça neste slot
		if slot.peca_atual != null:
			total_pecas_nos_slots += 1
			feedback_sprite.visible = true # Torna o feedback visível

			# Se a peça no slot for a correta...
			if slot.peca_atual.tipo_forma == slot.forma_correta:
				feedback_sprite.frame = 0 # MOSTRA O FRAME 0 (VERDE)
				pecas_corretas += 1
			# Se for a incorreta...
			else:
				feedback_sprite.frame = 1 # MOSTRA O FRAME 1 (VERMELHO)
		# Se o slot estiver vazio...
		else:
			feedback_sprite.visible = false # Esconde o feedback

	# Condição de vitória: Apenas se todos os 9 slots tiverem peças E todas estiverem corretas.
	if total_pecas_nos_slots == 9 and pecas_corretas == 9:
		puzzle_resolvido()

func set_interacao(ativa : bool):
	interacao_ativa = ativa
	# O modo de processamento "Disabled" congela o nó e seus filhos, parando a interação.
	if ativa:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

func puzzle_resolvido():
	print("PARABÉNS! PUZZLE RESOLVIDO!")
	emit_signal("puzzle_concluido")
	# Desativa o puzzle permanentemente após a resolução.
	set_interacao(false)
