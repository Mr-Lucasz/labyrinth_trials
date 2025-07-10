# puzzle_forma_sequencia.gd
extends Node2D

signal puzzle_concluido

var puzzle_resolvido_flag = false

@onready var slots_container = $GridSlots
# Adicione referências para os novos nós se você os adicionou
@onready var som_sucesso = $AudioStreamPlayer # Renomeie se necessário

func _ready():
	print("[LOG] _ready chamado em puzzle_forma_sequencia.gd")
	process_mode = Node.PROCESS_MODE_DISABLED

	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		
		if peca_interativa:
			peca_interativa.forma_alterada.connect(verificar_solucao)

		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")
		if feedback_sprite:
			feedback_sprite.visible = false

func encontrar_peca_no_slot(slot_node):
	for child in slot_node.get_children():
		if child is Area2D:
			return child
	return null

func verificar_solucao():
	if puzzle_resolvido_flag:
		return

	var pecas_corretas = 0
	
	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")

		if not peca_interativa or not feedback_sprite:
			continue

		if peca_interativa.forma_atual == slot.forma_correta:
			feedback_sprite.frame = 0 # Feedback VERDE
			pecas_corretas += 1
		else:
			feedback_sprite.frame = 1 # Feedback VERMELHO 
		
		feedback_sprite.visible = true

	if pecas_corretas == slots_container.get_child_count():
		# Atraso de um pequeno momento para o jogador ver a última peça ficar verde
		await get_tree().create_timer(0.2).timeout
		puzzle_resolvido()

func set_interacao(ativa: bool):
	# Se o puzzle já foi resolvido, ele nunca mais deve ser ativado.
	if puzzle_resolvido_flag:
		process_mode = Node.PROCESS_MODE_DISABLED
		# Garante que os feedbacks fiquem desligados se o jogador sair e voltar
		for slot in slots_container.get_children():
			var feedback = slot.get_node_or_null("FeedbackSprite")
			if feedback:
				feedback.visible = false
		return

	# Lógica normal de ativação/desativação
	process_mode = Node.PROCESS_MODE_INHERIT if ativa else Node.PROCESS_MODE_DISABLED
	
	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		if peca_interativa:
			peca_interativa.set_interativo(ativa)
		
		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")
		if feedback_sprite:
			feedback_sprite.visible = ativa
			
	if ativa:
		verificar_solucao()

func puzzle_resolvido():
	if puzzle_resolvido_flag:
		return
	print("PARABÉNS! PUZZLE RESOLVIDO!")
	puzzle_resolvido_flag = true
	if som_sucesso:
		som_sucesso.play()
	emit_signal("puzzle_concluido")
	set_interacao(false)
