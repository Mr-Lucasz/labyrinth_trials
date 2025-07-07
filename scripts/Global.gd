extends Node

# Dados do jogador
var player_nickname: String = ""
var fase_atual: int = 1
var checkpoint_alcancado: bool = false
var puzzle_atual: int = 1
var puzzles_completados: int = 0

const RANKING_FILE_PATH = "user://ranking.dat"

# Função para verificar se existe um arquivo de save para o nickname
func has_save_file(nickname: String) -> bool:
	if nickname.strip_edges().is_empty():
		return false
		
	# Verificar o formato antigo (do jogador.gd)
	var old_path = "user://savegame_%s.save" % nickname
	if FileAccess.file_exists(old_path):
		return true
		
	# Verificar o formato Global
	var global_path = get_save_file_path(nickname)
	return FileAccess.file_exists(global_path)

# Utilitário para múltiplos saves por nickname
func get_save_file_path(nickname: String) -> String:
	return "user://savegame_%s.dat" % nickname

func save_game_at_checkpoint(player_state: Dictionary):
	# Esta função agora recebe o estado do jogador e o combina com o estado global.
	var puzzles_completed = int(player_state.get("shape_completed", false)) + \
							int(player_state.get("number_completed", false)) + \
							int(player_state.get("arrow_completed", false))

	var save_data = {
		"nickname": player_nickname,
		"fase_atual": fase_atual,
		"puzzle_atual": puzzle_atual,
		"checkpoint_alcancado": player_state.get("checkpoint_reached", false),
		"puzzles_completados": puzzles_completed,
		"timestamp": Time.get_unix_time_from_system()
	}
	# Adiciona todos os dados específicos do jogador ao save
	save_data.merge(player_state, true)
	
	var file_path = get_save_file_path(player_nickname)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Jogo salvo no checkpoint para %s!" % player_nickname)
	else:
		print("Erro ao salvar o jogo!")

func load_game_data(nickname: String):
	var file_path = get_save_file_path(nickname)
	if not FileAccess.file_exists(file_path):
		return null
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			return json.data
		else:
			print("Erro ao analisar dados de save")
			return null
	else:
		print("Erro ao abrir arquivo de save")
		return null

func get_player_state_for_level() -> Dictionary:
	# Esta função é chamada pelo jogador no _ready() para obter seu estado inicial.
	# Se um jogo foi carregado, ele retorna os dados salvos.
	# Se for um novo jogo, retorna um dicionário vazio.
	var data = load_game_data(player_nickname)
	return data if data else {}

func delete_save_file(nickname: String):
	var file_path = get_save_file_path(nickname)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
func list_save_files() -> Array:
	var saves = []
	var dir = DirAccess.open("user://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("savegame_") and file_name.ends_with(".dat"):
				saves.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return saves
func apply_loaded_data(data: Dictionary) -> void:
	if data == null:
		return
	player_nickname = data.get("nickname", "")
	fase_atual = data.get("fase_atual", 1)
	checkpoint_alcancado = data.get("checkpoint_alcancado", false)
	puzzle_atual = data.get("puzzle_atual", 1)
	puzzles_completados = data.get("puzzles_completados", 0)

# --- Funções do Ranking ---

func add_score(nickname: String, time_seconds: float) -> void:
	var ranking = load_ranking()
	ranking.append({"nickname": nickname, "time": time_seconds})

	# Ordena o ranking antes de salvar
	ranking.sort_custom(func(a, b): return a["time"] < b["time"])

	# Salva o ranking atualizado
	var file = FileAccess.open(RANKING_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(ranking))
		file.close()
		print("Nova pontuação adicionada ao ranking para %s: %f segundos" % [nickname, time_seconds])
		print("Ranking salvo em: %s" % ProjectSettings.globalize_path(RANKING_FILE_PATH))
	else:
		print("Erro ao salvar o ranking!")

func load_ranking() -> Array:
# Garante que o ranking sempre será um Array válido, mesmo se o arquivo estiver corrompido
	if not FileAccess.file_exists(RANKING_FILE_PATH):
		return []

	var file = FileAccess.open(RANKING_FILE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK and typeof(json.data) == TYPE_ARRAY:
			return json.data as Array
		else:
			print("Ranking inválido ou corrompido. Resetando ranking.")
			return []

	print("Erro ao carregar ou analisar o arquivo de ranking.")
	return []
# Função para resetar os dados do jogo para um novo jogo
func reset_game_data():
	fase_atual = 1
	checkpoint_alcancado = false
	puzzle_atual = 1
	puzzles_completados = 0 # Este valor agora é derivado do estado do jogador
	print("Dados de jogo resetados para novo jogo")
