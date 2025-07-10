extends Area2D

signal peca_alterada

@export var id_peca_atual: int = 0
@export var id_peca_correta: int = 0
@onready var sprite = $Sprite2D

func _ready():
	input_pickable = true
	_update_sprite()
	# Debug temporário: verificar se id_peca_correta está definido corretamente
	print("Peça inicializada - ID correto: ", id_peca_correta, " Posição: ", global_position)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var total_frames = sprite.hframes * sprite.vframes
		id_peca_atual = (id_peca_atual + 1) % total_frames
		_update_sprite()
		_update_feedback()
		emit_signal("peca_alterada")

func _update_sprite():
	sprite.frame = id_peca_atual

func _update_feedback():
	# Feedback simples: muda a cor da própria peça
	if id_peca_atual == id_peca_correta:
		sprite.modulate = Color(0, 1, 0, 1)  # Verde = correto
		print("Feedback: Peça ", id_peca_atual, " CORRETA (verde)")
	else:
		sprite.modulate = Color(1, 1, 1, 1)  # Branco = normal
		print("Feedback: Peça ", id_peca_atual, " incorreta (branco), deveria ser ", id_peca_correta)

func set_interativo(ativo: bool):
	input_pickable = ativo
	
	# Quando desativar, volta ao normal
	if not ativo:
		sprite.modulate = Color(1, 1, 1, 1)
	else:
		# Quando ativar, atualiza o feedback baseado no estado atual
		_update_feedback()
