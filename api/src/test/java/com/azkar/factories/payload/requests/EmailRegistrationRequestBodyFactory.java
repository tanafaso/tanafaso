package com.azkar.factories.payload.requests;

import com.azkar.payload.authenticationcontroller.requests.EmailRegistrationRequestBody;

public class EmailRegistrationRequestBodyFactory {

  public static EmailRegistrationRequestBody getDefaultEmailRegistrationRequestBody() {
    return EmailRegistrationRequestBody.builder()
        .firstName("test_first_name")
        .lastName("test_last_name")
        .email("test_email@test.com")
        .password("test_password")
        .build();
  }
}
