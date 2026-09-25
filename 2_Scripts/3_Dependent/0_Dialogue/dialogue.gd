extends Resource

class_name Dialogue

@export var speaker : Speaker = Speaker.opponent
enum Speaker{
	opponent,
	player
}
@export var dialogue : String
