extends Control

@onready var nickname_popup = $NicknamePopup
@onready var nickname_edit = $NicknamePopup/VBoxContainer/NicknameEdit
# Esta função será chamada quando o botão "Novo Jogo" for pressionado.
# Ela irá carregar a cena da primeira fase do seu jogo.
# ATENÇÃO: Substitua "res://caminho/para/sua/fase1.tscn" pelo caminho real da sua cena da Fase 1.
func _on_button_novo_pressed():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

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
	# Garante que o popup de apelido comece oculto
	nickname_popup.hide()

# Função chamada quando o botão "Novo Jogo" é pressionado
func _on_new_game_button_pressed():
	# Mostra o popup para o jogador inserir o apelido
	nickname_popup.show()
	
# Função chamada quando o botão de confirmação do apelido é pressionado
func _on_confirm_button_pressed():
	var player_nickname = nickname_edit.text
	
	# Verifica se o apelido não está vazio
	if player_nickname.strip_edges().is_empty():
		# Você pode adicionar um feedback visual aqui (por exemplo, um label de erro)
		print("O apelido não pode estar vazio!")
		return
		
	# Salva o apelido em um script global (Autoload)
	# Veja o passo 4 para criar o PlayerData.gd
	get_node("/root/PlayerData").nickname = player_nickname
	
	# Esconde o popup
	nickname_popup.hide()
	
	# Muda para a cena da primeira fase do jogo
	# Certifique-se de que o caminho para a sua cena de jogo está correto
	get_tree().change_scene_to_file("res://fase1.tscn") 
