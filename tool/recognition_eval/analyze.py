import json, sys
sel = json.load(open('oi/sel.json'))
coco = {'mug':['cup'],'bowl':['bowl'],'spoon':['spoon'],'fork':['fork'],'bottle':['bottle'],'banana':['banana'],'apple':['apple'],
'carrot':['carrot'],'fridge':['refrigerator'],'sink':['sink'],'sofa':['couch'],'tv':['tv'],'laptop':['laptop'],'keyboard':['keyboard'],
'remote':['remote'],'phone':['cell phone'],'plant':['potted plant'],'chair':['chair'],'clock':['clock'],'book':['book'],'teddy':['teddy bear'],
'ball':['sports ball'],'bed':['bed'],'backpack':['backpack'],'dog':['dog'],'cat':['cat'],'bicycle':['bicycle'],'umbrella':['umbrella'],
'car':['car'],'skateboard':['skateboard'],'toothbrush':['toothbrush'],'toycar':['car'],'doll':['person','teddy bear']}
for f in sys.argv[1:]:
    res = json.load(open(f)); print('==', f)
    print(f"{'item':10} n  rec@.3 rec@.4 rec@.5  fp@.3 fp@.4 fp@.5")
    tot=[0,0,0,0]
    for it, cl in coco.items():
        pos = sel['sel'][it]
        neg = [i for i in res if it not in sel['present'][i]]
        sc = lambda i: max(res[i].get(c,0) for c in cl)
        r = [sum(sc(i)>=t for i in pos)/max(1,len(pos)) for t in (.3,.4,.5)]
        fp = [sum(sc(i)>=t for i in neg)/len(neg) for t in (.3,.4,.5)]
        tot[0]+=len(pos); tot[1]+=sum(sc(i)>=.4 for i in pos)
        print(f"{it:10} {len(pos):2} " + ' '.join(f'{x:5.0%}' for x in r) + '  ' + ' '.join(f'{x:5.1%}' for x in fp))
    print('overall recall@.4', tot[1]/tot[0])
