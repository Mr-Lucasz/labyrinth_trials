# puzzle_forma_sequencia.gd
extends Node2D

signal puzzle_concluido

var puzzle_resolvido_flag = false

@onready var slots_container = $GridSlots
# Certifique-se de que o nó de áudio na sua cena tenha exatamente este nome.
@onready var som_sucesso = $AudioStreamPlayer 

func _ready():
	# Esconde todos os feedbacks e conecta os sinais ao iniciar a cena.
	for slot in slots_container.get_children():
		# Conecta o sinal de cada peça para verificar a solução.
		var peca_interativa = encontrar_peca_no_slot(slot)
		if peca_interativa:
			peca_interativa.forma_alterada.connect(verificar_solucao)

		# Garante que o feedback comece invisível.
		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")
		if feedback_sprite:
			feedback_sprite.visible = false

# --- NENHUMA ALTERAÇÃO NECESSÁRIA ATÉ AQUI ---

func encontrar_peca_no_slot(slot_node):
	for child in slot_node.get_children():
		# Assumindo que sua peça interativa herda de Area2D.
		if child is Area2D:
			return child
	return null

# --- FUNÇÃO MODIFICADA ---
func verificar_solucao():
	if puzzle_resolvido_flag:
		return

	var pecas_corretas = 0
	
	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		var feedback_sprite = slot.get_node_or_null("FeedbackSprite")

		# Pula a iteração se o slot não tiver a peça ou o feedback.
		if not peca_interativa or not feedback_sprite:
			continue

		# Verifica se a forma na peça é a forma correta para o slot.
		if peca_interativa.forma_atual == slot.forma_correta:
			# --- LÓGICA DE FEEDBACK CORRIGIDA ---
			feedback_sprite.visible = true       # 1. Torna o feedback VISÍVEL.
			feedback_sprite.modulate.a = 0.5     # 2. Define a TRANSPARÊNCIA (0.5 = 50%).
			pecas_corretas += 1
		else:
			# Se a forma estiver incorreta, o feedback fica invisível.
			feedback_sprite.visible = false

	# Verifica se todas as peças estão corretas.
	if pecas_corretas == slots_container.get_child_count():
		# Usa 'call_deferred' para garantir que a última atualização visual ocorra
		# antes de desativar tudo.
		call_deferred("puzzle_resolvido")

# --- NENHUMA ALTERAÇÃO NECESSÁRIA EM set_interacao ---
func set_interacao(ativa: bool):
	if puzzle_resolvido_flag:
		return

	process_mode = Node.PROCESS_MODE_INHERIT if ativa else Node.PROCESS_MODE_DISABLED
	
	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		if peca_interativa:
			peca_interativa.set_interativo(ativa)
		
		# Esconde todos os feedbacks quando o jogador sai da área de interação.
		if not ativa:
			var feedback_sprite = slot.get_node_or_null("FeedbackSprite")
			if feedback_sprite:
				feedback_sprite.visible = false
			
	if ativa:
		# Ao entrar na área, reavalia a solução.
		verificar_solucao()

# --- FUNÇÃO MODIFICADA ---
func puzzle_resolvido():
	if puzzle_resolvido_flag:
		return
		
	print("PARABÉNS! PUZZLE RESOLVIDO!")
	puzzle_resolvido_flag = true

	# Toca o som de sucesso.
	if som_sucesso:
		som_sucesso.play()

	# Emite o sinal para o mapa (level2.gd) remover a porta.
	emit_signal("puzzle_concluido")
	
	# Desativa a interação com as peças permanentemente.
	for slot in slots_container.get_children():
		var peca_interativa = encontrar_peca_no_slot(slot)
		if peca_interativa:
			peca_interativa.set_interativo(false)
