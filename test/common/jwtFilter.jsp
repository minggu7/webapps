<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // ? Access Token ��Ű ��������
    Cookie[] cookies = request.getCookies();
    String accessToken = null;

    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("access_token".equals(cookie.getName())) {
                accessToken = cookie.getValue();
                break;
            }
        }
    }

    boolean valid = false;

    if (accessToken != null) {
        try {
            String secretKey = "MySuperSecretKey1234567890"; // ��� Ű �����ϰ�

            // ? JWT �Ľ� �� ����
            Claims claims = Jwts.parser()
                .setSigningKey(secretKey.getBytes("UTF-8"))
                .parseClaimsJws(accessToken)
                .getBody();

            // ? ���� �ð� �˻�
            Date exp = claims.getExpiration();
            if (exp.after(new Date())) {
                valid = true;
            }
        } catch (ExpiredJwtException e) {
            out.println("<script>alert('������ ����Ǿ����ϴ�. �ٽ� �α������ּ���.'); location.href='../test/user/login.jsp';</script>");
        } catch (JwtException e) {
            out.println("<script>alert('�߸��� �����Դϴ�.'); location.href='../test/user/login.jsp';</script>");
        }
    }

    if (!valid) {
%>
        <script>
            alert("�α����� �ʿ��մϴ�.");
            location.href = "../test/user/login.jsp";
        </script>
<%
        return;
    }
%>
