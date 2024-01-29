:local GetDomain do={
	:local ipaddr [:toip $1]
	/ip dhcp-server network
	:foreach network in [find] do={
		:local netblock [get value-name=address $network]
		:if ($ipaddr in $netblock) do={
			:return [get value-name=domain $network]
        }
    }
}
:log debug ("Ready GetDomain");


:local IsValidFQDN do={
	:local string [:tostr $1]
	:return ($string~"^(([a-zA-Z0-9][a-zA-Z0-9-]{0,61}){0,1}[a-zA-Z]\\.){1,9}[a-zA-Z][a-zA-Z0-9-]{0,28}[a-zA-Z]\$")
}
:log debug ("Ready IsValidFQDN");


:local MAC2Host do={
	:local macSRC [:tostr $1]
	:local macDST [:tostr $1]

	:while ($macDST ~ ":") do={
		:local pos [ :find $macDST ":" ];
		:set macDST ( [ :pick $macDST 0 $pos ] . [ :pick $macDST ($pos + 1) 999 ] );
	};
	:return ($macDST)
}
:log debug ("Ready MAC2Host");

:local getStaticHostnameByMAC do={
	:local mac [:tostr $1]
	
	:foreach n in=[ /system script environment find where name=("shost" . $mac) ] do={
		:return [ /system script environment get $n value ];
	}
	
	:return "";
}
:log debug ("Ready getStaticHostnameByMAC");

:local cleanHostName do={
	:local hostName [:tostr $1]	
    :local cleanHostname;
    :for i from=0 to=([:len $hostName ]-1) do={ 
            :local tmp [:pick $hostName  $i];
            :if ($tmp !=":" && $tmp !=" ") do={ 
                :set cleanHostname  "$cleanHostname$tmp" 
        }
    }
	:return $cleanHostname;
}
:log debug ("Ready cleanHostName");







   





    
/ip dhcp-server lease;
   :foreach i in=[find] do={
		:log debug ("Read ROW");

		:local dhcpIP;
		:set dhcpIP  [ get $i address ];
		:log debug ("dhcpIP:" . $dhcpIP);

		:local dhcpMAC;
		:set dhcpMAC [ get $i mac-address ];
		:log debug ("dhcpMAC:" . $dhcpMAC);

		:local dhcpHostName;
		:set dhcpHostName [ get $i host-name ];	
		:log debug ("dhcpHostName:" . $dhcpHostName);
		
		:local dhcpHostNameClean;
		:set dhcpHostNameClean [$cleanHostName $dhcpHostName];	
		:log debug ("dhcpHostNameClean:" . $dhcpHostNameClean);
		
		:local dhcpDomain;
		:set dhcpDomain [$GetDomain $dhcpIP];	
		:log debug ("dhcpDomain:" . $dhcpDomain);
		
		:local hostMAC;
		:set hostMAC [$MAC2Host $dhcpMAC];	
		:log debug ("hostMAC:" . $hostMAC);

		:local staticHostName;
		:set staticHostName [$getStaticHostnameByMAC $hostMAC ];	
		:log debug ("staticHostName:" . $staticHostName);


		:local hostName;		
		:if ( [ :len $hostMAC ] > 0) do={
			:set hostName $hostMAC;
		}		
		:if ( [ :len $dhcpHostNameClean ] > 0) do={
			:set hostName $dhcpHostNameClean;
		}				
		:if ( [ :len $staticHostName ] > 0) do={
			:set hostName $staticHostName;
		}
		:log debug ("hostName:" . $hostName);
		
		:local fullHost; 
		:set fullHost ( $hostName . "." . $dhcpDomain );
		:log debug ("fullHost:" . $fullHost);  
		  
		  
		:if ( [ :len $fullHost ] > 0) do={
			/ip dns static remove numbers=[find name=$fullHost]
			/ip dns static add name=$fullHost address=$dhcpIP;								
		}

	}