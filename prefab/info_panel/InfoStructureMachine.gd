extends InfoStructure
class_name InfoStructureMachine

@onready var recipeSprite: TextureRect = $RecipeSprite
@onready var recipeLabel: Label = $RecipeLabel
@onready var tickProgressBar: ProgressBar = $TickProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureMachine := structure.structure as StructureMachine
		if structureMachine:
			var activeRecipe := structureMachine.get_recipe(structure)
			var tick := structureMachine.get_tick(structure)
			if activeRecipe:
				recipeSprite.texture = activeRecipe.output.texture
				recipeLabel.text = activeRecipe.output.name
				tickProgressBar.max_value = activeRecipe.duration - 1
				tickProgressBar.value = tick
			else:
				recipeSprite.texture = null
				recipeLabel.text = ""
				tickProgressBar.max_value = 1
				tickProgressBar.value = 0
