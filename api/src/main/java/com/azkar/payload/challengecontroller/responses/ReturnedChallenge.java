package com.azkar.payload.challengecontroller.responses;

import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.MemorizationChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
public class ReturnedChallenge {
  AzkarChallenge azkarChallenge;
  MeaningChallenge meaningChallenge;
  ReadingQuranChallenge readingQuranChallenge;
  MemorizationChallenge memorizationChallenge;
  CustomSimpleChallenge customSimpleChallenge;
}
