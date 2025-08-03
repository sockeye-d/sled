class_name ForceDirectedControl extends PanelContainer

static var last_clicked: ForceDirectedControl

var connected_to: Array[ForceDirectedControl]
var other_controls: Array[ForceDirectedControl]

var labels: Dictionary[ForceDirectedControl, String]


var velocity: Vector2
var last_velocity: Vector2

func _ready() -> void:
	velocity = Vector2.from_angle(randf_range(0.0, TAU)) * 500.0
	(func(): position = get_parent_control().get_rect().get_center()).call_deferred()

func _physics_process(delta: float) -> void:
	var acceleration := (velocity - last_velocity) / delta
	var target_distance := 200.0
	var total_spring_force := Vector2.ZERO
	var total_repulsion_force := Vector2.ZERO
	
	for connected_control in connected_to:
		var vec := get_center() - connected_control.get_center()
		total_spring_force += Util.signed_sqr(target_distance - vec.length()) * vec.normalized()
	for repulsive_control in other_controls:
		if repulsive_control in connected_to:
			continue
		var vec := get_center() - repulsive_control.get_center()
		var force := vec.length()
		force = minf(600.0, 3000000.0 / (force * force))
		total_repulsion_force += force * vec.normalized()
	
	var center_force: Vector2 = get_viewport_rect().size * 0.5 - get_center()
	
	velocity -= acceleration * delta * 0.5
	velocity += total_spring_force * 4.0 * delta
	velocity += total_repulsion_force * 70.0 * delta
	velocity += center_force * 5.0 * delta
	
	if last_clicked == self and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		velocity = -((get_center() - get_global_mouse_position()) * 10.0)
	elif last_clicked == self and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		last_clicked = null
	
	velocity = velocity.limit_length(80000.0)
	position += velocity * delta
	
	var parent_rect := get_parent_control().get_rect()
	position = position.clamp(Vector2.ZERO, parent_rect.size - size)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			last_clicked = self


func apply_force(force: Vector2) -> void:
	velocity += force


func connect_tree(root: ForceDirectedControl = self) -> void:
	var all_nodes: Array[ForceDirectedControl]
	all_nodes.assign(root.find_children("", "ForceDirectedControl", true, false))
	_connect_tree(root, all_nodes)


func _connect_tree(root: ForceDirectedControl, all_nodes: Array[ForceDirectedControl]) -> void:
	root.connected_to.assign(root.find_children("", "ForceDirectedControl", false, false))
	root.other_controls = all_nodes
	var i := 0
	for child in root.get_children():
		var child_fc := child as ForceDirectedControl
		if not child_fc:
			continue
		var connector := ControlArrow.new()
		connector.start_control = root
		connector.end_control = child_fc
		connector.label = root.labels.get(child, str(i))
		root.add_child(connector)
		_connect_tree(child_fc, all_nodes)
		i += 1


func get_center() -> Vector2:
	return global_position + size * 0.5


func flatten_hierarchy(base: Node, root: ForceDirectedControl = self) -> void:
	for child in root.get_children():
		if child is not ForceDirectedControl:
			continue
		root.remove_child(child)
		base.add_child(child)
		flatten_hierarchy(base, child)


func connect_parents() -> void:
	for child in connected_to:
		child.connect_parents()
		child.connected_to.append(self)
