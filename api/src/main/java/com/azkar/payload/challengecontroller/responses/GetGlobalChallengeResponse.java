package com.azkar.payload.challengecontroller.responses;

import com.azkar.payload.ResponseBase;
import com.azkar.payload.challengecontroller.responses.GetGlobalChallengeResponse.ReturnedGlobalChallenge;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class GetGlobalChallengeResponse extends ResponseBase<ReturnedGlobalChallenge> {

  // This class holds an instance of one of the challenge types. For now, it can only hold an
  // AzkarChallenge instance.
  @Builder
  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  @Setter
  public static class ReturnedGlobalChallenge {

    ReturnedChallenge challenge;
    int finishedCount;
  }
}
