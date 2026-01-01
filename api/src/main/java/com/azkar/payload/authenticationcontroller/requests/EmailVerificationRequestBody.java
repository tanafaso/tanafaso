package com.azkar.payload.authenticationcontroller.requests;

import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.exceptions.BadRequestException;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailVerificationRequestBody extends RequestBodyBase {

  private String email;
  private Integer pin;

  @Override public void validate() throws BadRequestException {
    checkNotNull(email, pin);
    email = email.toLowerCase();
  }
}
