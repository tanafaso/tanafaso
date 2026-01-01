package com.azkar.payload.authenticationcontroller.requests;

import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.exceptions.BadRequestException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GoogleAuthenticationRequest extends RequestBodyBase {

  private String googleIdToken;

  @Override public void validate() throws BadRequestException {
    checkNotNull(googleIdToken);
  }
}
