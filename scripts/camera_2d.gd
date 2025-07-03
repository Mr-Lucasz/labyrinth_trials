extends Camera2D

# Configuração da câmera para mostrar o mapa inteiro
func _ready():
	# Zoom reduzido para ver o mapa completo
	zoom = Vector2(0.3, 0.3)
	
	# Centralizar na posição do mapa
	position = Vector2(1837, -1146)
	
	# Habilitar a câmera
	enabled = true

# Opcional: permitir zoom com scroll do mouse
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(0.1, 0.1)
			zoom = zoom.clamp(Vector2(0.2, 0.2), Vector2(2.0, 2.0))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(0.1, 0.1)
			zoom = zoom.clamp(Vector2(0.2, 0.2), Vector2(2.0, 2.0))
