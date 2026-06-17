from ultralytics import YOLO
from pathlib import Path
import shutil

model = YOLO(r'C:\Users\USER\project\yolo26n.pt')

export_path = model.export(format='tflite', imgsz=640, half=True, int8=False, nms=False)

src = Path(export_path)
dst = Path(__file__).parent / 'yolo_coco_bench' / 'assets' / 'yolo26n_coco_float16.tflite'
dst.parent.mkdir(parents=True, exist_ok=True)
shutil.copy(src, dst)
print(f'Saved: {dst}')
