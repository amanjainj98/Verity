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

import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/WriterSignUp")
public class WriterSignUp extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WriterSignUp() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		doPost(request,response) ; 

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();

		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String name = request.getParameter("name");





		try {

			PrintWriter out = response.getWriter() ;
			String query = "insert into password values (?,?)";

			String res = DbHelper.executeUpdateJson (query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING,DbHelper.ParamType.STRING}, 
					new Object[] {username,password});

			JSONObject j0 = new JSONObject(res) ;
			if (j0.get("status").toString() == "false") {
				// delete that password username entry
				out.print(res);
				return ; 
			}

			System.out.println("WriterSignUp q1: "+ res) ;

			String query2 = "insert into writer (username,name) values(?,?) returning writer_id";

			String res2 = DbHelper.executeQueryJson (query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING,DbHelper.ParamType.STRING}, 
					new Object[] {username,name});

			System.out.println("WriterSignUp q2: "+ res2) ;

			JSONObject j = new JSONObject(res2) ;

			if (j.get("status").toString() == "true") {
				JSONArray ja = new JSONArray(j.get("data").toString()) ;
				JSONObject jj = ja.getJSONObject(0);
				Integer writer_id = Integer.parseInt(jj.get("writer_id").toString());
				session.setAttribute("writer_id", writer_id);

				System.out.println("WriterSignUp: Writer_id = " + String.valueOf(writer_id)) ;
				System.out.println("WriterSignUp: " + res) ;
				session.setAttribute("username", username);
				session.setAttribute("name", name);
				session.setAttribute("writer_id", String.valueOf(writer_id));

			}
			response.getWriter().println(res) ;
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

}
