import bpy

obj = bpy.context.active_object

if obj and obj.type == 'MESH' and obj.data.shape_keys:
  # Get all shape keys except 'Basis'
  shape_keys = obj.data.shape_keys.key_blocks
  key_names = [k.name for k in shape_keys if k.name != 'Basis']

  # Get selected vertex indices from the basis shape
  bpy.ops.object.mode_set(mode='OBJECT')
  selected_verts = [v.index for v in obj.data.vertices if v.select]

  for key_name in key_names:
    key = shape_keys[key_name]
    for idx in selected_verts:
      co = key.data[idx].co
      key.data[idx].co = (0.0, co.y, co.z)

  bpy.ops.object.mode_set(mode='EDIT')
else:
  print("No mesh object with shape keys selected.")