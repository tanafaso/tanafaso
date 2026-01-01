package com.azkar.controllers.authenticationcontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.RegistrationEmailConfirmationState;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.factories.payload.requests.EmailRegistrationRequestBodyFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.authenticationcontroller.requests.EmailRegistrationRequestBody;
import com.azkar.payload.authenticationcontroller.requests.EmailVerificationRequestBody;
import com.azkar.payload.authenticationcontroller.responses.EmailRegistrationResponse;
import com.azkar.payload.authenticationcontroller.responses.EmailVerificationResponse;
import com.azkar.repos.RegistrationEmailConfirmationStateRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.Iterators;
import org.junit.Ignore;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.ResultActions;

// NOTE: Add tests for register/email/v2 and verify/email/v2 instead of register/email and
// verify/email.
@Ignore("issue/108: Email tests are flaky")
public class RegistrationWithEmailTest extends TestBase {

  @Autowired
  RegistrationEmailConfirmationStateRepo registrationEmailConfirmationStateRepo;

  @Autowired
  PasswordEncoder passwordEncoder;

  @Autowired
  UserRepo userRepo;

  @Test
  public void registerWithEmail_normalScenario_shouldAddStateEntryForBodyParams() throws Exception {
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();

    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    RegistrationEmailConfirmationState state =
        Iterators.getOnlyElement(registrationEmailConfirmationStateRepo.findAll().iterator());
    assertThat(state.getFirstName(), is(body.getFirstName()));
    assertThat(state.getLastName(), is(body.getLastName()));
    assertThat(state.getEmail(), is(body.getEmail()));
    assertThat("Password is hashed and saved",
        passwordEncoder.matches(body.getPassword(), state.getPassword()));
  }

  @Test
  public void registerWithEmail_normalScenario_shouldAddStateEntryWithSixDigitsPin()
      throws Exception {
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();

    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    RegistrationEmailConfirmationState state = Iterators
        .getOnlyElement(registrationEmailConfirmationStateRepo.findAll().iterator());
    assertThat((state.getPin() + "").length(), is(6));
  }

  @Test
  public void registerWithEmail_emailMissingAtSign_shouldNotSucceed() throws Exception {
    final String emailWithoutAtSign = "test_emailtest.com";
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setEmail(emailWithoutAtSign);

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_NOT_VALID_ERROR));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
  }

  @Test
  public void registerWithEmail_emailMissingDotSymbol_shouldNotSucceed() throws Exception {
    String emailWithoutDot = "test_email@testcom";
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setEmail(emailWithoutDot);

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_NOT_VALID_ERROR));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
  }

  @Test
  public void registerWithEmail_passwordTooShort_shouldNotSucceed() throws Exception {
    String shortPassword = "abcdefg";
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setPassword(shortPassword);

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse
        .setStatus(
            new Status(Status.PASSWORD_CHARACTERS_LESS_THAN_8_ERROR));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
  }

  @Test
  public void registerWithEmail_nameEmpty_shouldNotSucceed() throws Exception {
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setFirstName("");
    body.setLastName("example last name");

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse
        .setStatus(new Status(Status.NAME_EMPTY_ERROR));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
  }

  @Test
  public void registerWithEmail_nameNotProvided_shouldNotSucceed() throws Exception {
    EmailRegistrationRequestBody bodyMissingNameField =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    bodyMissingNameField.setFirstName(null);
    bodyMissingNameField.setLastName(null);

    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse
        .setStatus(new Status(Status.REQUIRED_FIELDS_NOT_GIVEN_ERROR));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(bodyMissingNameField))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
  }

  @Test
  public void registerWithEmail_emailConfirmationSentAndStillPending_shouldNotSucceed()
      throws Exception {
    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();

    EmailRegistrationResponse expectedResponse1 = new EmailRegistrationResponse();
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse1)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(1L));

    EmailRegistrationResponse expectedResponse2 = new EmailRegistrationResponse();
    expectedResponse2
        .setStatus(new Status(Status.PIN_ALREADY_SENT_TO_USER_ERROR));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse2)));

    assertThat(registrationEmailConfirmationStateRepo.count(), is(1L));
  }

  @Test
  public void registerWithEmail_userAlreadyRegistered_shouldNotSucceed()
      throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);

    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setEmail(user.getEmail());
    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse.setStatus(new Status(Status.USER_ALREADY_REGISTERED_ERROR));

    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    assertThat(userRepo.count(), is(1L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    assertThat(userRepo.count(), is(1L));
  }

  @Test
  public void registerWithEmail_userAlreadyRegisteredWithFacebook_shouldNotSucceed()
      throws Exception {
    User registeredWithFacebookUser = UserFactory.getUserRegisteredWithFacebook();
    addNewUser(registeredWithFacebookUser);

    EmailRegistrationRequestBody body =
        EmailRegistrationRequestBodyFactory.getDefaultEmailRegistrationRequestBody();
    body.setEmail(registeredWithFacebookUser.getUserFacebookData().getEmail());
    EmailRegistrationResponse expectedResponse = new EmailRegistrationResponse();
    expectedResponse
        .setStatus(new Status(Status.USER_ALREADY_REGISTERED_WITH_FACEBOOK));

    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    assertThat(userRepo.count(), is(1L));
    registerWithEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), is(0L));
    assertThat(userRepo.count(), is(1L));
  }

  @Test
  public void verifyEmail_normalScenario_shouldSucceed() throws Exception {
    final String email = "example_email@example_domain.com";
    final int pin = 123456;
    insertEmailVerificationPinInDatabase(email, pin);

    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(1L));
    assertThat(userRepo.count(), equalTo(0L));
    EmailVerificationRequestBody body = EmailVerificationRequestBody.builder()
        .email(email)
        .pin(pin)
        .build();
    EmailVerificationResponse expectedResponse = new EmailVerificationResponse();

    verifyEmail(JsonHandler.toJson(body))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(0L));
    assertThat(userRepo.count(), equalTo(1L));
    User user = userRepo.findAll().get(0);
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getUsername(), is(notNullValue()));
  }

  @Test
  public void verifyEmail_userAlreadyVerified_shouldNotSucceed() throws Exception {
    final String email = "example_email@example_domain.com";
    final int pin = 123456;
    insertEmailVerificationPinInDatabase(email, pin);

    EmailVerificationRequestBody body = EmailVerificationRequestBody.builder()
        .email(email)
        .pin(pin)
        .build();
    // Verify for the first time.
    verifyEmail(JsonHandler.toJson(body)).andExpect(status().isOk());
    EmailVerificationResponse expectedResponse = new EmailVerificationResponse();
    expectedResponse.setStatus(new Status(Status.EMAIL_ALREADY_VERIFIED_ERROR));

    // Verify again
    verifyEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(0L));
    assertThat(userRepo.count(), equalTo(1L));
  }

  @Test
  public void verifyEmail_wrongEmail_shouldNotSucceed() throws Exception {
    final String correctEmail = "example_email1@example_domain.com";
    final String wrongEmail = "example_email2@example_domain.com";
    final int pin = 123456;
    insertEmailVerificationPinInDatabase(correctEmail, pin);

    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(1L));
    assertThat(userRepo.count(), equalTo(0L));
    EmailVerificationRequestBody body = EmailVerificationRequestBody.builder()
        .email(wrongEmail)
        .pin(pin)
        .build();
    EmailVerificationResponse expectedResponse = new EmailVerificationResponse();
    expectedResponse.setStatus(new Status(Status.VERIFICATION_ERROR));

    verifyEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(1L));
    assertThat(userRepo.count(), equalTo(0L));
  }

  @Test
  public void verifyEmail_wrongPin_shouldNotSucceed() throws Exception {
    final String email = "example_email1@example_domain.com";
    final int correctPin = 123456;
    final int wrongPin = 111111;
    insertEmailVerificationPinInDatabase(email, correctPin);

    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(1L));
    assertThat(userRepo.count(), equalTo(0L));
    EmailVerificationRequestBody body = EmailVerificationRequestBody.builder()
        .email(email)
        .pin(wrongPin)
        .build();
    EmailVerificationResponse expectedResponse = new EmailVerificationResponse();
    expectedResponse.setStatus(new Status(Status.VERIFICATION_ERROR));

    verifyEmail(JsonHandler.toJson(body))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    assertThat(registrationEmailConfirmationStateRepo.count(), equalTo(1L));
    assertThat(userRepo.count(), equalTo(0L));
  }

  private void insertEmailVerificationPinInDatabase(String email, int pin) {
    registrationEmailConfirmationStateRepo.insert(
        RegistrationEmailConfirmationState.builder()
            .firstName("example_first_name")
            .lastName("example_last_name")
            .email(email)
            .password("example_password")
            .pin(pin)
            .build());
  }

  private ResultActions registerWithEmail(String body) throws Exception {
    return performPutRequest(
        /*user=*/null,
        ApiAuthenticationController.REGISTER_WITH_EMAIL_PATH,
        body);
  }

  private ResultActions verifyEmail(String body) throws Exception {
    return performPutRequest(
        /*user=*/null,
        ApiAuthenticationController.VERIFY_EMAIL_PATH,
        body);
  }
}
