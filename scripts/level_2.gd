# level2.gd (Sem alterações necessárias)
extends Node2D

# Crie uma referência para a instância do puzzle no inspetor
@export var puzzle_formas : Node
# Crie uma referência para a porta/barreira que deve sumir
@export var porta_fase_2 : Node

func _ready():
	# Conecta o sinal do puzzle a uma função neste script
	# Esta linha agora vai funcionar porque o sinal "puzzle_concluido" existe.
	puzzle_formas.puzzle_concluido.connect(_on_puzzle_formas_concluido)

func _on_puzzle_formas_concluido():
	print("Mapa recebeu a informação de que o puzzle foi concluído!")
	# Ação de recompensa: remove a porta ou a torna inativa
	porta_fase_2.queue_free() # ou porta_fase_2.visible = false
