package com.azkar.controllers.homecontroller;

import com.azkar.controllers.BaseController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebHomeController extends BaseController {

  public static final String HOME_PAGE_VIEW_NAME = "home";
  public static final String DELETE_ME_PAGE_VIEW_NAME = "delete_me";

  @GetMapping(value = "/")
  public String homePage(Model model) {
    return HOME_PAGE_VIEW_NAME;
  }

  @GetMapping(value = "/delete_me")
  public String deleteMe(Model model) {
    return DELETE_ME_PAGE_VIEW_NAME;
  }

  @DeleteMapping(value = "/delete_me")
  public String deleteMeDeleteMapping(Model model) {
    return DELETE_ME_PAGE_VIEW_NAME;
  }
}
