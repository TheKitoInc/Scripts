<?php

function ip_hex_string_to_dotted_decimals($ip_hex_string) {
    $ip_bytes = array_reverse(
        array_map(fn($s): int => intval($s, 16),
            str_split($ip_hex_string, 2)));

    return implode('.', $ip_bytes);
}

function tryNumber($_)
{
        $__ = intval($_);

        if($__ == $_)
                return $__;

        return $_;
}

function getRoutes() {
        $routes = array();

        $headersIP = array('destination','gateway','mask');
        $header = null;
        foreach (explode("\n", str_replace("\r", "\n", file_get_contents('/proc/net/route'))) as $line)
        {
                $line = trim($line);

                if ($line == '')
                        continue;

                $_ = array();
                foreach (explode(" ", str_replace("\t", " ", $line)) as $lineItem)
                {

                        $lineItem = trim($lineItem);

                        if ($lineItem == '')
                                continue;

                        if($header===null)
                                $lineItem =  strtolower($lineItem);

                        $_[] = $lineItem;
                }

                if($header===null)
                {
                        $header = $_;
                        continue;
                }

                $line = array_combine($header, $_);

                foreach ($line as $key => $value)
                {
                        if(in_array($key,$headersIP))
                                $line[$key] = ip_hex_string_to_dotted_decimals($value);
                        else
                                $line[$key] = tryNumber($value);
                }

                $routes[] = $line;
        }

        return $routes;
}


ob_start();
$_ = json_encode(getRoutes());
ob_clean();
header('Content-Length: ' . strlen($_));
header('Content-Type: application/json; charset=utf-8');
echo $_;
exit();
