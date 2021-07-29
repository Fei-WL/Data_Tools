#!/bin/bash
# 传入路径，设置源语言、目标语言
root_path=$1
dict_path=$2
src_lang=$3
tgt_lang=$4

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
        perl $tokenize -no-escape -l $lang < $token_prefix/$prefix.norm.$lang > $token_prefix/$prefix.tok.$lang;
        rm $token_prefix/$prefix.norm.$lang;
    done
done

echo "Clean the corpus"
for prefix in "train" "dev";
do
    echo "Do clean $clean_prefix/$prefix.$src_lang $clean_prefix/$prefix.$tgt_lang";
    perl $clean $token_prefix/$prefix.tok $src_lang $tgt_lang $clean_prefix/$prefix.clean 0 200;
    echo "$prefix Clean Done"
done
for lang in $src_lang $tgt_lang;
do
    cp -f $token_prefix/test.tok.$lang $clean_prefix/;
    mv $clean_prefix/test.tok.$lang $clean_prefix/test.clean.$lang
done
rm -rf $token_prefix

echo "Apply BPE code to datas"
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "dev" "test";
    do
        subword-nmt apply-bpe -i $clean_prefix/$prefix.clean.$lang -c $dict_path/code.$lang -o $bpe_prefix/$prefix.bpe.$lang
        echo "Get $bpe_prefix/$prefix.bpe.$lang"
    done
done
rm -rf $clean_prefix