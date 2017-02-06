<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
String studentName = (String)session.getAttribute( "studentName" );
int studentID = ((Integer)session.getAttribute( "studentID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

if ( studentName == null ) {
   %><jsp:forward page="login.jsp" /><%
}

try {
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Request Conferences for <%= studentName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted2" ) == null || !request.getParameter( "submitted2" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">Select Teachers (Step 2 of 3)</big></big><br>


<form action="request2.jsp" method="post">

<p>Select the teachers that you would like to meet with and the priority ranking of that meeting: (9 is the highest priority.) If you do not need to meet with a teacher please leave the priority box blank.
<br>
<% 

ResultSet results = state.executeQuery( "SELECT teachers.teacherID, teachers.name, classes.name FROM classMembers LEFT JOIN classes ON classMembers.classID = classes.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE classMembers.studentID = " + studentID + " ORDER BY teachers.teacherID" );

Vector has = new Vector();
Vector classes = new Vector();
Vector hasIDs = new Vector();
while( results.next() ) {
    hasIDs.add( new Integer( results.getInt( 1 ) ) );
    has.add( results.getString( 2 ) );
    classes.add( results.getString( 3 ) );
}

for ( int i = 0; i < has.size(); i++ ) { 
    results = state.executeQuery( "SELECT withID, rank, max_conferences FROM preferences WHERE isTeacher = 0 AND ID = " + studentID );
	%><br><select name="teacher<%= ((Integer)hasIDs.get(i)).intValue() %>" >
		<option value="-1">
		<% int rank = -1;
                boolean multiple_selected = false;
                while ( results.next() ) {
		      if ( results.getInt( 1 ) == ((Integer)hasIDs.get( i )).intValue() ) {
		      	 rank = results.getInt( 2 );
			 if ( results.getInt( 3 ) > 1 )
			     multiple_selected = true;
		      }
		}
		for ( int j = 1; j < 10; j++ ) {
			%><option value="<%= j %>" <%= j == rank ? "SELECTED" : "" %>><%= j %><%
		}%>
	</select> <%= (String)has.get(i) %> (<%= (String)classes.get(i) %><% 
	boolean doubled = false;
	//int i2 = i;
	while ( (i+1) < has.size() && has.get( i ).equals( has.get( i+1 ) ) ) {
            %>, <%= classes.get( i+1 ) %><%
	    doubled = true;
	    i++;
	} %>) <%
	if ( doubled ) {
	    %>Request second conference? <input type="checkbox" name="multiple<%= ((Integer)hasIDs.get(i-1)).intValue() %>" value="checked" <%= multiple_selected ? "CHECKED" : "" %>> <%
	}
}
 %>
<p>Because there is limited time available for teachers to meet with parents, and since you may have already been in touch with some teachers, please select only the teachers that you truly need to see.

<p><input type="submit" value="Continue"/>
<input type="hidden" name="submitted2" value="yes"/>
</form>



<% } else { %>

<%
boolean errors = false;
boolean none = true;

ResultSet results = state.executeQuery( "SELECT teachers.teacherID FROM classMembers LEFT JOIN classes ON classMembers.classID = classes.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE classMembers.studentID = " + studentID + " ORDER BY teachers.teacherID" );

Vector hasIDs = new Vector();
while( results.next() ) {
    hasIDs.add( new Integer( results.getInt( 1 ) ) );
}

state.executeUpdate( "DELETE FROM preferences WHERE isTeacher = 0 AND ID = " + studentID );

results = state.executeQuery( "SELECT * FROM preferences WHERE isTeacher = 0 AND ID = " + studentID );

for ( int i = 0; i < hasIDs.size(); i++ ) {
	String param = request.getParameter( "teacher"+((Integer)hasIDs.get(i)).intValue() );
	if ( i != 0 && hasIDs.get( i ).equals( hasIDs.get( i-1 ) ) )
	    continue;
	if ( param != null && !param.equals( "-1" ) ) {
		 try {
		    results.moveToInsertRow();
		    results.updateInt( 1, studentID );
		    results.updateInt( 2, 0 );
		    results.updateInt( 3, ((Integer)hasIDs.get(i)).intValue() );
		    results.updateInt( 4, Integer.parseInt( param ) );
		    String mult = request.getParameter( "multiple"+((Integer)hasIDs.get(i)).intValue() );
		    if ( mult != null && mult.equals( "checked" ) ) {
			results.updateInt( 5, 2 );
		    } else {
			results.updateInt( 5, 1 );
		    }
		    results.insertRow();
		    none = false;		
		} catch (NumberFormatException e ) {}
	}
} 

if ( !errors && none ) {
   errors = true;
   %><br>You did not select any teachers to meet.<%
}

%>
<% if ( errors ) { %>
<p>Please use your browser's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="request3.jsp" />
<% } %>
<% } %>
</body>
</html>
