package com.verity.www;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

/**
 * Servlet implementation class WriterViewArticle
 */
@WebServlet("/WriterViewArticle")
public class WriterViewArticle extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WriterViewArticle() {
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
		//Integer section_id = Integer.parseInt(request.getParameter("section_id").toString());

		String query = "select title,"
				+ "body from article where article_id = ?";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
		try {
		JSONObject j = new JSONObject(res) ;
				
		System.out.println(res) ;
		PrintWriter out = response.getWriter();
		
		if (j.get("status") == "false") {		
			out.print(res); 
			return ; 
		}
		
		String query2 = "select s.section_id,length,count(comment_id) from section as s left outer join comment as c "
				+ " on s.article_id = c.article_id and c.section_id = s.section_id where s.article_id = ? "
				+ "group by s.section_id,s.length";
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
	
		JSONObject j2 = new JSONObject(res2) ;
				
		System.out.println(res2) ;
		
		if (j2.get("status").toString() == "false") {		
			out.print(res2); 
			return ; 
		}

		
		
		JSONObject output = new JSONObject() ;
		output.put("status", "true");
		output.put("data1" ,  j.get("data"));
		output.put("data2" , j2.get("data"));
		
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
