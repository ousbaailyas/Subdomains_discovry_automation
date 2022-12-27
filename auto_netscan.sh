#!/bin/bash

# check for dependencies
hash amass 2>/dev/null || { echo >&2 "Amass is not installed. Installing..."; apt update && apt install amass; }
hash httpx 2>/dev/null || { echo >&2 "Httpx is not installed. Installing..."; apt update && apt install httpx; }
hash eyewitness 2>/dev/null || { echo >&2 "Eyewitness is not installed. Installing..."; apt update && apt install eyewitness; }
hash masscan 2>/dev/null || { echo >&2 "Masscan is not installed. Installing..."; apt update && apt install masscan; }
hash dirbuster 2>/dev/null || { echo >&2 "Dirbuster is not installed. Installing..."; apt update && apt install dirbuster; }
hash gitleaks 2>/dev/null || { echo >&2 "Gitleaks is not installed. Installing..."; apt update && apt install gitleaks; }
hash JSminer 2>/dev/null || { echo >&2 "JSminer is not installed. Installing..."; git clone https://github.com/jobertabma/jsminer.git; cd jsminer; npm install; }
hash gau 2>/dev/null || { echo >&2 "Gau is not installed. Installing..."; git clone https://github.com/lc/gau.git; cd gau; go build; }

# discover subdomains with amass
amass enum -d example.com -o subdomains.txt

# check if subdomains are live or dead with httpx
cat subdomains.txt | httpx -silent | grep -v "dead" > live_subdomains.txt

# take a screenshot of live subdomains with eyewitness
eyewitness --web --threads 50 -f live_subdomains.txt

# identify default credentials if known for live subdomains
# (replace "username:password" with your known default credentials)
cat live_subdomains.txt | xargs -I {} sh -c 'echo {} && curl -u "username:password" -I {}'

# do a port scan for the top ports with massscan
masscan -p1-65535 example.com -oG ports.txt

# do a directory bruteforce with dirbuster using common wordlist
dirbuster -u example.com -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt

# search for leaks in GitHub with gitleaks
gitleaks --repo-path https://github.com/example/repo --verbose

# extract javascript files from all subdomains and search for missed API keys with JSminer
JSminer --subdomains subdomains.txt --api-keys

# search for subdomains in the web archive with gau
gau example.com

# organize output into HTML report
# (replace "report.html" with your desired report filename)
cat subdomains.txt live_subdomains.txt ports.txt | sort | uniq > report.html
