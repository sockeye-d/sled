class_name ScriptUtils

static func run(script: Script, method_name: StringName, method_args: Array) -> Variant:
	var instance = script.new()
	var returned_value = instance.callv(method_name, method_args)
	if not instance is RefCounted:
		instance.free()
	return returned_value
