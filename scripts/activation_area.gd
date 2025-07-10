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
	# Verifica se quem entrou é o jogador e se o puzzle ainda não foi resolvido
	if body.is_in_group("player") and puzzle_node and not puzzle_node.get("puzzle_resolvido_flag"):
		print("Jogador entrou na área, ativando puzzle.")
		puzzle_node.set_interacao(true)
		if hint_label:
			hint_label.text = "Pressione [E] para interagir." # Ou a tecla que preferir
			hint_label.visible = true

func _on_body_exited(body):
	# Verifica se quem saiu é o jogador
	if body.is_in_group("player") and puzzle_node:
		print("Jogador saiu da área, desativando puzzle.")
		puzzle_node.set_interacao(false)
		if hint_label:
			hint_label.visible = false
