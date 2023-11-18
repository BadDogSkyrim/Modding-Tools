""" REMOVE SHAPE KEY NUMBERS
"""

import bpy

dstobj = bpy.context.active_object # Active object is destination

print ("Removing Shape Key Numbers From " + dstobj.name)

for sp in dstobj.data.shape_keys.key_blocks:
    strippedname = sp.name.split(' [')[0].strip()
    sp.name = strippedname
