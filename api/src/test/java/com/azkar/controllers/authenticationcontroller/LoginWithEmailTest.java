package com.azkar.controllers.authenticationcontroller;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.factories.payload.requests.EmailLoginRequestBodyFactory;
import com.azkar.factories.payload.requests.EmailRegistrationRequestBodyFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.authenticationcontroller.requests.EmailLoginRequestBody;
import com.azkar.payload.authenticationcontroller.requests.EmailRegistrationRequestBody;
import com.azkar.payload.authenticationcontroller.responses.EmailLoginResponse;
import com.azkar.payload.authenticationcontroller.responses.EmailRegistrationResponse;
import com.azkar.payload.utils.FeaturesVersions;
import org.junit.Ignore;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;

public class LoginWithEmailTest extends TestBase {

  @Autowired
  PasswordEncoder passwordEncoder;

  @Test
  public void loginWithEmail_normalScenario_shouldReturnToken() throws Exception {
    String email = "example@domain.com";
    String password = "example_password";
    User user = UserFactory.getNewUserWithEmailAndEncodedPassword(email,
        passwordEncoder.encode(password));
    addNewUser(user);

    EmailLoginRequestBody emailLoginRequestBody =
        EmailLoginRequestBody.builder().email(email).password(password).build();
    MvcResult result = loginWithEmail(JsonHandler.toJson(emailLoginRequestBody))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new EmailLoginResponse())))
        .andReturn();

    // Validate the JWT returned by the API.
    azkarApi.getAllChallengesV2(user, FeaturesVersions.READING_QURAN_CHALLENGE_VERSION)
        .andExpect(status().isOk());
  }

  @Test
  public void loginWithEmail_emailMissingAtSign_shouldNotSucceed() throws Exception {
    final String emailWithoutAtSign = "test_emailtest.com";
    EmailLoginRequestBody body =
        EmailLoginRequestBodyFactory.getDefaultEmailLoginRequestBodyFactory();
    body.setEmail(emailWithoutAtSign);

    EmailLoginResponse expectedResponse = new EmailLoginResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_NOT_VALID_ERROR));
    loginWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void loginWithEmail_emailMissingDotSymbol_shouldNotSucceed() throws Exception {
    String emailWithoutDot = "test_email@testcom";
    EmailLoginRequestBody body =
        EmailLoginRequestBodyFactory.getDefaultEmailLoginRequestBodyFactory();
    body.setEmail(emailWithoutDot);

    EmailLoginResponse expectedResponse = new EmailLoginResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_NOT_VALID_ERROR));
    loginWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void loginWithEmail_passwordTooShort_shouldNotSucceed() throws Exception {
    String shortPassword = "abcdefg";
    EmailLoginRequestBody body =
        EmailLoginRequestBodyFactory.getDefaultEmailLoginRequestBodyFactory();
    body.setPassword(shortPassword);

    EmailLoginResponse expectedResponse = new EmailLoginResponse();
    expectedResponse
        .setStatus(
            new Status(Status.PASSWORD_CHARACTERS_LESS_THAN_8_ERROR));
    loginWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void loginWithEmail_emailNotProvided_shouldNotSucceed() throws Exception {
    EmailLoginRequestBody bodyMissingEmailField =
        EmailLoginRequestBodyFactory.getDefaultEmailLoginRequestBodyFactory();
    bodyMissingEmailField.setEmail(null);

    EmailLoginResponse expectedResponse = new EmailLoginResponse();
    expectedResponse
        .setStatus(new Status(Status.REQUIRED_FIELDS_NOT_GIVEN_ERROR));
    loginWithEmail(JsonHandler.toJson(bodyMissingEmailField))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Ignore("issue/108: Email tests are flaky")
  @Test
  public void loginWithEmail_emailConfirmationSentAndStillPending_shouldNotSucceed()
      throws Exception {
    EmailRegistrationRequestBody emailRegistrationRequestBody =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();

    performPutRequest(
        ApiAuthenticationController.REGISTER_WITH_EMAIL_PATH,
        JsonHandler.toJson(emailRegistrationRequestBody))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new EmailRegistrationResponse())));

    EmailLoginRequestBody emailLoginRequestBody =
        EmailLoginRequestBody.builder().email(emailRegistrationRequestBody.getEmail())
            .password(emailRegistrationRequestBody.getPassword()).build();
    EmailLoginResponse expectedResponse = new EmailLoginResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_NOT_VERIFIED_ERROR));

    loginWithEmail(JsonHandler.toJson(emailLoginRequestBody))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  private ResultActions loginWithEmail(String body) throws Exception {
    return performPutRequest(
        ApiAuthenticationController.LOGIN_WITH_EMAIL_PATH,
        body);
  }
}

