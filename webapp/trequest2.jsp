<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
String teacherName = (String)session.getAttribute( "teacherName" );
int teacherID = ((Integer)session.getAttribute( "teacherID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

if ( teacherName == null ) {
   %><jsp:forward page="tlogin.jsp" /><%
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
  <title>Request Conferences for <%= teacherName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted2" ) == null || !request.getParameter( "submitted2" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">Select Students (Step 2 of 3)</big></big><br>


<form action="trequest2.jsp" method="post">
<p>Select the students that you absolutely have to meet with and the priority ranking of that meeting: (9 is the highest priority.) Otherwise just leave the box blank. You do not need to rank a student to have them be scheduled for a meeting. Your selections just provide an extra way for a meeting to be scheduled.
<br>
<% 

ResultSet results = state.executeQuery( "SELECT students.studentID, students.name, classes.name FROM classMembers LEFT JOIN classes ON classMembers.classID = classes.classID LEFT JOIN students ON classMembers.studentID = students.studentID WHERE classes.teacherID = " + teacherID + " ORDER BY students.studentID" );

Vector has = new Vector();
Vector classes = new Vector();
Vector hasIDs = new Vector();
while( results.next() ) {
    hasIDs.add( new Integer( results.getInt( 1 ) ) );
    has.add( results.getString( 2 ) );
    classes.add( results.getString( 3 ) );
}

for ( int i = 0; i < has.size(); i++ ) { 
        results = state.executeQuery( "SELECT withID, rank, max_conferences FROM preferences WHERE isTeacher = 1 AND ID = " + teacherID );
	%><br><select name="student<%= ((Integer)hasIDs.get(i)).intValue() %>" >
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
	    if ( !doubled ) {
		%>, <%= classes.get( i+1 ) %><%
	    }
	    doubled = true;
	    i++;
	} %>) <%
	if ( doubled ) {
	    %>Request second conference? <input type="checkbox" name="multiple<%= ((Integer)hasIDs.get(i-1)).intValue() %>" value="checked" <%= multiple_selected ? "CHECKED" : "" %>> <%
	}
}
 %>

<p><input type="submit" value="Continue"/>
<input type="hidden" name="submitted2" value="yes"/>
</form>



<% } else { %>

<%
boolean errors = false;
boolean none = true;

ResultSet results = state.executeQuery( "SELECT students.studentID FROM classMembers LEFT JOIN classes ON classMembers.classID = classes.classID LEFT JOIN students ON classMembers.studentID = students.studentID WHERE classes.teacherID = " + teacherID + " ORDER BY students.studentID" );

Vector hasIDs = new Vector();
while( results.next() ) {
    hasIDs.add( new Integer( results.getInt( 1 ) ) );
}

state.executeUpdate( "DELETE FROM preferences WHERE isTeacher = 1 AND ID = " + teacherID );

results = state.executeQuery( "SELECT * FROM preferences WHERE isTeacher = 1 AND ID = " + teacherID );
for ( int i = 0; i < hasIDs.size(); i++ ) {
	String param = request.getParameter( "student"+((Integer)hasIDs.get(i)).intValue() );
	if ( i != 0 && hasIDs.get( i ).equals( hasIDs.get( i-1 ) ) )
	    continue;
	if ( param != null && !param.equals( "-1" ) ) {
		 try {
		    results.moveToInsertRow();
		    results.updateInt( 1, teacherID );
		    results.updateInt( 2, 1 );
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
		} catch (NumberFormatException e ) { %>Error<% }
	}
} 

results.close();

%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="trequest3.jsp" />
<% } %>
<% } %>
</body>
</html>
