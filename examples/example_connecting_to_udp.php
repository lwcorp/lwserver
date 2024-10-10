<?php
	// Define the UDP server's address and port
	$server = '127.0.0.1';
	$port = 8080;

	// Create a UDP client using stream_socket_client()
	$client = stream_socket_client("udp://$server:$port", $errno, $errstr, 30);

	if (!$client) {
		die("Failed to connect: $errstr ($errno)\n");
	} else {
		echo '<pre>';
		var_dump($client, true);
		echo '</pre>';
	}

	// Message to send
	$message = "GET http://example.com/index.html HTTP/1.1";
	echo $message;

	// Send the message to the UDP server
	fwrite($client, $message);

	// Close the stream
	fclose($client);

/*
	// Create a UDP server listening on 127.0.0.1:9000
	$server = stream_socket_server("udp://127.0.0.1:8080", $errno, $errstr, STREAM_SERVER_BIND);

	if (!$server) {
		die("Failed to bind to UDP port: $errstr ($errno)\n");
	} else
		echo "Worked";

	// Buffer size for receiving data
	$buffer = 1024;

	// Listen for incoming data (non-blocking mode)
	while ($packet = stream_socket_recvfrom($server, $buffer, 0, $peer)) {
		echo "Received from $peer: $packet\n";

		// Optionally, send a response back to the client
		stream_socket_sendto($server, "Pong", 0, $peer);
	}

	// Close the server
	fclose($server);
}
*/
?>
