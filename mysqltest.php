<html>

<head>

<title>Test Title</title>

</head>

<body>

<h1>SQL test...</h1>
<br>
<br>

<?php
    
    $id = $_POST['id'];
    $name = $_POST['name'];
    $translations = $_POST['translations'];
    
    if(!$id) {
        die("id missing");
    }
    
    if(!$name) {
        die("name missing");
    }
    
    if(!$translations) {
        die("translations missing");
    }
    
    $verbindung = mysql_connect ("vocabbook.vo.funpicsql.de", "mysql1185038", "5170Oliver")
    or die ("keine Verbindung möglich. Benutzername oder Passwort sind falsch");
            
    mysql_select_db("mysql1185038")
    or die ("Die Datenbank existiert nicht.");
    
    echo "Connecting to database successfull.<br>";
    
    // enter row into db
    $query = "INSERT INTO vocabbook_test0 (id, name, translations) VALUES ('$id', '$name', '$translations')";
    $result = mysql_query($query);
    if($result == false) {
        die("Error inserting row into table");
    }
    
    echo "Inserting row successfull.<br>"
?>

</body>