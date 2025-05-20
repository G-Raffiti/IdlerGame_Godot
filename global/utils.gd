extends Node
class_name Utils

static func resource_to_str(in_resource: E.Res) -> String:
	match in_resource:
		E.Res.GOLD: return "[color=gold]Gold[/color]"
		E.Res.ENERGY: return "[color=pale_green]Energy[/color]"
		_: return "Unknown Resource"

static func stats_to_str(in_stat: E.Res) -> String:
	match in_stat:
		E.Stats.HP: return "[color=red]HP[/color]"
		E.Stats.REGEN: return "[color=chartreuse]Regen[/color]"
		E.Stats.ATTACK: return "[color=tomato]Attack[/color]"
		E.Stats.DEFENSE: return "[color=sky_blue]Defense[/color]"
		E.Stats.ATTACK_SPEED: return "[color=tomato]Attack[/color] [color=yellow]Speed[/color]"
		E.Stats.DEFENSE_SPEED: return "[color=sky_blue]Defense[/color] [color=yellow]Speed[/color]"
		_: return "Unknown Stat"

static func resources_to_str(in_resources: Dictionary[E.Res, Vector2]) -> String:
	var res_str: String
	
	var i: int = 0
	for res: E.Res in in_resources:
		i += 1
		res_str += Number.to_str(in_resources[res]) + " " + resource_to_str(res)
		if i < in_resources.size():
			res_str += ", "
	
	return res_str
