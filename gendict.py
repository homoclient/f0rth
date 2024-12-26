import re
import json

if __name__=="__main__":
    x = open("dict.json").read()
    y1 = re.findall(r'(?<=###\n)([^\n].*?)(?=###;)', x, flags=re.S)
    y2 = []
    for s in y1:
        y2.append('"{s}"'.format(s = re.sub(r'\n', r'\\\\n', s)))
    for i in range(len(y2)):
        x = re.sub(r'###\n[^\n].*?###;', y2[i], x, count=1, flags=re.S)
    dict = json.loads(x)

    res = open('dict.txt', 'w')
    name_label_last = ""
    for i, content in enumerate(dict):
        name = content["name"]
        name_label = "word_"
        for c in name:
            if c in " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~":
                name_label = name_label + hex(ord(c)) + "_"
            else:
                name_label = name_label + c
        name_length = len(name)
        payload = content["payload"]
        res.write(".balign 4\n")
        res.write(".ascii " + "\"" + name + "\"" + "\n")
        res.write(".balign 4\n")
        res.write(name_label + ":\n")
        res.write(".word " + (name_label_last if len(name_label_last) > 0 else "0") + "\n")
        res.write(".word " + str(name_length) + "\n")
        res.write(payload)
        res.write("\n")
        name_label_last = name_label

    res.close()
