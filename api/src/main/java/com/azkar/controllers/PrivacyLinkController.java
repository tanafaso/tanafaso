package com.azkar.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PrivacyLinkController {

  public static final String PRIVACY_PAGE_ROUTE = "/privacy-policy";
  public static final String PRIVACY_PAGE_VIEW_NAME = "privacy";

  @GetMapping(value = PRIVACY_PAGE_ROUTE)
  public String homePage(Model model) {
    return PRIVACY_PAGE_VIEW_NAME;
  }
}
