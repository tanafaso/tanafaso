package com.azkar.controllers;

import static com.azkar.controllers.authenticationcontroller.WebAuthenticationController.SUCCESS_PAGE_VIEW_NAME;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

import com.azkar.TestBase;
import org.junit.Test;

public class ContactUsControllerTest extends TestBase {

  @Test
  public void getContactUsPage() throws Exception {
    httpClient.performGetRequest(/* token= */"", "/contact").andExpect(status().isOk())
        .andExpect(view().name(ContactUsController.CONTACT_US_PAGE_PATH));
  }

  @Test
  public void submitFeedback() throws Exception {
    httpClient.performPostRequest("/feedback?name=name&email=email&msg=msg&subject=subject", "")
        .andExpect(status().isOk())
        .andExpect(view().name(SUCCESS_PAGE_VIEW_NAME));
    // TODO: Make sure that the feedback is saved
  }
}
