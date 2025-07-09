# grid_slot.gd
extends Area2D

# Defina no inspetor qual a forma correta para este slot (ex: "circulo", "quadrado")
@export var forma_correta: String = ""

var peca_atual = null # Guarda a referência da peça que está no slot
