#!/bin/bash
# 传入路径，设置源语言、目标语言
root_path=$1
lang=$2
file=$3

raw_path="raw"
token_path="tok"
clean_path="clean"
bpe_path="bpe"
normalization="mosesdecoder/scripts/tokenizer/normalize-punctuation.perl"
tokenize="mosesdecoder/scripts/tokenizer/tokenizer.perl"
clean="mosesdecoder/scripts/training/clean-corpus-n.perl"
learnbpe="subword-nmt/subword_nmt/learn_bpe.py"

echo "Make relative dir(raw, tok, clean, bpe)"
for path in $raw_path $token_path $clean_path $bpe_path;
do
    if [ ! -d $root_path$path ];
    then
        mkdir $root_path$path
        echo $root_path$path
    else
        echo "$root_path$path exists"
    fi
done

raw_prefix=$root_path$raw_path
token_prefix=$root_path$token_path
clean_prefix=$root_path$clean_path
bpe_prefix=$root_path$bpe_path

echo "Make Normalization & Tokenize & Cleaning"
echo "Normalize $raw_prefix/$file";
perl $normalization -l $lang < $raw_prefix/$file > $token_prefix/$file.norm;

echo "Tokenize $token_prefix/$prefix.norm.$lang";
perl $tokenize -no-escape -l $lang < $token_prefix/$file.norm > $token_prefix/$file.tok;
rm $token_prefix/$file.norm;

echo "Apply BPE code to datas"
subword-nmt apply-bpe -i $token_prefix/$file.tok -c $bpe_prefix/$lang.code -o $bpe_prefix/$file.bpe
echo "Get $bpe_prefix/$file.bpe"