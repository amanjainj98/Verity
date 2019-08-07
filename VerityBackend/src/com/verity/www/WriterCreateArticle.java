package com.verity.www;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@WebServlet("/WriterCreateArticle")

public class WriterCreateArticle extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Integer maxRoutingUsers = 10000;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WriterCreateArticle() {
		super();
		// TODO Auto-generated constructor stub
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		if(session.getAttribute("writer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		Integer writer_id = Integer.parseInt(session.getAttribute("writer_id").toString());
		Integer article_id = 0 ; 
		String title = (String) request.getParameter("title") ;
		String description = (String) request.getParameter("description") ;
		String body = (String) request.getParameter("body") ;
		String end_time = (String) request.getParameter("end_time");
		String tags = (String) request.getParameter("tags");
		Integer max_users = Integer.parseInt(request.getParameter("max_users").toString()) ;	
		
		System.out.println(body);
		System.out.println(tags);
		
		// Can use a with query to convert the three queries into one query.
		String query1 = "insert into article("
				+ "title,description,body,publish_time,end_time,max_users,writer_id) "
				+ "values (?,?,?, now() ,to_timestamp(?, 'YYYY-MM-DD HH24:MI:SS.FFF'), ?, ?) returning article_id";
//		String query1 = "insert into article("
//				+ "title,description,body,publish_time,end_time,max_users,writer_id) "
//				+ "values (?,?,?, now() ,now(), ?, ?) returning article_id";
	
		
		String json1 = DbHelper.executeQueryJson(query1, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.STRING, 
						DbHelper.ParamType.STRING,
						DbHelper.ParamType.STRING,
						DbHelper.ParamType.STRING,
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,},
				new Object[] {title,description,body, end_time, max_users, writer_id});
		
		try {
			JSONObject j = new JSONObject(json1) ;
			System.out.println(json1);
			if (j.get("status").toString() == "false") {
				response.getWriter().print(DbHelper.errorJson("Error inserting into article"));
				return ;
			}
			else if(j.get("status").toString() == "true"){
			
				JSONArray ja = new JSONArray(j.get("data").toString()) ;
				JSONObject jj = ja.getJSONObject(0);
				article_id = Integer.parseInt(jj.get("article_id").toString());
				String json3 = "" ;
								
				JSONArray j3 = new JSONArray(tags) ;
								
				for (int i=0;i<j3.length();i++) {
					String query3 = "insert into article_tag values (?, (select tag_id from tag where tag_name=?))";
					json3 += DbHelper.executeUpdateJson(query3, 
							new DbHelper.ParamType[] {DbHelper.ParamType.INT,  DbHelper.ParamType.STRING},
							new Object[] { article_id, j3.get(i) });	
					JSONObject temp = new JSONObject(json3) ;
					if (temp.get("status").toString() == "false")
					{
						response.getWriter().print(DbHelper.errorJson("Error inserting tags into database"));
						return ;
					}
				}

				response.getWriter().print(DbHelper.okJson());
			
			}
		}
		catch (Exception e){
			e.printStackTrace();
		}
		
		
		// Now creating sections and inserting them into the database.
		int l = 0 ;
		for (int i=0;i<body.length();i++) {
			l ++ ; 
			if (body.charAt(i) == '\n' || i==body.length()-1) {
				if (l==0) continue ; 
				 
				// inserting this l into database with section_number
				try {
					String query = "insert into section (article_id,length) values (?,?) " ;
					String res = DbHelper.executeUpdateJson (query, 
							new DbHelper.ParamType[] {
									DbHelper.ParamType.INT,
									DbHelper.ParamType.INT}, 
							new Object[] {article_id,l});
							
					l = 0 ;
					JSONObject j = new JSONObject(res) ;
					
					if (j.get("status").toString() == "false") {
						response.getWriter().println(res);
						return ; 
					}

				}
				catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		
		
		PrintWriter out = response.getWriter();
		
		// Routing
		// take tags of the article 
		try {
			String query = "select volunteer_id, sum(acc_rating)*(cast (? as float)) + sum(ex_rating)*(cast (? as float)) as rating "
					+ " from volunteer_tag where tag_id in (select tag_id from article_tag where article_id = ?) "
					+ " group by volunteer_id order by rating desc limit (cast (? as integer))";
			String res = DbHelper.executeQueryJson(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING,
							DbHelper.ParamType.STRING,
							DbHelper.ParamType.INT,
							DbHelper.ParamType.STRING}, 
					new Object[] {"0.5","0.5",article_id,"100"});
						
			JSONObject j = new JSONObject(res) ;
			
			if (j.get("status").toString() == "false") {
				out.println(res);
				return ; 
			}
			
//			out.println(res);
			JSONArray jj = new JSONArray (j.get("data").toString()) ;
			System.out.println(jj.toString());
			int length = jj.length(); 
			System.out.println(String.valueOf(length)) ;
			
			
			int num_route = Integer.min(max_users, length / 10) ;
			int status = 0 ;

			for (int i=0;i<length;i++) {
				if (i > num_route) status = 4 ;  
				String query3 = "insert into article_volunteer values (?, ?, now(), cast (? as float), ?)";
				JSONObject j3 = jj.getJSONObject(i); ;
				System.out.println(j3.get("volunteer_id").toString()) ;
				String json3 = DbHelper.executeUpdateJson(query3, 
						new DbHelper.ParamType[] {DbHelper.ParamType.INT,  
								DbHelper.ParamType.INT,
								DbHelper.ParamType.STRING,
								DbHelper.ParamType.INT
								},
						new Object[] { Integer.parseInt(j3.get("volunteer_id").toString()),article_id,j3.get("rating").toString(), status});	
				JSONObject temp = new JSONObject(json3) ;
				if (temp.get("status").toString() == "false")
				{
					response.getWriter().print(temp);
					return ;
				}
			}
			
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
		doGet(request, response);
	}

}
