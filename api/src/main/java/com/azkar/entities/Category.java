package com.azkar.entities;

import java.util.ArrayList;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.Setter;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class Category {

  @NonNull
  Integer id;
  @NonNull
  String name;
  List<Zekr> azkar = new ArrayList<>();
}
