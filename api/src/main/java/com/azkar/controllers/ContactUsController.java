package com.azkar.controllers;

import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.ERROR_PAGE_VIEW_NAME;
import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.SUCCESS_PAGE_VIEW_NAME;

import java.io.FileWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller()
public class ContactUsController {

  public static final String CONTACT_US_PAGE_PATH = "contact_us_page";
  private static final Logger logger = LoggerFactory.getLogger(ContactUsController.class);
  private static final String SUCCESS_MESSAGE = "تم إرسال رسالتك بنجاح.";
  private static final String ERROR_MESSAGE = "حدث خطأ. برجاء المحاولة مرة أخرى.";
  private static final String FEEDBACK_FILE_PATH = "feedback.csv";

  @Autowired
  ResourceLoader resourceLoader;

  @GetMapping(value = "/contact")
  public String contactUs() {
    return CONTACT_US_PAGE_PATH;
  }

  @PostMapping(value = "/feedback")
  public String submitFeedback(@RequestParam String name, @RequestParam String email,
      @RequestParam String subject, @RequestParam String msg, Model model) {
    try {
      FileWriter pw =
          new FileWriter(FEEDBACK_FILE_PATH, /* append= */true);
      pw.append(String.join(",",
          name, email, subject, msg));
      pw.append("\n");
      pw.flush();
      pw.close();
      model.addAttribute("successMessage", SUCCESS_MESSAGE);
      return SUCCESS_PAGE_VIEW_NAME;
    } catch (Exception e) {
      logger.error(String.format("Cannot write to %s file.", FEEDBACK_FILE_PATH), e);
      model.addAttribute("errorMessage", ERROR_MESSAGE);
      return ERROR_PAGE_VIEW_NAME;
    }

  }

}
