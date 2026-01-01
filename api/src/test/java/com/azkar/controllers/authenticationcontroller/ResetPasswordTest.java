package com.azkar.controllers.authenticationcontroller;

import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.ERROR_PAGE_VIEW_NAME;
import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.SUCCESS_PAGE_VIEW_NAME;
import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.UPDATE_PASSWORD_VIEW_NAME;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsStringIgnoringCase;
import static org.hamcrest.Matchers.emptyString;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.authenticationcontroller.responses.ResetPasswordResponse;
import com.azkar.repos.UserRepo;
import java.time.Instant;
import org.hamcrest.Matchers;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;

@Ignore("issue/108: Email tests are flaky")
public class ResetPasswordTest extends TestBase {

  private static final String NEW_PASSWORD = "new_password";
  private static final String INVALID_PASSWORD_TOO_SHORT = "123";
  @Autowired
  UserRepo userRepo;
  @Autowired
  PasswordEncoder passwordEncoder;
  User user;

  @Before
  public void setUp() {
    user = UserFactory.getNewUser();
    user.setEncodedPassword("encoded_pass");
    user.setEmail("test_email@test.com");
    addNewUser(user);
  }

  @Test
  public void resetPassword_validUser_shouldSaveToken() throws Exception {

    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());

    User userFromDb = userRepo.findByEmail(user.getEmail()).get();
    assertThat(userFromDb.getResetPasswordToken(), Matchers.notNullValue());
    assertThat(userFromDb.getResetPasswordToken(), not(emptyString()));
    assertSetPasswordTokenIsNotIncludedInUserResponse(user);
  }

  private void assertSetPasswordTokenIsNotIncludedInUserResponse(User user) throws Exception {
    String userResponseFromApi = azkarApi.searchForUserByUsername(user, user.getUsername())
        .andReturn().getResponse().getContentAsString();
    assertThat(userResponseFromApi, not(containsStringIgnoringCase("resetPasswordToken")));
  }

  @Test
  public void resetPassword_invalidEmail_shouldFail() throws Exception {
    ResetPasswordResponse expectedResponse = new ResetPasswordResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));
    azkarApi.resetPassword("invalidEmail@example.com").andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void validatePasswordToken_validToken_shouldSucceed() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());
    User userFromDb = userRepo.findByEmail(user.getEmail()).get();
    String token = userFromDb.getResetPasswordToken();

    azkarApi.verifyResetPasswordToken(token).andExpect(status().isOk())
        .andExpect(view().name(UPDATE_PASSWORD_VIEW_NAME));
  }

  @Test
  public void validatePasswordToken_invalidToken_shouldFail() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());

    azkarApi.verifyResetPasswordToken("invalid_token").andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.valueOf("text/html;charset=UTF-8")))
        .andExpect(view().name(ERROR_PAGE_VIEW_NAME));
  }

  @Test
  public void updatePasswordToken_validToken_shouldSucceed() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());

    String resetPasswordToken = userRepo.findByEmail(user.getEmail()).get().getResetPasswordToken();
    azkarApi.updatePassword(resetPasswordToken, NEW_PASSWORD).andExpect(status().isOk())
        .andExpect(view().name(SUCCESS_PAGE_VIEW_NAME));

    String newEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();
    assertThat(passwordEncoder.matches(NEW_PASSWORD, newEncodedPassword), is(true));
  }

  @Test
  public void updatePasswordToken_tokenUsedTwice_shouldFailTheSecondTime() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());

    String resetPasswordToken = userRepo.findByEmail(user.getEmail()).get().getResetPasswordToken();
    azkarApi.updatePassword(resetPasswordToken, NEW_PASSWORD).andExpect(status().isOk())
        .andExpect(view().name(SUCCESS_PAGE_VIEW_NAME));

    azkarApi.updatePassword(resetPasswordToken, NEW_PASSWORD).andExpect(status().isBadRequest())
        .andExpect(view().name(ERROR_PAGE_VIEW_NAME));
  }

  @Test
  public void updatePasswordToken_invalidToken_shouldFail() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());
    String oldEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();

    azkarApi.updatePassword("invalid_token", NEW_PASSWORD).andExpect(status().isBadRequest())
        .andExpect(
            view().name(ERROR_PAGE_VIEW_NAME));

    String newEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();
    assertThat(passwordEncoder.matches(NEW_PASSWORD, newEncodedPassword), is(false));
    assertThat(oldEncodedPassword, is(newEncodedPassword));
  }

  @Test
  public void updatePasswordToken_invalidPassword_shouldFail() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());
    ResetPasswordResponse expectedResponse = new ResetPasswordResponse();
    expectedResponse.setStatus(new Status(Status.PASSWORD_CHARACTERS_LESS_THAN_8_ERROR));
    String oldEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();

    String resetPasswordToken = userRepo.findByEmail(user.getEmail()).get().getResetPasswordToken();
    azkarApi.updatePassword(resetPasswordToken, INVALID_PASSWORD_TOO_SHORT)
        .andExpect(status().isBadRequest())
        .andExpect(view().name(ERROR_PAGE_VIEW_NAME));

    String newEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();
    assertThat(oldEncodedPassword, is(newEncodedPassword));
  }

  @Test
  public void updatePasswordToken_expiredToken_shouldFail() throws Exception {
    azkarApi.resetPassword(user.getEmail()).andExpect(status().isOk());
    User userFromDb = userRepo.findByEmail(user.getEmail()).get();
    // TODO(issue#170): Use a better way to test expired tokens than overriding it in the database.
    overrideWithExpiredResetPasswordToken(userFromDb);

    String resetPasswordToken = userFromDb.getResetPasswordToken();
    azkarApi.updatePassword(resetPasswordToken, NEW_PASSWORD)
        .andExpect(status().isBadRequest())
        .andExpect(view().name(ERROR_PAGE_VIEW_NAME));

    String oldEncodedPassword = userFromDb.getEncodedPassword();
    String newEncodedPassword = userRepo.findByEmail(user.getEmail()).get().getEncodedPassword();
    assertThat(passwordEncoder.matches(NEW_PASSWORD, newEncodedPassword), is(false));
    assertThat(oldEncodedPassword, is(newEncodedPassword));
  }

  private void overrideWithExpiredResetPasswordToken(User user) {
    user.setResetPasswordTokenExpiryTime(Instant.now().getEpochSecond() - 777);
    userRepo.save(user);
  }
}
