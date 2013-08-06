<?php
	function hashLevel($lvlstr) {	
		$hashlvl = hash("md5", $lvlstr);
		while (true) {	
			$result = mysql_query("SELECT * FROM levels WHERE Hash='".$hashlvl."'");

			if (!$result) {
				$message  = 'ERROR: Invalid query: ' . mysql_error() . "\n";
				$message .= 'Whole query: ' . $query;
				die($message);
			}
			
			if ($row = mysql_fetch_assoc($result)) {
				if ($row['LevelStr'] == $lvlstr)
					return $hashlvl;
			} else
				return insertLevel($hashlvl, $lvlstr);
			
			$hashlvl = hash("md5", $hashlvl);
		}
		
		return null; //won't occur
	}
	
	function insertLevel($hashlvl, $lvlstr) {
		$colStr = "Hash, LevelStr";
		insert('levels', $colStr, "'" . $hashlvl . "', '" . $lvlstr . "'");
		return $hashlvl;
	}

	function insert($table, $colStr, $valStr) {
		$query = "INSERT INTO ".$table." (". $colStr . ")
				  VALUES (". $valStr .")";
		$success = mysql_query($query);
		if (!$success)
			die("ERROR: Query " . $query . " failed!");
	}
	
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

	function logError() {
		echo("\nBeginning log error!");
		$colStr = "Uid, Version, Error";
		
		$uid = getIPId();
		$version = mandatoryGet('version');
		$error = mandatoryGet('error');
		$valStr = $uid . ", '" . $version . "', '" . $error . "'";
		
		echo("\nGot basic variables!");
		
		$lvlstr = $_POST['lvl'];
		if (!$lvlstr) //dubious
			$lvlstr = $_GET['lvl'];
		echo("\nLevel string: " . $lvlstr);
		if ($lvlstr) {
			echo("\nLevel string exists!");
			$colStr .= ", LevelId";
			
			$hashlevel = hashLevel($lvlstr);
			echo("Hash: " . $hashlevel . "\n");
			$querystr = "SELECT Id,Hash FROM levels WHERE Hash='".$hashlevel."'";
			echo("\n" . $querystr . "\n");
			$result = mysql_query($querystr);

			if (!$result) {
				$message  = 'ERROR: Invalid query: ' . mysql_error() . "\n";
				$message .= 'Whole query: ' . $query;
				die($message);
			}
			
			$row = mysql_fetch_assoc($result);
			echo("\nResult: " . $row . ', ' .$row['Id']);
			$levelId = $row['Id'];
			$valStr .= ", " . $levelId;
			echo("\nGot level!");
		} else
			echo("\nNo level string found!");
		
		sendQuery('errors', $colStr, $valStr);
		echo("Error of MDE2 version " . $version . " successfully logged.");
	}
	
	function sendQuery($table, $colStr, $valStr) {
		$query = "INSERT INTO ".$table." (". $colStr . ")
				  VALUES (". $valStr .")";
		$success = mysql_query($query);
		if (!$success)
			die("Query " . $query . " failed! Error: " . mysql_error());
	}
	
	function mandatoryGet($varname) {
		$lvlstr = $_POST[$varname];
		if (!$lvlstr) //bad check - FIXME
			$lvlstr = $_GET[$varname];
		if (!$lvlstr) //bad check - FIXME
			die("ERROR: Must provide URL parameter ".$varname."!");
		return $lvlstr;
	}
	
	echo("I exist!");
	
	$con = mysql_connect("mysql51-014.wc1.dfw1.stabletransit.com",
						 "676583_mde3",
						 "C00||3\/3l5");
	if (!$con)
	  die('ERROR: Could not connect: ' . mysql_error());

	$success = mysql_select_db("676583_mde2levels", $con);
	if (!$success)
		die("ERROR: Couldn't find DB!");
	
	logError();
?> 