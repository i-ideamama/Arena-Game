extends CanvasLayer

var win = null
var txt = null


func _ready() -> void:
	if(win==false):
		txt = "you lose"
	if(win==true):
		txt = "you win"


func _process(delta: float) -> void:
	$RichTextLabel.text = "[wave amp=120 freq=8]"+str(txt)+"[/wave]"
