# puzzle_quebra_cabeca.gd (Versão Simplificada SEM BORDAS)
extends Node2D

signal puzzle_concluido

var puzzle_resolvido_flag = false

# --- Referências de Nós ---
@onready var slots_container = $SlotsContainer
@onready var som_sucesso = $AudioStreamPlayer

func _ready():
	# Conecta o sinal 'peca_alterada' de cada slot à função de verificação.
	for slot in slots_container.get_children():
		if slot.has_signal("peca_alterada"):
			slot.peca_alterada.connect(verificar_solucao)
		
		# Define o id correto para cada slot pelo seu nome (ex: Slot_0_0, Slot_1_2)
		var slot_name_parts = slot.name.split("_")
		if slot_name_parts.size() == 3: # Garante que o nome do slot está correto
			var row = int(slot_name_parts[1])
			var col = int(slot_name_parts[2])
			slot.id_peca_correta = row * 3 + col
			print("DEBUG: Slot ", slot.name, " configurado com id_peca_correta = ", slot.id_peca_correta)
		else:
			print("ERRO: O slot '", slot.name, "' não está no formato 'Slot_linha_coluna'!")
	
	# Embaralha as peças para evitar que comecem na posição correta
	embaralhar_pecas()

# Função para embaralhar as peças no início
func embaralhar_pecas():
	print("Embaralhando peças...")
	for slot in slots_container.get_children():
		if slot.peca:
			# Define uma posição aleatória diferente da correta
			var posicao_aleatoria = randi() % 9
			while posicao_aleatoria == slot.id_peca_correta:
				posicao_aleatoria = randi() % 9
			slot.peca.id_peca_atual = posicao_aleatoria
			slot.peca._update_sprite()
			print("Peça em ", slot.name, " iniciada com id_peca_atual = ", slot.peca.id_peca_atual)


# Função chamada toda vez que uma peça é alterada.
func verificar_solucao():
	if puzzle_resolvido_flag:
		print("DEBUG: Verificação pulada - puzzle já foi resolvido")
		return

	print("DEBUG: Iniciando verificação de solução...")
	var pecas_corretas = 0
	var total_slots = slots_container.get_children().size()

	for slot in slots_container.get_children():
		print("DEBUG: Slot:", slot.name, "id_peca_atual:", slot.id_peca_atual, "id_peca_correta:", slot.id_peca_correta)
		if slot.id_peca_atual == slot.id_peca_correta:
			pecas_corretas += 1

	print("DEBUG: Pecas corretas:", pecas_corretas, "/", total_slots)

	if pecas_corretas == total_slots:
		print("DEBUG: Puzzle resolvido! Chamando resolver_puzzle...")
		call_deferred("resolver_puzzle")
	else:
		print("DEBUG: Puzzle ainda não resolvido")

# Ativa ou desativa a interatividade do puzzle todo.
func set_interacao(ativa: bool):
	if puzzle_resolvido_flag:
		return

	for slot in slots_container.get_children():
		slot.set_interativo(ativa)
	
	# Se estiver ativando a interação, atualiza ddddddddddddddddddddddsdapenas feedbacks das peças
	if ativa:
		for slot in slots_container.get_children():
			if slot.has_method("_update_feedback"):
				slot._update_feedback()
	else:
		# Se estiver desativando, volta todas as peças ao normal
		for slot in slots_container.get_children():
			if slot.peca:
				slot.peca.sprite.modulate = Color(1, 1, 1, 1)

# Função chamada quando o puzzle é resolvido.
func resolver_puzzle():
	if puzzle_resolvido_flag:
		print("DEBUG: resolver_puzzle chamado, mas puzzle já estava resolvido")
		return
		
	print("DEBUG: RESOLVENDO PUZZLE DA JANELA!")
	print("!!! PARABÉNS! PUZZLE DA JANELA RESOLVIDO! !!!")
	puzzle_resolvido_flag = true

	# Desativa a interação de todas as peças
	for slot in slots_container.get_children():
		slot.set_interativo(false)

	# Toca o som de sucesso
	if som_sucesso:
		som_sucesso.play()
	
	# Emite o sinal de puzzle concluído
	emit_signal("puzzle_concluido")
	print("DEBUG: Sinal puzzle_concluido emitido")
