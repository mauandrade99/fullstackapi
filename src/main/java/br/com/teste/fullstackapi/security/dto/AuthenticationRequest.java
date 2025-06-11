package br.com.teste.fullstackapi.security.dto;

public class AuthenticationRequest {
    private String email;
    private String senha;
    public AuthenticationRequest() {}
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }
}