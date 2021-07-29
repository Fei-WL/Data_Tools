lang=$1
input=$2

python ~/Project/Tools/full2half.py --input $input.$lang --output $input.half.$lang
python ~/Project/Tools/charactor_zh.py --input $input.half.$lang --output $input.half.char.$lang

rm -f $input.half.$lang
