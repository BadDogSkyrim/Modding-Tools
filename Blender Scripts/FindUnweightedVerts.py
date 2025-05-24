import bpy

def find_unweighted_verts():
  obj = bpy.context.active_object
  if obj is None or obj.type != 'MESH':
    print("Active object is not a mesh.")
    return

  # Collect armature objects referenced by armature modifiers
  armature_objs = [
    mod.object for mod in obj.modifiers
    if mod.type == 'ARMATURE' and mod.object is not None
  ]
  if not armature_objs:
    print("No armature modifiers found.")
    return

  # Collect all vertex group names that correspond to bones in the armatures
  bone_names = set()
  for arm in armature_objs:
    bone_names.update(bone.name for bone in arm.data.bones)

  # Map vertex group indices to group names
  vg_idx_to_name = {vg.index: vg.name for vg in obj.vertex_groups}

  # Find unweighted vertices
  unweighted_verts = []
  for v in obj.data.vertices:
    weighted = False
    for g in v.groups:
      group_name = vg_idx_to_name.get(g.group)
      if group_name in bone_names and g.weight > 0.0001:
        weighted = True
        break
    if not weighted:
      unweighted_verts.append(v.index)

  print(f"Unweighted vertices (not assigned to any armature bone group): {unweighted_verts}")
  return unweighted_verts

# Run the function
find_unweighted_verts()