package br.com.teste.fullstackapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class FullstackapiApplication {

	public static void main(String[] args) {
		SpringApplication.run(FullstackapiApplication.class, args);
	}

} 
