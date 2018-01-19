<%@ include file="/include/init.jsp" %>

<%
boolean invalidPassword = false;
if (request.getParameter("passwd") != null) {
	PreparedStatement getPasswd = connect.prepareStatement("SELECT adminPasswd FROM config");
	ResultSet rgetPasswd = getPasswd.executeQuery();
	rgetPasswd.first();
	String adminPasswd = rgetPasswd.getString(1);

	PreparedStatement hashPassword = connect.prepareStatement("SELECT PASSWORD(?)");
	hashPassword.setString(1, request.getParameter("passwd"));
	ResultSet hashedPasswd = hashPassword.executeQuery();
	hashedPasswd.first();
	if (adminPasswd.equals(hashedPasswd.getString(1))) {
		session.setAttribute("admin", Boolean.TRUE);
		response.sendRedirect("/admin/");
	} else {
		invalidPassword = true;
	}
}
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Administrator Login</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<h2>Enter Administrator Password:</h2>
<% if (invalidPassword) { %><p class="error">Invalid password!</p><% } %>
<form method="post" action="/adminlogin.jsp">
<p>Password: <input type="password" name="passwd" /> <input type="submit" value="Login" /></p>
</form>
</body>
</html>
