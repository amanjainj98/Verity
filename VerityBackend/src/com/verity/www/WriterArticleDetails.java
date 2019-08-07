package com.verity.www;

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
 * Servlet implementation class WriterArticleDetails
 */
@WebServlet("/WriterArticleDetails")
public class WriterArticleDetails extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WriterArticleDetails() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		if(session.getAttribute("writer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		Integer writer_id = Integer.parseInt(session.getAttribute("writer_id").toString());
		Integer article_id = Integer.parseInt(request.getParameter("article_id").toString());
		
		System.out.println("WriterArticleDetails+Aid="+Integer.toString(article_id)) ;
		
		String query = "select article_id, title, publish_time, description from article where article_id = ?";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
		try {
		JSONObject j = new JSONObject(res) ;
				
		System.out.println("q1 "+res) ;
		PrintWriter out = response.getWriter();
		
		if (j.get("status").toString() == "false") {		
			out.print(res); 
			return ; 
		}
		
		String query2 = "select article_tag.tag_id,tag_name from article_tag, tag where article_tag.tag_id = tag.tag_id and article_id = ?";
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
	
		JSONObject j2 = new JSONObject(res2) ;
				
		System.out.println("q2 " + res2) ;
		
		if (j2.get("status").toString() == "false") {		
			out.print(res2); 
			return ; 
		}

		
		String query3 = "select count(*) from comment where article_id = ?";
		String res3 = DbHelper.executeQueryJson(query3, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
		
		JSONObject j3 = new JSONObject(res3) ;
				
		System.out.println("q3 "+res3) ;
		
		if (j3.get("status").toString() == "false") {		
			out.print(res3); 
			return ; 
		}
		
		int num_users = 0; 
		
		String query4 = "select count(*) from comment_rating where article_id = ? ";
		List<List<Object>> res4 = DbHelper.executeQueryList(query4, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
		
		JSONObject j4 = new JSONObject(res4) ;
				
		System.out.println("q4 "+res4) ;
		
		num_users = Integer.parseInt(res4.get(0).get(0).toString());
				
		JSONObject output = new JSONObject() ;
		output.put("status", "true");
		output.put("article_data" ,  j.get("data"));
		output.put("tag_data" , j2.get("data"));
		output.put("num_comments" , j3.get("data"));
		output.put("num_users" , String.valueOf(num_users));

		System.out.println("WriterArticleDetails+"+output.toString()) ;
		out.print(output.toString());
		
		}
		
		catch (Exception e) {
			e.printStackTrace();
		}
		
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}


}
