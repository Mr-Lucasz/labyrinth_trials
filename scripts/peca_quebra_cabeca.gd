extends Area2D

signal peca_alterada

@export var id_peca_atual: int = 0
@export var id_peca_correta: int = 0
@onready var sprite = $Sprite2D
@onready var feedback_sprite = $FeedbackSprite

func _ready():
	input_pickable = true
	_update_sprite()
	_update_feedback()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var total_frames = sprite.hframes * sprite.vframes
		id_peca_atual = (id_peca_atual + 1) % total_frames
		_update_sprite()
		_update_feedback()
		emit_signal("peca_alterada")

func _update_sprite():
	sprite.frame = id_peca_atual
	_update_feedback()

func _update_feedback():
	if id_peca_atual == id_peca_correta:
		feedback_sprite.visible = true
		feedback_sprite.modulate = Color(0,1,0,0.5) # verde com transparência
	else:
		feedback_sprite.visible = false

func set_interativo(ativo: bool):
	input_pickable = ativo
