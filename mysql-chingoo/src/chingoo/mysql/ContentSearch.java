package chingoo.mysql;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class ContentSearch {

	private Connect cn;
	
	private String searchKeyword;
	private String matchType;

//	private static ContentSearch instance = null;
	static String urlString = null;
	
	private static boolean running = false;
	private static boolean skipTable = false;	
	private static String progressStr;
	private int totalTableCount;
	private int currentTableIndex;
	private String currentTable;
	private int currentRow;
	
	private ContentSearch() {
	}
	
	public static ContentSearch getInstance() {
/*		if (instance==null && urlString==null) {
			urlString = urlStr;
			instance = new ContentSearch();
		}*/
		ContentSearch instance = new ContentSearch();
		return instance; 
	}
	
	public List<String> search(Connect cn, String searchKeyword, String inclTable, String exclTable, String matchType, String caseType) {

		this.cn = cn;
		
		this.searchKeyword = searchKeyword;
		this.matchType = matchType;

		this.progressStr = "";

/*		if (caseType.equals("ignore")) {
			this.searchKeyword = searchKeyword.toUpperCase();
		}
*/		this.searchKeyword = searchKeyword.toUpperCase();
		
		running = true;
		skipTable = false;
		List<String> tables = new ArrayList<String>();
		
		String qry = "select table_name from information_schema.tables where table_schema='" + cn.getSchemaName()+ "' and table_type='BASE TABLE' ";

		if (inclTable !=null && inclTable.length()>0) {
			qry += " AND ( ";
			StringTokenizer st = new StringTokenizer(inclTable, " ");
			int i = 0;
			while (st.hasMoreTokens()) {
				i ++;
				String token = st.nextToken();
				if (i>1) qry += " OR ";
				qry += "TABLE_NAME LIKE '%" + token.toUpperCase() + "%' ";
			}
			qry += " )";
		}
		if (exclTable !=null && exclTable.length()>0) {
			StringTokenizer st = new StringTokenizer(exclTable, " ");
			while (st.hasMoreTokens()) {
				String token = st.nextToken();
				qry += " AND TABLE_NAME NOT LIKE '%" + token.toUpperCase() + "%' ";
			}
		}
		
		qry += "ORDER BY TABLE_NAME";
		System.out.println("qry=" + qry);

		List<String> tlist = cn.queryMulti(qry);
		totalTableCount = tlist.size();
		currentTableIndex = 0;
		for (String tname : tlist) {
			currentTableIndex ++;
			currentTable = tname;
			progressStr = tname + "<br/>" + progressStr;
			String foundColumn = searchTable(tname);
			if (foundColumn!=null) {
				//System.out.println(tname + "." + foundColumn);
				tables.add(tname + "." + foundColumn.toLowerCase());
				progressStr = "&nbsp;&nbsp;&nbsp;<b>" + tname + "." + foundColumn.toLowerCase() + "</b><br/>" + progressStr;
			}
			
			if (!running) break; 
			if (skipTable) break;
		}

		running = false;
		skipTable = false;
		return tables;
	}
	
	public String searchTable(String tname) {
		String foundColumn = null;
		
		String qry = "SELECT * FROM " + tname;
		//System.out.println("qry=" + qry);
		OldQuery q = new OldQuery(cn, qry, null);
		
		ResultSet rs = q.getResultSet();
		try {
			int cnt=0;
			while (rs.next() && cnt <= Def.MAX_SEARCH_ROWS) {
				if (!running) break; 
				if (skipTable) break;
				cnt++;
				currentRow = cnt;
				for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){
					String val = q.getValue(i);
					if (val==null || val.equals("")) continue;
					//if (caseType.equals("ignore")) val = val.toUpperCase();
					val = val.toUpperCase();
					
					
					//System.out.println(val + "," + searchKeyword);
					if (matchType.equals("exact")) {

						if (val.equals(searchKeyword)) {
							foundColumn = q.getColumnLabel(i);
							break;
						}
					} else {
						if (val.contains(searchKeyword)) {
							foundColumn = q.getColumnLabel(i);
							break;
						}
					}
				}
				
				if (foundColumn != null) break;
			}
			skipTable = false;
			q.close();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		
		return foundColumn;
	}
	
	public void cancel() {
		running = false; 
		skipTable = false;
	}

	public void skip() {
		skipTable = true; 
	}
	
	public String getProgress() {
		int percent = 0;
		
		if (totalTableCount >0)
			percent = (100 * currentTableIndex) / totalTableCount;
		
		String status = "Processing " + currentTableIndex + " of " + totalTableCount + "<br/>" +
				currentTable + " " + currentRow + "<br/>";

		if (!running)
			status = "Finished " + currentTableIndex + " of " + totalTableCount +
				"<br/>";

		status += 
				"<div class='meter-wrap' id='meter-ex1' style='cursor: pointer'>"+
				"<div class='meter-value' style='background-color: rgb(77, 164, 243); width: " + percent + "%; '>"+
				"<div class='meter-text'>" + percent + "%</div>" +
				"</div>" +
				"</div><br/>";	
		
		return status + progressStr;
		
	}
}
