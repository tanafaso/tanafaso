package com.azkar.payload.utils;

import lombok.Builder;
import lombok.Getter;

@Builder(toBuilder = true)
@Getter
public class UserScore {

  String firstName;
  String lastName;
  String username;
  int totalScore;
}