"""Compare first two selected armature objects. Print any bone differences."""
import bpy
from blender_defs import *

def normalize_angle(angle):
    """
    Normalizes an angle to be within the range of -180 to 180 degrees.
    """
    normalized_angle = angle % 360  # Bring angle within 0 to 360 degrees
    if normalized_angle > 180:
        normalized_angle -= 360  # Convert to range of -180 to 180 degrees
    return normalized_angle

print("---------Bone Diffs-------------")
rollvalues = {}
arma1 = bpy.context.selected_objects[0]
arma2 = bpy.context.selected_objects[1]
for b1 in arma1.data.bones:
    if b1.name in arma2.data.bones:
        b2 = arma2.data.bones[b1.name]
        ax1, r1 = b1.AxisRollFromMatrix(b1.matrix_local.to_3x3(), axis=b1.y_axis)
        ax2, r2 = b2.AxisRollFromMatrix(b2.matrix_local.to_3x3(), axis=b2.y_axis)
        print(b1.name)
        if not VNearEqual(b1.matrix_local.translation, b2.matrix_local.translation):
            print(f"Location difference: {b1.matrix_local.translation - b2.matrix_local.translation}")
        if not VNearEqual(ax1, ax2):
            print(f"Axis1: {ax1}, Axis2: {ax2}")
        print(f"Roll difference: {r1} - {r2} = {round(r1 - r2, 4)}")
        print("")

        rv = round(normalize_angle((r1 - r2) * (360/(2*pi))), 4)
        try:
            rollvalues[rv].add(b1.name)
        except:
            rollvalues[rv] = set()
            rollvalues[rv].add(b1.name)
    else:
        print(f"{b1.name} not in {arma2.name}")

print(f"Unique roll differences {arma1.name} - {arma2.name}:")
for k, v in rollvalues.items():
    print(f"{k}: {v}")