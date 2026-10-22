extends PaperInfo

class_name EncounterInfo

@export var characterName : String
@export var dialogueTree : DialogueTree
##max of 3. use "DialogueBranch" only. first Dialogue should always be player, second should always be opponent
@export var hints : DialogueTree

@export var cupAnswer : CupAnswer = CupAnswer.notSet
enum CupAnswer{
	notSet,
	opponentCup,
	playerCup
}
