package com.azkar.payload.authenticationcontroller.requests;

import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.exceptions.BadRequestException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AppleAuthenticationRequest extends RequestBodyBase {

  private String firstName;
  private String lastName;
  private String email;
  private String authCode;

  @Override public void validate() throws BadRequestException {
    checkNotNull(email, authCode, firstName, lastName);
    email = email.toLowerCase();
  }
}
