<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<body>
<div>
	<ul class="nav navbar-nav">
		<li><a href="login.jsp">LOGIN</a></li>
		<li><a href="signup.jsp">SIGN UP</a></li>
		<li><a href="index.jsp">HOME</a></li>
	</ul>
 <form action="similarProducts.jsp" method="post">
 <div class="form-group">
  </div>

 <% 
    Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet r1, r2, r3= null;
	String SQL,sql2 = null; 
	Statement stmt = null;
	try {
		Class.forName("org.postgresql.Driver");
		String url="jdbc:postgresql://localhost/cse135small";
	    String user="postgres";
	    String password="postgres";
		conn =DriverManager.getConnection(url, user, password);
        //System.out.println("GOOD DRIVER");
        
        
        SQL = "SELECT p1.id AS p1id, p2.id AS p2id, (COALESCE((SELECT SUM(ord1.price * ord2.price)" +
        				" FROM orders ord1, orders ord2" +
        				" WHERE ord1.product_id = p1.id AND ord2.product_id = p2.id AND ord1.user_id = ord2.user_id),0)) /" +
        				" (SQRT ((SELECT SUM(POWER(price,2)) FROM orders WHERE product_id = p1.id)) * SQRT ((SELECT SUM(POWER(price,2)) FROM orders WHERE product_id = p2.id))) AS cosine" +
        			" FROM  products p1, products p2" +
        			" WHERE p1.id < p2.id" +
        			" AND p1.id IN (Select product_id FROM orders)" +
        			" AND p2.id IN (Select product_id FROM orders)" +
        			" GROUP BY p1id,p2id" +
        			" ORDER BY cosine DESC" ;
         stmt = conn.createStatement(); 
         r1 = stmt.executeQuery(SQL);
         
         %>
          <table border = "2">
          <tr>
		    <td width=\"30%\">Product 1 </td>
			<td width=\"30%\">Product 2</td>
			
			
	   </tr>
          <% 
         while(r1.next()){
        	sql2 = "SELECT p1.name AS p1, p2.name AS p2 FROM products p1, products p2" +
        			" WHERE p1.id = " +r1.getInt("p1id")+ "AND p2.id = " + r1.getInt("p2id");
        	stmt = conn.createStatement();
        	r2 = stmt.executeQuery(sql2);
        	 while(r2.next()){
        	%> 
        	<tr>
        	<td width=\"30%\"> <%=(r2.getString("p1"))%> </td> 
        	<td width=\"30%\"> <%=(r2.getString("p2"))%> </td> 
        	</tr>
        	<%
        	 }
         }
       
       %>
         </table>
       <%
       
        
        
	}
	
	catch(SQLException e){}
		 %>
		 </form>
</body>
</html>