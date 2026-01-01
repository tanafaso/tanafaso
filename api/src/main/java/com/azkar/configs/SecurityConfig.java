package com.azkar.configs;

import com.azkar.configs.authentication.JwtAuthenticationFilter;
import com.azkar.controllers.AppLinkController;
import com.azkar.controllers.PrivacyLinkController;
import com.azkar.controllers.authenticationcontroller.ApiAuthenticationController;
import com.azkar.controllers.authenticationcontroller.WebAuthenticationController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  public static final String[] PRE_AUTHENTICAITON_ALLOWED_ENDPOINT_PATTERNS = {
      "/",
      "/delete_me",
      "/contact",
      "/feedback",
      "/images/**",
      WebAuthenticationController.UPDATE_PASSWORD_PATH + "/**", // allow all subdirectories
      ApiAuthenticationController.REGISTER_WITH_EMAIL_PATH,
      ApiAuthenticationController.REGISTER_WITH_EMAIL_V2_PATH,
      ApiAuthenticationController.VERIFY_EMAIL_PATH,
      WebAuthenticationController.VERIFY_EMAIL_V2_PATH,
      ApiAuthenticationController.LOGIN_WITH_EMAIL_PATH,
      ApiAuthenticationController.LOGIN_WITH_FACEBOOK_PATH,
      ApiAuthenticationController.LOGIN_WITH_GOOGLE_PATH,
      ApiAuthenticationController.LOGIN_WITH_APPLE_PATH,
      ApiAuthenticationController.RESET_PASSWORD_PATH,
      AppLinkController.STORE_LINK_ANDROID_PATH,
      AppLinkController.STORE_LINK_IOS_PATH,
      PrivacyLinkController.PRIVACY_PAGE_ROUTE,
  };
  @Autowired
  JwtAuthenticationFilter jwtAuthenticationFilter;

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests()
        .antMatchers(PRE_AUTHENTICAITON_ALLOWED_ENDPOINT_PATTERNS)
        .permitAll()
        .antMatchers("/**")
        .authenticated()
        .and()
        .sessionManagement()
        .sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

    // allowing cors origin.
    http.cors().and().csrf().disable();
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.addAllowedOriginPattern("*");
    configuration.addAllowedMethod("*");
    configuration.addAllowedHeader("*");
    configuration.setAllowCredentials(true);
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }
}
