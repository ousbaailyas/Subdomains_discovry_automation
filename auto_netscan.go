package main

import (
	"fmt"
	"os/exec"
)

func checkDependency(name string) {
	_, err := exec.LookPath(name)
	if err != nil {
		fmt.Printf("%s is not installed. Installing...\n", name)
		installDependency(name)
	}
}

func installDependency(name string) {
	cmd := exec.Command("apt", "update")
	err := cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
	cmd = exec.Command("apt", "install", name)
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
}

func main() {
	// check for dependencies
	checkDependency("amass")
	checkDependency("httpx")
	checkDependency("eyewitness")
	checkDependency("masscan")
	checkDependency("dirbuster")
	checkDependency("gitleaks")
	checkDependency("JSminer")
	checkDependency("gau")

	// discover subdomains with amass
	cmd := exec.Command("amass", "enum", "-d", "example.com", "-o", "subdomains.txt")
	err := cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// check if subdomains are live or dead with httpx
	cmd = exec.Command("cat", "subdomains.txt", "|", "httpx", "-silent", "|", "grep", "-v", "dead", ">", "live_subdomains.txt")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// take a screenshot of live subdomains with eyewitness
	cmd = exec.Command("eyewitness", "--web", "--threads", "50", "-f", "live_subdomains.txt")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// identify default credentials if known for live subdomains
	// (replace "username:password" with your known default credentials)
	cmd = exec.Command("cat", "live_subdomains.txt", "|", "xargs", "-I", "{}", "sh", "-c", "'echo {} && curl -u \"username:password\" -I {}'")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// do a port scan for the top ports with massscan
	cmd = exec.Command("masscan", "-p1-65535", "example.com", "-oG", "ports.txt")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// do a directory bruteforce with dirbuster using common wordlist
	cmd = exec.Command("dirbuster", "-u", "example.com", "-w", "/usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// search for leaks in GitHub with gitleaks
	cmd = exec.Command("gitleaks", "--repo-path", "https://github.com/example/repo", "--verbose")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// extract javascript files from all subdomains and search for missed API keys with JSminer
	cmd = exec.Command("JSminer", "--subdomains", "subdomains.txt", "--api-keys")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// search for subdomains in the web archive with gau
	cmd = exec.Command("gau", "example.com")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}

	// organize output into HTML report
	// (replace "report.html" with your desired report filename)
	cmd = exec.Command("cat", "subdomains.txt", "live_subdomains.txt", "ports.txt", "|", "sort", "|", "uniq", ">", "report.html")
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
}
