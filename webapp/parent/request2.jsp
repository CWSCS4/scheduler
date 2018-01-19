<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<% if (request.getParameter("submitted2") == null || !request.getParameter("submitted2").equals("yes")) { %>
<h2>Select Teachers (Step 2)</h2>
<form action="/parent/request2.jsp" method="post">
<p>Select the teachers that you would like to meet with
and the priority ranking of that meeting:
(9 is the highest priority.)
If you do not need to meet with a teacher
please leave the priority box blank.</p>
<% 
ResultSet results = state.executeQuery("SELECT teachers.teacherID, teachers.name, classes.name FROM classMembers LEFT JOIN classes ON classMembers.classID = classes.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE classMembers.studentID = " + studentID + " ORDER BY teachers.teacherID");

Vector has = new Vector();
Vector classes = new Vector();
Vector hasIDs = new Vector();
while (results.next()) {
    hasIDs.add(new Integer(results.getInt(1)));
    has.add(results.getString(2));
    classes.add(results.getString(3));
}

for (int i = 0; i < has.size(); i++) { 
    results = state.executeQuery("SELECT withID, rank, max_conferences FROM preferences WHERE isTeacher = 0 AND ID = " + studentID);
	%><p><select name="teacher<%= ((Integer)hasIDs.get(i)).intValue() %>">
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
	</select> <%= (String)has.get(i) %> (<%= (String)classes.get(i) %><% 
	boolean doubled = false;
	//int i2 = i;
	while ((i + 1) < has.size() && has.get(i).equals(has.get(i + 1))) {
%>, <%= classes.get(i + 1) %>
	<% doubled = true;
	i++;
	}
%>)
	<% if (doubled) { %>
	    Request second conference? <input type="checkbox" name="multiple<%= ((Integer)hasIDs.get(i-1)).intValue() %>" value="checked" <%= multiple_selected ? "CHECKED" : "" %> /> <%
	} %>
</p>
<% } %>
<p>Because there is limited time available for teachers to meet with parents,
and since you may have already been in touch with some teachers, please select
only the teachers that you truly need to see.</p>
<p><input type="submit" value="Continue"/></p>
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
		} catch (NumberFormatException e) {
			session.setAttribute("errorMessage", "Some teacher priority parameters were not valid numbers.");
			throw e;
		}
	}
} 

if ( !errors && none ) {
   errors = true;
   %><br>You did not select any teachers to meet.<%
}

if (!errors) {
	state.execute("UPDATE students SET hasSetPrefs = 1 WHERE studentID = " + studentID);
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
