<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
<script src="/js/jquery.barrating.min.js"></script>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<% if (request.getParameter("submitted2") == null || !request.getParameter("submitted2").equals("yes")) { %>
<h2>Select Teachers for <%= studentName %> (Step 2)</h2>
<form action="/parent/request2.jsp" method="post" id="teacherForm">
<p>Check the checkbox for teacher you would like to meet with, then indicate how important it is that you meet with each one.</p>
<p>Because there is limited time available for teachers to meet with parents,
		and since you may have already been in touch with some teachers, please select
		only the teachers that you truly need to see.</p>

<div id="boxes">
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
	%>


	<div class="col">
		<div class="box box-blue box-example-movie">
      <div class="box-header" style="display: flex;padding: 0;">
          <p style="align-self: center; display: block;margin: auto;width: 50%;border-right: solid 1px white;padding: .5em;"><%= (String)has.get(i) %> (<%= (String)classes.get(i) %><% 
            boolean doubled = false;
            //int i2 = i;
            while ((i + 1) < has.size() && has.get(i).equals(has.get(i + 1))) {
          %>, <%= classes.get(i + 1) %>
            <% doubled = true;
            i++;
            }
          %>)</p>
          <p style="margin: 0;align-self: center;width: 50%;">
            <input class="teacherMeetBox" id="meetBox<%= ((Integer)hasIDs.get(i)).intValue() %>" teacherId="<%= ((Integer)hasIDs.get(i)).intValue() %>" type="checkbox" style="display: inline;">
            <span style="margin-left: 10px;">meet with this teacher?</span></p></div>
    
			<div class="box-body" id="boxBody<%= ((Integer)hasIDs.get(i)).intValue() %>" style="display:none; padding-top:0.5em; padding-bottom:3em;">
				<div class="preferenceInstructionsBox" style="flex-direction: column;flex-grow: 2;align-items: center;display: flex;margin-left:1.25em;margin-right:0.75em;">
					<p>How important is it that you meet with this teacher?</p>
					<select class="preferenceBar" id="bar<%= ((Integer)hasIDs.get(i)).intValue() %>" name="teacher<%= ((Integer)hasIDs.get(i)).intValue() %>" autocomplete="off">
							<option value="-1" hidden style="display:none;">Click on the bar to choose</option>
							<option value="1">Not Important</option>
							<option value="3">Somewhat Important</option>
							<option value="5" selected="selected">Important</option>
							<option value="7">Very Important</option>
							<option value="9">Urgent</option>
					</select>
				</div>
				<% if (doubled) { %>
					<div class="secondMeetingBox" style="flex-direction: column;flex-grow: 1;align-items: center;display: flex;margin-left:0.75em;margin-right:1.25em;">
							<p> Check the box if you would like to schedule a second meeting:</p>
						<input type="checkbox" name="multiple<%= ((Integer)hasIDs.get(i-1)).intValue() %>" class="2ndMeetingBox" id="2ndBox<%= ((Integer)hasIDs.get(i)).intValue() %>" value="checked"/>
					</div>

				<% } %>

			</div>
		</div>
	</div>

<% } %>
</div>
<script type="text/javascript">



$(function() {
      $('.preferenceBar').barrating({
        theme: 'bars-movie'
      });
   });
	
  $(window).bind("pageshow", function() {
    $("input.teacherMeetBox").change(function(){
      $("[data-rating-value='-1']").remove();
      var teacherID = $(this).attr("teacherId");
      var el = $(".box-body#boxBody" + teacherID);
      console.log(teacherID);
      var slideSpeed = "fast"
      if(this.checked){
        el.slideDown(slideSpeed);
      }else{
        el.slideUp(slideSpeed);
      }
      $("select.preferenceBar#bar" + teacherID).barrating('clear');
      $("select.preferenceBar#bar" + teacherID).val("-1");
      console.log("Icons only");
    });
    $(".br-current-rating").css('width', '0');
    $("input.teacherMeetBox").prop('checked', false);
    $("input.teacherMeetBox").trigger("change")
  });
</script>

<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted2" value="yes"/>
</form>

<!-- Style for teacher card: -->
<style>
	.br-theme-bars-movie .br-widget {
  height: 10px;
  white-space: nowrap;
}
.box {
	font-family: 'Lato', sans-serif;

  width: 100%;
  float: left;
  margin: 1em 0;
}
.box .box-header {
  text-align: center;
  font-weight: 400;
  padding: .5em 0;
}
.box .box-body {
  height: 85px;
  display: flex;
  /* rating widgets will be absolutely centered relative to box body */
  position: relative;
  flex-direction:row;
}
.box select {
	margin: auto;
  width: 120px;
  margin: 10px auto 0 auto;
  display: block;
  font-size: 16px;
}
.box-large .box-body {
  height: 120px;
}
.br-theme-bars-movie .br-widget a {
  display: block;
  width: 54px;
  height: 18px;
  float: left;
  background-color: #bbcefb;
  margin: 1px;
}
.br-theme-bars-movie .br-widget a.br-active,
.br-theme-bars-movie .br-widget a.br-selected {
  background-color: #4278F5;
}
.br-theme-bars-movie .br-widget .br-current-rating {
  clear: both;
  width: 288px;
  text-align: center;
  font-weight: 600;
  display: block;
  padding: .5em 0;
  color: #4278F5;
  font-weight: 400;
}
.br-theme-bars-movie .br-readonly a {
  cursor: default;
}
.br-theme-bars-movie .br-readonly a.br-active,
.br-theme-bars-movie .br-readonly a.br-selected {
  background-color: #729bf8;
}
.br-theme-bars-movie .br-readonly .br-current-rating {
  color: #729bf8;
}
.box-blue .box-header {
  background-color: #4278f5;
  color: white;
}
.box-blue .box-body {
  /* background-color: white; */
  border: 2px solid #8bacf9;
  border-top: 0;
}
@media print {
  .star-ratings h1 {
    color: black;
  }
  .star-ratings .stars .title {
    color: black;
  }
  .box-orange .box-header,
  .box-green .box-header,
  .box-blue .box-header {
    background-color: transparent;
    color: black;
  }
  .box-orange .box-body,
  .box-green .box-body,
  .box-blue .box-body {
    background-color: transparent;
    border: none;
  }
}

#teacherForm{
  width: 800px;
}


</style>

<script>
/*	var util = {};
util.post = function(url, fields) {
    var $form = $('<form>', {
        action: url,
        method: 'post'
    });
    $.each(fields, function(key, val) {
         $('<input>').attr({
             type: "hidden",
             name: key,
             value: val
         }).appendTo($form);
    });
    $form.appendTo('body').submit();
}*/

//util.post('/parent/request2.jsp', {'teacher1020': '9', 'multiple1020': 'checked', 'submitted2': 'yes'})

$( "#teacherForm" ).submit(function( event ) {
  console.log("Submt caled");
  var meetBoxes = $(".teacherMeetBox");
  for(var i = 0; i < meetBoxes.length; i++){
    if($(meetBoxes[i]).prop('checked') && $("select.preferenceBar#bar" + $(meetBoxes[i]).attr('teacherId')).val() == "-1"){
      alert("You checked the box for some teachers but didn't set an importance! Please choose one in order to proceed.")
      event.preventDefault();
      location.hash = "#bar" + $(meetBoxes[i]).attr('teacherId');
      break;
    }
  }
});
</script>


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
