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
		# Atenção: Seus slots na imagem estão nomeados como Slot_0_0, Slot_0_1, etc.
		# Isso não forma uma grade 3x3. Renomeie-os para:
		# Slot_0_0, Slot_0_1, Slot_0_2
		# Slot_1_0, Slot_1_1, Slot_1_2
		# Slot_2_0, Slot_2_1, Slot_2_2
		var slot_name_parts = slot.name.split("_")
		if slot_name_parts.size() == 3: # Garante que o nome do slot está correto
			var row = int(slot_name_parts[1])
			var col = int(slot_name_parts[2])
			slot.id_peca_correta = row * 3 + col
		else:
			print("ERRO: O slot '", slot.name, "' não está no formato 'Slot_linha_coluna'!")


# Função chamada toda vez que uma peça é alterada.
func verificar_solucao():
	if puzzle_resolvido_flag:
		return

	var pecas_corretas = 0
	var total_slots = slots_container.get_children().size()

	for slot in slots_container.get_children():
		print("Slot:", slot.name, "id_peca_atual:", slot.id_peca_atual, "id_peca_correta:", slot.id_peca_correta)
		if slot.id_peca_atual == slot.id_peca_correta:
			pecas_corretas += 1

	print("Pecas corretas:", pecas_corretas, "/", total_slots)

	if pecas_corretas == total_slots:
		call_deferred("resolver_puzzle")

# Ativa ou desativa a interatividade do puzzle todo.
func set_interacao(ativa: bool):
	if puzzle_resolvido_flag:
		return

	for slot in slots_container.get_children():
		slot.set_interativo(ativa)

# Função chamada quando o puzzle é resolvido.
func resolver_puzzle():
	if puzzle_resolvido_flag:
		return
		
	print("!!! PARABÉNS! PUZZLE DA JANELA RESOLVIDO! !!!")
	puzzle_resolvido_flag = true

	if som_sucesso:
		som_sucesso.play()

	emit_signal("puzzle_concluido")
	set_interacao(false)
