extends Node

#DIALOGUE SCENE EDIT SIGNALS
signal sent_idx_changed
signal seq_idx_changed
signal sent_added(idx :String)
signal seq_added
signal sent_deleted
signal seq_deleted

#CHR EDIT SIGNALS
signal chr_renamed(new_name :String)
signal emotion_renamed(old_name :String, new_name :String)
signal emotion_added(emo_name :String)
signal emotion_deleted(emo_name :String)

#Paths
#var path :String = OS.get_environment("USERPROFILE") + "/Documents/Dialogue Maker"
var path :String = "user://workspaces"
var cur_dir_path :String = ""
var asset_path :String = ""
var char_path :String = ""
var scene_path :String = ""

#Names
var cur_dialogue_workspc :String = ""
var cur_scene_name :String = ""
var cur_branch_name :String = ""

var workspace_list :Dictionary = {
	
}

var cur_scene_list :Dictionary = {
	
}

var cur_chr_list :Dictionary = {
	
}
#Character stuff
var cur_chr_info :Dictionary = {
	
}

#Dialogue stuff
var cur_dialogue_scene :Dictionary = {
	
}

var cur_dial_branch :Dictionary = {
	
}

var cur_dial_seq :Dictionary = {
	
}

var cur_seq_sent :Dictionary = {
	
}

#Templates
var sentence_template :Dictionary = {
	"sentence" = "",
	"speaker_emotion" = "none",
	"listener_emotion" = "none"
}

var dial_seq_template :Dictionary = {
	"size" : 0,
	"seq_idx" : 0,
	"text" : "",
	"speaker" : "none",
	"listener" : "none"
}

var dial_branch_template :Dictionary = {
	"size" : 0,
	"br_idx" : 0,
	
}

var chr_info_template :Dictionary = {
	"name" : ""
}

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	for dirname in DirAccess.get_directories_at(path):
		workspace_list[dirname] = path.path_join(dirname)

#FILE STUFF
func save_data(save_path :String, data_dict :Dictionary) -> void:
	var file :FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if !data_dict.is_empty():
		file.store_string(JSON.stringify(data_dict))
	else:
		file.store_string("")
	file.close()

func load_data(load_path :String, data_dict :Dictionary, create_new :bool) -> void:
	data_dict.clear()
	if !FileAccess.file_exists(load_path):
		if create_new:
			save_data(load_path, data_dict)
		return
	var file :FileAccess = FileAccess.open(load_path, FileAccess.READ)
	var file_text :String = file.get_as_text()
	file.close()
	if file_text.is_empty():
		return
	var file_data :Variant = JSON.parse_string(file_text)
	if typeof(file_data) != TYPE_DICTIONARY:
		Core.show_error("Data is not dictionary!")
		return
	data_dict.merge(file_data)

func remove(dirname :String) -> void:
	var rm_path = path.path_join(dirname)
	remove_recursive(rm_path)
	workspace_list.erase(dirname)

func remove_recursive(rm_path :String) -> void:
	for dir in DirAccess.get_directories_at(rm_path):
		remove_recursive(rm_path.path_join(dir))
	for file in DirAccess.get_files_at(rm_path):
		DirAccess.remove_absolute(rm_path.path_join(file))
	DirAccess.remove_absolute(rm_path)

func rename_filedir(base_path:String, old_name :String, new_name :String, data_dict :Dictionary, filetype :String = "") -> Error:
	var old_path :String = base_path.path_join(old_name) + filetype
	var new_path :String = base_path.path_join(new_name) + filetype
	var ren_error :Error = DirAccess.rename_absolute(old_path, new_path)
	if ren_error == Error.OK:
		data_dict.erase(old_name)
		data_dict[new_name] = new_path
	return ren_error
#

#WORKSPACE STUFF
func add_workspace(dirname :String) -> void:
	var add_path = path.path_join(dirname)
	DirAccess.make_dir_absolute(add_path)
	workspace_list[dirname] = add_path

func workspc_init() -> void:
	asset_path = cur_dir_path.path_join("assets")
	char_path = cur_dir_path.path_join("characters")
	scene_path = cur_dir_path.path_join("scenes")
	cur_chr_list.clear()
	cur_scene_list.clear()
	cur_dialogue_scene.clear()
	cur_chr_info.clear()
	#assets folder
	if !DirAccess.dir_exists_absolute(asset_path):
		DirAccess.make_dir_absolute(asset_path)
	#character folder
	if !DirAccess.dir_exists_absolute(char_path):
		DirAccess.make_dir_absolute(char_path)
	#scene folder
	if !DirAccess.dir_exists_absolute(scene_path):
		DirAccess.make_dir_absolute(scene_path)
	var scene_list :PackedStringArray = DirAccess.get_files_at(scene_path)
	var chr_list :PackedStringArray = DirAccess.get_files_at(char_path)
	for scene in scene_list:
		var file_path :String = scene_path.path_join(scene)
		scene = scene.get_basename()
		cur_scene_list[scene] = file_path
	for chr in chr_list:
		var file_path :String = char_path.path_join(chr)
		chr = chr.get_basename()
		cur_chr_list[chr] = file_path
#

#CHR STUFF
func add_chr(chr_name :String) -> void:
	cur_chr_list[chr_name] = char_path.path_join(chr_name) + ".json"
	cur_chr_info["name"] = chr_name
	cur_chr_info["emotions"] = []
	save_data(cur_chr_list.get(chr_name), cur_chr_info)
	cur_chr_info.clear()

func del_chr(chr_name :String) -> void:
	var del_error :Error = DirAccess.remove_absolute(cur_chr_list.get(chr_name))
	if del_error != Error.OK:
		Core.show_error("Failed to delete certain file")
		return
	cur_chr_list.erase(chr_name)

func rename_chr(new_name :String) -> void:
	var ren_err :Error = rename_filedir(char_path, cur_chr_info.get("name"), new_name, cur_chr_list, ".json")
	if ren_err != Error.OK:
		push_error(error_string(ren_err))
		return
	cur_chr_info["name"] = new_name
	chr_renamed.emit(new_name)
#emotion
func rename_emotion(old_name :String, new_name :String) -> void:
	cur_chr_info["emotions"].erase(old_name)
	cur_chr_info["emotions"].append(new_name)
	emotion_renamed.emit(old_name, new_name)

func del_emotion(emotion_name :String) -> void:
	cur_chr_info["emotions"].erase(emotion_name)
	emotion_deleted.emit(emotion_name)

func add_emotion(emotion_name :String) -> void:
	cur_chr_info["emotions"].append(emotion_name)
	emotion_added.emit(emotion_name)
#
func chr_info_init(chr_name :String) -> void:
	cur_chr_info.clear()
	load_data(cur_chr_list.get(chr_name), cur_chr_info, false)
	if cur_chr_info.is_empty():
		Core.show_error("Chr info is empty")
		return
	if typeof(cur_chr_info.get("emotions")) != TYPE_ARRAY:
		Core.show_error("Emotions is not an array")
		return
#

#DIALOGUE SCENE STUFF
func add_scene(scene_name :String) -> void:
	cur_scene_list[scene_name] = scene_path.path_join(scene_name) + ".json"
	save_data(cur_scene_list[scene_name], cur_dialogue_scene)

func del_scene(scene_name :String) -> void:
	var del_error :Error = DirAccess.remove_absolute(cur_scene_list.get(scene_name))
	if(del_error != Error.OK):
		Core.show_error("Failed to delete certain file")
		return
	cur_scene_list.erase(scene_name)
#sentence
func new_sent(idx :int) -> void:
	cur_dial_seq[str(idx)] = sentence_template.duplicate()
	cur_dial_seq["size"] += 1
	sent_added.emit(str(cur_dial_seq.get("size") - 1))

func ins_sent() -> void:
	for i in range(cur_dial_seq.get("size") - 1, cur_dial_seq.get("seq_idx"), -1):
		cur_dial_seq[str(i + 1)] = cur_dial_seq.get(str(i))
	cur_dial_seq[str(cur_dial_seq.get("seq_idx") + 1)] = cur_dial_seq.get(str(cur_dial_seq.get("seq_idx")))
	new_sent(cur_dial_seq.get("seq_idx"))
	change_sent(cur_dial_seq.get("seq_idx"))

func change_sent(idx :int) -> void:
	cur_seq_sent = cur_dial_seq.get(str(idx))
	cur_dial_seq["seq_idx"] = idx
	sent_idx_changed.emit()

func del_sent() -> void:
	for i in range(cur_dial_seq.get("seq_idx"), cur_dial_seq.get("size") - 1):
		cur_dial_seq[str(i)] = cur_dial_seq.get(str(i+1))
	cur_dial_seq.erase(str(cur_dial_seq.get("size") - 1))
	cur_dial_seq["size"] -= 1
	if cur_dial_seq.get("seq_idx") == cur_dial_seq.get("size"):
		change_sent(cur_dial_seq.get("seq_idx") - 1)
	else:
		change_sent(cur_dial_seq.get("seq_idx"))
	sent_deleted.emit()
#
#sequence
func new_seq(idx :int) -> void:
	cur_dial_branch[str(idx)] = dial_seq_template.duplicate()
	cur_dial_branch[str(idx)]["0"] = sentence_template.duplicate()
	cur_dial_branch[str(idx)]["size"] += 1
	cur_dial_branch["size"] += 1
	seq_added.emit()

func ins_seq() -> void:
	for i in range(cur_dial_branch.get("size") - 1, cur_dial_branch.get("br_idx"), -1):
		cur_dial_branch[str(i + 1)] = cur_dial_branch.get(str(i))
	cur_dial_branch[str(cur_dial_branch.get("br_idx") + 1)] =  cur_dial_branch.get(str(cur_dial_branch.get("br_idx")))
	new_seq(cur_dial_branch.get("br_idx"))
	change_seq(0)

func change_seq(inc :int) -> void:
	var new_idx :int = cur_dial_branch.get("br_idx") + inc
	if new_idx < 0 or inc > (cur_dial_branch.get("size") - 1):
		return
	cur_dial_seq = cur_dial_branch.get(str(new_idx))
	cur_seq_sent = cur_dial_seq.get(str(cur_dial_seq.get("seq_idx")))
	cur_dial_branch["br_idx"] = new_idx
	seq_idx_changed.emit()

func del_seq() -> void:
	for i in range(cur_dial_branch.get("br_idx"), cur_dial_branch.get("size") - 1):
		cur_dial_branch[str(i)] = cur_dial_branch.get(str(i+1))
	cur_dial_branch.erase(str(cur_dial_branch.get("size") - 1))
	cur_dial_branch["size"] -= 1
	if cur_dial_branch.get("br_idx") == cur_dial_branch.get("size"):
		change_seq(-1)
	else:
		change_seq(0)
	seq_deleted.emit()
#
func dial_scene_init() -> void:
	#RESET
	cur_dial_branch.clear()
	cur_dial_seq.clear()
	cur_dialogue_scene.clear()
	#LOAD SCENE FILE
	load_data(cur_scene_list.get(cur_scene_name), cur_dialogue_scene, false)
	if cur_dialogue_scene.is_empty():
		cur_dialogue_scene["current_branch"] = "main"
		cur_dialogue_scene["main"] = dial_branch_template.duplicate()
	#
	#DIALOGUE BRANCH
	cur_dial_branch = cur_dialogue_scene.get(cur_dialogue_scene.get("current_branch"))
	cur_branch_name = cur_dialogue_scene.get("current_branch")
	#float to int
	for i in cur_dialogue_scene:
		if typeof(cur_dialogue_scene.get(i)) == TYPE_DICTIONARY:
			var branch :Dictionary = cur_dialogue_scene.get(i)
			branch["size"] = int(branch.get("size"))
			branch["br_idx"] = int(branch.get("br_idx"))
			for j in branch:
				if typeof(branch.get(j)) == TYPE_DICTIONARY:
					var seq :Dictionary = branch.get(j)
					seq["size"] = int(seq.get("size"))
					seq["seq_idx"] = int(seq.get("seq_idx"))
	#if branch is empty
	if cur_dial_branch.get("size") == 0:
		cur_dial_branch["0"] = dial_seq_template.duplicate()
		cur_dial_branch["size"] += 1
	#
	#DIALOGUE SEQ
	cur_dial_seq = cur_dial_branch.get(str(cur_dial_branch.get("br_idx")))
	#if sequence is empty
	if cur_dial_seq.get("size") == 0:
		cur_dial_seq["0"] = sentence_template.duplicate()
		cur_dial_seq["size"] += 1
	#
	#SEQ SENT
	cur_seq_sent = cur_dial_seq.get(str(cur_dial_seq.get("seq_idx")))
	#
#
