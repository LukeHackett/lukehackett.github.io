---
layout: post

author: Luke Hackett
title:  "Setting up Spring and CORS using hostnames"
tags:
  - java
  - spring
  - spring boot
  - cors
---

The Spring framework has a number of ways in which adding CORS to your application can be achieved. I usually implement a Web Filter, rather than using Spring's configuration, as I often find myself having to implement some logic around which hostnames are accepted by the application's CORS policy (rather than Origins). Rather than use a Web Filter, I wanted to see if it can be done using Spring Config.

<!--excerpt-->

### What is CORS?

In a nutshell, CORS is a security mechanism that allows a web page from one Origin to access a resource with a different Origin (a cross-domain request), for example http://foo.com is accessing a resource hosted by http://bar.com.

Before accessing the resource, the browser will make a preflight request in order to see if it is able to communicate with the target server. As part of the preflight request, the browser will add the `Origin` header to the request, for example: `Origin: http://foo.com`.

If the server responses with a matching value in the `Access-Control-Allow-Origin` header, then the browser will continue to communicate with the resource server, otherwise it will not, and raise an error such as `Reason: CORS header 'Access-Control-Allow-Origin: http://foo.com' does not match 'http://bar.com'`.

### CORS seems simple, whats the problem?

To put it simply, the `Access-Control-Allow-Origin` header can contain one of two values a wildcard or the full acceptable Origin, e.g. `http://bar.com` - crucially not both! This means that it is not possible to return `*.bar.com` which could mean all subdomains under the `bar.com` domain.

If you in a situation where by multiple clients are accessing your resource (from multiple different origins) what do you do? One option could be to use a wildcard, while this would work, it's not particularly secure, as any client from any domain can make requests to your resource server.

An more secure alternative is to setup a whitelist of hostnames (not domains) which are allowed to access your resource, and have the application evaluate whether or not the client's hostname is whitelisted. Luckily Spring has already solved this problem with the [CorsConfiguration](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/cors/CorsConfiguration.html) object which can be used to create a [CorsConfigurationSource](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/cors/CorsConfigurationSource.html) bean.

The only issue (for me at least) is that it evaluates the entire origin string, for example, the following origins are classified as being different, even though they are the same origin:

    Origin: http://localhost
    Origin: http://localhost:8080
    Origin: https://localhost
    Origin: https://localhost:8080

My solution to this problem, was to alter the matching logic, so that if checks the hostname of the origin header value, rather than matching the entire value.

### Matching with the hostname rather than Origin

The first step was to extend Spring's [CorsConfiguration](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/cors/CorsConfiguration.html) class, and override the `checkOrigin` method. As the name suggests the `checkOrigin` method will check to make sure that origin (or in our case the hostname) is an accepted host.

```java
public class HostnameCorsConfiguration extends CorsConfiguration {

    @Override
    public String checkOrigin(String requestOrigin) {
        String hostname = getHostname(requestOrigin);
        boolean isAcceptedHost = super.checkOrigin(hostname) != null;

        return isAcceptedHost ? requestOrigin : null;
    }

    private String getHostname(String requestOrigin) {
        try {
            return new URL(requestOrigin).getHost();
        } catch (MalformedURLException e) {
            // If we are unable to parse the request origin it's probably invalid anyway
        }

        return null;
    }

}
```

Now that we have an implementation that the checks the Hostname rather than the Origin, it's as simple as creating a  [CorsConfigurationSource](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/cors/CorsConfigurationSource.html) bean, using an instance of the `HostnameCorsConfiguration` as the configuration source.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private CorsFilterProperties corsFilterProperties;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        HostnameCorsConfiguration configuration = new HostnameCorsConfiguration();
        configuration.setAllowedOrigins(corsFilterProperties.getAllowedOrigins());
        configuration.setAllowedMethods(corsFilterProperties.getAllowedMethods());
        configuration.setAllowedHeaders(corsFilterProperties.getAllowedHeaders());
        configuration.setMaxAge(corsFilterProperties.getMaxAge());
        configuration.setAllowCredentials(corsFilterProperties.isAllowCredentials());

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }

    // Other methods have been omitted

}
```

The `CorsFilterProperties` is a POJO whose values are pulled from the `application.yaml` file using the `@ConfigurationProperties` annotation - I have omitted this class for brevity. The reason for moving the CORS hostnames into property files is so that different hostnames can be whitelisted for different environments - for example in your dev profile you'd probably want to whitelist localhost.

While the above solution works for all endpoints within the application, when using Spring OAuth2 Resource server, it seems that the CORS filter does not get applied. The solution is to explicitly to set the `CorsFilter` bean as part of the configuration setup, as shown below.

```java
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Autowired
    private  CorsConfigurationSource corsConfigurationSource;

    @Override
    public void configure(AuthorizationServerSecurityConfigurer security) {
        // Ensure the OAuth2 Endpoints are compatible with the application's CORS policy
        security.addTokenEndpointAuthenticationFilter(new CorsFilter(corsConfigurationSource));
    }

    // Other methods have been omitted

}
```

I've previously implemented the CORS hostname whitelist in several ways within various Spring applications, such as using a `WebFilter`. I've always felt that those implementations were "wrong", but now I feel as though this is a cleaner solution, and should be compatible between MVC and Webflux projects! 
