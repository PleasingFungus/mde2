<?php
	$con = mysql_connect("mysql51-014.wc1.dfw1.stabletransit.com",
						 "676583_mde2",
						 "C00||3\/3l5");
	if (!$con)
	  die('ERROR: Could not connect: ' . mysql_error());

	$success = mysql_select_db("676583_mde2levels", $con);
	if (!$success)
		die("ERROR: Couldn't find DB!");

	$hashlvl = $_POST['hash'];
	if (!$hashlvl)
		$hashlvl = $_GET['hash'];
	if (!$hashlvl)
		die("ERROR: Must provide a level hash!");

	$result = mysql_query("SELECT * FROM levels WHERE Hash='".$hashlvl."'");

	if (!$result) {
		$message  = 'ERROR: Invalid query: ' . mysql_error() . "\n";
		$message .= 'Whole query: ' . $query;
		die($message);
	}

	while ($row = mysql_fetch_assoc($result)) {
		die($row['LevelStr']);
	}
	die("ERROR: No result found matching hash ".$hashlvl);
?> 