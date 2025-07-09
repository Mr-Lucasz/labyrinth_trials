# peca_arrastavel.gd
extends Area2D

# Defina no inspetor qual forma esta peça representa (ex: "circulo")
@export var tipo_forma: String = ""

signal peca_solta(peca)

var is_dragging = false
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position

# Esta função é chamada quando um clique do mouse ocorre na área de colisão da peça
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
		else:
			is_dragging = false
			# Quando soltar, verifica se está sobre um slot válido
			var areas_sobrepostas = get_overlapping_areas()
			var slot_valido = null
			for area in areas_sobrepostas:
				if area is Area2D and "forma_correta" in area: # Verifica se é um grid_slot
					slot_valido = area
					break

			if slot_valido:
				global_position = slot_valido.global_position # Encaixa a peça no slot
				slot_valido.peca_atual = self
			else:
				global_position = start_position # Retorna à posição inicial

			emit_signal("peca_solta", self)


func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()
