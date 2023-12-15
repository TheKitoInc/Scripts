if ( [/file get [/file find name=cloudflare-ips-v6.txt] size] > 0 ) do={
	/ip firewall address-list remove [find list=CloudFlare-IPv6]

	:log info "Reading IPv6";
	:local content [/file get [/file find name=cloudflare-ips-v6.txt] contents] ;
	:local contentLen [:len $content];

	:local lineEnd 0;
	:local line "";
	:local lastEnd 0;

	:while ($lineEnd < $contentLen) do={

		# depending on file type (linux/windows), "\n" might need to be "\r\n"
		:set lineEnd [:find $content "\n" $lastEnd];

		# if there are no more line breaks, set this to be the last one
		:if ([:len $lineEnd] = 0) do={
			:set lineEnd $contentLen;
		}

		# get the current line based on the last line break and next one
		:set line [:pick $content $lastEnd $lineEnd];

		# depending on "\n" or "\r\n", this will be 1 or 2 accordingly
		:set lastEnd ($lineEnd + 1);

		# don't process blank lines
		:if ($line != "\r") do={
			:log info "Add IP/NET $line";
			/ipv6 firewall address-list add list=CloudFlare-IPv6 address=$line			
		}
	} 
}
