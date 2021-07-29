#!/bin/bash
# 传入路径，设置源语言、目标语言
root_path=$1
src_lang=$2
tgt_lang=$3

raw_path="raw"
token_path="tok"
clean_path="clean"
bpe_path="bpe"
normalization="~/Project/Tools/mosesdecoder/scripts/tokenizer/normalize-punctuation.perl"
tokenize="~/Project/Tools/mosesdecoder/scripts/tokenizer/tokenizer.perl"
clean="~/Project/Tools/mosesdecoder/scripts/training/clean-corpus-n.perl"
learnbpe_vocab="~/Project/Tools/subword-nmt/subword_nmt/learn_joint_bpe_and_vocab.py"
applybpe="~/Project/Tools/subword-nmt/subword_nmt/apply_bpe.py"

echo "Make relative dir(raw, tok, clean, bpe)"
for path in $raw_path $token_path $clean_path $bpe_path;
do
    if [ ! -d $root_path$path ];
    then
        mkdir $root_path/$path
        echo $root_path/$path
    else
        echo "$root_path/$path exists"
    fi
done

raw_prefix=$root_path/$raw_path
token_prefix=$root_path/$token_path
clean_prefix=$root_path/$clean_path
bpe_prefix=$root_path/$bpe_path

echo "Make Normalization & Tokenize"
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "valid" "test";
    do
        echo "Normalize $raw_prefix/$prefix.$lang";
        perl $normalization -l $lang < $raw_prefix/$prefix.$lang > $token_prefix/$prefix.norm.$lang;

        echo "Tokenize $token_prefix/$prefix.norm.$lang";
        perl $tokenize -no-escape -l $lang < $token_prefix/$prefix.norm.$lang > $token_prefix/$prefix.norm.tok.$lang;
        rm $token_prefix/$prefix.norm.$lang;
    done
done

echo "Learn BPE code from training datas"
for lang in $src_lang $tgt_lang;
do
	echo "Learn BPE code adn vocab from $token_prefix/train.tok.$lang"
    python $learnbpe_vocab --input $token_prefix/train.norm.tok.$lang \
	--output $bpe_prefix/code.$lang \
	--write-vocabulary $bpe_prefix/vocab.$lang \
	--num-workers 300
done

echo "Apply BPE code to datas"
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "valid" "test";
    do
		echo "Apply BPE code to $token_prefix/$prefix.norm.tok.$lang"
        python $applybpe --input $token_prefix/$prefix.norm.tok.$lang \
		--output $bpe_prefix/$prefix.norm.tok.bpe.$lang \
		--code $bpe_prefix/code.$lang \
		--num-workers 300
    done
done

echo "Clean the corpus"
for prefix in "train" "valid";
do
    echo "Cut too long or too short sents in $bpe_prefix/$prefix.norm.tok.bpe"
    perl $clean $token_prefix/$prefix.norm.tok.bpe $src_lang $tgt_lang $clean_prefix/$prefix.clean 5 150;
done
for lang in $src_lang $tgt_lang;
do
    cp -f $token_prefix/test.tok.$lang $clean_prefix/;
    mv $clean_prefix/test.tok.$lang $clean_prefix/test.clean.$lang
done
