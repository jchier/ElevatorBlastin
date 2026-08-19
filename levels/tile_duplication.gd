@tool
extends Node2D

@export_tool_button("Sync Tile Layers")
var sync_button = sync_tiles

@export var source: TileMapLayer
@export var target1: TileMapLayer
@export var target2: TileMapLayer


func sync_tiles():
	if not source or not target1 or not target2:
		return

	target1.clear()
	target2.clear()

	for cell in source.get_used_cells():
		target1.set_cell(
			cell,
			source.get_cell_source_id(cell),
			source.get_cell_atlas_coords(cell),
			source.get_cell_alternative_tile(cell)
	)
		target2.set_cell(
			cell,
			source.get_cell_source_id(cell),
			source.get_cell_atlas_coords(cell),
			source.get_cell_alternative_tile(cell)
	)
