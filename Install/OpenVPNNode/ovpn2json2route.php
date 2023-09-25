<?php

function isIP($value) : bool
{
        return filter_var($value, FILTER_VALIDATE_IP);
}

function isNetwork($value) : bool
{
        $_ = explode('/', $value, 2);

        if(count($_)!=2)
                return false;

        list($network_ip, $network_cidr) = $_;

        if(!isIP($network_ip))
                return false;

        if(!filter_var($network_cidr, FILTER_VALIDATE_INT, array('options' => array('min_range' => 0, 'max_range' => 32))))
                return false;

        return true;

}

function getKernelRoutes() : array
{
        static $routes = null;

        if($routes === null)
        {
                $routes = array();
                exec ('ip route', $__);
                foreach($__ as $route)
                {

                        if(!str_contains($route,"tunTCP") && !str_contains($route,"tunUDP"))
                                continue;

                        $_ = array();

                        foreach (explode(' ',$route) as $item)
                        {
                                $item = trim($item);

                                if(empty($item))
                                        continue;

                                if(isIP($item))
                                        $_['router'] = $item;
                                elseif(isNetwork($item))
                                        $_['network'] = $item;
//                              else
//                                      $_[] = $item;
                        }



                        if(isset($_['router']) && $_['network'] && explode('.',$_['router'])[3] != 1)
                                $routes[] = $_;

                }
        }

        return $routes;
}


function checkRouteInKernel($router, $network) : bool
{
        foreach(getKernelRoutes() as $route)
                if($route['router'] == $router && $route['network']==$network)
                        return true;

        return false;
}

function checkRouteInOVPN($router, $network) : bool
{
        foreach(getOVPNRoutes() as $route)
                if($route['router'] == $router && $route['network']==$network)
                        return true;

        return false;
}

function getOVPNRoutes() : array
{
        static $routes = null;

        if($routes === null)
        {
                $routes = array();
                $data = json_decode(file_get_contents('/var/log/openvpn.json'), true);
                foreach($data as $ip_port => $subData)
                {
                        if(!isset($subData['networks']))
                                continue;

                        $networks = $subData['networks'];

                        if(!is_array($networks))
                                continue;

                        if(count($networks)===0)
                                continue;

                        if(!isset($subData['next_hop']))
                                continue;

                        $router = $subData['next_hop'];

                        if(!isIP($router))
                                continue;

                        foreach($networks as $network)
                        {

                                if(!isNetwork($network))
                                        continue;

                                $routes[] = array(
                                        'router' => $router,
                                        'network' => $network,
                                );


                        }
                }
        }

        return $routes;
}



//OVPN2Kernel
foreach(getOVPNRoutes() as $route)
{
        $router = $route['router'];
        $network = $route['network'];

        if(!checkRouteInKernel($router,$network))
                exec("route add -net $network gw $router metric 2");
}


//Kernel2OVPN
foreach(getKernelRoutes() as $route)
{
        $router = $route['router'];
        $network = $route['network'];

//      if(!checkRouteInOVPN($router,$network))
//TODO: remove route from kernel table
}
