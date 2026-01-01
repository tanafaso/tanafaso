package com.azkar.factories.payload.requests;

import com.azkar.payload.authenticationcontroller.requests.EmailLoginRequestBody;

public class EmailLoginRequestBodyFactory {

  public static EmailLoginRequestBody getDefaultEmailLoginRequestBodyFactory() {
    return EmailLoginRequestBody.builder()
        .email("test_email@test.com")
        .password("test_password")
        .build();
  }
}
