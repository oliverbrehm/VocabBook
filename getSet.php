<?php
    
    $verbindung = mysql_connect ("vocabbook.vo.funpicsql.de", "mysql1185038", "5170Oliver")
    or die ("keine Verbindung möglich. Benutzername oder Passwort sind falsch");
    
    mysql_select_db("mysql1185038")
    or die ("Die Datenbank existiert nicht.");
    
    $query = "SELECT * FROM vocabbook_test0 LIMIT 0 , 30";
    $result = mysql_query($query);
    if($result == false) {
        die("Error getting table");
    }
    while($row = mysql_fetch_object($result))
    {
        echo "($row->id, $row->Name, $row->Translations)\n";
    }
?>