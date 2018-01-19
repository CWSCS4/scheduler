<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= teacherName %></title>
<%@ include file="/include/meta.jsp" %>
<style type="text/css">
td.priority { width: 5em; padding: 0.2em; text-align: center; }
td.name { width: 20em; }
td.classes { width: 20em; }
td.multiple { width: 10em; }
</style>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<% if ( request.getParameter( "submitted2" ) == null || !request.getParameter( "submitted2" ).equals( "yes" ) ) { %>

<h2>Select Students (Step 2)</h2>

<form action="request2.jsp" method="post">
<p>Select the students that you absolutely have to meet with and the priority
ranking of that meeting: (9 is the highest priority.) Otherwise just leave the
box blank. You do not need to rank a student to have them be scheduled for a
meeting. Your selections just provide an extra way for a meeting to be
scheduled.</p>

<table cols="2">
<tr><th>Pri</th><th>Student</th><th>Classes</th><th>Number of Conferences<br />(for students in<br />multiple classes)</th></tr>
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
	%><tr><td class="priority"><select name="student<%= ((Integer)hasIDs.get(i)).intValue() %>" >
		<option value="-1"></option>
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
			%><option value="<%= j %>" <%= j == rank ? "SELECTED" : "" %>><%= j %></option><%
		}%>
	</select></td><td class="name"><%= (String)has.get(i) %></td><td class="classes"><%= (String)classes.get(i) %><% 
	boolean doubled = false;
	//int i2 = i;
	while ( (i+1) < has.size() && has.get( i ).equals( has.get( i+1 ) ) ) {
	    if ( !doubled ) {
		%><br /><%= classes.get( i+1 ) %><%
	    }
	    doubled = true;
	    i++;
	} %></td><td class="multiple"><%
	if ( doubled ) { %>
<input type="radio" name="multiple<%= ((Integer)hasIDs.get(i)).intValue() %>" value="no"  <%= !multiple_selected ? "checked=\"checked\"" : "" %> />One
<input type="radio" name="multiple<%= ((Integer)hasIDs.get(i)).intValue() %>" value="yes" <%=  multiple_selected ? "checked=\"checked\"" : "" %> />Two
	<% } else {
		%>
<input type="radio" name="multiple<%= ((Integer)hasIDs.get(i)).intValue() %>" value="no"  disabled="disabled" checked="checked" />One
<input type="radio" name="multiple<%= ((Integer)hasIDs.get(i)).intValue() %>" value="yes" disabled="disabled"                   />Two
	<% }
	%></td></tr><%
}
 %>
</table>

<p><input type="submit" value="Continue"/></p>
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
		    if ( mult != null && mult.equals( "yes" ) ) {
			results.updateInt( 5, 2 );
		    } else {
			results.updateInt( 5, 1 );
		    }
		    results.insertRow();
		    none = false;		
		} catch (NumberFormatException e ) {
			throw new Exception("Student priority parameter is not a valid number.", e);
		}
	}
} 

results.close();

if (!errors) {
	state.execute("UPDATE teachers SET hasSetPrefs = 1 WHERE teacherID = " + teacherID);
}

%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="/teacher/request3.jsp" />
<% } %>
<% } %>
</body>
</html>
