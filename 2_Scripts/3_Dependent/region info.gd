extends Resource

class_name RegionInfo

@export var totalEncounters : int = 4

@export var traitSheet : PaperInfo
@export var characterSheets : Array[EncounterInfo]
@export var atlas : PaperInfo

@export var noteSheet : bool = true

##orders the encounters as they are listed in the Array. 0 is first
#@export var linearEncounters : bool = false
