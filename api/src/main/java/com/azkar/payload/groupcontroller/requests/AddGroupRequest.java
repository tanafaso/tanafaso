package com.azkar.payload.groupcontroller.requests;

import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.exceptions.BadRequestException;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddGroupRequest extends RequestBodyBase {

  String name;

  @Override public void validate() throws BadRequestException {
    checkNotNull(name);
  }
}
