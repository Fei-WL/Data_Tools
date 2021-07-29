#!/bin/bash
# 传入路径，设置源语言、目标语言
root_path=$1
src_lang=$2
tgt_lang=$3
context=$4

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
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "dev" "test";
    do
        echo "Normalize $raw_prefix/$prefix.$lang";
        perl $normalization -l $lang < $raw_prefix/$prefix.$lang > $token_prefix/$prefix.norm.$lang;

        echo "Tokenize $token_prefix/$prefix.norm.$lang";
        perl $tokenize -no-escape -l $lang < $raw_prefix/$prefix.$lang > $token_prefix/$prefix.tok.$lang;
        rm $token_prefix/$prefix.norm.$lang;
    done
done

echo "Clean the corpus"
for prefix in "train" "dev" "test";
do
    echo "Do clean $clean_prefix/$prefix.$src_lang $clean_prefix/$prefix.$tgt_lang";
    perl $clean $token_prefix/$prefix.tok $src_lang $tgt_lang $clean_prefix/$prefix.clean 4 150;
    echo "$prefix Clean Done"
done

echo "Learn BPE code from training datas"
for lang in $src_lang $tgt_lang;
do
    subword-nmt learn-joint-bpe-and-vocab -i $clean_prefix/train.clean.$lang -o $bpe_prefix/$lang.code --write-vocabulary $bpe_prefix/$lang.vocab
    echo "Get $bpe_prefix/$lang.code & $bpe_prefix/$lang.vocab"
done

echo "Apply BPE code to datas"
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "dev" "test";
    do
        subword-nmt apply-bpe -i $clean_prefix/$prefix.clean.$lang -c $bpe_prefix/$lang.code -o $bpe_prefix/$prefix.bpe.$lang
        echo "Get $bpe_prefix/$prefix.bpe.$lang"
    done
    python $context.py --path $bpe_prefix/$prefix.bpe.$lang --lang $lang --src $src_lang
done