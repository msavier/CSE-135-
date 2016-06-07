

function updateCellValue() {


	console.log("test");
	
	var xmlHttp=new XMLHttpRequest();	
	
	xmlHttp.onreadystatechange=function() {
		if (xmlHttp.readyState != 4) return;
		
		if (xmlHttp.status != 200) {
			alert("HTTP status is " + xmlHttp.status + " instead of 200");
			return;
		};

		var returnobj = JSON.parse(xmlHttp.responseText);
		var arrays = returnobj["arrays"]; 

		var cellArray = arrays[0];
		var headerCellArray = arrays[1];
		
		if(cellArray.length > 0){
			alert("cell array length = " +cellArray.length );
		}
		
		

		for(var i = 0; i < cellArray.length; i++) {
		    var obj = cellArray[i];

			var cell = document.getElementById( obj["cellid"]);
			cell.style.color = "#FF0000";
			cell.innerHTML = obj["updateValue"];
		}


		for(var i = 0; i < headerCellArray.length; i++) {
		    var obj = headerCellArray[i];

			var cell = document.getElementById( obj["cellid"]);
			cell.style.color = "#FF0000";
			var celltext = obj["name"] + " $" + obj["updateValue"];
			cell.innerHTML = celltext;
		}




	};


	var url = "processAjaxCell.jsp";
	xmlHttp.open("GET",url,true);
	xmlHttp.send();
	
	 updateColumn();
	
}



function updateColumn(){

	var xmlHttp=new XMLHttpRequest();	
	
	xmlHttp.onreadystatechange=function() {
		if (xmlHttp.readyState != 4) return;
		
		if (xmlHttp.status != 200) {
			alert("HTTP status is " + xmlHttp.status + " instead of 200");
			return;
		};

		var jsonCell = JSON.parse(xmlHttp.responseText);
		var cellArray = jsonCell["cellArray"];

		var colstr = cellArray[0];
		var purple = colstr["columns"];

		
		if(purple == "nothing"){
			alert("nothing new for columns");
		}
		
		else{
			var productList = purple.split(",");
			
			var table = document.getElementById("table");
			

			
			
			console.log("before for productlist");	
			for (i = 0; i < productList.length; i++) {
				
		    		for (var r = 0, n = table.rows.length; r < n; r++) {
		     	   		for (var c = 0, m = table.rows[r].cells.length; c < m; c++) {
		     
		     	   		var temp = productList[i];
		     	   		console.log(productList[i]);

		     	   		if(c == productList[i]) {
		     	 
		     	   			table.rows[r].cells[c].style.backgroundColor  = "#FF00FF";
		     	   		}
		           	 }
		       	}
		    }
		}



		var headerstr = cellArray[1];
		var prodNames = headerstr["prodstr"];

		
		if(prodNames == "nothing"){
			alert("nothing new for products names");
		}


		else{
			
			var productList = "The products now in the top 50 are " + prodNames;
			document.getElementById("productHeader").innerHTML = productList;

			

			
			

		}

		




			
		//	table.rows[5].cells[2].style.color = "#FF00FF";


	};


	var url = "processAjax.jsp";
	xmlHttp.open("GET",url,true);
	xmlHttp.send();
}


















