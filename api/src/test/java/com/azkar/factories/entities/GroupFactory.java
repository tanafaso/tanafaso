package com.azkar.factories.entities;

import com.azkar.entities.Group;
import java.util.ArrayList;
import java.util.List;

public class GroupFactory {

  static int groupsRequested = 0;

  // Use AzkarApi.addGroup or AzkarApi.addGroupAndReturn instead.
  @Deprecated
  public static Group getNewGroup(String adminId) {
    groupsRequested++;

    List<String> groupUsersIds = new ArrayList();
    groupUsersIds.add(adminId);

    Group group = Group.builder()
        .id("group_id" + groupsRequested)
        .creatorId(adminId)
        .name("group_name" + groupsRequested)
        .usersIds(groupUsersIds)
        .build();

    return group;
  }
}
