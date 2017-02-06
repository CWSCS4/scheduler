<%@page contentType="text/html"%>
<html>
<head><title>Authenticating...</title></head>
<body>

<%@ page import="java.sql.*" %>

<% 
Connection connect = null;
Statement state = null;
try {
    Class.forName( "com.mysql.jdbc.Driver" ).newInstance();
    connect = DriverManager.getConnection( "jdbc:mysql://127.0.0.1/scheduler", "scheduler", "" );
    connect.setAutoCommit( true );
} catch ( Exception e ) {
    %>Internal error! Unable to connect to database."<%
}

int studentID = 0;
try {
    studentID = Integer.parseInt( request.getParameter( "user" ) );
} catch ( NumberFormatException e ) {
    %>Student ID not valid number.<%
}
String studentName;

try {
    PreparedStatement queryUser = connect.prepareStatement( "SELECT studentID, name, password, email, hasSignedIn FROM students WHERE studentID = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
    PreparedStatement hashPassword = connect.prepareStatement( "SELECT PASSWORD( ? )" );
    PreparedStatement queryPreferences = connect.prepareStatement( "SELECT * FROM preferences WHERE isTeacher = 0 AND ID = ?" );
    PreparedStatement queryAvailability = connect.prepareStatement( "SELECT * FROM available WHERE type = 0 AND ID = ?" );
    PreparedStatement queryConferences = connect.prepareStatement( "SELECT * FROM conference WHERE studentID = ?" );
    
    queryUser.setInt( 1, studentID );
    ResultSet results = queryUser.executeQuery();
    
    if ( results.first() ) {
        String password = results.getString( 3 );
        studentName = results.getString( 2 );
	boolean setEmail = ( results.getString( 4 ) != null );
        hashPassword.setString( 1, request.getParameter( "passwd" ) );
        ResultSet rpasswd = hashPassword.executeQuery();
        rpasswd.first();
        if ( password.equals( rpasswd.getString( 1 ) ) ) {
            rpasswd.close();
            hashPassword.close();

            session.setAttribute( "db", connect );
      	    session.setAttribute( "studentName", studentName );
            session.setAttribute( "studentID", new Integer( studentID ) );
	    results.first();
	    if ( results.getInt( 2 ) != 1 ) {
	       results.updateInt( 2, 1 );
	       results.updateRow();
	    }
            results.close();
            queryUser.close();

            queryPreferences.setInt( 1, studentID );
            results = queryPreferences.executeQuery();
            boolean setPreferences = results.first();
            results.close();
            queryPreferences.close();

            queryAvailability.setInt( 1, studentID );
            results = queryAvailability.executeQuery();
            boolean setTimes = results.first();
            results.close();
            queryAvailability.close();

            queryConferences.setInt( 1, studentID );
	    results = queryConferences.executeQuery();
	    boolean conferences = results.first();
            results.close();
            queryConferences.close();

	    if ( conferences ) {
	        %><jsp:forward page="conferences.jsp" /><%
	    } else if ( !setTimes ) {
	        %><jsp:forward page="request.jsp" /><%
	    } else if ( !setPreferences ) {
	        %><jsp:forward page="request2.jsp" /><%
            } else if ( !setEmail ) {
	        %><jsp:forward page="request3.jsp" /><%
	    } else {
	        %><jsp:forward page="view.jsp" /><%
      	    }
        } else {
            %>Sorry, you entered an invalid password.
            <br><a href="login.jsp">Return</a> to the login page.<%
        }
    } else {
        %>Error: Student not found.
        <br><a href="login.jsp">Return</a> to the login page.<%
    }
} catch ( SQLException e ) {
    %>Internal Error <%= e %><%
}

%>

</body>
</html>
