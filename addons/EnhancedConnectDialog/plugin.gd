tool
extends EditorPlugin

var hook_container : MarginContainer

var scene_tree : Control
var hbox_name : HBoxContainer
var name_edit : LineEdit
var advanced_check : CheckButton

var mc1 : MarginContainer
var mc2 : MarginContainer

var method_list : ItemList
var msg_label : Label
var generate_check : CheckButton

var selected_node
var node_methods = []

const TYPE_NAME = ["any", "bool", "int", "float", "String", "Vector2", "Rect2", 
	"Vector3", "Transform2D", "Plane", "Quat", "AABB", "Basis", "Transform",
	"Color", "NodePath", "RID", "Object", "Dictionary", "Array",
	"PoolByteArray", "PoolIntArray", "PoolRealArray", "PoolStringArray",
	"PoolVector2Array", "PoolVector3Array", "PoolColorArray"]


func _enter_tree():
	var start = OS.get_ticks_usec()
	
	var control = get_editor_interface().get_base_control()
	var dock = _find_ConnectDialog(control)
	
	# left-vbox
	var vbox : VBoxContainer = dock.get_child(3).get_child(0).get_child(0)
	
	scene_tree = vbox.get_child(3).get_child(0)
	hbox_name = vbox.get_child(6).get_child(0)
	name_edit = hbox_name.get_child(0)
	advanced_check = hbox_name.get_child(1)
	
	scene_tree.connect("node_selected", self, "_on_node_selected")
	name_edit.connect("text_changed", self, "_on_name_changed")
	
	# method list
	mc1 = MarginContainer.new()
	vbox.add_child(mc1)
	vbox.move_child(mc1, 6)
	
	method_list = ItemList.new()
	method_list.rect_min_size.y = 100
#	method_list.visible = false
	mc1.add_child(method_list)
	
	method_list.connect("item_selected", self, "_on_method_selected")
	
	# msg label
	mc2 = MarginContainer.new()
	vbox.add_child(mc2)
	var hbox = HBoxContainer.new()
	mc2.add_child(hbox)
	
	msg_label = Label.new()
	msg_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(msg_label)
	
	# move Advanced checkbutton
	hbox_name.remove_child(advanced_check)
	hbox.add_child(advanced_check)
	
	# generate-checkbutton
	generate_check = CheckButton.new()
	generate_check.text = "Generate Code"
	hbox_name.add_child(generate_check)
	
	print("enhanced " + str(dock) + " in " + str(OS.get_ticks_usec() - start) + "us")


func _find_ConnectDialog(parent : Node):
	for node in parent.get_children():
		if node.get_class() == "ConnectDialog":
			return node
		if node is Container:
			var result = _find_ConnectDialog(node)
			if result:
				return result
	return null


func _exit_tree():
	scene_tree.disconnect("node_selected", self, "_on_node_selected")
	name_edit.disconnect("text_changed", self, "_on_name_changed")
	
	msg_label.get_parent().remove_child(advanced_check)
	name_edit.get_parent().add_child(advanced_check)
	
	mc1.free()
	generate_check.free()
	mc2.free()


func _on_name_changed(new_text):
	pass


func _on_node_selected():
	node_methods.clear()
	var np = scene_tree.get_child(0).get_selected().get_metadata(0)
	selected_node = get_node(np)
	
#	var script = selected_node.get_script()
#	var type = script.get_instance_base_type()
#	while script:
#		node_methods.append({name=script.get_class(), methods=script.get_script_method_list(), is_script=true})
#		script = script.get_base_script()
#
#	while type:
#		node_methods.append({name=type, methods=ClassDB.class_get_method_list(type, true)})
#		type = ClassDB.get_parent_class(type)
	
	var list = selected_node.get_script().get_script_method_list()
	method_list.clear()
	var idx = 0
	for method in list:
		
		var text = method.name
		var args = PoolStringArray()
		for arg in method.args:
			args.append(TYPE_NAME[arg.type])
		
		method_list.add_item("%s(%s)" % [method.name, args.join(", ")])
		method_list.set_item_metadata(idx, method)
		idx += 1


func refresh_method_list():
	pass


func _on_method_selected(idx):
	var method = method_list.get_item_metadata(idx)
	name_edit.text = method.name
