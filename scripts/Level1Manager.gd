extends Node2D

# Variáveis de controle do puzzle
@export var puzzle_atual: int = 1
var puzzles_completados: int = 0
var checkpoint_salvo: bool = false

# Referências para gerenciar o jogador (ajuste conforme sua estrutura)
@onready var sair_button = $ButtonSair  
@onready var jogador = get_node_or_null("Jogador")

# PuzzleManager para detectar conclusão dos puzzles
var puzzle_manager: Node

func _ready():
	print("Fase 1 iniciada!")
	
	# Tentar localizar o jogador na cena
	jogador = get_node_or_null("Jogador")
	if not jogador:
		jogador = get_node_or_null("Player")
	
	# Inicializar dados do jogador se encontrado
	if jogador:
		print("Jogador encontrado na cena")
		
		# Verificar se estamos carregando um save ou começando novo jogo
		if Global.player_nickname != "":
			# Tentar carregar dados de save
			if Global.checkpoint_alcancado:
				print("Checkpoint alcançado, carregando estado...")
				jogador.player_name = Global.player_nickname
				jogador.load_game(Global.player_nickname)
				
				# Restaurar estado visual (checkpoints, mensagens, etc.)
				_update_visual_state_from_save()
			else:
				# Novo jogo com nickname definido
				jogador.player_name = Global.player_nickname
				print("Novo jogo iniciado para: " + Global.player_nickname)
		else:
			print("Aviso: Jogador sem nickname definido")
	else:
		print("Aviso: Jogador não encontrado na cena")
		
	# Inicializar gerenciadores de puzzles
	puzzle_manager = get_node_or_null("PuzzleManager")
	
	# Cria e adiciona o PuzzleManager se não existir na cena
	if not puzzle_manager:
		puzzle_manager = preload("res://scripts/PuzzleManager.gd").new()
		add_child(puzzle_manager)
	
	# Verifica se o jogo foi carregado de um checkpoint
	
	if Global.checkpoint_alcancado:
		start_from_checkpoint()
	else:
		start_new_game()
		

	# Conecta sinais se necessário
	connect_puzzle_signals()

func start_new_game():
	print("Iniciando novo jogo...")
	puzzle_atual = 1
	puzzles_completados = 0
	checkpoint_salvo = false
	
	# Posiciona o jogador no início da fase
	position_player_at_start()
	
	# Inicia com o primeiro puzzle (Velocidade e Tempo de Reação)
	load_speed_reaction_puzzle()

func start_from_checkpoint():
	print("Carregando do checkpoint...")
	# Se há checkpoint, inicia no terceiro puzzle (Ordem Numérica)
	puzzle_atual = Global.puzzle_atual
	puzzles_completados = Global.puzzles_completados
	checkpoint_salvo = true
	
	# Posiciona o jogador no início do terceiro desafio
	position_player_at_checkpoint()
	
	# Carrega o puzzle correto baseado no progresso salvo
	match puzzle_atual:
		1:
			load_speed_reaction_puzzle()
		2:
			load_rotation_puzzle()
		3:
			load_numerical_order_puzzle()
		_:
			complete_phase()

func position_player_at_start():
	# Posiciona o jogador no início da fase
	if jogador:
		# Ajuste as coordenadas conforme necessário
		jogador.position = Vector2(2238.0, 23) # Exemplo de posição inicial
		print("Jogador posicionado no início da fase")

func position_player_at_checkpoint():
	# Posiciona o jogador no início do terceiro puzzle
	if jogador:
		# Ajuste as coordenadas conforme necessário para o checkpoint
		jogador.position = Vector2(2238.0, -77.0) # Exemplo de posição do checkpoint
		print("Jogador posicionado no checkpoint (terceiro puzzle)")

func connect_puzzle_signals():
	# Conecta sinais dos puzzles se eles existirem
	# Exemplo: se você tiver nós específicos para cada puzzle
	pass

# Função chamada quando um puzzle é completado
func on_puzzle_completed(puzzle_number: int):
	print("Puzzle ", puzzle_number, " completado!")
	puzzles_completados += 1
	
	# Atualiza as variáveis globais
	Global.puzzles_completados = puzzles_completados
	
	# Verifica se completou o segundo puzzle (momento do checkpoint)
	if puzzle_number == 2 and not checkpoint_salvo:
		save_checkpoint()
	
	# Avança para o próximo puzzle
	advance_to_next_puzzle()

func save_checkpoint():
	print("=== CHECKPOINT ALCANÇADO ===")
	Global.checkpoint_alcancado = true
	Global.puzzle_atual = 3 # Próximo puzzle após o checkpoint
	Global.save_game_at_checkpoint()
	checkpoint_salvo = true
	print("Progresso salvo automaticamente!")

func advance_to_next_puzzle():
	puzzle_atual += 1
	Global.puzzle_atual = puzzle_atual
	
	# Lógica para carregar o próximo puzzle
	match puzzle_atual:
		2:
			load_rotation_puzzle()
		3:
			load_numerical_order_puzzle()
		_:
			complete_phase()

# Implementações dos puzzles (ajuste conforme sua estrutura)
func load_speed_reaction_puzzle():
	print("=== INICIANDO PUZZLE 1: VELOCIDADE E TEMPO DE REAÇÃO ===")
	# Aqui você implementaria a lógica específica do primeiro puzzle
	# Por exemplo: ativar objetos específicos, configurar timers, etc.
	
	# O PuzzleManager detectará automaticamente quando este puzzle for completado

func load_rotation_puzzle():
	print("=== INICIANDO PUZZLE 2: ROTAÇÃO ===")
	# Aqui você implementaria a lógica específica do segundo puzzle
	# Por exemplo: mostrar objetos rotativos, configurar controles, etc.
	
	# O PuzzleManager detectará automaticamente quando este puzzle for completado

func load_numerical_order_puzzle():
	print("=== INICIANDO PUZZLE 3: ORDEM NUMÉRICA ===")
	# Aqui você implementaria a lógica específica do terceiro puzzle
	# Por exemplo: mostrar números, configurar sistema de ordenação, etc.
	
	# O PuzzleManager detectará automaticamente quando este puzzle for completado

func complete_phase():
	print("=== FASE 1 COMPLETADA! ===")
	
	# Aqui você pode implementar:
	# - Tela de parabéns
	# - Estatísticas do jogador
	# - Transição para próxima fase
	# - Salvar progresso final
	
	# Por enquanto, volta ao menu principal
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Funções auxiliares para serem chamadas pelos sistemas de puzzle
func trigger_puzzle_completion(puzzle_number: int):
	# Função que pode ser chamada por outros scripts quando um puzzle é realmente completado
	on_puzzle_completed(puzzle_number)

func get_current_puzzle() -> int:
	return puzzle_atual

func get_puzzles_completed() -> int:
	return puzzles_completados

func is_checkpoint_reached() -> bool:
	return checkpoint_salvo

func _on_sair_button_pressed() -> void:
	print("Voltando ao menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# A conexão do sinal 'pressed' do ButtonSair já é feita pela cena (Level1.tscn)
# Não conecte novamente por código para evitar erro de conexão duplicada
# if sair_button:

# Atualiza o estado visual da cena baseado nos dados carregados
func _update_visual_state_from_save() -> void:
	# Atualizar estado dos puzzles baseado nos valores carregados
	if jogador:
		# Atualizar contagem de puzzles completados
		puzzles_completados = int(jogador.shape_completed) + int(jogador.number_completed) + int(jogador.arrow_completed)
		
		# Atualizar estado de checkpoint
		checkpoint_salvo = jogador.checkpoint_reached
		
		print("Estado visual atualizado: %d puzzles completados, checkpoint: %s" % 
			[puzzles_completados, "Sim" if checkpoint_salvo else "Não"])
		
		# Aqui você pode adicionar atualizações visuais adicionais:
		# - Desativar puzzles já completados
		# - Mover objetos para suas posições corretas
		# - Atualizar mensagens de UI
		# etc.
