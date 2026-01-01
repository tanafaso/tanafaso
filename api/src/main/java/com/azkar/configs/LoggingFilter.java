package com.azkar.configs;

import java.util.Arrays;
import javax.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.CommonsRequestLoggingFilter;

@Configuration
public class LoggingFilter extends CommonsRequestLoggingFilter {

  @Bean
  public CommonsRequestLoggingFilter requestLoggingFilter() {
    CommonsRequestLoggingFilter loggingFilter = new LoggingFilter();
    loggingFilter.setIncludeClientInfo(true);
    loggingFilter.setIncludeQueryString(true);
    loggingFilter.setIncludePayload(true);
    loggingFilter.setMaxPayloadLength(64000);
    return loggingFilter;
  }

  @Override protected boolean shouldLog(HttpServletRequest request) {
    if (Arrays.stream(SecurityConfig.PRE_AUTHENTICAITON_ALLOWED_ENDPOINT_PATTERNS).anyMatch(
        uri -> uri.equals(request.getRequestURI()))) {
      return false;
    }
    return super.shouldLog(request);
  }
}
