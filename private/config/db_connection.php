<?php


	function get_db_connection(server, db_user, db_pass, db_name)
	{
	$connection = new mysqli($server, $db_user, $db_pass, $db_name);
	if ($connection->connect_error)
	{
	die("connection failed:". $connection->connect_error;
	}
	return $connection;
?>

