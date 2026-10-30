extends Resource

class_name RegionMusic

##stems in the order they are added. index 0 plays from the first encounter, each later encounter adds the next one.
@export var stems : Array[AudioStream]

##tempo the stems were exported at. a new stem comes in at the start of the next section
@export var bpm : float = 120.0
@export var beatsPerBar : int = 4
@export var barsPerSection : int = 8

func _get_section_length() -> float:
	return 60.0 / bpm * beatsPerBar * barsPerSection
