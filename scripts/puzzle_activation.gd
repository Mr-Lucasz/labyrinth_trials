# puzzle_activation.gd
extends Area2D

# Arraste o nó do puzzle (PuzzleJanela) para este campo no Inspetor.
@export var puzzle_node : Node

func _on_body_entered(body):
	# Verifica se quem entrou é o jogador.
	if body.is_in_group("player"):
		print("Jogador entrou na área, ativando puzzle.")
		if puzzle_node and puzzle_node.has_method("set_interacao"):
			puzzle_node.set_interacao(true)

func _on_body_exited(body):
	# Verifica se quem saiu é o jogador.
	if body.is_in_group("player"):
		print("Jogador saiu da área, desativando puzzle.")
		if puzzle_node and puzzle_node.has_method("set_interacao"):
			puzzle_node.set_interacao(false)
