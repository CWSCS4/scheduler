<%@ include file="/include/init.jsp" %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Front Office Interface</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/front_office_header.jsp" %>

<% String passwd = request.getParameter("passwd");
if ((passwd == null || passwd.equals("")) && session.getAttribute("frontoffice") != Boolean.TRUE) { %>
<h2>Enter Front Office Password:</h2>
<form method="post" action="/frontofficelogin.jsp">
<p>Password: <input type="password" name="passwd" /><input type="submit" value="Login" /></p>
</form>
<% } else if (session.getAttribute("frontoffice") != Boolean.TRUE) {
	try {
	    PreparedStatement getPasswd = connect.prepareStatement("SELECT frontOfficePasswd FROM config");
	    ResultSet rgetPasswd = getPasswd.executeQuery();
	    rgetPasswd.first();
	    String frontOfficePasswd = rgetPasswd.getString(1);

		PreparedStatement hashPassword = connect.prepareStatement("SELECT PASSWORD(?)");
	    hashPassword.setString(1, request.getParameter("passwd"));
	    ResultSet hashedPasswd = hashPassword.executeQuery();
	    hashedPasswd.first();
	    if (frontOfficePasswd.equals(hashedPasswd.getString(1))) {
			session.setAttribute("frontoffice", Boolean.TRUE);
			response.sendRedirect("/frontoffice");
		} else { %>
			<p>Sorry, you entered an invalid password.<br />
			<a href="/frontofficelogin.jsp">Return</a> to the login page.</p>
		<% }
	} catch (SQLException e) {
		session.setAttribute("errorMessage", "Front office password could not be checked.");
		throw e;
	}
} else {
	response.sendRedirect("/frontoffice");
}
%>
</body>
</html>
