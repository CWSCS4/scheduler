<%@ include file="/include/init.jsp" %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Authenticating...</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<h2>Authenticating...</h2>
<%
try {
    studentID = Integer.parseInt(request.getParameter("user"));
} catch (NumberFormatException e) {
	throw new Exception("Student ID is not a valid number.", e);
}

try {
    PreparedStatement queryUser = connect.prepareStatement("SELECT studentID, name, password, email, hasSignedIn FROM students WHERE studentID = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    PreparedStatement hashPassword = connect.prepareStatement("SELECT PASSWORD(?)");
    PreparedStatement queryPreferences = connect.prepareStatement("SELECT * FROM preferences WHERE isTeacher = 0 AND ID = ?");
    PreparedStatement queryAvailability = connect.prepareStatement("SELECT * FROM available WHERE type = 0 AND ID = ?");
    PreparedStatement queryConferences = connect.prepareStatement("SELECT * FROM conference WHERE studentID = ?");
    
    queryUser.setInt(1, studentID);
    ResultSet results = queryUser.executeQuery();
    
    if (results.first()) {
        String password = results.getString(3);
        studentName = results.getString(2);
		boolean setEmail = (results.getString(4) != null);
        hashPassword.setString(1, request.getParameter("passwd"));
        ResultSet rpasswd = hashPassword.executeQuery();
        rpasswd.first();
        if (password.equals(rpasswd.getString(1))) {
            rpasswd.close();
            hashPassword.close();

            session.setAttribute("db", connect);
      	    session.setAttribute("studentName", studentName);
            session.setAttribute("studentID", new Integer(studentID));
		    results.first();
		    results.updateInt("hasSignedIn", 1);
		    results.updateRow();
            results.close();
            queryUser.close();

            queryPreferences.setInt(1, studentID);
            results = queryPreferences.executeQuery();
            boolean setPreferences = results.first();
            results.close();
            queryPreferences.close();

            queryAvailability.setInt(1, studentID);
            results = queryAvailability.executeQuery();
            boolean setTimes = results.first();
            results.close();
            queryAvailability.close();

            queryConferences.setInt(1, studentID);
		    results = queryConferences.executeQuery();
		    boolean conferences = results.first();
            results.close();
            queryConferences.close();

		    if (conferences) {
		        %><jsp:forward page="parent/conferences.jsp" /><%
		    } else if (!setTimes) {
		        %><jsp:forward page="parent/request.jsp" /><%
		    } else if (!setPreferences) {
		        %><jsp:forward page="parent/request2.jsp" /><%
            } else if (!setEmail) {
		        %><jsp:forward page="parent/request3.jsp" /><%
		    } else {
		        %><jsp:forward page="parent/view.jsp" /><%
      	    }
        } else {
            %>Sorry, you entered an invalid password.
            <br><a href="parentlogin.jsp">Return</a> to the login page.<%
        }
    } else {
		throw new Exception("Student " + studentID + " not found.");
    }
} catch (SQLException e) {
	throw new Exception("Student could not be authenticated.", e);
} %>
</body>
</html>
