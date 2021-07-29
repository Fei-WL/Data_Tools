#!/bin/bash
# 传入路径，设置源语言、目标语言
root_path=$1
src_lang=$2
tgt_lang=$3

raw_path="raw"
token_path="tok"
clean_path="clean"
bpe_path="bpe"
normalization="/data/fwl/Project/Tools/mosesdecoder/scripts/tokenizer/normalize-punctuation.perl"
tokenize="/data/fwl/Project/Tools/mosesdecoder/scripts/tokenizer/tokenizer.perl"
clean="/data/fwl/Project/Tools/mosesdecoder/scripts/training/clean-corpus-n.perl"
learnbpe="/data/fwl/Project/Tools/subword-nmt/subword_nmt/learn_joint_bpe_and_vocab.py"
applybpe="/data/fwl/Project/Tools/subword-nmt/subword_nmt/apply_bpe.py"
make_context="/data/fwl/Project/Tools/make_context.py"

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

echo "Make Normalization & Tokenize & Cleaning"
for lang in $src_lang $tgt_lang;
do
    for prefix in "train" "valid" "test";
    do
        echo "Normalize $raw_prefix/$prefix.$lang";
        perl $normalization -l $lang < $raw_prefix/$prefix.$lang > $token_prefix/$prefix.norm.$lang;

        echo "Tokenize $token_prefix/$prefix.norm.$lang";
        perl $tokenize -no-escape -l $lang < $token_prefix/$prefix.norm.$lang > $token_prefix/$prefix.tok.$lang;
        rm $token_prefix/$prefix.norm.$lang;
    done
done

echo "Clean the corpus"
for prefix in "train" "valid" "test";
do
    echo "Do clean $clean_prefix/$prefix.$src_lang $clean_prefix/$prefix.$tgt_lang";
    perl $clean $token_prefix/$prefix.tok $src_lang $tgt_lang $clean_prefix/$prefix.clean 5 150;
    echo "$prefix Clean Done"
done
#for lang in $src_lang $tgt_lang;
#do
#    cp -f $token_prefix/test.tok.$lang $clean_prefix/;
#    mv $clean_prefix/test.tok.$lang $clean_prefix/test.clean.$lang
#done

echo "Learn BPE code from training datas"
for lang in $src_lang $tgt_lang;
do
    python $learnbpe -i $clean_prefix/train.clean.$lang -o $bpe_prefix/code.$lang --write-vocabulary $bpe_prefix/vocab.$lang --num-workers 300
    echo "Get $bpe_prefix/code.$lang & $bpe_prefix/vocab.$lang"
done

echo "Apply BPE code to datas"
#for lang in $src_lang $tgt_lang;
#do
#    for prefix in "train" "dev" "test";
#    do
#        python $applybpe -i $clean_prefix/$prefix.clean.$lang -c $bpe_prefix/code.$lang -o $bpe_prefix/$prefix.bpe.$lang --num-workers 300
#        echo "Get $bpe_prefix/$prefix.bpe.$lang"
#    done
#done
for prefix in "train" "valid" "test";
do
    python $applybpe -i $clean_prefix/$prefix.clean.$tgt_lang -c $bpe_prefix/code.$tgt_lang -o $bpe_prefix/$prefix.bpe.$tgt_lang --num-workers 300
    echo "Get $bpe_prefix/$prefix.bpe.$tgt_lang"
done

for prefix in "train" "valid" "test";
do
    python $applybpe -i $clean_prefix/$prefix.clean.$src_lang -c $bpe_prefix/$src_lang.code -o $bpe_prefix/$prefix.bpe.$src_lang --num-workers 300
    echo "Get $bpe_prefix/$prefix.bpe.$src_lang"
    python $make_context --path $bpe_prefix/$prefix.bpe.$src_lang
done
