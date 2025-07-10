# puzzle_activation.gd
extends Area2D

# Crie uma referência para o puzzle que esta área vai controlar.
# Arraste o nó do puzzle (puzzle_forma_sequencia) para este campo no Inspetor.
@export var puzzle_node : Node

# Opcional: Uma referência para um Label que mostrará a dica.
@export var hint_label : Label

func _ready():
	# Garante que a dica comece escondida
	if hint_label:
		hint_label.visible = false

func _on_body_entered(body):
	# Verifica se quem entrou é o jogador
	if body.is_in_group("player") and puzzle_node:
		# Verifica se o puzzle já foi resolvido
		var puzzle_resolvido = false
		if puzzle_node.has_method("get") and puzzle_node.get("puzzle_resolvido_flag"):
			puzzle_resolvido = true
		elif puzzle_node.has_method("get") and puzzle_node.get("puzzle_resolvido"):
			puzzle_resolvido = true
		
		print("DEBUG: Puzzle resolvido = ", puzzle_resolvido, " para puzzle: ", puzzle_node.name)
		
		if not puzzle_resolvido:
			print("Jogador entrou na área, ativando puzzle.")
			if puzzle_node.has_method("set_interacao"):
				puzzle_node.set_interacao(true)
			if hint_label:
				hint_label.text = "Pressione [E] para interagir."
				hint_label.visible = true
		else:
			print("Puzzle já foi resolvido!")
			if hint_label:
				hint_label.text = "Puzzle já resolvido!"
				hint_label.visible = true

func _on_body_exited(body):
	# Verifica se quem saiu é o jogador
	if body.is_in_group("player") and puzzle_node:
		# Verifica se o puzzle já foi resolvido
		var puzzle_resolvido = false
		if puzzle_node.has_method("get") and puzzle_node.get("puzzle_resolvido_flag"):
			puzzle_resolvido = true
		elif puzzle_node.has_method("get") and puzzle_node.get("puzzle_resolvido"):
			puzzle_resolvido = true
		
		if not puzzle_resolvido:
			print("Jogador saiu da área, desativando puzzle.")
			if puzzle_node.has_method("set_interacao"):
				puzzle_node.set_interacao(false)
		
		if hint_label:
			hint_label.visible = false
