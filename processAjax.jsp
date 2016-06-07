<%@ page import="java.util.*, cell.*, java.lang.*, java.sql.*, javax.naming.*, javax.sql.*, org.json.simple.*" %>

<%
//get the sum of all orders in log, grouping by product



Hashtable<String, Cell> cellTable =(Hashtable<String, Cell>)(application.getAttribute("cellTable"));
Hashtable<String, Cell> headerTable =(Hashtable<String, Cell>)(application.getAttribute("headerTable"));



try {
	System.out.println("1");
	Class.forName("org.postgresql.Driver");
	String url="jdbc:postgresql://localhost/cse135";
    String user="postgres";
    String password="postgres";
    
	Connection cn = DriverManager.getConnection(url, user, password);
    Statement st = cn.createStatement();
    ResultSet rs = st.executeQuery("SELECT product_id, SUM(price) AS logTot FROM log GROUP BY product_id");
    
    
    /*  THE CODE FROM BEFORE
    // update uprodtable
    if (!rs.isBeforeFirst()) {  // log empty, don't need to update anything
        throw new Exception();
    }
    while (rs.next()) {
    	st = cn.createStatement();
    	int results = st.executeUpdate("UPDATE utopproducts SET sales=sales+" + rs.getInt(2) + "WHERE product_id=" + rs.getInt(1));
    }
*/
    
    
    
    
    
    
   // update uprodtable
    if (rs.isBeforeFirst()) {  // log not empty
        st = cn.createStatement();
        st.executeUpdate("UPDATE utopproducts SET refreshed=FALSE");
    	while (rs.next()) {
            st = cn.createStatement();
            st.executeUpdate("UPDATE utopproducts SET refreshed=TRUE, sales=sales+" + rs.getInt(2) + " WHERE product_id=" + rs.getInt(1));
        }
        // "reset" log
        st = cn.createStatement();
        st.executeUpdate("TRUNCATE TABLE log");
    }
    else {  // log empty, was utopproducts updated (from another owner refresh)?
        st = cn.createStatement();
        rs = st.executeQuery("SELECT * FROM utopproducts WHERE refreshed=TRUE");
    	if (!rs.next()) {  // nope, nothing to update then
            throw new Exception();
        }
        System.out.println("*** Yay");
    }
    
    
    
    
    List<Integer> updatedTableid = new ArrayList<Integer>();
    List<String> updatedTablename = new ArrayList<String>();
    List<String> origTablename = new ArrayList<String>();
    

        // check if row from top50(origtable) is in top50(uprodtable), 1 row at a time
    st = cn.createStatement();
    ResultSet rsOT = st.executeQuery("SELECT product_id, product_name FROM topproductsorig ORDER BY sales DESC LIMIT 50");
    
    st = cn.createStatement();
    ResultSet rsUT = st.executeQuery("SELECT product_id, product_name FROM utopproducts ORDER BY sales DESC LIMIT 50");


    while (rsUT.next()) {
    	updatedTableid.add(rsUT.getInt(1));
        updatedTablename.add(rsUT.getString(2));
    	//  System.out.println(rsUT.getInt(1) + "," + rsUT.getInt(2));
    }
 //   System.out.println(updatedTableid.size());
  //  System.out.println(updatedTablename.size());



    
    //   CASE 2
    //     if the product with product_id is in OT but not UT,
    //     call ajax function to update that specific product column and turn it purple
    boolean found = false;
    int rowid = 1;
    boolean first = false;
    String purple = "";
    JSONArray cellArray = new JSONArray();
          
    while (rsOT.next()) {  // product_id
        origTablename.add(rsOT.getString(2));  //product name

        found = false;
        if ( updatedTableid.contains( rsOT.getInt(1)) ){
        	  found = true;
        }
        
        else {
        	 System.out.println("orig column not found in new top 50");
            if (!first) {  // just don't want comma in front if first
                purple += rowid;
            	first = true;
            }
            else {
                purple += "," + rowid;
            }
        }
        rowid++;
    }

    System.out.println("colums are " + purple);
    if(purple.length()==0){
        System.out.println("nothing for columns");
        purple = "nothing";
    }

    JSONObject colstr = new JSONObject(); 
    colstr.put("columns", purple);
    cellArray.add(colstr);
   

    found = false;
    first = false;
    String headerUpdate = "";
    for (String productName : updatedTablename) {  // product_name

        found = false;
        if ( origTablename.contains( productName) ){
              found = true;
        }
        
        else {
             System.out.println("product " + productName + " name not found in original table");
             Cell headerCell = (Cell) headerTable.get(productName);
             String money ="";
             if(headerCell != null){
            	 money = Float.toString(headerCell.getOrigVal());
             }
             
            if (!first) {  // just don't want comma in front if first
            	String up = "" + productName + "($" + money + ")";
                headerUpdate += up ;
                first = true;
            }
            else {
                headerUpdate += "," + productName;
            }
        }
        rowid++;
    }

    System.out.println("new prod names are " + headerUpdate);
    if(headerUpdate.length()==0){
        System.out.println("no new prod names in top 50");
        headerUpdate = "nothing";
    }

    JSONObject prodstr = new JSONObject(); 
    prodstr.put("prodstr", headerUpdate);
    cellArray.add(prodstr);

/* STUFF FROM BEFORE
    st = cn.createStatement();
    st.executeUpdate("truncate table log");
*/
    JSONObject returnobj = new JSONObject();
    returnobj.put("cellArray", cellArray);

    out.print(returnobj);
    out.flush();


  //  st = cn.createStatement();
   // st.executeUpdate("truncate table topproductsorig");



   // out.print(purple);
  //  response.getWriter().write(purple);
    //   CASE 1
} catch (Exception e) {
	
	 System.out.println(e);
}
%>
