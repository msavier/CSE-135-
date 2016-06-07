<%@ page import="java.util.*, javax.sql.*, java.sql.*, javax.naming.*, java.lang.*, cell.*, java.util.Hashtable, org.json.simple.JSONObject,  org.json.simple.*"%>

<%

System.out.println("in ajax cell");


Hashtable<String, Cell> cellTable =(Hashtable<String, Cell>)(application.getAttribute("cellTable"));
Hashtable<String, Cell> headerTable =(Hashtable<String, Cell>)(application.getAttribute("headerTable"));

	Connection conn = null;
	ResultSet rs = null;
	Statement stmt = null;
		try {
		Class.forName("org.postgresql.Driver");
		String url="jdbc:postgresql://localhost/cse135";
	    String user="postgres";
	    String password="postgres";
  	conn = DriverManager.getConnection(url, user, password);
	}
	catch (Exception e) {}




	String sql = "select product_id, states, sum(price) as totalPrice from log group by product_id, states";

	stmt = conn.createStatement();
	rs = stmt.executeQuery(sql);

	JSONArray cellArray = new JSONArray();

	System.out.println("size is " + cellTable.size()) ;
	//Cell c = (Cell)cellTable.get("FL_5");
	

	// System.out.println(  c.getOrigVal()   );
	// System.out.println(  c.getCellId() );
	 
	List<String> headerUpdates = new ArrayList<String>();
	 
	 
	while (rs.next()){
		String key = rs.getString(2) + "_" + rs.getString(1);
		System.out.println("key  is "  + key);
		Cell cellobj= (Cell) cellTable.get(key);
		if(cellobj != null){
			int x =cellobj.getCellId();
			System.out.println("not null");
			System.out.println("cellid is " +cellobj.getCellId());
			
			
			JSONObject celljson = new JSONObject();
			
			float updateValue = cellobj.getOrigVal() + rs.getInt(3);
			celljson.put("updateValue", updateValue);
			System.out.println("origi value is " + cellobj.getOrigVal() + "addvalue is " + rs.getInt(3) + "total value is " +  updateValue);
			celljson.put("cellid", cellobj.getCellId());
			celljson.put("statename", cellobj.getstateName());
			cellArray.add(celljson);
			
			
			
			
			Cell statecell = (Cell) headerTable.get(cellobj.getstateName());
			Cell productcell = (Cell) headerTable.get(cellobj.getProdName());
			
			if(headerUpdates.contains(statecell.getstateName()) == false){
				headerUpdates.add(statecell.getstateName());	
			}
			
			float val = statecell.getOrigVal() + updateValue;
			statecell.setOrigVal(val);
			String headerkey = (statecell.getstateName());
			headerTable.put(key,statecell );
			
			if(headerUpdates.contains(productcell.getProdName()) == false){
				headerUpdates.add(productcell.getProdName());	
			}
			
			val = productcell.getOrigVal() + updateValue;
			productcell.setOrigVal(val);
			headerkey = (productcell.getstateName());
			headerTable.put(key,productcell );
			
			
			
			
		}
		else{
			System.out.println("null");
		}

	}

	JSONArray headerCellArray = new JSONArray();
	
	for (String headerName : headerUpdates) {
		
		Cell headerCell = (Cell) headerTable.get(headerName);
		JSONObject headerCellobj = new JSONObject();
		headerCellobj.put("cellid", headerCell.getCellId());
		headerCellobj.put("updateValue", headerCell.getOrigVal());
		
		if( headerCell.getCellType() == 1) {
			headerCellobj.put(("name"),  headerCell.getProdName());
		}
		else if( headerCell.getCellType() == 2) {
			headerCellobj.put(("name"),  headerCell.getstateName());
		}
		else {
			headerCellobj.put(("name"), ""  );
		} 
		headerCellArray.add(headerCellobj);

	}
	
	
	JSONArray arrays = new JSONArray();
	arrays.add(cellArray);
	arrays.add(headerCellArray);

	
	JSONObject returnobj = new JSONObject();
	returnobj.put("arrays", arrays);
	
	/*
	JSONObject returnobj = new JSONObject();
	returnobj.put("cellArray", cellArray);
	*/

	out.print(returnobj);
	out.flush();












%>































