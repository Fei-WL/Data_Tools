import argparse

parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument('--path', type=str, default = None)
parser.add_argument('--lang', type=str, default = None)
parser.add_argument('--src', type=str, default = None)

args = parser.parse_args()
split_path = args.path.split('.')
split_path.insert(-1, 'context')
new_path = '.'.join(split_path)

with open(args.path, encoding='utf-8') as file_to_bpe:
    sentences = file_to_bpe.readlines()
    context = []
    if split_path[0][-5:] == "train":
        for index in range(len(sentences)-1):
            if args.lang == args.src:
                temp = "[CLS] " + sentences[index][:-1] + " [SEP] [CLS] " + sentences[index+1][:-1] + " [SEP]\n"
            else:
                temp = "[CLS] " + sentences[index+1][:-1] + " [SEP]\n"
            context.append(temp)
    else:
#         if len(sentences) % 2 == 0:
#             length = len(sentences) - 1
#         else:
#             length = len(sentences) - 2
        for index in range(len(sentences)-1):
            if args.lang == args.src:
                temp = "[CLS] " + sentences[index][:-1] + " [SEP] [CLS] " + sentences[index+1][:-1] + " [SEP]\n"
            else:
                temp = "[CLS] " + sentences[index+1][:-1] + " [SEP]\n"
            context.append(temp)


with open(new_path, encoding='utf-8', mode='w') as new_file:
    for index in range(len(context)):
        new_file.write(context[index])

print('Save to {}'.format(new_path))