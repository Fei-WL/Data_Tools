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
    
    n = len(sentences)    
    if n % 2 != 0:
        n -= 1
    
    for index in range(0, n-2 ,2):
        temp = "[CLS] "+ sentences[index][:-1] + " [CLS] " + sentences[index+1][:-1] + " [SEP]\n"
        context.append(temp)

with open(new_path, encoding='utf-8', mode='w') as new_file:
    for index in range(len(context)):
        new_file.write(context[index])

print('Save to {}'.format(new_path))