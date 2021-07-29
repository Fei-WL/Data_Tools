#!/usr/bin/env python
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import argparse
import fileinput

from tqdm import tqdm, trange


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Extract back-translations from the stdout of fairseq-generate. "
            "If there are multiply hypotheses for a source, we only keep the first one. "
        )
    )
    parser.add_argument("--output", required=True, help="output prefix")
    parser.add_argument(
        "--srclang", required=True, help="source language (extracted from H-* lines)"
    )
    parser.add_argument(
        "--tgtlang", required=True, help="target language (extracted from S-* lines)"
    )
    parser.add_argument(
        "--path", required=True, help="path of file needed deal with"
    )
    args = parser.parse_args()


    def safe_index(toks, index, default):
        try:
            return toks[index]
        except IndexError:
            return default

    print(args)
    with open(args.output + "." + args.srclang, "w", encoding="utf-8") as src_h, \
            open(args.output + "." + args.tgtlang, "w", encoding="utf-8") as tgt_h:
        src_sents = dict()
        tgt_sents = dict()
        file_sents = open(args.path, mode="rb")
        for line in tqdm(file_sents):
            line = line.decode("utf-8")
            if line.startswith("S-"):
                text = line.rstrip().split("\t")
                src_txt = safe_index(text, 1, "")
                src_idx = int(text[0][2:])
            elif line.startswith("H-"):
                if src_txt is not None and src_idx is not None:
                    text = line.rstrip().split("\t")
                    tgt_txt = safe_index(text, 2, "")
                    tgt_idx = int(text[0][2:])
                    src_sents[src_idx] = src_txt
                    tgt_sents[tgt_idx] = tgt_txt
                    src_txt = None
                    src_idx = None
        src_sents = dict(sorted(src_sents.items(), key=lambda item: item[0]))
        tgt_sents = dict(sorted(tgt_sents.items(), key=lambda item: item[0]))
        pbar = trange(len(tgt_sents))
        for idx in pbar:
            pbar.set_description("Writing Sents")
            print(src_sents[idx], file=src_h)
            print(tgt_sents[idx], file=tgt_h)


if __name__ == "__main__":
    main()
