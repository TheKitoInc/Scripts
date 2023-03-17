import sys, requests, socket
hostname=socket.gethostbyaddr(requests.get('https://ipv4.jsonip.com/').json()['ip'])[0].split('.')
hostname[0]=hostname[0].upper()
hostnameSTR='.'.join(hostname)
print(hostnameSTR)
