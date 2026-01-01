package com.azkar.payload.utils;

public class VersionComparator {

  public static int compare(String v1, String v2) {
    String[] v1Parts = v1.split("\\.");
    String[] v2Parts = v2.split("\\.");
    int length = Math.max(v1Parts.length, v2Parts.length);
    for (int i = 0; i < length; i++) {
      int v1Part = i < v1Parts.length ? Integer.parseInt(v1Parts[i]) : 0;
      int v2Part = i < v2Parts.length ? Integer.parseInt(v2Parts[i]) : 0;
      if (v1Part < v2Part) {
        return -1;
      }
      if (v1Part > v2Part) {
        return 1;
      }
    }
    return 0;
  }
}
