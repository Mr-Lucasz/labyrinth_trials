extends Node

# Script para detectar a conclusão dos puzzles e comunicar com o Level1Manager

signal puzzle_completed(puzzle_number: int)

# Referências para os diferentes sistemas de puzzle
var slots: Array[Area2D] = []
var pickable_items: Array[StaticBody2D] = []
var puzzle_1_completed: bool = false
var puzzle_2_completed: bool = false
var puzzle_3_completed: bool = false

# Referência ao Level1Manager
var level_manager: Node2D

func _ready():
	# Conecta ao Level1Manager
	level_manager = get_parent()
	if level_manager and level_manager.has_method("on_puzzle_completed"):
		puzzle_completed.connect(level_manager.on_puzzle_completed)
	
	# Coleta todos os slots e itens da cena
	collect_puzzle_elements()
	
	# Monitora o progresso dos puzzles
	monitor_puzzles()

func collect_puzzle_elements():
	# Coleta todos os slots e itens pickable da cena
	slots = []
	pickable_items = []
	
	# Busca recursivamente por slots e itens
	find_puzzle_elements(get_tree().current_scene)
	
	print("PuzzleManager: Encontrados ", slots.size(), " slots e ", pickable_items.size(), " itens")

func find_puzzle_elements(node: Node):
	# Função recursiva para encontrar elementos do puzzle
	if node.has_method("accepts") and node.get("slot_type") != null:
		slots.append(node)
	elif node.get("item_type") != null:
		pickable_items.append(node)
	
	for child in node.get_children():
		find_puzzle_elements(child)

func monitor_puzzles():
	# Inicia o monitoramento dos puzzles
	# Verificação periódica do estado dos puzzles
	var timer = Timer.new()
	timer.wait_time = 1.0  # Verifica a cada segundo
	timer.timeout.connect(_check_puzzle_completion)
	add_child(timer)
	timer.start()

func _check_puzzle_completion():
	# Verifica se algum puzzle foi completado
	if not puzzle_1_completed:
		check_puzzle_1()
	elif not puzzle_2_completed:
		check_puzzle_2()
	elif not puzzle_3_completed:
		check_puzzle_3()

func check_puzzle_1():
	# Puzzle 1: Velocidade e Tempo de Reação
	# Este é mais conceitual - pode ser disparado por outros eventos
	# Por enquanto, vamos simular baseado em movimento do jogador
	
	var jogador = get_tree().get_first_node_in_group("jogador")
	if jogador and jogador.global_position.x > 500:  # Exemplo: jogador se moveu para certa posição
		complete_puzzle(1)

func check_puzzle_2():
	print("[PuzzleManager] check_puzzle_2 chamado")
	# Puzzle 2: Rotação
	# Verifica se formas estão nos slots corretos
	var shapes_in_correct_slots = 0
	var total_shape_slots = 0
	for slot in slots:
		if slot.slot_type in ["Triangulo", "Circulo", "Quadrado"]:
			total_shape_slots += 1
			if slot.filled:
				shapes_in_correct_slots += 1
	print("[PuzzleManager] total_shape_slots=", total_shape_slots, ", shapes_in_correct_slots=", shapes_in_correct_slots)
	if total_shape_slots > 0 and shapes_in_correct_slots >= total_shape_slots:
		print("[PuzzleManager] Todos os slots de forma preenchidos. Chamando complete_puzzle(2)")
		complete_puzzle(2)

func check_puzzle_3():
	# Puzzle 3: Ordem Numérica
	# Verifica se números estão na ordem correta
	var number_slots = []
	
	for slot in slots:
		if slot.slot_type in ["1", "2", "3", "numero_um", "numero_dois", "numero_tres"]:
			number_slots.append(slot)
	
	# Ordena por posição X para verificar ordem
	number_slots.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	
	var correct_order = true
	for i in range(number_slots.size()):
		var expected_number = str(i + 1)
		var slot = number_slots[i]
		
		# Verifica se o slot tem o número correto
		if not slot.filled or not is_correct_number_in_slot(slot, expected_number):
			correct_order = false
			break
	
	if correct_order and number_slots.size() >= 3:
		complete_puzzle(3)

func is_correct_number_in_slot(slot: Area2D, _expected: String) -> bool:
	# Verifica se o número correto está no slot
	# Esta função pode precisar ser ajustada baseado na implementação específica
	return slot.filled  # Simplificado por enquanto

func complete_puzzle(puzzle_number: int):
	print("=== PUZZLE ", puzzle_number, " COMPLETADO! === (complete_puzzle)")
	match puzzle_number:
		1:
			puzzle_1_completed = true
		2:
			puzzle_2_completed = true
		3:
			puzzle_3_completed = true
	print("[PuzzleManager] Emitindo sinal puzzle_completed para puzzle ", puzzle_number)
	# Emite o sinal para o Level1Manager
	puzzle_completed.emit(puzzle_number)

# Funções públicas para serem chamadas por outros scripts
func force_complete_puzzle(puzzle_number: int):
	# Permite que outros scripts forcem a conclusão de um puzzle
	complete_puzzle(puzzle_number)

func get_puzzle_status() -> Dictionary:
	return {
		"puzzle_1": puzzle_1_completed,
		"puzzle_2": puzzle_2_completed,
		"puzzle_3": puzzle_3_completed
	}

func reset_puzzles():
	puzzle_1_completed = false
	puzzle_2_completed = false
	puzzle_3_completed = false
