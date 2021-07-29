import os
import jieba
from tqdm import tqdm, trange
import unicodedata
import re

# 从指定的文件夹中获取文件名
def get_filename(root):
    files = []
    file_list = os.listdir(root)
    for file_name in file_list:
        files.append("{}{}".format(root, file_name))
    return files

# 从文件中读取数据
def read_file(file_name):
    with open(file_name, encoding="UTF-8-sig") as file:
        res = file.readlines()
        file.close()
        return res

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

# 从文件中获取数据
def get_data(src_files, tgt_files):

    def deal(text):
        text = eval(text.strip().__repr__())
        text = strQ2B(text)
        text = re.sub(r'\\u.{4}', '', text)
        text = re.sub(r' ', '', text)
        text = unicodedata.normalize("NFKC", text)

        return text

    n = len(src_files)
    src_data = []
    tgt_data = []

    pbar = trange(n)
    for idx in pbar:
        pbar.set_description("Reading Files")
        src_data += read_file(src_files[idx])
        tgt_data += read_file(tgt_files[idx])

    assert len(src_data) == len(tgt_data)
    total_len = len(src_data)

    pbar = trange(total_len)
    for idx in pbar:
        pbar.set_description("Dealing Data")
        src_data[idx] = deal(src_data[idx])
        tgt_data[idx] = deal(tgt_data[idx])

    return src_data, tgt_data

# 处理中文语料数据
def deal_zh_data(datas):
    res = []
    pbar = trange(len(datas))
    for idx in pbar:
        pbar.set_description("Dealing Zh Data")
        text = jieba.lcut(datas[idx])
        text = " ".join(text)
        res.append(text)
    return res

# 写入双语数据
def write_data(src_data, tgt_data, src_path, tgt_path):
    if os.path.exists(src_path):
        os.remove(src_path)
        src_file = open(src_path, mode="w", encoding="utf-8")
    if os.path.exists(tgt_path):
        os.remove(tgt_path)
        tgt_file = open(tgt_path, mode="w", encoding="utf-8")
    pbar = trange(len(src_data))
    for idx in pbar:
        pbar.set_description("Writing Files")
        if len(src_data[idx]) == 0 or len(tgt_data[idx]) == 0:
            continue
        else:
            print(src_data[idx], file=src_file)
            print(tgt_data[idx], file=tgt_file)

if __name__ == '__main__':
    """
    1 从根目录中读取文件名
    2 从根据文件名构造读取文件，并从中读取数据
    3 判断是否有中文数据，如果有中文数据，那么就做分词处理
    4 写入数据
    """
    root = "./CCMT/ti-ch"
    sub = "test"
    src = "ti"
    tgt = "zh"
    src_root = "/".join([root, sub, "data", src]) + "/"
    tgt_root = "/".join([root, sub, "data", tgt]) + "/"

    src_files = get_filename(src_root)
    tgt_files = get_filename(tgt_root)

    assert len(src_files) == len(tgt_files)

    src_data, tgt_data = get_data(src_files, tgt_files)

    if src == "zh":
        src_data = deal_zh_data(src_data)
    elif tgt == "zh":
        tgt_data = deal_zh_data(tgt_data)

    src_path = "/".join([root, "raw", sub]) + "." + src
    tgt_path = "/".join([root, "raw", sub]) + "." + tgt

    write_data(src_data, tgt_data, src_path, tgt_path)