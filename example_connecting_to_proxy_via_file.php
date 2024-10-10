<?php
	$url = 'https://something.com';
	$proxy = '1.2.3.4'; // your public IP address
	$port = ''; // Leave blank for default
	
	$cparams = array();
	$cparams['http']['header'] = ['Connection: close']; // to not cache either the URL or the proxy
	$cparams['http']['proxy'] = $proxy;
	if (!empty($port))
		$cparams['http']['proxy'] .= ':' . $port;
	$cparams['http']['request_fulluri'] = true;

	$context=stream_context_create($cparams);
	$data_orig = file_get_contents($url, context: $context);
?>