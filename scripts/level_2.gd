# level2.gd (Sem alterações necessárias)
extends Node2D

# Crie uma referência para a instância do puzzle no inspetor
@export var puzzle_formas : Node
@export var puzzle_cores: Node  # Adicione esta linha

func _ready():
	# Conecta o sinal do puzzle a uma função neste script
	# Esta linha agora vai funcionar porque o sinal "puzzle_concluido" existe.
	puzzle_formas.puzzle_concluido.connect(_on_puzzle_formas_concluido)
	
	# Conecta o novo puzzle de cores
	if puzzle_cores:
		puzzle_cores.puzzle_concluido.connect(_on_puzzle_cores_concluido)

func _on_puzzle_formas_concluido():
	print("Puzzle de formas concluído!")

func _on_puzzle_cores_concluido():
	print("Puzzle de cores concluído!")
	# Aqui você pode abrir uma porta, dar uma recompensa, etc.
