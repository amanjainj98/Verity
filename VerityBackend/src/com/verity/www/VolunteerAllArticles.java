package com.verity.www ;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

/**
 * Servlet implementation class VolunteerAllArticles
 */
@WebServlet("/VolunteerAllArticles")
public class VolunteerAllArticles extends HttpServlet {
	private static final long serialVersionUID = 1L;
//	private static final String limit_val = "10" ; 
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerAllArticles() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		
		
		
		if(session.getAttribute("volunteer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		try {
		
		Integer volunteer_id = Integer.parseInt(session.getAttribute("volunteer_id").toString());
		System.out.println("V_ID"+volunteer_id);
		
		//select article_id,title,description,publish_time,status from article_volunteer natural join article where volunteer_id = 2 and (status = 0 or status = 2)  order by status desc,assign_time asc
		
		String query = "select article_id,title,description,publish_time,status from article_volunteer natural join article "
				+ "where volunteer_id = ? and (status = 0 or status = 2) "
				+ "order by status asc,assign_time asc";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {volunteer_id});
		
		PrintWriter out = response.getWriter();
		System.out.println("VolunteerAllArticles q1 "+res) ;
//		out.print(res);
		
		JSONObject j = new JSONObject(res) ;
		
		if (j.get("status").toString() == "false") {
			out.println(res);
			return ; 
		}
		
		String query2 = "select * from tag natural join article_tag where article_id in (select article_id from article_volunteer where volunteer_id = ? and (status = 0 or status = 2) order by status asc,assign_time asc)";
		List<List<Object>> res2 = DbHelper.executeQueryList(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {volunteer_id});
	
		JSONObject j2 = new JSONObject(res2) ;
				
		System.out.println("VolunteerAllArticles q2 " + res2) ;
		
//		if (j2.get("status").toString() == "false") {		
//			out.print(res2); s
//			return ; 
//		}
		
		JSONObject output = new JSONObject() ; 
		output.put("status","true") ;
		output.put("data", j.get("data")) ;
		output.put("tags", res2) ;

		out.print(output.toString());
		
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	
	/**
	 * For testing other methods in this class.
	 */
	public static void main(String[] args) throws ServletException, IOException {
		new VolunteerAllArticles().doGet(null, null);
	}

}
