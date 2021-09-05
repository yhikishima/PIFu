import os
import glob
import pymeshlab as ml

os.chdir('./results/pifu_demo')
ms = ml.MeshSet()
obj_files = glob.glob("*.obj")

for file in obj_files:
  print(file)
  ms.load_new_mesh(file)
  basename = os.path.splitext(os.path.basename(file))[0]
  ms.save_current_mesh(basename + '.ply')

