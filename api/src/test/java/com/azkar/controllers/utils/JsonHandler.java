package com.azkar.controllers.utils;

import com.fasterxml.jackson.annotation.JsonInclude.Include;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonHandler {

  private static final ObjectMapper mapper = new ObjectMapper();

  static {
    mapper.setSerializationInclusion(Include.NON_NULL);
  }

  public static String toJson(Object obj) throws JsonProcessingException {
    return mapper.writeValueAsString(obj);
  }

  public static <T> T fromJson(String json, Class<T> c) throws JsonProcessingException {
    return mapper.readValue(json, c);
  }
}
