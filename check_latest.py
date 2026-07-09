import json
import os

db_path = r"C:\Users\34948\.ai_completion\.code_contribution\_code_commit.db"

with open(db_path, 'r', encoding='utf-8') as f:
    content = f.read()

print(f"数据库最后修改时间: {os.path.getmtime(db_path)}")
import datetime
mtime = datetime.datetime.fromtimestamp(os.path.getmtime(db_path))
print(f"  即: {mtime}")

data = json.loads(content)
print(f"\n数据库中键的总数: {len(data)}")

# 查找 test3.html 的记录
print(f"\n===== test3.html 的最新记录 =====")
test3_keys = [k for k in data.keys() if 'test3' in k.lower()]
for k in test3_keys:
    v = data[k]
    records = json.loads(v) if isinstance(v, str) else v
    print(f"\n键: {k}")
    print(f"总记录数: {len(records)}")
    # 显示最后5条记录
    print(f"\n最后5条记录:")
    for i, rec in enumerate(records[-5:]):
        print(f"\n  记录 {len(records)-5+i+1}:")
        print(f"    aiScene: {rec.get('aiScene', 'N/A')}")
        print(f"    behaviorType: {rec.get('behaviorType', 'N/A')}")
        print(f"    originTextLength: {rec.get('originTextLength', 'N/A')}")
        print(f"    updateTime: {rec.get('updateTime', 'N/A')}")
        # 转换时间戳
        ts = rec.get('updateTime', 0)
        if ts:
            dt = datetime.datetime.fromtimestamp(ts / 1000)
            print(f"    updateTime(可读): {dt}")
        text = rec.get('originAcceptText', '')
        print(f"    originAcceptText: {text[:100]}")

# 查找最近的记录（按时间戳排序）
print(f"\n===== 所有记录中最近的10条（按updateTime排序）=====")
all_records = []
for k, v in data.items():
    records = json.loads(v) if isinstance(v, str) else v
    for rec in records:
        rec['_file'] = k
        all_records.append(rec)

all_records.sort(key=lambda x: x.get('updateTime', 0), reverse=True)
for i, rec in enumerate(all_records[:10]):
    ts = rec.get('updateTime', 0)
    dt = datetime.datetime.fromtimestamp(ts / 1000) if ts else 'N/A'
    print(f"\n  {i+1}. 时间: {dt}")
    print(f"     文件: {rec['_file']}")
    print(f"     aiScene: {rec.get('aiScene', 'N/A')}")
    print(f"     originTextLength: {rec.get('originTextLength', 'N/A')}")
