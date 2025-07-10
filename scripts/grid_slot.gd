# grid_slot.gd
extends Area2D

# O enum e a forma correta continuam como antes.
const Formas = preload("res://scripts/forma_interativa.gd").Formas
@export var forma_correta: Formas = Formas.CIRCULO

# --- CÓDIGO NOVO ---

# 1. Nova propriedade para definir o estado inicial da peça no Inspetor.
@export var forma_inicial: Formas = Formas.CIRCULO

# 2. Referência para o nó da peça que está dentro desta cena.
#    Use o nome exato do nó na sua cena grid_slot.tscn.
@onready var peca_interativa = $forma_interativa

func _ready():
	# 3. No início, pega o valor de "forma_inicial" e passa para a peça.
	if peca_interativa:
		peca_interativa.forma_atual = forma_inicial

# --------------------
