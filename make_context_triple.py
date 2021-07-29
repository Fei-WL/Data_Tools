import argparse

parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument('--path', type=str, default = None)
parser.add_argument('--lang', type=str, default = None)
parser.add_argument('--src', type=str, default = None)

args = parser.parse_args()
split_path = args.path.split('.')
split_path.insert(-1, 'context')
new_path = '.'.join(split_path)
lang = args.lang
src = args.src

with open(args.path, encoding='utf-8') as file_to_bpe:
    sentences = file_to_bpe.readlines()
    context = []
    if lang == src:
        for index in range(len(sentences)-2):
            temp = sentences[index][:-1] + " [SEP] " + sentences[index+1][:-1] + " [SEP] " + sentences[index+2][:-1] + "\n"
            context.append(temp)
    else:
        for index in range(1, len(sentences)-1):
            temp = sentences[index][:-1] + "\n"
            context.append(temp)

with open(new_path, encoding='utf-8', mode='w') as new_file:
    for index in range(len(context)):
        new_file.write(context[index])

if lang == src:
    print("{} src examples.".format(len(context)))
else:
    print("{} tgt examples.".format(len(context)))
        
print('Save to {}'.format(new_path))