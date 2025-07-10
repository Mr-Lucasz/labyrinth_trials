# forma_interativa.gd
extends Area2D

signal forma_alterada
enum Formas { CIRCULO, QUADRADO, TRIANGULO }

@onready var sprite = $Sprite2D

# --- LINHA MODIFICADA ---
# Adicionamos um "setter" que será executado sempre que a variável for alterada.
@export var forma_atual: Formas = Formas.CIRCULO:
	set(value):
		forma_atual = value
		# Garante que o sprite seja atualizado, mesmo que a cena já tenha iniciado.
		if sprite:
			sprite.frame = forma_atual
# -------------------------

func _ready():
	# Esta linha continua importante para definir o estado inicial se o script
	# for executado de forma independente.
	sprite.frame = forma_atual
	input_pickable = true

# ... (o resto do seu script _input_event e set_interativo continua igual) ...
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# A lógica do setter não afeta o ciclo de cliques.
		# O clique vai chamar o setter automaticamente.
		self.forma_atual = (forma_atual + 1) % 3
		emit_signal("forma_alterada")

func set_interativo(ativo: bool):
	input_pickable = ativo
