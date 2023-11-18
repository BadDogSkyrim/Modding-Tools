""" ADD SHAPE KEY NUMBERS
"""

import bpy

dstobj = bpy.context.active_object # Active object is destination

print ("Adding Shape Key Numbers to " + dstobj.name)

i = 1

for sp in dstobj.data.shape_keys.key_blocks:
    sp.name = sp.name + " [" + str(i) + "]"
    i += 1
