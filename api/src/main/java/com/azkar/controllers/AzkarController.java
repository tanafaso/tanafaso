package com.azkar.controllers;

import com.azkar.configs.AzkarCacher;
import com.azkar.configs.CategoriesCacher;
import com.azkar.entities.Category;
import com.azkar.entities.Zekr;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.azkarcontroller.responses.GetAzkarResponse;
import com.azkar.payload.azkarcontroller.responses.GetCategoriesResponse;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

// TODO(issue/238): Remove GET /azkar and rename this class
@RestController
public class AzkarController extends BaseController {

  private static final Logger logger = LoggerFactory.getLogger(ChallengeController.class);

  @Autowired
  AzkarCacher azkarCacher;

  @Autowired
  CategoriesCacher categoriesCacher;

  @GetMapping(path = "/azkar", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<GetAzkarResponse> getAzkar() {
    GetAzkarResponse response = new GetAzkarResponse();
    List<Zekr> azkar = azkarCacher.getAzkar();
    if (azkar.isEmpty()) {
      logger.error("Can't retrieve azkar");
      response.setStatus(new Status(Status.DEFAULT_ERROR));
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    response.setData(azkar);
    return ResponseEntity.ok(response);
  }

  @GetMapping(path = "/categories", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<GetCategoriesResponse> getCategories() {
    GetCategoriesResponse response = new GetCategoriesResponse();
    List<Category> categories = categoriesCacher.getCategories();
    if (categories.isEmpty()) {
      logger.error("Can't retrieve categories");
      response.setStatus(new Status(Status.DEFAULT_ERROR));
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    response.setData(categories);
    return ResponseEntity.ok(response);
  }

}
