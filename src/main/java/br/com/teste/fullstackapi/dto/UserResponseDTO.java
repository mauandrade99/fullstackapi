package br.com.teste.fullstackapi.dto;

import br.com.teste.fullstackapi.model.Role;

// Esta classe representa os dados de um usuário que serão enviados para o cliente.
public class UserResponseDTO {

    private Long id;
    private String nome;
    private String email;
    private Role role;

    // Construtor vazio
    public UserResponseDTO() {}

    // Construtor com argumentos para facilitar a conversão
    public UserResponseDTO(Long id, String nome, String email, Role role) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.role = role;
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
}