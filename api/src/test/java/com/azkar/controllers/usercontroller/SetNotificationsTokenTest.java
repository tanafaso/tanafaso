package com.azkar.controllers.usercontroller;

import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.usercontroller.requests.SetNotificationTokenRequestBody;
import com.azkar.payload.usercontroller.responses.SetNotificationTokenResponse;
import org.junit.Test;
import org.springframework.http.MediaType;

public class SetNotificationsTokenTest extends TestBase {

  @Test
  public void setNotificationsToken_normalScenario_shouldSucceed() throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);
    assertThat(user.getNotificationsToken(), nullValue());
    String notificationsTokenExample = "token-example";
    SetNotificationTokenRequestBody body =
        new SetNotificationTokenRequestBody(notificationsTokenExample);

    SetNotificationTokenResponse response = new SetNotificationTokenResponse();
    azkarApi.sendNotificationsToken(user, body)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(response)));
  }
}
