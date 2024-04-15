"""Convert tris to quads one FO4 Segment at at a time."""

import bpy

obj = bpy.context.object

for g in obj.vertex_groups:
    if g.name.startswith('FO4 Seg'):
        bpy.ops.mesh.select_all(action='DESELECT')
        obj.vertex_groups.active = g
        bpy.ops.object.vertex_group_select()
        bpy.ops.mesh.tris_convert_to_quads()
        bpy.context.view_layer.update()

