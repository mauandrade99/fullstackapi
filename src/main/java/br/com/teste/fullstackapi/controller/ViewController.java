package br.com.teste.fullstackapi.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.ModelAndView; 

@Controller
public class ViewController {

    @GetMapping("/login")
    public ModelAndView loginPage() {
        return new ModelAndView("login"); 
    }

    @GetMapping("/register")
    public ModelAndView registerPage() {
        return new ModelAndView("register");
    }

    @GetMapping("/dashboard")
    public ModelAndView dashboardPage() {
        return new ModelAndView("dashboard");
    }
}