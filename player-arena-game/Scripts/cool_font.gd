extends CanvasLayer

var win = null
var txt = null


func _ready() -> void:
	if(win==false):
		txt = "you lose"
	elif (win==true):
		txt = "you win"
	else:
		txt = "--draw--"


func _process(delta: float) -> void:
	$RichTextLabel.text = "[wave amp=120 freq=8]"+str(txt)+"[/wave]"
