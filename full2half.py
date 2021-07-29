import argparse
from tqdm import tqdm

# 处理全角到半角
def strQ2B(ustring):
    """
    全角转半角
    :param ustring: string with encoding utf8
    :return: string with encoding utf8
    """
    ss = []
    for s in ustring:
        rstring = ""
        for uchar in s:
            inside_code = ord(uchar)
            if inside_code == 12288:
                inside_code = 32
            elif (inside_code >= 65281 and inside_code <= 65374):
                inside_code -= 65248
            rstring += chr(inside_code)
        ss.append(rstring)
    return ''.join(ss)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, help="output file path")
    parser.add_argument("--input", required=True, help="input file path")
    args = parser.parse_args()

    with open(args.input, mode="rb") as input_f, \
        open(args.output, mode="w", encoding="utf-8") as output_f:
        for line in tqdm(input_f):
            line = line.decode("utf-8").strip().split(" ")
            line = "".join(line)
            line = strQ2B(line)
            print(line, file=output_f)
