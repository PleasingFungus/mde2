<?php
	function getIPId() {
		$ip=hash("md5", $_SERVER['REMOTE_ADDR']);
		$queryResult = mysql_query("SELECT Id FROM userIPs WHERE IP = '".$ip."'");
		if ($queryResult) {
			$queryRow = mysql_fetch_assoc($queryResult);
			if ($queryRow)
				return $queryRow['Id'];
		}
		
		echo('Creating new IP for ' . $ip.'\n');
		sendQuery('userIPs', 'IP', "'".$ip."'");
		return mysql_insert_id();
	}

	function startup() {
		$colStr = "Uid, Version";
		$uid = getIPId();
		$version = mysql_real_escape_string($_POST['version']);
		sendQuery('startups', $colStr, $uid . ", '" . $version."'");
		echo("Startup of MDE2 version " . $version . " successfully logged.");
	}
	
	function sendQuery($table, $colStr, $valStr) {
		$query = "INSERT INTO ".$table." (". $colStr . ")
				  VALUES (". $valStr .")";
		$success = mysql_query($query);
		if (!$success)
			die("Query " . $query . " failed! Error: " . mysql_error());
	}
	
	$con = mysql_connect("mysql51-014.wc1.dfw1.stabletransit.com",
						 "676583_mde2",
						 "C00||3\/3l5");
	if (!$con)
	  die('ERROR: Could not connect: ' . mysql_error());

	$success = mysql_select_db("676583_mde2levels", $con);
	if (!$success)
		die("ERROR: Couldn't find DB!");
	  
	startup();
?> 