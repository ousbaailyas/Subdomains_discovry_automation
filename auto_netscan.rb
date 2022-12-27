# check for dependencies
system("apt update")
def check_dependency(name)
    if !system("which #{name}")
      puts "#{name} is not installed. Installing..."
      install_dependency(name)
    end
  end
  def check_dependency_github(name)
    if !system("which #{name}")
      puts "#{name} is not installed. Installing..."
      install_dependency_github(name)
    end
  end
  
  def install_dependency(name)
    system("apt install -y #{name}")
  end
  
  def install_dependency_github(name)
    system("git clone https://github.com/jobertabma/jsminer.git; cd jsminer; npm install; git clone https://github.com/lc/gau.git; cd gau; go build;")
  end
  check_dependency("amass")
  check_dependency("httpx")
  check_dependency("eyewitness")
  check_dependency("masscan")
  check_dependency("dirbuster")
  check_dependency("gitleaks")
  check_dependency_github("jsminer")
  check_dependency_github("gau")

  
  # discover subdomains with amass
  system("amass enum -d example.com -o subdomains.txt")
  
  # check if subdomains are live or dead with httpx
  subdomains = File.read("subdomains.txt")
  live_subdomains = subdomains.split("\n").select { |subdomain| system("httpx -silent #{subdomain}") }
  
  File.open("live_subdomains.txt", "w") do |f|
    f.puts(live_subdomains)
  end
  
  # take a screenshot of live subdomains with eyewitness
  system("eyewitness --web --threads 50 -f live_subdomains.txt")
  
  # identify default credentials if known for live subdomains
  # (replace "username:password" with your known default credentials)
  live_subdomains.each do |subdomain|
    puts subdomain
    system("curl -u username:password -I #{subdomain}")
  end
  
  # do a port scan for the top ports with masscan
  system("masscan -p1-65535 example.com -oG ports.txt")
  
  # do a directory bruteforce with dirbuster using common wordlist
  system("dirbuster -u example.com -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt")
  
  # search for leaks in GitHub with gitleaks
  system("gitleaks --repo-path https://github.com/example/repo --verbose")
  
  # extract javascript files from all subdomains and search for missed API keys with JSminer
  system("JSminer --subdomains subdomains.txt --api-keys")
  
  # search for subdomains in the web archive with gau
  system("gau example.com")
  
  # organize output into HTML report
  # (replace "report.html" with your desired report filename)
  output = File.read("subdomains.txt") + File.read("live_subdomains.txt") + File.read("ports.txt")
  output = output.split("\n").sort.uniq.join("\n")
  
  File.open("report.html", "w") do |f|
    f.puts(output)
  end
  