extends Control

@onready var nickname_window = $NicknameWindow
@onready var nickname_edit = $NicknameWindow/VBoxContainer/NicknameEdit
# Esta função será chamada quando o botão "Novo Jogo" for pressionado.
# Ela irá carregar a cena da primeira fase do seu jogo.
# ATENÇÃO: Substitua "res://caminho/para/sua/fase1.tscn" pelo caminho real da sua cena da Fase 1.
func _on_button_novo_pressed():
	nickname_window.popup_centered()

# Esta função será chamada pelo botão "Carregar Jogo".
func _on_button_carregar_pressed():
	# A lógica para carregar o jogo salvo (checkpoint) virá aqui.
	# Por enquanto, podemos apenas imprimir uma mensagem.
	print("Botão Carregar Pressionado!")
	# Você precisará verificar se existe um arquivo de save antes de habilitar este botão.

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
	PlayerData.nickname = player_nickname
	nickname_window.hide()
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	print("Apelido salvo: ", PlayerData.nickname)

func _on_nickname_window_close_requested() -> void:
	nickname_window.hide()
