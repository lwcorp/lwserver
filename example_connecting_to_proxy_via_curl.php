<?php
	$url = 'https://something.com';
	$proxy = '1.2.3.4'; // your public IP address
	$port = ''; // Leave blank for default
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Connection: Close')); // to not cache the real URL
	curl_setopt($ch, CURLOPT_PROXYHEADER, array('Proxy-Connection: Close')); // to not cache the proxy
	curl_setopt($ch, CURLOPT_PROXY, $proxy);
	if ($port)
		curl_setopt($ch, CURLOPT_PROXYPORT, $port);
	curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_HTTP);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

	$data_orig = curl_exec($ch);
?>