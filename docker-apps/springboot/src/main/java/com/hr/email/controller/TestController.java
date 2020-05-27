package com.hr.email.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

	@GetMapping("/sample")
	public String sample(@RequestParam(value = "name", defaultValue = "Sample") String name) {
		return String.format("This is  %s!", name);
	}

}
