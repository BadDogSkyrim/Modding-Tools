import bpy
context = bpy.context
obj = context.object

namelist = [
('NPC Toe0 [Toe].R','NPC R Toe0 [RToe]'),
('NPC Calf [Clf].R','NPC R Calf [RClf]'),
('NPC Foot [ft ].R','NPC R Foot [Rft ]'),
('NPC Foot [ft ].L','NPC L Foot [Lft ]'),
('NPC Toe0 [Toe].L','NPC L Toe0 [LToe]'),
('NPC Calf [Clf].L','NPC L Calf [LClf]'),
('NPC Thigh [Thg].R', 'NPC R Thigh [RThg]'),
('NPC Thigh [Thg].L', 'NPC L Thigh [LThg]'),
('NPC Finger00 [F00].R', 'NPC R Finger00 [RF00]'),
('NPC Finger01 [F01].R', 'NPC R Finger01 [RF01]'),
('NPC Finger02 [F02].R', 'NPC R Finger02 [RF02]'),
('NPC Finger10 [F10].R', 'NPC R Finger10 [RF10]'),
('NPC Finger11 [F11].R', 'NPC R Finger11 [RF11]'),
('NPC Finger12 [F12].R', 'NPC R Finger12 [RF12]'),
('NPC Finger20 [F20].R', 'NPC R Finger20 [RF20]'),
('NPC Finger21 [F21].R', 'NPC R Finger21 [RF21]'),
('NPC Finger22 [F22].R', 'NPC R Finger22 [RF22]'),
('NPC Finger30 [F30].R', 'NPC R Finger30 [RF30]'),
('NPC Finger31 [F31].R', 'NPC R Finger31 [RF31]'),
('NPC Finger32 [F32].R', 'NPC R Finger32 [RF32]'),
('NPC Finger40 [F40].R', 'NPC R Finger40 [RF40]'),
('NPC Finger41 [F41].R', 'NPC R Finger41 [RF41]'),
('NPC Finger42 [F42].R', 'NPC R Finger42 [RF42]'),
('NPC Finger42 [F42].R', 'NPC R Finger42 [RF42]'),
('NPC Finger42 [F42].R', 'NPC R Finger42 [RF42]'),
('NPC Forearm [Lar].R', 'NPC R Forearm [RLar]'),
('NPC Forearm [Lar].L', 'NPC L Forearm [LLar]'),
('NPC Hand [Hnd].L', 'NPC L Hand [LHnd]'),
('NPC Finger00 [F00].L', 'NPC L Finger00 [LF00]'),
('NPC Finger01 [F01].L', 'NPC L Finger01 [LF01]'),
('NPC Finger02 [F02].L', 'NPC L Finger02 [LF02]'),
('NPC Finger10 [F10].L', 'NPC L Finger10 [LF10]'),
('NPC Finger11 [F11].L', 'NPC L Finger11 [LF11]'),
('NPC Finger12 [F12].L', 'NPC L Finger12 [LF12]'),
('NPC Finger20 [F20].L', 'NPC L Finger20 [LF20]'),
('NPC Finger21 [F21].L', 'NPC L Finger21 [LF21]'),
('NPC Finger22 [F22].L', 'NPC L Finger22 [LF22]'),
('NPC Finger30 [F30].L', 'NPC L Finger30 [LF30]'),
('NPC Finger31 [F31].L', 'NPC L Finger31 [LF31]'),
('NPC Finger32 [F32].L', 'NPC L Finger32 [LF32]'),
('NPC Finger40 [F40].L', 'NPC L Finger40 [LF40]'),
('NPC Finger41 [F41].L', 'NPC L Finger41 [LF41]'),
('NPC Finger42 [F42].L', 'NPC L Finger42 [LF42]'),
('NPC ForearmTwist1 [Lt1].R', 'NPC R ForearmTwist1 [RLt1]'),
('NPC ForearmTwist2 [Lt2].R', 'NPC R ForearmTwist2 [RLt2]'),
('NPC Hand [Hnd].R', 'NPC R Hand [RHnd]')
]

for name, newname in namelist:
    # get the pose bone with name
    pb = obj.pose.bones.get(name)
    # continue if no bone of that name
    if pb is None:
        continue
    # rename
    pb.name = newname