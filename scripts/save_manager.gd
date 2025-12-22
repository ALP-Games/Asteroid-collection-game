class_name SaveManager extends RefCounted

const SAVE_FILE_NAME := "asteroid.save"
var FILE_ACCESS_KEY := "1d3353cb8c3ee3e5d20d5cc1adda6f912dbd47364e20fd14f0c3724a5401fb0e".hex_decode()

var _save_data: SaveData

var _save_path: String

func _init() -> void:
	var save_root: String
	if OS.has_feature("release"):
		save_root = OS.get_executable_path().get_base_dir() + "/"
	else:
		save_root = "res://"
	_save_path = save_root + SAVE_FILE_NAME


func reset_save_data() -> SaveData:
	_save_data = SaveData.new()
	return _save_data


func load_save() -> SaveData:
	if not FileAccess.file_exists(_save_path):
		# maybe we should always try to read it?
		# And throw a warning here that it has no write permisssions
		_save_data = SaveData.new()
	else:
		var file_read := _get_read_access()
		_save_data = file_read.get_var(true)
		_save_data.fresh_load = false
	return _save_data


func sync_save() -> void:
	var write_access := _get_write_access()
	write_access.store_var(_save_data, true)


func _get_read_access() -> FileAccess:
	return FileAccess.open_encrypted(_save_path, FileAccess.READ, FILE_ACCESS_KEY)


func _get_write_access() -> FileAccess:
	return FileAccess.open_encrypted(_save_path, FileAccess.WRITE, FILE_ACCESS_KEY)
