package com.azkar.controllers.authenticationcontroller;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.azkar.controllers.BaseController;
import com.azkar.entities.RegistrationEmailConfirmationState;
import com.azkar.entities.User;
import com.azkar.entities.User.UserFacebookData;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.authenticationcontroller.requests.AppleAuthenticationRequest;
import com.azkar.payload.authenticationcontroller.requests.EmailLoginRequestBody;
import com.azkar.payload.authenticationcontroller.requests.EmailRegistrationRequestBody;
import com.azkar.payload.authenticationcontroller.requests.EmailVerificationRequestBody;
import com.azkar.payload.authenticationcontroller.requests.FacebookAuthenticationRequest;
import com.azkar.payload.authenticationcontroller.requests.GoogleAuthenticationRequest;
import com.azkar.payload.authenticationcontroller.requests.ResetPasswordRequest;
import com.azkar.payload.authenticationcontroller.responses.AppleAuthenticationResponse;
import com.azkar.payload.authenticationcontroller.responses.EmailLoginResponse;
import com.azkar.payload.authenticationcontroller.responses.EmailRegistrationResponse;
import com.azkar.payload.authenticationcontroller.responses.EmailVerificationResponse;
import com.azkar.payload.authenticationcontroller.responses.FacebookAuthenticationResponse;
import com.azkar.payload.authenticationcontroller.responses.GoogleAuthenticationResponse;
import com.azkar.payload.authenticationcontroller.responses.ResetPasswordResponse;
import com.azkar.repos.RegistrationEmailConfirmationStateRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.JwtService;
import com.azkar.services.UserService;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.security.KeyFactory;
import java.security.interfaces.ECPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Instant;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import lombok.Data;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.bouncycastle.util.io.pem.PemObject;
import org.bouncycastle.util.io.pem.PemReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE)
public class ApiAuthenticationController extends BaseController {

  public static final String LOGIN_WITH_FACEBOOK_PATH = "/login/facebook";
  public static final String LOGIN_WITH_GOOGLE_PATH = "/login/google";
  public static final String LOGIN_WITH_APPLE_PATH = "/login/apple";
  // Use REGISTER_WITH_EMAIL_V2_PATH instead.
  @Deprecated
  public static final String REGISTER_WITH_EMAIL_PATH = "/register/email";
  public static final String REGISTER_WITH_EMAIL_V2_PATH = "/register/email/v2";
  // Use AuthenticationWebController.VERIFY_EMAIL_V2_PATH instead.
  @Deprecated
  public static final String VERIFY_EMAIL_PATH = "/verify/email";
  public static final String LOGIN_WITH_EMAIL_PATH = "/login/email";
  public static final String RESET_PASSWORD_PATH = "/reset_password";
  private static final Logger logger = LoggerFactory.getLogger(ApiAuthenticationController.class);
  private static final long RESET_PASSWORD_EXPIRY_TIME_SECONDS = 30 * 60;

  private static final String RESET_PASSWORD_EMAIL_TEMPLATE_PATH =
      "emailTemplates/reset_password_email.html";
  // Use VERIFY_EMAIL_V2_TEMPLATE_PATH instead.
  @Deprecated
  private static final String VERIFY_EMAIL_TEMPLATE_PATH = "emailTemplates/verify_email.html";
  private static final String VERIFY_EMAIL_V2_TEMPLATE_PATH = "emailTemplates/verify_email_v2.html";
  @Value("${files.apple_auth_private_key}")
  public String appleAuthPrivateKeyFile;
  @Autowired
  UserRepo userRepo;
  @Autowired
  UserService userService;
  @Autowired
  JwtService jwtService;
  @Autowired
  PasswordEncoder passwordEncoder;
  @Autowired
  private RegistrationEmailConfirmationStateRepo registrationEmailConfirmationStateRepo;
  @Autowired
  private JavaMailSender javaMailSender;
  private final RestTemplate restTemplate;
  @Value("${APPLE_TEAM_ID}")
  private String appleTeamId;
  @Value("${APPLE_SIGN_IN_KEY_ID}")
  private String appleSignInKeyId;


  public ApiAuthenticationController(RestTemplateBuilder restTemplateBuilder) {
    restTemplate = restTemplateBuilder.build();
  }

  // Use registerWithEmailV2 instead.
  @Deprecated
  @PutMapping(value = REGISTER_WITH_EMAIL_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<EmailRegistrationResponse> registerWithEmail(
      @RequestBody EmailRegistrationRequestBody body)
      throws MessagingException, IOException {
    EmailRegistrationResponse response = new EmailRegistrationResponse();
    body.validate();

    if (userRepo.existsByEmail(body.getEmail())) {
      response.setStatus(new Status(Status.USER_ALREADY_REGISTERED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (userRepo.existsByUserFacebookData_Email(body.getEmail())) {
      response.setStatus(new Status(Status.USER_ALREADY_REGISTERED_WITH_FACEBOOK));
      return ResponseEntity.badRequest().body(response);
    }

    if (registrationEmailConfirmationStateRepo.existsByEmail(body.getEmail())) {
      logger.warn("A user with email %s is trying to register more than once.", body.getEmail());
    }
    RegistrationEmailConfirmationState registrationEmailConfirmationState =
        registrationEmailConfirmationStateRepo.findByEmail(body.getEmail()).orElse(
            RegistrationEmailConfirmationState.builder()
                .email(body.getEmail())
                .password(passwordEncoder.encode(body.getPassword()))
                .firstName(body.getFirstName())
                .lastName(body.getLastName())
                .build());

    int pin = generatePin();
    registrationEmailConfirmationState.setPin(pin);
    sendVerificationEmail(body.getEmail(), pin);

    registrationEmailConfirmationStateRepo.save(registrationEmailConfirmationState);

    return ResponseEntity.ok(response);
  }

  @PutMapping(value = REGISTER_WITH_EMAIL_V2_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<EmailRegistrationResponse> registerWithEmailV2(
      @RequestBody EmailRegistrationRequestBody body)
      throws MessagingException, IOException {
    EmailRegistrationResponse response = new EmailRegistrationResponse();
    body.validate();

    if (userRepo.existsByEmail(body.getEmail())) {
      response.setStatus(new Status(Status.USER_ALREADY_REGISTERED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (userRepo.existsByUserFacebookData_Email(body.getEmail())) {
      response.setStatus(new Status(Status.USER_ALREADY_REGISTERED_WITH_FACEBOOK));
      return ResponseEntity.badRequest().body(response);
    }

    if (registrationEmailConfirmationStateRepo.existsByEmail(body.getEmail())) {
      logger.warn("A user with email %s is trying to register more than once.", body.getEmail());
    }
    RegistrationEmailConfirmationState registrationEmailConfirmationState =
        registrationEmailConfirmationStateRepo.findByEmail(body.getEmail()).orElse(
            RegistrationEmailConfirmationState.builder()
                .email(body.getEmail())
                .password(passwordEncoder.encode(body.getPassword()))
                .firstName(body.getFirstName())
                .lastName(body.getLastName())
                .build());

    String emailValidationToken = UUID.randomUUID().toString();
    registrationEmailConfirmationState.setToken(emailValidationToken);
    sendVerificationEmailV2(body.getEmail(), emailValidationToken);

    registrationEmailConfirmationStateRepo.save(registrationEmailConfirmationState);

    return ResponseEntity.ok(response);
  }

  // Use verifyEmailV2 instead.
  @Deprecated
  @PutMapping(value = VERIFY_EMAIL_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<EmailVerificationResponse> verifyEmail(
      @RequestBody EmailVerificationRequestBody body) {
    EmailVerificationResponse response = new EmailVerificationResponse();
    body.validate();

    if (userRepo.existsByEmail(body.getEmail())) {
      response.setStatus(new Status(Status.EMAIL_ALREADY_VERIFIED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    Optional<RegistrationEmailConfirmationState> registrationEmailConfirmationState =
        registrationEmailConfirmationStateRepo.findByEmail(body.getEmail());
    if (!registrationEmailConfirmationState.isPresent()
        || registrationEmailConfirmationState.get().getPin() != body.getPin().intValue()) {
      response.setStatus(new Status(Status.VERIFICATION_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    User user = userService.buildNewUser(registrationEmailConfirmationState.get().getEmail(),
        registrationEmailConfirmationState.get().getFirstName(),
        registrationEmailConfirmationState.get().getLastName(),
        registrationEmailConfirmationState.get().getPassword());

    userService.addNewUser(user);
    registrationEmailConfirmationStateRepo.delete(registrationEmailConfirmationState.get());

    return ResponseEntity.ok(response);
  }

  @PutMapping(value = LOGIN_WITH_EMAIL_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<EmailLoginResponse> loginWithEmail(
      @RequestBody EmailLoginRequestBody body) {
    EmailLoginResponse response = new EmailLoginResponse();
    body.validate();

    if (!(SecurityContextHolder.getContext()
        .getAuthentication() instanceof AnonymousAuthenticationToken)) {
      response
          .setStatus(new Status(Status.USER_ALREADY_LOGGED_IN_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (registrationEmailConfirmationStateRepo.existsByEmail(body.getEmail())) {
      response.setStatus(new Status(Status.EMAIL_NOT_VERIFIED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    Optional<User> user = userRepo.findByEmail(body.getEmail());
    if (!user.isPresent() || !passwordEncoder.matches(
        body.getPassword(),
        user.get().getEncodedPassword())) {
      response.setStatus(new Status(Status.EMAIL_PASSWORD_COMBINATION_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    String jwtToken = null;
    try {
      jwtToken = jwtService.generateToken(user.get());
    } catch (UnsupportedEncodingException e) {
      logger.error("Error when generating a verified user token: " + e.getStackTrace());
      response
          .setStatus(new Status(Status.LOGIN_WITH_EMAIL_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.setBearerAuth(jwtToken);
    ResponseEntity<EmailLoginResponse> responseEntity =
        new ResponseEntity(response, httpHeaders, HttpStatus.OK);
    return responseEntity;
  }

  @PostMapping(value = RESET_PASSWORD_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ResetPasswordResponse> resetPassword(
      @RequestBody ResetPasswordRequest request) throws MessagingException, IOException {
    request.validate();
    Optional<User> user = userRepo.findByEmail(request.getEmail());
    if (user.isPresent()) {
      String resetPasswordToken = UUID.randomUUID().toString();
      user.get().setResetPasswordToken(resetPasswordToken);
      user.get().setResetPasswordTokenExpiryTime(
          Instant.now().getEpochSecond() + RESET_PASSWORD_EXPIRY_TIME_SECONDS);
      userRepo.save(user.get());
      sendResetPasswordEmail(request.getEmail(), resetPasswordToken);
      return ResponseEntity.ok(new ResetPasswordResponse());
    } else {
      ResetPasswordResponse errorResponse = new ResetPasswordResponse();
      errorResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }
  }

  /**
   * <p>
   * This mapping is used in two cases: 1- A new user is authenticating with facebook. 2- An
   * existing user is authenticating with facebook because their JWT token is expired or or they
   * don't have it in their session.
   * </p>
   * <p>
   * This request is expected to called by a non-logged in user so the security context
   * authentication is expected to be not set.
   * </p>
   */
  @PutMapping(value = LOGIN_WITH_FACEBOOK_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<FacebookAuthenticationResponse> loginWithFacebook(
      @RequestBody FacebookAuthenticationRequest requestBody) {
    requestBody.validate();
    FacebookAuthenticationResponse response = new FacebookAuthenticationResponse();

    if (!(SecurityContextHolder.getContext()
        .getAuthentication() instanceof AnonymousAuthenticationToken)) {
      logger.warn("User with facebook user ID {} is already logged in",
          requestBody.getFacebookUserId());

      response
          .setStatus(new Status(Status.USER_ALREADY_LOGGED_IN_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    logger.info("Asserting facebook user data for user with ID {} and token {}",
        requestBody.getFacebookUserId(), requestBody.getToken());
    FacebookBasicProfileResponse facebookResponse = assertUserFacebookData(requestBody);

    if (facebookResponse == null) {
      logger.warn("Failed to assert facebook user data for user with ID {}",
          requestBody.getFacebookUserId());

      response
          .setStatus(new Status(Status.AUTHENTICATION_WITH_FACEBOOK_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (facebookResponse.email == null) {
      logger.warn(
          "Facebook has returned a null email address, but we will allow the user to sign in.");
      facebookResponse.setEmail(String.format("%s@fake-generated-email", facebookResponse.id));
    }

    String jwtToken;
    try {
      // Case 2
      User user =
          userRepo.findByUserFacebookData_UserId(facebookResponse.getId()).orElse(null);
      if (user == null) {
        // Case 1
        final Optional<User> sameEmailUser = userRepo.findByEmail(facebookResponse.getEmail());
        if (sameEmailUser.isPresent() && sameEmailUser.get().getUserFacebookData() == null) {
          user = sameEmailUser.get();
        } else if (sameEmailUser.isPresent()) {
          logger.warn("Someone else has already connected this facebook account for facebook user"
              + " ID {}", requestBody.getFacebookUserId());

          response.setStatus(new Status(Status.SOMEONE_ELSE_ALREADY_CONNECTED_ERROR));
          return ResponseEntity.badRequest().body(response);
        } else {
          user = userService.buildNewUser(facebookResponse.email, facebookResponse.firstName,
              facebookResponse.lastName);
          user = userService.addNewUser(user);
        }
      }

      UserFacebookData userFacebookData = UserFacebookData.builder()
          .accessToken(requestBody.getToken())
          .userId(facebookResponse.id)
          .firstName(facebookResponse.firstName)
          .lastName(facebookResponse.lastName)
          .email(facebookResponse.email).build();
      user.setUserFacebookData(userFacebookData);
      user.setFirstName(userFacebookData.getFirstName());
      user.setLastName(userFacebookData.getLastName());
      userRepo.save(user);
      jwtToken = jwtService.generateToken(user);
    } catch (Exception e) {
      logger.error("Problem while trying to connect to facebook.", e);

      response
          .setStatus(new Status(Status.AUTHENTICATION_WITH_FACEBOOK_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.setBearerAuth(jwtToken);
    ResponseEntity<FacebookAuthenticationResponse> responseEntity =
        new ResponseEntity<>(response, httpHeaders, HttpStatus.OK);
    return responseEntity;
  }

  /**
   * This mapping should only be used in case of a logged in user who wants to connect their account
   * with facebook. Note, that maybe they have already connected an account; in that case the new
   * facebook information will override the old one. This request is expected to called by a logged
   * in user so the security context authentication is expected to be set.
   */
  @PutMapping(value = "/connect/facebook", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<FacebookAuthenticationResponse> connectFacebook(
      @RequestBody FacebookAuthenticationRequest requestBody) {
    requestBody.validate();
    FacebookAuthenticationResponse response = new FacebookAuthenticationResponse();

    FacebookBasicProfileResponse facebookResponse = assertUserFacebookData(requestBody);

    if (facebookResponse == null) {
      response
          .setStatus(new Status(Status.AUTHENTICATION_WITH_FACEBOOK_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    User user =
        userRepo.findByUserFacebookData_UserId(facebookResponse.getId())
            .orElse(userRepo.findById(getCurrentUser().getUserId()).get());
    if (!user.getId().equals(getCurrentUser().getUserId())) {
      logger.warn("The user is attempting to connect a facebook account already connected to "
          + "another account.");
      response
          .setStatus(new Status(Status.SOMEONE_ELSE_ALREADY_CONNECTED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    UserFacebookData userFacebookData = UserFacebookData.builder()
        .accessToken(requestBody.getToken())
        .userId(facebookResponse.id)
        .firstName(facebookResponse.firstName)
        .lastName(facebookResponse.lastName)
        .email(facebookResponse.email).build();
    user.setUserFacebookData(userFacebookData);
    userRepo.save(user);

    return ResponseEntity.ok(response);
  }

  @PutMapping(value = LOGIN_WITH_GOOGLE_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<GoogleAuthenticationResponse> loginWithGoogle(
      @RequestBody GoogleAuthenticationRequest request) {
    request.validate();

    GoogleAuthenticationResponse response = new GoogleAuthenticationResponse();
    GoogleIdTokenVerifier verifier =
        new GoogleIdTokenVerifier(new NetHttpTransport(), new GsonFactory());

    GoogleIdToken idToken;
    try {
      idToken = verifier.verify(request.getGoogleIdToken());
    } catch (Exception e) {
      logger.warn("Failed to verify the Google ID token: {}", request.getGoogleIdToken(), e);
      response.setStatus(new Status(Status.AUTHENTICATION_WITH_GOOGLE_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (idToken == null) {
      logger.warn("ID token returned from verification for token: {} is empty",
          request.getGoogleIdToken());
      response.setStatus(new Status(Status.AUTHENTICATION_WITH_GOOGLE_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    Payload payload = idToken.getPayload();
    String userId = payload.getSubject();
    String email = payload.getEmail();
    boolean emailVerified = payload.getEmailVerified();
    String name = (String) payload.get("name");
    String familyName = (String) payload.get("family_name");
    String givenName = (String) payload.get("given_name");
    logger.info("User is trying to login with Google [userId: {}, email: {}, emailVerified: {},"
            + " name: {}, familyName: {}, givenName: {}]", userId, email, emailVerified, name,
        familyName, givenName);

    Optional<User> user = userRepo.findByEmail(email);
    if (user.isPresent()) {
      logger.info("Logging with Google: User has logged in with this email before");
    } else {
      if (givenName == null || givenName.isEmpty()) {
        user = Optional.of(
            userService.addNewUser(userService.buildNewUser(email, name, "")));
      } else {
        user = Optional.of(
            userService.addNewUser(userService.buildNewUser(email, givenName, familyName)));
      }
    }

    String jwtToken;
    try {
      jwtToken = jwtService.generateToken(user.get());
    } catch (UnsupportedEncodingException e) {
      logger.warn("Failed to generate JWT token for user logging in with Google with email {}",
          email, e);
      response.setStatus(new Status(Status.AUTHENTICATION_WITH_GOOGLE_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.setBearerAuth(jwtToken);
    ResponseEntity<GoogleAuthenticationResponse> responseEntity =
        new ResponseEntity<>(response, httpHeaders, HttpStatus.OK);
    return responseEntity;
  }

  @PutMapping(value = LOGIN_WITH_APPLE_PATH, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<AppleAuthenticationResponse> loginWithApple(
      @RequestBody AppleAuthenticationRequest request) {
    request.validate();

    AppleAuthenticationResponse response = new AppleAuthenticationResponse();

    logger.info("A user is trying to login with Apple [email: {}, firstName: "
        + "{}, lastName: {}]", request.getEmail(), request.getFirstName(), request.getLastName());

    if (!validateAppleAuthCode(request)) {
      response.setStatus(new Status(Status.AUTHENTICATION_WITH_APPLE_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    logger.info("Verified data for user who is trying to login with Apple [email: {}, firstName: "
        + "{}, lastName: {}]", request.getEmail(), request.getFirstName(), request.getLastName());

    Optional<User> user = userRepo.findByEmail(request.getEmail());
    if (user.isPresent()) {
      logger.info("Logging with Apple: User has logged in with this email before");
    } else {
      user = Optional.of(
          userService.addNewUser(userService.buildNewUser(request.getEmail(),
              request.getFirstName(), request.getLastName())));
    }

    String jwtToken;
    try {
      jwtToken = jwtService.generateToken(user.get());
    } catch (UnsupportedEncodingException e) {
      logger.warn("Failed to generate JWT token for user logging in with Apple with email {}",
          request.getEmail(), e);
      response.setStatus(new Status(Status.AUTHENTICATION_WITH_APPLE_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.setBearerAuth(jwtToken);
    ResponseEntity<AppleAuthenticationResponse> responseEntity =
        new ResponseEntity<>(response, httpHeaders, HttpStatus.OK);
    return responseEntity;
  }

  private void sendVerificationEmail(String email, int pin)
      throws MessagingException, IOException {
    String subject = "تأكيد البريد الإلكتروني";
    String text = getEmailTemplate(VERIFY_EMAIL_TEMPLATE_PATH)
        .replaceAll("PIN", "" + pin);
    sendEmail(email, subject, text);
  }

  private void sendVerificationEmailV2(String email, String token)
      throws MessagingException, IOException {
    String subject = "تأكيد البريد الإلكتروني";
    String url = String.format("https://www.tanafaso.com/verify/email/v2?token=%s", token);
    String html = getEmailTemplate(VERIFY_EMAIL_V2_TEMPLATE_PATH)
        .replaceAll("URL", url);
    sendEmail(email, subject, html);
  }

  private void sendResetPasswordEmail(String email, String token)
      throws MessagingException, IOException {
    String subject = "إعادة ضبط كلمة المرور";
    String url = String.format("https://www.tanafaso.com/update_password?token=%s", token);
    // adding a random number at the end to make sure that gmail does not collapse the email ending.
    String text = getEmailTemplate(RESET_PASSWORD_EMAIL_TEMPLATE_PATH)
        .replaceAll("URL", url)
        .replaceAll("RANDOM", RandomStringUtils.randomNumeric(2));
    sendEmail(email, subject, text);
  }

  private String getEmailTemplate(String path) throws IOException {
    return IOUtils.toString(
        new InputStreamReader(new ClassPathResource(path).getInputStream()));
  }

  private void sendEmail(String email, String subject, String body)
      throws MessagingException, UnsupportedEncodingException {
    MimeMessage mimeMessage = javaMailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");
    // This should be disregarded by new Mime clients.
    InternetAddress fromAddress = new InternetAddress("azkar_email_name@azkaremaildomain.com",
        "تنافسوا");
    helper.setFrom(fromAddress);
    helper.setSubject(subject);
    helper.setText(body, /* html= */ true);
    helper.setTo(email);
    javaMailSender.send(mimeMessage);
  }

  private int generatePin() {
    final int min = 100_000;
    final int max = 1000_000 - 1;
    return new Random(System.currentTimeMillis()).nextInt(max - min) + min;
  }

  private FacebookBasicProfileResponse assertUserFacebookData(FacebookAuthenticationRequest body) {
    String facebookGraphApiUril =
        "https://graph.facebook.com/v7.0/me?fields=id,first_name,last_name,email&access_token="
            + body.getToken();

    logger.info("Sending to Facebook graph API");
    FacebookBasicProfileResponse facebookResponse = restTemplate.getForObject(
        facebookGraphApiUril,
        FacebookBasicProfileResponse.class);

    logger.info("Got response from facebook graph API. ID: {}, email: {}, first name: {}, last "
            + "name: {}",
        facebookResponse.id,
        facebookResponse.email, facebookResponse.firstName, facebookResponse.lastName);
    if (facebookResponse.id == null || !facebookResponse.id.equals(body.getFacebookUserId())) {
      logger.warn("Facebook returned a null ID");
      return null;
    }

    return facebookResponse;
  }

  private boolean validateAppleAuthCode(AppleAuthenticationRequest request) {
    Map<String, Object> appleApiRequestHeader = new HashMap<>();
    appleApiRequestHeader.put("alg", "ES256");
    appleApiRequestHeader.put("kid", appleSignInKeyId);
    appleApiRequestHeader.put("typ", "JWT");

    InputStreamReader appleAuthPrivateKeyInputStreamReader;
    try {
      appleAuthPrivateKeyInputStreamReader =
          new InputStreamReader(new ClassPathResource(appleAuthPrivateKeyFile).getInputStream());
    } catch (IOException e) {
      logger.error("Couldn't read the apple authorization private key file.", e);
      return false;
    }

    ECPrivateKey privateKey;
    try {
      PemObject pemObject;
      pemObject = new PemReader(appleAuthPrivateKeyInputStreamReader).readPemObject();
      PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(pemObject.getContent());
      KeyFactory factory;
      factory = KeyFactory.getInstance("EC");
      privateKey = (ECPrivateKey) factory.generatePrivate(spec);
    } catch (Exception e) {
      logger.error("Could not convert Apple private key into an EC key.", e);
      return false;
    }

    String signedJwt = JWT.create()
        .withHeader(appleApiRequestHeader)
        .withIssuer(appleTeamId)
        .withIssuedAt(new Date(System.currentTimeMillis()))
        .withExpiresAt(new Date(System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(10)))
        .withAudience("https://appleid.apple.com")
        .withSubject("com.tanafaso.azkar")
        .sign(Algorithm.ECDSA256(privateKey));

    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

    MultiValueMap<String, String> map = new LinkedMultiValueMap<String, String>();
    map.add("client_id", "com.tanafaso.azkar");
    map.add("client_secret", signedJwt);
    map.add("code", request.getAuthCode());
    map.add("grant_type", "authorization_code");

    HttpEntity<MultiValueMap<String, String>> appleApiRequestHttpEntity =
        new HttpEntity<>(map, headers);

    logger.info("Sending to Apple auth code verification API.");

    ResponseEntity<AppleIdToken> appleIdToken = restTemplate
        .postForEntity("https://appleid.apple.com/auth/token", appleApiRequestHttpEntity,
            AppleIdToken.class);

    if (appleIdToken.getStatusCode() == HttpStatus.OK) {
      DecodedJWT decodedJwt = JWT.decode(appleIdToken.getBody().getIdToken());
      boolean emailIsVerified = decodedJwt.getClaim("email_verified").asString().equals("true");
      String potentiallyVerifiedEmail = decodedJwt.getClaim("email").asString().toLowerCase();
      if (emailIsVerified && potentiallyVerifiedEmail.equals(request.getEmail())) {
        return true;
      }

      logger.info("Failed to verify user signing in with apple: email={}, firstName={}, "
              + "lastName={}, emailIsVerified={}, appleApiReturnedEmail={}",
          request.getEmail(), request.getFirstName(), request.getLastName(), emailIsVerified,
          potentiallyVerifiedEmail);
      return false;
    }

    logger.info("Failed to verify user signing in with apple as apple API returned status code: "
            + "{} for email={}, firstName={}, lastName={}",
        appleIdToken.getStatusCode(), request.getEmail(), request.getFirstName(),
        request.getLastName());
    return false;
  }


  @Data
  public static class FacebookBasicProfileResponse {

    String id;
    @JsonProperty("first_name")
    String firstName;
    @JsonProperty("last_name")
    String lastName;
    String email;
  }

  @Data
  public static class AppleIdToken {

    @JsonProperty("id_token")
    String idToken;
  }

}
