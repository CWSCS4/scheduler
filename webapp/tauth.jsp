<%@ include file="/include/init.jsp" %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Authenticating...</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<h2>Authenticating...</h2>
<% 
try {
    teacherID = Integer.parseInt(request.getParameter("user"));
} catch ( NumberFormatException e ) {
	session.setAttribute("errorMessage", "Teacher ID is not a valid number.");
	throw e;
}

try {
    PreparedStatement queryUser = connect.prepareStatement("SELECT teacherID, name, password, email, hasSignedIn FROM teachers WHERE teacherID = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    PreparedStatement hashPassword = connect.prepareStatement("SELECT PASSWORD(?)");
    PreparedStatement queryPreferences = connect.prepareStatement("SELECT * FROM preferences WHERE isTeacher = 1 AND ID = ?");
    PreparedStatement queryAvailability = connect.prepareStatement("SELECT * FROM available WHERE type = 1 AND ID = ?");
    PreparedStatement queryConferences = connect.prepareStatement("SELECT * FROM conference WHERE teacherID = ?");
    
    queryUser.setInt(1, teacherID);
    ResultSet results = queryUser.executeQuery();
    
    if (results.first()) {
        String password = results.getString(3);
        teacherName = results.getString(2);
        boolean setEmail = (results.getString(4) != null);

        hashPassword.setString(1, request.getParameter("passwd"));
        ResultSet rpasswd = hashPassword.executeQuery();
        rpasswd.first();
        if (password.equals(rpasswd.getString(1))) {
            rpasswd.close();
            hashPassword.close();

      	    session.setAttribute("teacherName", teacherName);
            session.setAttribute("teacherID", new Integer(teacherID));
		    results.first();
		    results.updateInt("hasSignedIn", 1);
		    results.updateRow();
            results.close();
            queryUser.close();

			response.sendRedirect("/teacher");
		} else {
            %><p>Sorry, you entered an invalid password.<br />
            <a href="/tlogin.jsp">Return</a> to the login page.</p><%
        }
    } else {
		throw new Exception("Teacher " + teacherID + " not found.");
    }
} catch (SQLException e) {
	session.setAttribute("errorMessage", "Teacher could not be authenticated.");
	throw e;
}
%>
</body>
</html>
