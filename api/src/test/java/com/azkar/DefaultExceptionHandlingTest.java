package com.azkar;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.DefaultExceptionResponse;
import org.junit.Test;
import org.springframework.http.MediaType;

public class DefaultExceptionHandlingTest extends TestBase {

  @Test
  public void invalidRequest_handlerNotSupportingHttpMethod_shouldNotSucceed() throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);

    DefaultExceptionResponse expectedResponse = new DefaultExceptionResponse();
    expectedResponse.setStatus(new Status(Status.DEFAULT_ERROR));
    azkarApi.callNonExistingEndpoint(user)
        .andExpect(status().isInternalServerError())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }
}
