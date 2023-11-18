import bpy

skyrimGroups = 1

name_list = [
# old name - new name
('NPC Collarbone.L', 'NPC LCollarbone'),
('NPC Elbow.L', 'NPC LElbow'),
('NPC Finger11.L', 'NPC LFinger11'),
('NPC Finger12.L', 'NPC LFinger12'),
('NPC Finger21.L', 'NPC LFinger21'),
('NPC Finger22.L', 'NPC LFinger22'),
('NPC Finger31.L', 'NPC LFinger31'),
('NPC Finger32.L', 'NPC LFinger32'),
('NPC Finger41.L', 'NPC LFinger41'),
('NPC Finger42.L', 'NPC LFinger42'),
('NPC Forearm1.L', 'NPC LForearm1'),
('NPC Forearm2.L', 'NPC LForearm2'),
('NPC UpArm1.L', 'NPC LUpArm1'),
('NPC UpArm2.L', 'NPC LUpArm2'),
('NPC Hand.L', 'NPC LHand'),
('NPC Thumb1.L', 'NPC LThumb1'),
('NPC Collarbone.R', 'NPC RCollarbone'),
('NPC Elbow.R', 'NPC RElbow'),
('NPC Finger11.R', 'NPC RFinger11'),
('NPC Finger12.R', 'NPC RFinger12'),
('NPC Finger21.R', 'NPC RFinger21'),
('NPC Finger22.R', 'NPC RFinger22'),
('NPC Finger31.R', 'NPC RFinger31'),
('NPC Finger32.R', 'NPC RFinger32'),
('NPC Finger41.R', 'NPC RFinger41'),
('NPC Finger42.R', 'NPC RFinger42'),
('NPC Forearm1.R', 'NPC RForearm1'),
('NPC Forearm2.R', 'NPC RForearm2'),
('NPC UpArm1.R', 'NPC RUpArm1'),
('NPC UpArm2.R', 'NPC RUpArm2'),
('NPC Hand.R', 'NPC RHand'),
('NPC Thumb1.R', 'NPC RThumb1')
]

v_groups = bpy.context.active_object.vertex_groups
for old_name, new_name in name_list:
    if old_name in v_groups:
        v_groups[old_name].name = new_name
    elif new_name in v_groups:
        v_groups[new_name].name = old_name
print('done')