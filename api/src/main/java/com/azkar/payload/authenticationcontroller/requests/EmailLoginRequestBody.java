package com.azkar.payload.authenticationcontroller.requests;

import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.exceptions.BadRequestException;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class EmailLoginRequestBody extends RequestBodyBase {

  private String email;
  private String password;

  @Override public void validate() throws BadRequestException {
    checkNotNull(email, password);
    email = email.toLowerCase();
    EmailAuthenticationRequestBodyUtil.validateEmail(email);
    EmailAuthenticationRequestBodyUtil.validatePassword(password);
  }
}
