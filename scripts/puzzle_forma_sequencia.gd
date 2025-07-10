# puzzle_forma_sequencia.gd
extends Node2D

signal puzzle_concluido

var puzzle_resolvido_flag = false

@onready var slots_container = $GridSlots

func _ready():
	print("[LOG] _ready chamado em puzzle_forma_sequencia.gd")
	process_mode = Node.PROCESS_MODE_DISABLED

	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		
		if peca_interativa:
			print("[LOG] Conectando 'forma_alterada' de:", peca_interativa.name, "em", slot.name)
			peca_interativa.forma_alterada.connect(verificar_solucao)
		else:
			print("[AVISO] Não foi encontrada uma peça interativa (Area2D) no slot: ", slot.name)

		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")
		if feedback_sprite:
			feedback_sprite.visible = false
		else:
			print("[ERRO NO READY] Não foi possível encontrar 'FeedbackSprite' no slot: ", slot.name)

# Função auxiliar para encontrar a peça interativa (Area2D) dentro de um slot
func encontrar_peca_no_slot(slot_node):
	for child in slot_node.get_children():
		if child is Area2D: # Assumimos que a peça é o único Area2D filho do slot
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
			feedback_sprite.frame = 0 # VERDE
			pecas_corretas += 1
		else:
			feedback_sprite.frame = 1 # VERMELHO
		
		feedback_sprite.visible = true

	if pecas_corretas == slots_container.get_child_count():
		puzzle_resolvido()

func set_interacao(ativa: bool):
	if puzzle_resolvido_flag:
		return

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
	emit_signal("puzzle_concluido")
	set_interacao(false)
