package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(proxyBeanMethods = false)
public class GraalvmSpringbootExampleApplication {

	public static void main(String[] args) {
		SpringApplication.run(GraalvmSpringbootExampleApplication.class, args);
	}

}
