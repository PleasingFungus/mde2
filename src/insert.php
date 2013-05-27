<?php
	function insertLevel($lvlstr) {
		$colStr = "Hash, LevelStr";
		$hashlvl = hash("md5", $lvlstr);
		insert('levels', $colStr, "'" . $hashlvl . "', '" . $lvlstr . "'");
		echo($hashlvl);
	}

	function insert($table, $colStr, $valStr) {
		$query = "INSERT INTO ".$table." (". $colStr . ")
				  VALUES (". $valStr .")";
		$success = mysql_query($query);
		if (!$success)
			die("Query " . $query . " failed!");
	}
	$con = mysql_connect("mysql51-014.wc1.dfw1.stabletransit.com",
						 "676583_mde2",
						 "C00||3\/3l5");
	if (!$con)
	  die('Could not connect: ' . mysql_error());

	$success = mysql_select_db("676583_mde2levels", $con);
	if (!$success)
		die("Couldn't find DB!");

	$lvlstr = $_POST['lvl'];
	if (!$lvlstr)
		$lvlstr = $_GET['lvl'];
	if (!$lvlstr)
		die("Must provide a level string!");
	
	insertLevel($lvlstr);
?> 