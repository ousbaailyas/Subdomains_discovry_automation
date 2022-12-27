import os
import subprocess

def check_dependency(name):
	try:
		subprocess.run([name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
	except FileNotFoundError:
		print(f"{name} is not installed. Installing...")
		install_dependency(name)

def install_dependency(name):
	subprocess.run(["apt", "update"])
	subprocess.run(["apt", "install", name])

# check for dependencies
check_dependency("amass")
check_dependency("httpx")
check_dependency("eyewitness")
check_dependency("masscan")
check_dependency("dirbuster")
check_dependency("gitleaks")

# discover subdomains with amass
subprocess.run(["amass", "enum", "-d", "example.com", "-o", "subdomains.txt"])

# check if subdomains are live or dead with httpx
with open("subdomains.txt") as f:
	subdomains = f.read()

output = subprocess.run(["httpx", "-silent"], input=subdomains, capture_output=True)
live_subdomains = "\n".join([line for line in output.stdout.decode().split("\n") if "dead" not in line])

with open("live_subdomains.txt", "w") as f:
	f.write(live_subdomains)

# take a screenshot of live subdomains with eyewitness
subprocess.run(["eyewitness", "--web", "--threads", "50", "-f", "live_subdomains.txt"])

# identify default credentials if known for live subdomains
# (replace "username:password" with your known default credentials)
with open("live_subdomains.txt") as f:
	subdomains = f.read()

for subdomain in subdomains.split("\n"):
	print(subdomain)
	subprocess.run(["curl", "-u", "username:password", "-I", subdomain])

# do a port scan for the top ports with massscan
subprocess.run(["masscan", "-p1-65535", "example.com", "-oG", "ports.txt"])

# do a directory bruteforce with dirbuster using common wordlist
subprocess.run(["dirbuster", "-u", "example.com", "-w", "/usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt"])

# search for leaks in GitHub with gitleaks
subprocess.run(["gitleaks", "--repo-path", "https://github.com/example/repo", "--verbose"])

# extract javascript files from all subdomains and search for missed API keys with JSminer
subprocess.run(["JSminer", "--subdom
# search for subdomains in the web archive with gau
subprocess.run(["gau", "example.com"])

# organize output into HTML report
# (replace "report.html" with your desired report filename)
with open("subdomains.txt") as f1:
	with open("live_subdomains.txt") as f2:
		with open("ports.txt") as f3:
			output = set(f1.read().split("\n") + f2.read().split("\n") + f3.read().split("\n"))
			output = "\n".join(sorted(output))

with open("report.html", "w") as f:
	f.write(output)
