<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html>
<head><title>MySQL 연결 테스트</title></head>
<body>
<%
    // 📌 DB 연결을 위한 정보 (DB URL, 사용자명, 비밀번호)
    String url = "jdbc:mysql://localhost:3306/jsptestdb?serverTimezone=Asia/Seoul"; // DB URL 및 timezone 설정
    String user = "kmg2388";       // MySQL 사용자 이름
    String password = "2388";      // MySQL 사용자 비밀번호

    Connection conn = null; // DB 연결 객체, 처음엔 null로 초기화

    try {
        // 1. JDBC 드라이버를 로드 (JAR 파일 안에 들어있는 클래스)
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 2. DB에 연결 시도 (url, 사용자명, 비밀번호 이용)
        conn = DriverManager.getConnection(url, user, password);

        // 3. 연결 성공 시 메시지 출력 (클라이언트 웹 브라우저에 출력됨)
        out.println("<h2>✅ MySQL 연결 성공!</h2>");
        


    } catch (Exception e) {
        // 연결 실패 시 예외 메시지를 웹 페이지에 출력
        out.println("<h2>❌ 연결 실패: " + e.getMessage() + "</h2>");

        // 콘솔(서버) 로그로 예외의 상세 내용을 출력 (개발자 디버깅용)
        e.printStackTrace(); // 👉 어떤 에러인지 상세히 로그 출력됨 (System.err로 출력)
    } finally {
        // try든 catch든 마지막에 무조건 실행되는 블록
        // 연결이 열려 있으면 닫기 (자원 반납)
        if (conn != null) try { conn.close(); } catch (Exception e) {} // 연결 종료
    }
%>
</body>
</html>
