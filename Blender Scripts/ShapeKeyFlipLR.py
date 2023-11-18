""" ShapeKeyFlipLR

Change all shape keys ending in ".R" to ".L" and vice versa
"""

import bpy

keyblocks = bpy.context.object.data.shape_keys.key_blocks
for name in keyblocks.keys():
    if name[-2:] == '.L':
        keyblocks[name].name = name[:-2] + ".R"
    elif name[-2:] == '.R':
        keyblocks[name].name = name[:-2] + ".L"
print('done')