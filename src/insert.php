<?php
	function insertLevel($hashlvl, $lvlstr) {
		$colStr = "Hash, LevelStr";
		insert('levels', $colStr, "'" . $hashlvl . "', '" . $lvlstr . "'");
		die($hashlvl);
	}

	function insert($table, $colStr, $valStr) {
		$query = "INSERT INTO ".$table." (". $colStr . ")
				  VALUES (". $valStr .")";
		$success = mysql_query($query);
		if (!$success)
			die("ERROR: Query " . $query . " failed!");
	}
	$con = mysql_connect("mysql51-014.wc1.dfw1.stabletransit.com",
						 "676583_mde2",
						 "C00||3\/3l5");
	if (!$con)
	  die('ERROR: Could not connect: ' . mysql_error());

	$success = mysql_select_db("676583_mde2levels", $con);
	if (!$success)
		die("ERROR: Couldn't find DB!");

	$lvlstr = $_POST['lvl'];
	if (!$lvlstr)
		$lvlstr = $_GET['lvl'];
	if (!$lvlstr)
		die("ERROR: Must provide a level string!");
	
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
				die($hashlvl);
		} else
			insertLevel($hashlvl, $lvlstr); //and die
		
		$hashlvl = hash("md5", $hashlvl);
	}
	
?> 