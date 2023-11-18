""" RenameShapeKeysFO4.py

Convert from game expression morph name to blender name and back 
"""

import bpy

name_list = [
# blender name - game name
('UprLipRollOut', 'UprLipRollOut'),
('UprLipRollIn', 'UprLipRollIn'),
('UprLipFunnel', 'UprLipFunnel'),
('StickyLips', 'StickyLips'),
('UprLipUp.R', 'RUprLipUp'),
('UprLipDn.R', 'RUprLipDn'),
('UprLidUp.R', 'RUprLidUp'),
('UprLidDn.R', 'RUprLidDn'),
('Smile.R', 'RSmile'),
('OutBrowDn.R', 'ROutBrowDn'),
('NoseUp.R', 'RNoseUp'),
('MidBrowUp.R', 'RMidBrowUp'),
('MidBrowDn.R', 'RMidBrowDn'),
('LwrLipUp.R', 'RLwrLipUp'),
('LwrLipDn.R', 'RLwrLipDn'),
('LwrLidUp.R', 'RLwrLidUp'),
('LwrLidDn.R', 'RLwrLidDn'),
('LipCornerOut.R', 'RLipCornerOut'),
('LipCornerIn.R', 'RLipCornerIn'),
('Jaw.R', 'RJaw'),
('Frown.R', 'RFrown'),
('CheekUp.R', 'RCheekUp'),
('BrowOutUp.R', 'RBrowOutUp'),
('Pucker', 'Pucker'),
('JawOpen', 'JawOpen'),
('JawFwd', 'JawFwd'),
('BrowSqueeze', 'BrowSqueeze'),
('UprLipUp.L', 'LUprLipUp'),
('UprLipDn.L', 'LUprLipDn'),
('UprLidUp.L', 'LUprLidUp'),
('UprLidDn.L', 'LUprLidDn'),
('Smile.L', 'LSmile'),
('OutBrowDn.L', 'LOutBrowDn'),
('NoseUp.L', 'LNoseUp'),
('MidBrowUp.L', 'LMidBrowUp'),
('MidBrowDn.L', 'LMidBrowDn'),
('LwrLipUp.L', 'LLwrLipUp'),
('LwrLipDn.L', 'LLwrLipDn'),
('LwrLidUp.L', 'LLwrLidUp'),
('LwrLidDn.L', 'LLwrLidDn'),
('LipCornerOut.L', 'LLipCornerOut'),
('LipCornerIn.L', 'LLipCornerIn'),
('Jaw.L', 'LJaw'),
('Frown.L', 'LFrown'),
('CheekUp.L', 'LCheekUp'),
('BrowOutUp.L', 'LBrowOutUp'),
('LwrLipRollOut', 'LwrLipRollOut'),
('LwrLipFunnel', 'LwrLipFunnel'),
('LwrLipRollIn', 'LwrLipRollIn')]

keyblocks = bpy.context.object.data.shape_keys.key_blocks
for old_name, new_name in name_list:
    if old_name in keyblocks:
        keyblocks[old_name].name = new_name
    elif new_name in keyblocks:
        keyblocks[new_name].name = old_name
print('done')