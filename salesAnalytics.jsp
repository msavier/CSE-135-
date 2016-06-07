<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="cell.*, java.sql.*, java.util.*, javax.naming.*, java.lang.*, java.util.Hashtable, org.json.simple.JSONObject,  org.json.simple.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>



   	   <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
	<script type="text/javascript" src="updateTablejs.js"></script>
	
	
	
</head>


<% 
String rows= ""; 
String order= ""; 
String state = "";
int totalRows = 0;
int totalCols = 0;
Boolean next_clicked = false;



if(application.getAttribute("cellTable")==null) {
    application.setAttribute("cellTable", new Hashtable<String, Cell>());
}

if(application.getAttribute("headerTable")==null) {
    application.setAttribute("headerTable", new Hashtable<String, Cell>());
}



Hashtable<String, Cell> cellTable =  new Hashtable<String, Cell>();
Hashtable<String, Cell> headerTable =  new Hashtable<String, Cell>();
	
long   query1Start, query1Finish, query2Start, query2Finish, query3Start, query3Finish, query4Start, query4Finish;
double query1Time, query2Time, query3Time, query4Time;





	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs, r1, r2, r3, r4 = null;
	String SQL = null; 
	Statement stmt = null;
 	String row_offset = "";
 	String col_offset = "";
	try {
		Class.forName("org.postgresql.Driver");
		String url="jdbc:postgresql://localhost/cse135";
	    String user="postgres";
	    String password="postgres";
		conn =DriverManager.getConnection(url, user, password);
    System.out.println("GOOD DRIVER");
 

		    
		    state = request.getParameter("filter");
		    if(state == null){
		    	state = "all_filter";
		    }
		    application.setAttribute("cat_filter", state);
		    System.out.println("filter is " + state);
		    
		    String sql, sql1, sql2, sql3 = "";
		     
		     
		
       %>
       
       <form action="salesAnalytics.jsp" method="post">

<body>
<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="login.jsp">LOGIN</a></li>
		<li><a href="signup.jsp">SIGN UP</a></li>
	</ul>
</div>
<div>
	<h1 id="productHeader"></h1>
	
	<%
		sql = "Select name, id from categories";
		stmt = conn.createStatement();
		rs = stmt.executeQuery(sql);
	%>
		
		    <div class="form-group">
	  	<label for="filter">Filter</label>
	  	<select name="filter" id="filter" class="form-control">
	  		    <option value="all_filter" selected>All</option>
	
	<%
		while (rs.next()){
			if(rs.getString(2).equals(state)){
	%>
				<option value=  <%=rs.getString(2) %> selected> <%=rs.getString(1) %>    </option>	
	<% 	
			}
			else { %>
				<option value=  <%=rs.getString(2) %> > <%=rs.getString(1) %>    </option>	<% 
			}
		}
	%>

	</select>
	
	
  </div>

    <div class="form-group">
  	<input class="btn btn-primary" type="submit" value="Generate Data">
  </div>
  
</form>
   
       <table border = "2" id = "table" >
    
       <% 
    
       
       //query for row headers - TOP - K order
       
    stmt = conn.createStatement();
    stmt.executeUpdate("truncate table utopproducts");
    stmt = conn.createStatement();
    stmt.executeUpdate("truncate table topproductsorig");
    
    
    

 	sql1 = "SELECT state.name, state.id, COALESCE (SUM(o.price), 0) AS amount, COUNT(*) OVER () as totalRows" + 			
 			" FROM (SELECT name, id FROM states ORDER BY name )" +
 			" AS state JOIN users u ON (state.id = u.state_id)" + 
 			" LEFT JOIN orders o ON (o.user_id = state.id)" + 
 			" GROUP BY state.name, state.id" + 
 			" order by COALESCE (SUM(o.price), 0)  desc"		;	
 			
 		  
    		   
    String utablesql =null;
    String origtablesql = null;
    //query for product headers - TOP - K order
   if(state.equals("all_filter") || state.equals(null) ){
    	
    	
 		sql2 = "SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount, COUNT(*) OVER () as totalCols" + 
 	   			" FROM (SELECT id, name FROM products ORDER BY name ASC ) AS prod" +
 	   			" LEFT JOIN orders ON (orders.product_id = prod.id)" +
 	   			" GROUP BY prod.id, prod.name" +
 	   			" order by COALESCE (SUM(orders.price), 0) desc LIMIT 50";
 	
 		
 		origtablesql =" insert into topproductsorig (product_id, product_name, sales) SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount" + 
 	   			" FROM (SELECT id, name FROM products ORDER BY name ASC ) AS prod" +
 	   			" LEFT JOIN orders ON (orders.product_id = prod.id)" +
 	   			" GROUP BY prod.id, prod.name" +
 	   			" order by COALESCE (SUM(orders.price), 0) desc";
 		
 		
 		 utablesql =" insert into utopproducts (product_id, product_name, sales, refreshed)  SELECT product_id, product_name, sales, FALSE from topproductsorig";
 		
   	}
    
 	else{
 			
 			//filter present
 			System.out.println("filter present");
 	    sql2 = "SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount, COUNT(*) OVER () as totalCols" + 
 	   			" FROM (SELECT id, name FROM products where products.category_id = " +state+ 
 	       		" ORDER BY name ASC ) AS prod" +
 	   			" LEFT JOIN orders ON (orders.product_id = prod.id)" +
 	   			" GROUP BY prod.id, prod.name" +
     			" order by COALESCE (SUM(orders.price), 0) desc LIMIT 50 ";		
 	   
 	  origtablesql = " insert into topproductsorig (product_id, product_name, sales) SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount" + 
	   			" FROM (SELECT id, name FROM products where products.category_id = " +state+ 
	       		" ORDER BY name ASC ) AS prod" +
	   			" LEFT JOIN orders ON (orders.product_id = prod.id)" +
	   			" GROUP BY prod.id, prod.name" +
    			" order by COALESCE (SUM(orders.price), 0) desc  ";		
	    
 	 utablesql =" insert into utopproducts (product_id, product_name, sales, refreshed)  SELECT product_id, product_name, sales, FALSE from topproductsorig";   
 	    
 	    
 	}   	
    
	try{
	stmt = conn.createStatement();
	 stmt.executeUpdate(origtablesql);
	}
	catch(Exception e){
		System.out.println("here1");
		System.out.println(e);
	}

   try{
	stmt = conn.createStatement();
	  stmt.executeUpdate(utablesql);
   }
	catch(Exception e){
		System.out.println("here2");
		System.out.println(e);
	}


 	

 	/*
 	try{
 	stmt = conn.createStatement();
    r1 = stmt.executeQuery(sql1);
 	}
 	catch(Exception e){
 		System.out.println("here");
 	}

    try{
 	stmt = conn.createStatement();
   	r2 = stmt.executeQuery(sql2);
    }
    
    catch(Exception e){
 		System.out.println("here2");
 	} */

    
    query1Start = System.nanoTime();
 	stmt = conn.createStatement();
    r1 = stmt.executeQuery(sql1);
 	query1Finish = System.nanoTime();
 	
 	query1Time = (query1Finish - query1Start) / 1000000.0;
 	System.out.println("Query 1 time = " + query1Time);

 	
    query2Start = System.nanoTime();
    stmt = conn.createStatement();
    r2 = stmt.executeQuery(sql2);
    query2Finish = System.nanoTime();
 	
 	query2Time = (query2Finish - query2Start) / 1000000.0;
 	System.out.println("Query 2 time = " + query2Time);

    
    
   	   %> <tr> <td> XXXXX </td>

	
   	   
 <%   	    //loop for product headers
 List<Integer> productid = new ArrayList<Integer>();
 List<String> productname = new ArrayList<String>();
int headerCellNumber = 5000;

 	while(r2.next()){   
 		//	System.out.println("Total prods from query = " + r2.getInt(4));
 			totalCols = r2.getInt(4);
 			productid.add(r2.getInt(1));
 			productname.add(r2.getString(2));
 			Cell cell = new Cell(r2.getString(2), Float.valueOf(r2.getString(3)), headerCellNumber, 0, headerCellNumber, "", 1 );
 			String key = r2.getString(2);
 			headerTable.put(key, cell);
 	//		System.out.println("product id into vector = " + (r2.getInt(1)));
 			String header = r2.getString("name") + " ($" + Math.round(Float.valueOf(r2.getString("amount"))) + ")";
 			%>
 			  
 		<td width=\"30%\" id="<%=headerCellNumber%>"  > <%=header %> </td>   
 	<% 	   headerCellNumber++;  	
     }
   	%> </tr> <% //end of product headers

   	
   	
 		   //loop through the users or states
 		   
 	int cellnumber = 1;
	while(r1.next()){
    	    	//query for row data
    	  //  	System.out.println(r1.getString(state) + " is state"); 			 
       
       //		System.out.println("STATES");
       		
      // 	    System.out.println("Total row names from query = " + r1.getInt(3)); 
      		int rowID = r1.getInt(2);
       	    totalRows = r1.getInt(3);
 	    	String st = r1.getString(1); 
 	    	System.out.println(st);
 	    	System.out.println(rowID);

       		
   
                //top K
		if(state.equals("all_filter") || state.equals(null) ){
					System.out.println("all no filter");
 	    		//states top k no filter
			sql3 =  "SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount" +	
 	    			" FROM (SELECT id, name FROM products ) AS prod " +
		 			" LEFT JOIN orders ON (orders.product_id = prod.id " +
					" and orders.user_id in (select id from users where state_id = " +rowID+  " ) )" +
		 			" GROUP BY prod.id, prod.name " +
		 			" order by COALESCE (SUM(orders.price), 0) DESC limit 50" ;	
		}
	       		
		else{ //states top k cat filter 
			System.out.println(" filter");
			sql3 =  "SELECT prod.id, prod.name, COALESCE (SUM(orders.price), 0) AS amount" +
					" FROM (SELECT id, name FROM products WHERE products.category_id = " +state+  ") AS prod " +
		 			" LEFT JOIN orders ON (orders.product_id = prod.id " +
					" and orders.user_id in (select id from users where state_id = " +rowID+  " ) )" +
 					" GROUP BY prod.id, prod.name " +
		 			" order by COALESCE (SUM(orders.price), 0) DESC limit 50 " ;	
	    }
	       	

     	 // end of if else for row data
       		

       		
       	//	System.out.println(sql3); 
       		//System.out.println("DSf"); 
	
    	   r3 = null;			
   		   
   		   stmt = conn.createStatement();
			try{
   		 	query3Start = System.nanoTime();
			stmt = conn.createStatement();
			r3 = stmt.executeQuery(sql3);
   		 	query3Finish = System.nanoTime();
   		 	
   		 	query3Time = (query3Finish - query3Start) / 1000000.0;
   		 	System.out.println("Query 3 time = " + query3Time);

   		   }
   		   catch(Exception e){
   			System.out.println("bad result set");
   		   }
   		   

   		String header = st + " \n ($" + Math.round(Float.valueOf(r1.getString("amount"))) + ")";
   		
   		Cell rowcell = new Cell("", Math.round(Float.valueOf(r1.getString("amount"))), headerCellNumber, 0, 0, st, 2 );
		String rowkey = st;
		headerTable.put(rowkey, rowcell);
		headerCellNumber++;
   		
   		
   		
   		

   		 %>
   		<tr> <td id="<%=headerCellNumber%>"  ><%= header %> </td> 
   		<% 
   		//loop for row data
   		int column = 1;
   		int productIndex = 0;
			while(r3.next()){
				String key = st + "_" + productid.get(productIndex);
				System.out.println("cell key is " + key);
				
				//set row as productIndex just for right now, dont want to update cell.class
				Cell cell = new Cell(productname.get(productIndex), r3.getInt("amount"), cellnumber, productid.get(productIndex), column, st, 3 );
						
				
				cellTable.put(key, cell);
				
    			//System.out.println("just added + " + productid.get(productIndex) );  
    			productIndex++;													%>
    	   		<td id="<%=cellnumber%>"   width=\"30%\" >  <%= r3.getInt("amount") %> </td> 
    	   		
    	    <%	column++;
				cellnumber++;
    	    }
			productIndex = 0;
			 application.setAttribute("cellTable", cellTable);
			 application.setAttribute("headerTable", headerTable);
			
			 //end of nested while
   			%> </tr>  <% 
   		
   		
   		
	} //end of first while
  	    


	 %>
     
     <tr><input onClick="updateCellValue(); return false;" type="button" value="Refresh"/></tr>
     </table>
     <button type="button" onClick="updateCellValue(); return false;" >Refresh</button>
     <% 
    	 

     
	}
	 catch (Exception e) {
		 System.out.println(e);
	 } 
	
	
	
	//Cell c = cellTable.get("FL_5");
	

		// System.out.println(  c.getOrigVal()   );
	//	 System.out.println(  c.getCellId() );
		
	
  //     stmt.close();
    //   conn.close();
		
 

%>


	
	


</body>
</html>
