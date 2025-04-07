<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ include file="../common/dbConfig.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "INSERT INTO user (username, password) VALUES (?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, password);

        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("🎉 회원가입 성공! 로그인 해주세요.");
                location.href = "login.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("❌ 회원가입 실패");
                history.back();
            </script>
<%
        }

    } catch (SQLIntegrityConstraintViolationException e) {
%>
        <script>
            alert("❗ 이미 존재하는 아이디입니다.");
            history.back();
        </script>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
        <p>DB 오류 발생: <%= e.getMessage() %></p>
<%
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
