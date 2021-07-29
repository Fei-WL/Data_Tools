import argparse
from tqdm import tqdm, trange
from copy import deepcopy

parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument('--path', type=str, default = None)
#parser.add_argument('--lang', type=str, default = None)
#parser.add_argument('--src', type=str, default = None)

args = parser.parse_args()
split_path = args.path.split('.')
prev_path = deepcopy(split_path)
post_path = deepcopy(split_path)
prev_path.insert(-1, "prev")
post_path.insert(-1, "post")
prev_path = '.'.join(prev_path)
post_path = '.'.join(post_path)

with open(args.path, encoding='utf-8') as file_to_bpe, open(prev_path, encoding='utf-8', mode="w") as prev_file, open(post_path, encoding='utf-8', mode="w") as post_file:
    bpe_sentences = file_to_bpe.readlines()
    prev_sentences = [bpe_sentences[0]] + bpe_sentences[:-1]
    post_sentences = bpe_sentences[1:] + [bpe_sentences[-1]]
    assert len(bpe_sentences) == len(prev_sentences) and len(bpe_sentences) == len(post_sentences), print(len(bpe_sentences), len(prev_sentences), len(post_sentences))
    pbar = trange(len(bpe_sentences))
    for idx in pbar:
        prev_file.write(prev_sentences[idx])
        post_file.write(post_sentences[idx])
#        print(prev_sentences[idx], file=prev_file)
#        print(post_sentences[idx], file=post_file)
    print("Save to {}".format(prev_path))
    print("Save to {}".format(post_path))

#with open(args.path, encoding='utf-8') as file_to_bpe:
#    sentences = file_to_bpe.readlines()
#    context = []
#    if split_path[0][-5:] == "train":
#        for index in range(len(sentences)-1):
#            temp = sentences[index][:-1] + " " + sentences[index+1]
#            context.append(temp)
#    else:
#        if len(sentences) % 2 == 0:
#            length = len(sentences) - 1
#        else:
#            length = len(sentences) - 2
#        for index in range(0, length, 2):
#            temp = sentences[index][:-1] + " " + sentences[index+1]
#            context.append(temp)


#with open(new_path, encoding='utf-8', mode='w') as new_file:
#    for index in range(len(context)):
#        new_file.write(context[index])

#print('Save to {}'.format(new_path))
