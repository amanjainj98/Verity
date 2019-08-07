/**
 * Sample javascript file. Read the contents and understand them, then modify
 * this file for your use case.
 */

var myTable1;

$(document).ready(

function beginWork() {
	myTable1 = $("#usersTable").DataTable({
		columns : [ {
			data : "uid"
		}, {
			data : "last_timestamp"
		}, {
			data : "num_msgs"
		} ]
	});

	loadTableAsync();

	$('#usersTable tbody').on('click', 'tr', function() {
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');
		} else {
			myTable1.$('tr.selected').removeClass('selected');
			$(this).addClass('selected');
		}
		// Getting conversation details from here

		showMessages(myTable1.row(this).data()["uid"]);

	});
	$('#usersTable_filter').find('input[type="search"]').autocomplete({
		source : "AutoCompleteUser?source=usersTable",
		select :function(event,ui){
			var id=ui.item.label.split(" ")[0];
			console.log(id);
			showMessages(id);
		}
	});


});

function loadTableAsync() {
	myTable1.ajax.url("AllConversations").load();
}

function showMessages(str) {
	var xhttp;
	if (str == "") {
		console.log("string is null");
		return;
	}
	xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			var ob = JSON.parse(this.responseText);

			var myStr = "<table border=1px>";

			for (i in ob.data) {
				myStr += "<tr> <td> " + ob.data[i].uid + " </td> <td>"
						+ ob.data[i].timestamp + " </td> <td>"
						+ ob.data[i].text + "</td> " +
						"<td><button onclick=\"confirmDelete(\'"+ob.data[i].post_id+"\',\'"+str+"\')\">Delete</button></td>"+
						"</tr>";
			}

			myStr += "</table>";
			myStr += "<form action=\"javascript:newMsg(msg.value, other_id.value )\">"
					+ "New Message:<br>"
					+ "<input type=\"text\" name=\"msg\" id=\"msg\"> "
					+
					// "<input type=\"hidden\" name=\"name_default\" id=
					// value=\"name_default\" />
					"<input type=\"hidden\" name=\"other_id\" id=\"other_id\" value="
					+ str
					+ ">"
					+ "<br>"
					+ "<input type=\"submit\" value=\"Send\">" + "</form>";
			document.getElementById("content").innerHTML = myStr;
		}
	};
	xhttp.open("POST", "ConversationDetail?other_id=" + str, true);
	xhttp.send();
}

function confirmDelete(post_id,str){
	if (post_id == null || post_id == "") {
		return;
	}
	var xhttp;
	if(!confirm("Do you want to delete the message?"))	return;
	xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			var result =  JSON.parse(xhttp.response)['status'];
			console.log(result);
			if(result == 0){
				alert("Could not delete");
				showMessages(str);
			}
			showMessages(str);
		}
	};

	xhttp.open("POST", "deletePost?post_id=" + post_id, true);
	xhttp.send();
	
}

function newMsg(msg, other_id) {

	if (msg == null || msg == "") {
		return;
	}
	var xhttp;

	xhttp = new XMLHttpRequest();
	// console.log("Msg is " + msg);
	//
	// console.log("oid " + other_id);
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {

			console.log(xhttp.response);
			var result =  JSON.parse(xhttp.response)['status'];
			if(result == 0){
				alert("Error");
				goHome();
			}
			showMessages(other_id);
		}
	};

	xhttp.open("POST", "NewMessage?other_id=" + other_id + "&msg=" + msg, true);
	xhttp.send();
}

function sendMessage(msg) {
	var xhttp;
	if (str == "") {
		document.getElementById("content").innerHTML = "";
		return;
	}
	xhttp = new XMLHttpRequest();

	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			showMessages(str);
		}
	};

	xhttp.open("POST", "NewMessage", true); // ?other_id="+"p2" + "?msg=" +
											// document.getElementById(msg),
											// true);
	xhttp.send();

}

function goHome(){
	document.getElementById("content").innerHTML = "<table id=\"usersTable\" class=\"display\"> <thead>" + 
	"        <tr> <th>User ID</th> <th>Name</th> <th>Phone</th> </tr>" + 
	"        </thead>" + 
	"    </table>";
	myTable1 = $("#usersTable").DataTable({
		columns : [ {
			data : "uid"
		}, {
			data : "last_timestamp"
		}, {
			data : "num_msgs"
		} ]
	});
	loadTableAsync();
	$('#usersTable_filter').find('input[type="search"]').autocomplete({
		source : "AutoCompleteUser?source=usersTable",
		select :function(event,ui){
			var id=ui.item.label.split(" ")[0];
			console.log(id);
			showMessages(id);
		}
	});

	$('#usersTable tbody').on('click', 'tr', function() {
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');
		} else {
			myTable1.$('tr.selected').removeClass('selected');
			$(this).addClass('selected');
		}
		// Getting conversation details from here

		showMessages(myTable1.row(this).data()["uid"]);

	});

}

function createConversation(){
	document.getElementById("content").innerHTML = "<form action=\"javascript:jscreateConversation(other_id.value)\" id=\"conversation\" method=\"get\">" +
												   "<input type=\"search\" name=\"other_id\" id=\"other_id\">" +
												   "<input type=\"submit\" value=\"Start conversation\"></form>";

	$('#other_id').autocomplete({
		source : "AutoCompleteUser?source=createConversation",
	});
}

function jscreateConversation(str){

	var xhttp;
	if (str == "") {
		document.getElementById("content").innerHTML = "";
		return;
	}
	xhttp = new XMLHttpRequest();

	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var result =  JSON.parse(xhttp.response)['status'];
			console.log(result);
			if(result == 0){
				alert("could not create conversation");
			}
			goHome();
		}
	};

	xhttp.open("POST", "CreateConversation?other_id="+str, true); // ?other_id="+"p2" + "?msg=" +
											// document.getElementById(msg),
											// true);
	xhttp.send();
}

function reset(){
	loadTableAsync();
	$('#usersTable_filter').find('input[type="search"]').autocomplete({
		source : "AutoCompleteUser?source=usersTable",
		select :function(event,ui){
			var id=ui.item.label.split(" ")[0];
			console.log(id);
			showMessages(id);
		}
	});

}


