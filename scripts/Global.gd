extends Node

# Dados do jogador
var player_nickname: String = ""
var fase_atual: int = 1
var checkpoint_alcancado: bool = false
var puzzle_atual: int = 1
var puzzles_completados: int = 0


# Utilitário para múltiplos saves por nickname
func get_save_file_path(nickname: String) -> String:
	return "user://savegame_%s.dat" % nickname

func save_game_at_checkpoint():
	var save_data = {
		"nickname": player_nickname,
		"fase_atual": fase_atual,
		"checkpoint_alcancado": checkpoint_alcancado,
		"puzzle_atual": puzzle_atual,
		"puzzles_completados": puzzles_completados,
		"timestamp": Time.get_unix_time_from_system()
	}
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

func has_save_file(nickname: String) -> bool:
	return FileAccess.file_exists(get_save_file_path(nickname))

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

func reset_game_data():
	player_nickname = ""
	fase_atual = 1
	checkpoint_alcancado = false
	puzzle_atual = 1
	puzzles_completados = 0
