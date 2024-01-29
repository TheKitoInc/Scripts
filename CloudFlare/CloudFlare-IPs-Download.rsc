:log info "Download Cloudflare IP list";
/tool fetch url="https://www.cloudflare.com/ips-v4" mode=https dst-path=cloudflare-ips-v4.txt;
/tool fetch url="https://www.cloudflare.com/ips-v6" mode=https dst-path=cloudflare-ips-v6.txt;
