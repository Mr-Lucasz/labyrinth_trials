extends Camera2D

# Crie uma variável para arrastar o seu mapa para ela no editor.
@export var target_map: NodePath

func _ready():
	# Verifica se o alvo foi definido
	if target_map.is_empty():
		print("ERRO DE CÂMERA: O mapa alvo (target_map) não foi definido!")
		return
	 
	var map_sprite = get_node_or_null(target_map) as Sprite2D
	if not map_sprite:
		print("ERRO DE CÂMERA: O nó alvo não é um Sprite2D.")
		return

	# Espera um frame para garantir que tudo foi carregado e dimensionado
	await get_tree().process_frame

	# Pega o tamanho da imagem do mapa e o tamanho da janela do jogo
	var map_rect = map_sprite.get_rect()
	var window_size = get_viewport_rect().size

	# 1. Centraliza a câmera no meio exato do mapa
	position = map_rect.position + (map_rect.size / 2)

	# 2. Calcula o fator de zoom necessário para o mapa caber na tela
	var zoom_x = map_rect.size.x / window_size.x
	var zoom_y = map_rect.size.y / window_size.y
	
	# Usa o maior dos dois fatores de zoom para garantir que o mapa inteiro seja visível
	zoom = Vector2(max(zoom_x, zoom_y), max(zoom_x, zoom_y))
