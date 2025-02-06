extends RichTextLabel

var txt = "you win"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = "[wave amp=120 freq=8]"+str(txt)+"[/wave]"
	# self.text = "[tornado radius=15 freq=5]you win[/tornado]"
