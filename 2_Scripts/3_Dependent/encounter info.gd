extends PaperInfo

class_name EncounterInfo

@export var characterName : String
@export var dialogueTree : DialogueTree

@export var cupAnswer : CupAnswer = CupAnswer.notSet
enum CupAnswer{
	notSet,
	opponentCup,
	playerCup
}
