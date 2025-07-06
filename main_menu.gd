extends Control

@onready var nickname_window = $NicknameWindow
@onready var nickname_edit = $NicknameWindow/VBoxContainer/NicknameEdit
@onready var sobre_window = $SobreWindow

# Referências aos botões (você pode precisar ajustar os caminhos baseado na sua estrutura de cena)
var carregar_button: Button
# Esta função será chamada quando o botão "Novo Jogo" for pressionado.
# Ela irá carregar a cena da primeira fase do seu jogo.
# ATENÇÃO: Substitua "res://caminho/para/sua/fase1.tscn" pelo caminho real da sua cena da Fase 1.
func _on_button_novo_pressed():
	nickname_window.popup_centered()

# Esta função será chamada pelo botão "Carregar Jogo".
func _on_button_carregar_pressed():
	# Verifica se há nickname definido
	if Global.player_nickname == "":
		# Se não há nickname definido, mostra o prompt para inserir
		nickname_window.popup_centered()
		nickname_edit.placeholder_text = "Digite seu apelido para carregar o jogo"
		return
		
	if not Global.has_save_file(Global.player_nickname):
		print("Nenhum jogo salvo encontrado para: " + Global.player_nickname)
		return

	# Primeiro tenta carregar do sistema Global
	var save_data = Global.load_game_data(Global.player_nickname)
	
	if save_data:
		# Restaura os dados do jogador exatamente como estavam no checkpoint
		Global.player_nickname = save_data["nickname"]
		Global.fase_atual = save_data["fase_atual"]
		Global.checkpoint_alcancado = save_data["checkpoint_alcancado"]
		
		# Se houver um checkpoint salvo, usa os valores salvos exatamente como estão
		if Global.checkpoint_alcancado:
			# Importante: usa os dados exatos que foram salvos no checkpoint
			Global.puzzle_atual = save_data["puzzle_atual"] 
			Global.puzzles_completados = save_data["puzzles_completados"]
			print("Carregando do checkpoint: Fase %d, Puzzle %d, Puzzles completados: %d" % [Global.fase_atual, Global.puzzle_atual, Global.puzzles_completados])
		else:
			# Caso não haja checkpoint, começa do início
			Global.puzzle_atual = save_data.get("puzzle_atual", 1)
			Global.puzzles_completados = save_data.get("puzzles_completados", 0)
		
		# Também atualiza o PlayerData para compatibilidade
		PlayerData.nickname = Global.player_nickname
	else:
		# Se falhou, pode haver um save no formato antigo (jogador.gd)
		print("Tentando carregar no formato antigo...")
		# Vamos tentar carregar via Level1.tscn e deixar o jogador.gd lidar com isso
		PlayerData.nickname = Global.player_nickname
	
	print("Carregando jogo para: " + Global.player_nickname)
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

# Esta função será chamada pelo botão "Ranking".
func _on_button_ranking_pressed():
	# A lógica para mostrar a tela de Ranking virá aqui.
	print("Botão Ranking Pressionado!")

# Esta função será chamada pelo botão "Sobre".
func _on_button_sobre_pressed():
	# A lógica para mostrar a tela com os nomes dos desenvolvedores virá aqui.
	sobre_window.popup_centered()

func _ready():
	nickname_window.hide() # Começa invisível
	sobre_window.hide()    # Garante que a janela "Sobre" comece invisível

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
		if Global.has_save_file(Global.player_nickname):
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
	
	# Verifica se estamos carregando ou iniciando novo jogo
	if nickname_edit.placeholder_text.contains("carregar"):
		# Estamos tentando carregar um jogo
		if Global.has_save_file(player_nickname):
			nickname_window.hide()
			print("Carregando jogo para: ", player_nickname)
			get_tree().change_scene_to_file("res://scenes/Level1.tscn")
		else:
			print("Nenhum save encontrado para: ", player_nickname)
			# Pode mostrar mensagem de erro aqui
	else:
		# Novo jogo - Remove qualquer save anterior para garantir um início limpo
		if Global.has_save_file(player_nickname):
			Global.delete_save_file(player_nickname)
			print("Save anterior deletado para novo jogo")
		
		# Reseta todos os dados para um novo jogo
		Global.reset_game_data()
		Global.player_nickname = player_nickname # Mantém apenas o nickname
		
		# Não salvamos os dados iniciais agora - deixamos que o jogo salve quando alcançar um checkpoint
		# Isso evita confusão entre um jogo novo e um checkpoint
		
		nickname_window.hide()
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
		print("Novo jogo iniciado com apelido: ", player_nickname)

func _on_nickname_window_close_requested() -> void:
	nickname_window.hide()

# Função para fechar a janela "Sobre" ao clicar no botão "Fechar" dentro dela.
# Conecte o sinal 'pressed' do seu botão de fechar a este método.
func _on_sobre_close_button_pressed() -> void:
	sobre_window.hide()

# Função para fechar a janela "Sobre" ao clicar no 'X' da janela.
# Conecte o sinal 'close_requested' da sua SobreWindow a este método.
func _on_sobre_window_close_requested() -> void:
	sobre_window.hide()
