package com.azkar.controllers;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Category;
import com.azkar.entities.User;
import com.azkar.entities.Zekr;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.azkarcontroller.responses.GetAzkarResponse;
import com.azkar.payload.azkarcontroller.responses.GetCategoriesResponse;
import com.google.common.collect.ImmutableList;
import java.util.List;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.MediaType;

// TODO(issue/238): Remove GET /azkar test and rename this class
public class AzkarControllerTest extends TestBase {

  final String ZEKR0 = "اللهم أنت ربي، لا إله إلا أنت، خلَقتني وأنا عبدك، وأنا على عهدك ووعدك ما "
      + "استطعت، أعوذ بك من شرِّ ما صنعت، أبُوء لك بنعمتك عليّ وأبوء بذنبي، فاغفر لي؛ فإنه لا يغفر الذنوب إلا أنت'، قال: 'مَن قالها من النهار موقنًا بها، فمات من يومه قبل أن يُمسي، فهو من أهل الجنة، ومن قالها من الليل وهو مُوقن بها، فمات قبل أن يُصبح، فهو من أهل الجنة";
  final String ZEKR1 = "اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور";
  final String ZEKR2 =
      "أصبحنا وأصبح (أمسينا وأمسى) المُلك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير، ربِّ أسألك خير ما في هذا اليوم (الليلة)، وخير ما بعده، وأعوذ بك من شرِّ ما في هذا اليوم (الليلة)، وشر ما بعده، ربِّ أعوذ بك من الكسل، وسوء الكِبَر، ربِّ أعوذ بك من عذابٍ في النار وعذاب في القبر";
  @Autowired
  ResourceLoader resourceLoader;

  // NOTE: Please refer to resources/test-azkar.csv file to view the test data.
  @Test
  public void getAzkar_shouldSucceed() throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);

    List<Zekr> expectedAzkar = ImmutableList.of(
        Zekr.builder().id(0).zekr(ZEKR0).build(),
        Zekr.builder().id(1).zekr(ZEKR1).build(),
        Zekr.builder().id(2).zekr(ZEKR2).build());

    GetAzkarResponse expectedResponse = new GetAzkarResponse();
    expectedResponse.setData(expectedAzkar);

    performGetRequest(user, "/azkar")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  // NOTE: Please refer to resources/test-azkar.csv and resources/test-categories.csv files to view
  // the test data.
  @Test
  public void getCategories_shouldSucceed() throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);

    String category0 = "أذكار الصباح";
    String category1 = "أذكار المساء";

    List<Zekr> category0Azkar = ImmutableList.of(
        Zekr.builder().id(0).zekr(ZEKR0).build(),
        Zekr.builder().id(1).zekr(ZEKR1).build());

    List<Zekr> category1Azkar = ImmutableList.of(
        Zekr.builder().id(1).zekr(ZEKR1).build(),
        Zekr.builder().id(2).zekr(ZEKR2).build());

    List<Category> expectedCategories = ImmutableList.of(
        Category.builder().id(0).name(category0).azkar(category0Azkar).build(),
        Category.builder().id(1).name(category1).azkar(category1Azkar).build());

    GetCategoriesResponse expectedResponse = new GetCategoriesResponse();
    expectedResponse.setData(expectedCategories);

    performGetRequest(user, "/categories")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }
}
