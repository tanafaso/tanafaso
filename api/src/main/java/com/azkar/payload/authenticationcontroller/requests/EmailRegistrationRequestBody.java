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
@NoArgsConstructor
@AllArgsConstructor
public class EmailRegistrationRequestBody extends RequestBodyBase {

  private String email;
  private String password;
  private String firstName;
  private String lastName;

  @Override public void validate() throws BadRequestException {
    checkNotNull(email, password, firstName, lastName);
    email = email.toLowerCase();
    EmailAuthenticationRequestBodyUtil.validateEmail(email);
    EmailAuthenticationRequestBodyUtil.validatePassword(password);
    EmailAuthenticationRequestBodyUtil.validateName(firstName);
    EmailAuthenticationRequestBodyUtil.validateName(lastName);
  }

}
