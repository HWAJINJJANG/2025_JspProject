<!-- read.jsp -->
<%@page import="ch15.BCommentBean"%>
<%@page import="java.util.Vector"%>
<%@page import="ch15.BoardBean"%>
<%@page import="ch15.MUtil"%>
<%@page contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="mgr" class="ch15.BoardMgr"/>
<jsp:useBean id="cmgr" class = "ch15.BCommentMgr"/>
<%
		/*read.jsp?num=3&nowPage=1&numPerPage=10
		&keyField=name&keyWord=aaa*/
		String nowPage = request.getParameter("nowPage");
		String numPerPage = request.getParameter("numPerPage");
		String keyField = request.getParameter("keyField");
		String keyWord = request.getParameter("keyWord");
		int num = MUtil.parseInt(request, "num");
		
		// 댓글 입력 및 삭제 요청 시 flag 필요
		String flag = request.getParameter("flag");
		if(flag != null){
			if(flag.equals("insert")){
				BCommentBean cbean = new BCommentBean();
				cbean.setNum(num); // 어떤 게시물
				cbean.setName(request.getParameter("cname"));
				cbean.setComment(request.getParameter("comment"));
				cmgr.insertBComment(cbean);
			} else if (flag.equals("delete")){
				int cnum = MUtil.parseInt(request, "cnum");
				cmgr.deleteBComment(cnum);
			}
		} else {
			//조회수 증가
			mgr.upCount(num);			
		}

		//게시물 가져옴
		BoardBean bean = mgr.getBoard(num);
		session.setAttribute("bean", bean); // 세션에 게시물 저장 (수정, 삭제, 답변)

		String name = bean.getName();
		String subject = bean.getSubject();
		String regdate = bean.getRegdate();
		String content = bean.getContent();
		String filename = bean.getFilename();
		int filesize = bean.getFilesize();
		String ip = bean.getIp();
		int count = bean.getCount();
		
%>
<!DOCTYPE html>
<html>
<head>
<title>JSP Board</title>
<link href="style.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
	function list(){
		document.listFrm.action = "list.jsp";
		document.listFrm.submit();
	}
	
	function down(filename) {
	    document.downFrm.filename.value = filename;
	    document.downFrm.submit();
	}
	
	function delFn(){
		const pass = document.getElementById("passId");
		// alert(pass.value);
		if(pass.value.length==0){
			alert("비밀번호를 입력하세요");
			return;
		}
		document.delFrm.pass.value = pass.value;
		document.delFrm.submit();
	}
	
	function cInsert() {
		if(document.cFrm.comment.value==""){
			alert("댓글을 입력하세요.");
			document.cFrm.comment.focus();
			return;
		}
		document.cFrm.submit();
	}
	
	function cDel(cnum) {
		document.cFrm.cnum.value=cnum;
		document.cFrm.flag.value="delete";
		document.cFrm.submit();
	}
	
</script>
</head>
<body bgcolor="#FFFFCC">
<br/><br/>
<table align="center" width="600" cellspacing="3">
 <tr>
  <td bgcolor="#9CA2EE" height="25" align="center">글읽기</td>
 </tr>
 <tr>
  <td colspan="2">
   <table cellpadding="3" cellspacing="0" width="100%"> 
    <tr> 
  <td align="center" bgcolor="#DDDDDD" width="10%"> 이 름 </td>
  <td bgcolor="#FFFFE8"><%=name%></td>
  <td align="center" bgcolor="#DDDDDD" width="10%"> 등록날짜 </td>
  <td bgcolor="#FFFFE8"><%=regdate%></td>
 </tr>
 <tr> 
    <td align="center" bgcolor="#DDDDDD"> 제 목</td>
    <td bgcolor="#FFFFE8" colspan="3"><%=subject%></td>
   </tr>
   <tr> 
     <td align="center" bgcolor="#DDDDDD">첨부파일</td>
     <td bgcolor="#FFFFE8" colspan="3">
		<% if(filename!=null && !filename.equals("")){ %>
			<a href ="javascript.down('<%=filename%>')"><%=filename %></a>
			<font color = "blue">(<%=MUtil.intFormat(filesize) %>bytes)</font>
		<% } else { %>
		첨부된 파일이 없습니다.
		<% } // -- else문 %>
     </td>
   </tr>
   <tr> 
    <td align="center" bgcolor="#DDDDDD">비밀번호</td>
    <td bgcolor="#FFFFE8" colspan="3">
    	<input type="password" name="pass" id="passId">
    </td>
   </tr>
   <tr> 
    <td colspan="4"><br/><pre><%=content%></pre><br/></td>
   </tr>
   <tr>
    <td colspan="4" align="right">
     IP주소 : <%=ip%> / 조회수  <%=count%>
    </td>
   </tr>
   </table>
  </td>
 </tr>
 <tr>
  <td align="center" colspan="2">
  <!-- 댓글 입력폼 Start -->
  <form method="post" name="cFrm">
		<table>
			<tr  align="center">
				<td width="50">이 름</td>
				<td align="left">
					<input name="cname" size="10" value="aaa">
				</td>
			</tr>
			<tr align="center">
				<td>내 용</td>
				<td>
				<input name="comment" size="50"> 
				<input type="button" value="등록" onclick="cInsert()"></td>
			</tr>
		</table>
	 <input type="hidden" name="flag" value="insert">	
	 <input type="hidden" name="num" value="<%=num%>">
	 <!-- cnum은 삭제시 필요 -->
	 <input type="hidden" name="cnum">
     <input type="hidden" name="nowPage" value="<%=nowPage%>">
     <input type="hidden" name="numPerPage" value="<%=numPerPage%>">
     <%if(!(keyWord==null||keyWord.equals(""))){ %>
     <input type="hidden" name="keyField" value="<%=keyField%>">
     <input type="hidden" name="keyWord" value="<%=keyWord%>">
	<%}%>
	</form>
  <!-- 댓글 입력폼 End -->
  <hr>
  <!-- 댓글 리스트 Start -->
  <%
  		Vector<BCommentBean> cvlist = cmgr.getBComment(num);
  		if(!cvlist.isEmpty()){
  			// out.print(cvlist.size());
  	%>	
  	<table>
  	<% 
  			for(int i = 0; i < cvlist.size(); i++) { 
  				BCommentBean cbean = cvlist.get(i);
  				int cnum = cbean.getCnum();
  				String cname = cbean.getName();
  				String comment = cbean.getComment();
  				String cregdate = cbean.getRegdate();
  	%>
  		<tr>
		<td colspan="3" width="600"><b><%=cname%></b></td>
	</tr>
	<tr>
		<td>댓글:<%=comment%></td>
		<td align="right"><%=cregdate%></td>
		<td align="center" valign="middle">
		<input type="button" value="삭제" onclick="cDel('<%=cnum%>')">
		</td>
	</tr>
	<tr>
		<td colspan="3"><br></td>
	</tr>
  	<%} // --for	%>
  	</table>	
  	<% } // --if %>
  
  <!-- 댓글 리스트 End -->
 [ <a href="javascript:list()" >리스트</a> | 
 <a href="update.jsp?nowPage=<%=nowPage%>&numPerPage=<%=numPerPage%>" >수 정</a> |
 <a href="reply.jsp?nowPage=<%=nowPage%>&numPerPage=<%=numPerPage%>" >답 변</a> |
 <a href="javascript:delFn()">삭 제</a> ]<br/>
  </td>
 </tr>
</table>

<form method="post" name="downFrm" action="download.jsp">
	<input type="hidden" name="filename">
</form>

<form name="listFrm">
	<input type="hidden" name="nowPage" value="<%=nowPage%>">
	<input type="hidden" name="numPerPage" value="<%=numPerPage%>">
	<%if(!(keyWord==null||keyWord.equals(""))){%>
	<input type="hidden" name="keyField" value="<%=keyField%>">
	<input type="hidden" name="keyWord" value="<%=keyWord%>">
	<%}%>
</form>

<form name="delFrm" action="boardDelete" method="post">
	<input type="hidden" name="nowPage" value="<%=nowPage%>">
	<input type="hidden" name="numPerPage" value="<%=numPerPage%>">
	<%if(!(keyWord==null||keyWord.equals(""))){%>
	<input type="hidden" name="keyField" value="<%=keyField%>">
	<input type="hidden" name="keyWord" value="<%=keyWord%>">
	<%}%>
	<input type="hidden" name="pass">
</form>

</body>
</html>