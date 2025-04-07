<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // ? Access Token 쿠키 가져오기
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
            String secretKey = "MySuperSecretKey1234567890"; // 비밀 키 동일하게

            // ? JWT 파싱 및 검증
            Claims claims = Jwts.parser()
                .setSigningKey(secretKey.getBytes("UTF-8"))
                .parseClaimsJws(accessToken)
                .getBody();

            // ? 만료 시간 검사
            Date exp = claims.getExpiration();
            if (exp.after(new Date())) {
                valid = true;
            }
        } catch (ExpiredJwtException e) {
            out.println("<script>alert('세션이 만료되었습니다. 다시 로그인해주세요.'); location.href='../test/user/login.jsp';</script>");
        } catch (JwtException e) {
            out.println("<script>alert('잘못된 접근입니다.'); location.href='../test/user/login.jsp';</script>");
        }
    }

    if (!valid) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "../test/user/login.jsp";
        </script>
<%
        return;
    }
%>
