# slot_quebra_cabeca.gd
extends Node2D

signal peca_alterada

@onready var peca = $Peca

func _ready():
	if peca:
		peca.peca_alterada.connect(_on_peca_alterada)

func _on_peca_alterada():
	emit_signal("peca_alterada")

func set_interativo(ativo: bool):
	if peca:
		peca.set_interativo(ativo)

func _update_feedback():
	if peca and peca.has_method("_update_feedback"):
		peca._update_feedback()

@export var id_peca_correta: int = 0
@export var id_peca_atual: int:
	get:
		return peca.id_peca_atual if peca else -1
