<html>
<head>
<title>Form Test</form>
</head>
<body>

<form action="test.jsp" method="post">

<p><textarea name="input" rows="25" cols="80"></textarea>
<p><input type="submit" name="Submit" />

</form>

<p><%= request.getParameter( "input" ) %>

</body>