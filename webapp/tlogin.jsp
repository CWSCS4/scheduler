<%@ include file="/include/init.jsp" %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Login</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>

<h2>Log in (Teachers)</h2>
<form action="tauth.jsp" method="post">
<p>Name: <select name="user">
<%
Statement state = connect.createStatement();
ResultSet results = state.executeQuery( "SELECT name, teacherID FROM teachers ORDER BY name" );
while ( results.next() ) {
    %><option value="<%= results.getInt( 2 ) %>"><%= results.getString( 1 ) %></option>
<% } %>
</select></p>
<p>Password: <input type="password" name="passwd"></p>
<p><input type="submit" name="Login" value="Login"></p>
</form>
</body>
</html>

