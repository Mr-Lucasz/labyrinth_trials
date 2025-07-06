extends Control

@onready var nickname_window = $NicknameWindow
@onready var nickname_edit = $NicknameWindow/VBoxContainer/NicknameEdit

# Referências aos botões (você pode precisar ajustar os caminhos baseado na sua estrutura de cena)
var carregar_button: Button
# Esta função será chamada quando o botão "Novo Jogo" for pressionado.
# Ela irá carregar a cena da primeira fase do seu jogo.
# ATENÇÃO: Substitua "res://caminho/para/sua/fase1.tscn" pelo caminho real da sua cena da Fase 1.
func _on_button_novo_pressed():
	nickname_window.popup_centered()

# Esta função será chamada pelo botão "Carregar Jogo".
func _on_button_carregar_pressed():
	if not Global.has_save_file():
		print("Nenhum jogo salvo encontrado.")
		return
	
	var save_data = Global.load_game_data()
	if save_data:
		# Restaura os dados do jogador
		Global.player_nickname = save_data["nickname"]
		Global.fase_atual = save_data["fase_atual"]
		Global.checkpoint_alcancado = save_data["checkpoint_alcancado"]
		Global.puzzle_atual = save_data.get("puzzle_atual", 3)
		Global.puzzles_completados = save_data.get("puzzles_completados", 2)
		
		# Também atualiza o PlayerData para compatibilidade
		PlayerData.nickname = Global.player_nickname
		
		print("Jogo carregado! Retornando ao checkpoint...")
		# Carrega a fase do jogo no ponto do checkpoint
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	else:
		print("Erro ao carregar o jogo.")

# Esta função será chamada pelo botão "Ranking".
func _on_button_ranking_pressed():
	# A lógica para mostrar a tela de Ranking virá aqui.
	print("Botão Ranking Pressionado!")

# Esta função será chamada pelo botão "Sobre".
func _on_button_sobre_pressed():
	# A lógica para mostrar a tela com os nomes dos desenvolvedores virá aqui.
	print("Botão Sobre Pressionado!")

func _ready():
	nickname_window.hide() # Começa invisível
	
	# Busca o botão carregar na cena (ajuste o caminho conforme sua estrutura)
	carregar_button = find_button_by_name("carregar") # Tentativa de encontrar automaticamente
	
	# Atualiza o estado do botão carregar
	update_carregar_button_state()

func find_button_by_name(button_name: String) -> Button:
	# Função auxiliar para encontrar um botão pelo nome ou texto
	return find_button_recursive(self, button_name.to_lower())

func find_button_recursive(node: Node, button_name: String) -> Button:
	if node is Button:
		var button = node as Button
		if button.name.to_lower().contains(button_name) or button.text.to_lower().contains(button_name):
			return button
	
	for child in node.get_children():
		var result = find_button_recursive(child, button_name)
		if result:
			return result
	
	return null

func update_carregar_button_state():
	# Verifica se o botão carregar existe na cena
	if carregar_button:
		if Global.has_save_file():
			carregar_button.disabled = false
			carregar_button.modulate = Color.WHITE
			print("Save encontrado! Botão Carregar habilitado.")
		else:
			carregar_button.disabled = true
			carregar_button.modulate = Color(0.5, 0.5, 0.5)
			print("Nenhum save encontrado. Botão Carregar desabilitado.")
	else:
		print("Botão Carregar não encontrado na cena.")

# Função chamada quando o botão "Novo Jogo" é pressionado
func _on_new_game_button_pressed():
	print("Botão Novo clicado!")
	nickname_window.popup_centered() # Exibe centralizado
	
# Função chamada quando o botão de confirmação do apelido é pressionado
func _on_confirm_button_pressed():
	var player_nickname = nickname_edit.text.strip_edges()
	if player_nickname.is_empty():
		print("O apelido não pode estar vazio!")
		return
	
	# Atualiza ambos os sistemas de dados
	PlayerData.nickname = player_nickname
	Global.player_nickname = player_nickname
	Global.reset_game_data() # Reseta os dados para um novo jogo
	Global.player_nickname = player_nickname # Mantém o nickname
	
	nickname_window.hide()
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	print("Novo jogo iniciado com apelido: ", player_nickname)

func _on_nickname_window_close_requested() -> void:
	nickname_window.hide()
