package com.azkar.controllers.authenticationcontroller;

import com.azkar.entities.RegistrationEmailConfirmationState;
import com.azkar.entities.User;
import com.azkar.repos.RegistrationEmailConfirmationStateRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.UserService;
import java.time.Instant;
import java.util.Optional;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * This controller is responsible for handling some of the authentication endpoints and will only
 * return HTML pages and not JSON.
 */
@Controller()
public class WebAuthenticationController {


  public static final String UPDATE_PASSWORD_PATH = "/update_password";
  public static final String UPDATE_PASSWORD_VIEW_NAME = "update_password";
  public static final String VERIFY_EMAIL_V2_PATH = "/verify/email/v2";

  public static final String ERROR_PAGE_VIEW_NAME = "error_page";
  public static final String SUCCESS_PAGE_VIEW_NAME = "success_page";

  public static final String INVALID_TOKEN_ERROR =
      "هذا الرابط منتهي أو غير صحيح. من فضلك اطلب استعادة كلمة المرور مرة أخرى.";
  public static final String PASSWORD_MALFORMED_ERROR =
      "يجب ألا تقل كلمة المرور عن 8 أحرف.";
  private static final String UPDATE_SUCCESSFUL_MESSAGE = "تم تغيير كلمة المرور بنجاح.";

  @Autowired
  RegistrationEmailConfirmationStateRepo registrationEmailConfirmationStateRepo;

  @Autowired
  UserService userService;

  @Autowired
  UserRepo userRepo;

  @Autowired
  PasswordEncoder passwordEncoder;

  @GetMapping("/update_password")
  public String verifyResetPasswordToken(
      @RequestParam String token, HttpServletResponse response, Model model) {
    Optional<User> user = userRepo.findByResetPasswordToken(token);
    if (isResetPasswordTokenValid(user)) {
      model.addAttribute("token", token);
      return UPDATE_PASSWORD_VIEW_NAME;
    } else {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      model.addAttribute("errorMessage", INVALID_TOKEN_ERROR);
      return ERROR_PAGE_VIEW_NAME;
    }
  }

  private boolean isResetPasswordTokenValid(Optional<User> user) {
    return user.isPresent()
        && user.get().getResetPasswordTokenExpiryTime() > Instant.now().getEpochSecond();
  }

  @PostMapping(value = "update_password", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
  public String updatePassword(String token, String password, Model model,
      HttpServletResponse response) {
    if (password == null || password.length() < 8) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      model.addAttribute("errorMessage", PASSWORD_MALFORMED_ERROR);
      return ERROR_PAGE_VIEW_NAME;
    }
    Optional<User> user = userRepo.findByResetPasswordToken(token);
    if (isResetPasswordTokenValid(user)) {
      user.get().setEncodedPassword(passwordEncoder.encode(password));
      user.get().setResetPasswordTokenExpiryTime(Instant.now().getEpochSecond());
      userRepo.save(user.get());
      model.addAttribute("successMessage", UPDATE_SUCCESSFUL_MESSAGE);
      return SUCCESS_PAGE_VIEW_NAME;
    } else {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      model.addAttribute("errorMessage", INVALID_TOKEN_ERROR);
      return ERROR_PAGE_VIEW_NAME;
    }
  }

  @GetMapping(value = VERIFY_EMAIL_V2_PATH)
  public String verifyEmailV2(
      @RequestParam String token,
      HttpServletResponse response,
      Model model) {

    Optional<RegistrationEmailConfirmationState> state =
        registrationEmailConfirmationStateRepo.findByToken(token);

    if (!state.isPresent()) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      model.addAttribute("errorMessage",
          "هذا الرابط منتهي أو غير صحيح. من فضلك حاول الإشتراك في البرنامج مرة أخرى.");
      return ERROR_PAGE_VIEW_NAME;
    }

    if (userRepo.existsByEmail(state.get().getEmail())) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      model.addAttribute("errorMessage", "تم التحقق من هذا البريد الإلكتروني بالفعل من قبل.");
      return ERROR_PAGE_VIEW_NAME;
    }

    User user = userService.buildNewUser(state.get().getEmail(),
        state.get().getFirstName(),
        state.get().getLastName(),
        state.get().getPassword());

    userService.addNewUser(user);
    registrationEmailConfirmationStateRepo.delete(state.get());

    model.addAttribute("successMessage",
        "تم التحقق من البريد الإلكتروني بنجاح. يمكنك الآن تسجيل الدخول في البرنامج.");
    return SUCCESS_PAGE_VIEW_NAME;
  }
}
