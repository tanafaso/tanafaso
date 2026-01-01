package com.azkar.services;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.is;

import com.azkar.TestBase;
import com.azkar.entities.User;
import com.azkar.repos.UserRepo;
import com.google.common.collect.Iterators;
import java.util.ArrayList;
import java.util.HashSet;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

public class UserServiceTest extends TestBase {

  @Autowired
  UserService userService;

  @Autowired
  UserRepo userRepo;

  @Test
  public void buildAndAddNewUser_normalScenario_shouldSucceed() {
    String email = "example_email@example_domain.com";
    String firstName = "example_first_name";
    String lastName = "example_second_name";

    userService.addNewUser(userService.buildNewUser(email, firstName, lastName));

    User user = Iterators.getLast(userRepo.findAll().iterator());
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getFirstName(), equalTo(firstName));
    assertThat(user.getLastName(), equalTo(lastName));
    assertThat(user.getUpdatedAt(), greaterThan(0L));
    assertThat(user.getCreatedAt(), greaterThan(0L));
    assertThatUsernameIsValid(user.getUsername());
  }

  @Test
  public void buildAndAddNewUser_nameHasUpperCaseChars_usernameShouldNotHaveUpperCaseChars() {
    String email = "example_email@example_domain.com";
    String firstName = "eXample_first_name";
    String lastName = "example_second_namE";

    userService.addNewUser(userService.buildNewUser(email, firstName, lastName));

    User user = Iterators.getLast(userRepo.findAll().iterator());
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getFirstName(), equalTo(firstName));
    assertThat(user.getLastName(), equalTo(lastName));
    assertThatUsernameIsValid(user.getUsername());
  }

  @Test
  public void buildAndAddNewUser_nameHasSpaces_usernameShouldNotHaveSpaces() {
    String email = "example_email@example_domain.com";
    String firstName = "Example First Name";
    String lastName = "Example Second Name";

    userService.addNewUser(userService.buildNewUser(email, firstName, lastName));

    User user = Iterators.getLast(userRepo.findAll().iterator());
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getFirstName(), equalTo(firstName));
    assertThat(user.getLastName(), equalTo(lastName));
    assertThatUsernameIsValid(user.getUsername());
  }

  @Test
  public void buildAndAddNewUser_HundredUsersWithSameName_usernamesShouldBeUnique() {
    long usersCountBefore = userRepo.count();
    String email = "example_email@example_domain.com";
    String firstName = "Example First Name";
    String lastName = "Example Last Name";

    ArrayList<User> addedUsers = new ArrayList<>();
    for (int i = 0; i < 100; i++) {
      addedUsers.add(
          userService.addNewUser(
              userService.buildNewUser(email + i, firstName, lastName)));
    }

    assertThat(userRepo.count(), is(usersCountBefore + 100));
    HashSet<String> usernames = new HashSet<>();
    for (User addedUser : addedUsers) {
      User user = userRepo.findById(addedUser.getId()).get();
      assertThat("Usernames are unique", !usernames.contains(user.getUsername()));
      assertThat("Usernames shouldn't be null", user.getUsername() != null);
      assertThatUsernameIsValid(user.getUsername());

      usernames.add(user.getUsername());
    }
  }

  @Test
  public void buildAndAddNewUser_nameHasNonEnglishCharacters_usernameShouldContainOnlyEnglishCharacters()
      throws Exception {
    String email = "example_email@example_domain.com";
    String firstName = "مثال اسم";
    String lastName = "Example Last Name";

    userService.addNewUser(userService.buildNewUser(email, firstName, lastName));

    User user = Iterators.getLast(userRepo.findAll().iterator());
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getFirstName(), equalTo(firstName));
    assertThat(user.getLastName(), equalTo(lastName));
    assertThatUsernameIsValid(user.getUsername());
  }

  @Test
  public void buildAndAddNewUser_nameHasOnlyEnglishCharacters_usernameShouldHaveNameAsPrefix()
      throws Exception {
    String email = "example_email@example_domain.com";
    String firstName = "Example first Name";
    String lastName = "Example Last Name";

    userService.addNewUser(userService.buildNewUser(email, firstName, lastName));

    User user = Iterators.getLast(userRepo.findAll().iterator());
    assertThat(user.getEmail(), equalTo(email));
    assertThat(user.getFirstName(), equalTo(firstName));
    assertThat(user.getLastName(), equalTo(lastName));
    assertThatUsernameIsValid(user.getUsername());
    assertThat(user.getUsername().startsWith("examplefirstname"), is(true));
  }

  private void assertThatUsernameIsValid(String username) {
    assertThat(String.format("Username: %s must have only lower case characters", username),
        username.equals(username.toLowerCase()));
    assertThat(String.format("Username: %s must not contain spaces", username),
        username.indexOf(' ') == -1);
    assertThat(
        String.format("Username: %s must have only english alphabet, numbers, underscores and "
                + "possibly a hyphen",
            username),
        username.matches("[a-zA-Z0-9_-]*"));
  }
}
