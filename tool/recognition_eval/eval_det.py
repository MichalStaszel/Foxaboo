import json, sys, zipfile, numpy as np
from PIL import Image
from ai_edge_litert.interpreter import Interpreter
model = sys.argv[1]
labels = zipfile.ZipFile(model).read('labels.txt').decode().split('\n')
it = Interpreter(model_path=model, num_threads=8); it.allocate_tensors()
inp = it.get_input_details()[0]; size = inp['shape'][1]
outs = {o['shape'][-1]: o['index'] for o in it.get_output_details()}
sel = json.load(open('oi/sel.json'))
ids = sorted({i for s in sel['sel'].values() for i in s})
res = {}
for n, i in enumerate(ids):
    im = Image.open(f'oi/img/{i}.jpg').convert('RGB').resize((size, size))
    it.set_tensor(inp['index'], np.asarray(im, dtype=np.uint8)[None])
    it.invoke()
    s = it.get_tensor(outs[90])[0]
    if n == 0: print('score range', s.min(), s.max())
    if s.min() < 0 or s.max() > 1: s = 1/(1+np.exp(-s))
    m = s.max(axis=0)
    res[i] = {labels[k]: float(m[k]) for k in range(90) if labels[k] != '???' and m[k] > 0.05}
json.dump(res, open(sys.argv[2], 'w'))
print('done', len(res))
