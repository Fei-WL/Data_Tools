from tqdm import tqdm
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, help="output file path")
    parser.add_argument("--input", required=True, help="input file path")
    args = parser.parse_args()

    with open(args.input, mode="rb") as input_f, \
        open(args.output, mode="w", encoding="utf-8") as output_f:
        for line in tqdm(input_f):
            line = list(line.decode("utf-8").strip().lower())
            idx = 0
            text = []
            while idx < len(line):
                temp = ""
                if "".join(line[idx:idx+5]) == "<unk>":
                    text.append("<unk>")
                    idx += 5
                else:
                    while idx < len(line) and "0" <= line[idx] and line[idx] <= "9":
                        temp += line[idx]
                        idx += 1
                    if temp:
                        text.append(temp)

                    temp = ""
                    while idx < len(line) and "a" <= line[idx] and line[idx] <= "z":
                        temp += line[idx]
                        idx += 1
                    if temp:
                        text.append(temp)

                    if idx < len(line) and "0" <= line[idx] and line[idx] <= "9":
                        continue
                    elif idx < len(line):
                        text.append(line[idx])
                        idx += 1
            text = " ".join(text)
            print(text, file=output_f)