# puzzle_forma_sequencia.gd
extends Node2D

signal puzzle_concluido

var puzzle_resolvido_flag = false

@onready var slots_container = $GridSlots
@onready var som_sucesso = $AudioStreamPlayer

func _ready():
	# Conecta os sinais de todas as peças interativas.
	for slot in slots_container.get_children():
		var peca = encontrar_peca_no_slot(slot)
		if peca:
			peca.forma_alterada.connect(verificar_solucao)
		else:
			print("AVISO: Slot '", slot.name, "' não contém uma peça interativa (forma_interativa).")

		# Garante que todos os feedbacks comecem invisíveis.
		var feedback = slot.get_node_or_null("FeedbackSprite")
		if feedback:
			feedback.visible = false

func encontrar_peca_no_slot(slot_node):
	# Esta função procura por um filho que tenha o script 'forma_interativa.gd'.
	# É mais seguro do que checar pelo tipo 'Area2D'.
	for child in slot_node.get_children():
		if "forma_atual" in child: # Verifica se o nó tem a propriedade da nossa peça.
			return child
	return null

func verificar_solucao():
	if puzzle_resolvido_flag:
		return

	print("\n--- INICIANDO VERIFICAÇÃO ---")
	var pecas_corretas = 0
	var total_slots = slots_container.get_children().size()

	for i in range(total_slots):
		var slot = slots_container.get_child(i)
		var peca = encontrar_peca_no_slot(slot)
		var feedback = slot.get_node_or_null("FeedbackSprite")

		# Pula este slot se algo estiver faltando, e nos avisa.
		if not peca or not feedback:
			print("Slot ", i, ": ERRO! Não encontrou a peça ou o feedback. Pulando.")
			continue

		# --- PONTO CRÍTICO DA COMPARAÇÃO ---
		# Adicionamos prints para ver os valores que estão sendo comparados.
		print("Slot ", i, ": Comparando Peça (", peca.forma_atual, ") com Slot Correto (", slot.forma_correta, ")")

		if peca.forma_atual == slot.forma_correta:
			# CORRETO: Mostra o feedback e o torna translúcido.
			print(" > Resultado: CORRETO.")
			feedback.visible = true
			feedback.modulate = Color(1.0, 1.0, 1.0, 0.5) # 50% de transparência
			pecas_corretas += 1
		else:
			# INCORRETO: Garante que o feedback esteja escondido.
			print(" > Resultado: INCORRETO.")
			feedback.visible = false

	print("--- FIM DA VERIFICAÇÃO: ", pecas_corretas, " de ", total_slots, " corretas. ---\n")

	if pecas_corretas == total_slots:
		call_deferred("puzzle_resolvido")

func set_interacao(ativa: bool):
	if puzzle_resolvido_flag:
		return

	# Ativa ou desativa a interação nas peças.
	for slot in slots_container.get_children():
		var peca = encontrar_peca_no_slot(slot)
		if peca:
			peca.set_interativo(ativa)
	
	# A visibilidade do feedback agora é controlada APENAS por verificar_solucao.
	# Esta é a correção principal para o feedback que aparecia direto.
	if ativa:
		# Quando o jogador entra na área, verificamos o estado atual do puzzle.
		verificar_solucao()
	else:
		# Quando o jogador sai, escondemos todos os feedbacks.
		for slot in slots_container.get_children():
			var feedback = slot.get_node_or_null("FeedbackSprite")
			if feedback:
				feedback.visible = false

func puzzle_resolvido():
	if puzzle_resolvido_flag:
		return
		
	print("!!! PARABÉNS! PUZZLE RESOLVIDO! !!!")
	puzzle_resolvido_flag = true

	if som_sucesso:
		som_sucesso.play()

	emit_signal("puzzle_concluido")
	set_interacao(false) # Desativa o puzzle permanentemente.
