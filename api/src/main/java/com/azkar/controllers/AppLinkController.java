package com.azkar.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.view.RedirectView;

@Controller
public class AppLinkController {

  public static final String STORE_LINK_ANDROID_PATH = "/store-link/android";
  public static final String STORE_LINK_IOS_PATH = "/store-link/ios";

  @GetMapping(STORE_LINK_ANDROID_PATH)
  public RedirectView getAndroidStoreLink(
      RedirectAttributes attributes) {
    attributes.addFlashAttribute("flashAttribute", "redirectWithRedirectView");
    attributes.addAttribute("attribute", "redirectWithRedirectView");
    return new RedirectView("https://play.google.com/store/apps/details?id=com.tanafaso.azkar");
  }

  @GetMapping(STORE_LINK_IOS_PATH)
  public RedirectView getIosStoreLink(
      RedirectAttributes attributes) {
    attributes.addFlashAttribute("flashAttribute", "redirectWithRedirectView");
    attributes.addAttribute("attribute", "redirectWithRedirectView");
    return new RedirectView("https://apps.apple.com/us/app/id1564309117?platform=iphone");
  }
}
