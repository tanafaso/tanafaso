package com.azkar.controllers.utils;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.azkar.controllers.BaseController;
import com.azkar.entities.User;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.RequestBuilder;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

@Service
public class HttpClient {

  @Value("${app.jwtSecret}")
  String jwtSecret;

  @Autowired
  private MockMvc mockMvc;

  public ResultActions performGetRequest(String token, String path) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = get(path);
    addAuthenticationToken(requestBuilder, token);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performGetRequest(User user, String path) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = get(path);
    addAuthenticationToken(requestBuilder, user);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performGetRequestWithApiVersion(User user, String path, String apiVersion)
      throws Exception {
    MockHttpServletRequestBuilder requestBuilder = get(path);
    requestBuilder.header(BaseController.API_VERSION_HEADER, apiVersion);
    addAuthenticationToken(requestBuilder, user);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performPostRequest(String path, String body) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = post(path);
    addRequestBody(requestBuilder, body);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performDeleteRequest(String path, String body) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = delete(path);
    addRequestBody(requestBuilder, body);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions submitUpdatePasswordForm(String passwordToken, String password)
      throws Exception {
    MockHttpServletRequestBuilder requestBuilder = post("/update_password/");
    requestBuilder.contentType(MediaType.APPLICATION_FORM_URLENCODED_VALUE);
    requestBuilder.param("token", passwordToken);
    requestBuilder.param("password", password);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performPostRequest(User user, String path, String body) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = post(path);
    addAuthenticationToken(requestBuilder, user);
    addRequestBody(requestBuilder, body);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performPutRequest(String path, String body) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = put(path);
    addRequestBody(requestBuilder, body);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performPutRequest(User user, String path, String body) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = put(path);
    addAuthenticationToken(requestBuilder, user);
    addRequestBody(requestBuilder, body);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performPutRequest(User user, String path) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = put(path);
    addAuthenticationToken(requestBuilder, user);
    addRequestBody(requestBuilder, /*body=*/null);
    return mockMvc.perform(requestBuilder);
  }

  public ResultActions performDeleteRequest(User user, String path) throws Exception {
    MockHttpServletRequestBuilder requestBuilder = delete(path);
    addAuthenticationToken(requestBuilder, user);
    return mockMvc.perform(requestBuilder);
  }

  private RequestBuilder addAuthenticationToken(
      MockHttpServletRequestBuilder requestBuilder,
      User user) throws UnsupportedEncodingException {
    if (user != null) {
      addAuthenticationToken(requestBuilder, getAuthenticationToken(user));
    }
    return requestBuilder;
  }

  private RequestBuilder addAuthenticationToken(
      MockHttpServletRequestBuilder requestBuilder, String token) {
    requestBuilder.header(HttpHeaders.AUTHORIZATION, "Bearer " + token);
    return requestBuilder;
  }

  private RequestBuilder addRequestBody(
      MockHttpServletRequestBuilder requestBuilder,
      String body) {
    if (body != null) {
      requestBuilder.contentType(MediaType.APPLICATION_JSON);
      requestBuilder.content(body);
    }
    return requestBuilder;
  }

  private String getAuthenticationToken(User user) throws UnsupportedEncodingException {
    final long TOKEN_TIMEOUT_IN_MILLIS = TimeUnit.MINUTES.toMillis(1);
    return JWT.create()
        .withSubject(user.getId())
        .withExpiresAt(new Date(System.currentTimeMillis() + TOKEN_TIMEOUT_IN_MILLIS))
        .sign(Algorithm.HMAC512(jwtSecret));
  }

  public String getExpiredAuthenticationToken(User user) throws UnsupportedEncodingException {
    return JWT.create()
        .withSubject(user.getId())
        .withExpiresAt(new Date(System.currentTimeMillis() - 1000))
        .sign(Algorithm.HMAC512(jwtSecret));
  }
}
