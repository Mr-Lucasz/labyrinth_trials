extends Area2D

signal peca_alterada

@export var imagens: Array[Texture2D]
@export var id_peca_atual: int = 0
@onready var sprite = $Sprite2D

func _ready():
	input_pickable = true
	_update_sprite()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		id_peca_atual = (id_peca_atual + 1) % imagens.size()
		_update_sprite()
		emit_signal("peca_alterada")

func _update_sprite():
	if imagens.size() > id_peca_atual:
		sprite.texture = imagens[id_peca_atual]

func set_interativo(ativo: bool):
	input_pickable = ativo
