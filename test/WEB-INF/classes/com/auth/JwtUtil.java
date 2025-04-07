package com.auth;

// JWT 관련 클래스들 import
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;

import java.security.Key;
import java.util.Date;

public class JwtUtil {

    // JWT 서명을 위한 비밀 키 (HS256 방식에 사용할 키)
    private static final String SECRET = "ThisIsASecretKeyForJwtSigning1234567890";

    // 비밀 키를 바이트 배열로 변환하여 HMAC-SHA 알고리즘에 사용할 수 있는 Key 객체 생성
    private static final Key key = Keys.hmacShaKeyFor(SECRET.getBytes());

    // 액세스 토큰의 유효 기간 (5분 = 1000ms * 60초 * 5)
    private static final long EXPIRATION_TIME = 1000 * 60 * 5; // 5분

    // Access Token 생성 메서드
    public static String createAccessToken(String username) {
        return Jwts.builder() // JWT Builder 생성
                .setSubject(username) // 사용자 이름을 subject로 설정
                .setIssuedAt(new Date()) // 토큰 발급 시간 설정
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME)) // 만료 시간 설정
                .signWith(key, SignatureAlgorithm.HS256) // 키와 알고리즘으로 서명
                .compact(); // 토큰 문자열 생성
    }

    // 토큰 유효성 검사 메서드
    public static boolean isValid(String token) {
        try {
            // 파싱하면서 서명 검증 수행
            Jwts.parserBuilder()
                    .setSigningKey(key) // 서명 검증에 사용할 키 설정
                    .build()
                    .parseClaimsJws(token); // 토큰 파싱 시도
            return true; // 예외 없으면 유효한 토큰
        } catch (JwtException e) {
            return false; // 예외 발생하면 유효하지 않은 토큰
        }
    }

    // Refresh Token으로부터 새로운 Access Token 재발급
    public static String reissueAccessToken(String refreshToken) {
        if (!isValid(refreshToken)) return null; // Refresh Token 유효성 확인

        // 토큰에서 클레임 추출
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(refreshToken)
                .getBody();

        // 클레임에서 사용자 이름 추출 후 새로운 액세스 토큰 발급
        String username = claims.getSubject();
        return createAccessToken(username);
    }

    // 토큰에서 사용자 이름(Subject) 추출
    public static String getUsername(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();

        return claims.getSubject(); // subject = username
    }
}
