<%@page contentType="text/html"%>
<html>
<head><title>Login</title></head>
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
int teacherID = 0;
try {
    teacherID = Integer.parseInt( request.getParameter( "user" ) );
} catch ( NumberFormatException e ) {
    %>Teacher ID not valid number.<%
}
String teacherName;

try {
    PreparedStatement queryUser = connect.prepareStatement( "SELECT teacherID, name, password, email, hasSignedIn FROM teachers WHERE teacherID = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
    PreparedStatement hashPassword = connect.prepareStatement( "SELECT PASSWORD( ? )" );
    PreparedStatement queryPreferences = connect.prepareStatement( "SELECT * FROM preferences WHERE isTeacher = 1 AND ID = ?" );
    PreparedStatement queryAvailability = connect.prepareStatement( "SELECT * FROM available WHERE type = 1 AND ID = ?" );
    PreparedStatement queryConferences = connect.prepareStatement( "SELECT * FROM conference WHERE teacherID = ?" );
    
    queryUser.setInt( 1, teacherID );
    ResultSet results = queryUser.executeQuery();
    
    if ( results.first() ) {
        String password = results.getString( 3 );
        teacherName = results.getString( 2 );
	boolean setEmail = ( results.getString( 4 ) != null );

        hashPassword.setString( 1, request.getParameter( "passwd" ) );
        ResultSet rpasswd = hashPassword.executeQuery();
        rpasswd.first();
        if ( password.equals( results.getString( 1 ) ) ) {
            rpasswd.close();
            hashPassword.close();

            session.setAttribute( "db", connect );
      	    session.setAttribute( "teacherName", teacherName );
            session.setAttribute( "teacherID", new Integer( teacherID ) );
	    results.first();
	    if ( results.getInt( 2 ) != 1 ) {
	       results.updateInt( 2, 1 );
	       results.updateRow();
	    }
            results.close();
            queryUser.close();

            queryPreferences.setInt( 1, teacherID );
            results = queryPreferences.executeQuery();
            boolean setPreferences = results.first();
            results.close();
            queryPreferences.close();

            queryAvailability.setInt( 1, teacherID );
            results = queryAvailability.executeQuery();
            boolean setTimes = results.first();
            results.close();
            queryAvailability.close();

            queryConferences.setInt( 1, teacherID );
	    results = queryConferences.executeQuery();
	    boolean conferences = results.first();
            results.close();
            queryConferences.close();

	    if ( conferences ) {
	        %><jsp:forward page="tconferences.jsp" /><%
	    } else if ( !setTimes ) {
	        %><jsp:forward page="trequest.jsp" /><%
            } else if ( !setPreferences ) {
                %><jsp:forward page="trequest2.jsp" /><%
            } else if ( !setEmail ) {
	        %><jsp:forward page="trequest3.jsp" /><%
	    } else {
	        %><jsp:forward page="tview.jsp" /><%
      	    }
        } else {
            %>Sorry, you entered an invalid password.
            <br><a href="tlogin.jsp">Return</a> to the login page.<%
        }
    } else {
        %>Error: Teacher not found.
        <br><a href="tlogin.jsp">Return</a> to the login page.<%
    }
} catch ( SQLException e ) {
    %>Internal Error<%
}

%>

</body>
</html>
