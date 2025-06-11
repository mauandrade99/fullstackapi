// src/main/java/br/com/teste/fullstackapi/model/User.java
package br.com.teste.fullstackapi.model;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User implements UserDetails { // <-- 1. Implementar a interface

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nome;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String senha;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @OneToMany(mappedBy = "usuario", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Address> enderecos;
    
    // Construtor vazio
    public User() {}

    // --- 2. MÉTODOS EXIGIDOS PELA INTERFACE UserDetails ---

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Retorna a lista de permissões/roles do usuário.
        // O Spring Security usará isso para autorização.
        return List.of(new SimpleGrantedAuthority(role.name()));
    }

    @Override
    public String getPassword() {
        // Retorna a senha (criptografada).
        return this.senha;
    }

    @Override
    public String getUsername() {
        // Retorna o nome de usuário. No nosso caso, usaremos o e-mail.
        return this.email;
    }

    @Override
    public boolean isAccountNonExpired() {
        // Indica se a conta do usuário não expirou.
        return true; // Deixaremos como true por padrão.
    }

    @Override
    public boolean isAccountNonLocked() {
        // Indica se a conta não está bloqueada.
        return true; // Deixaremos como true por padrão.
    }

    @Override
    public boolean isCredentialsNonExpired() {
        // Indica se as credenciais (senha) não expiraram.
        return true; // Deixaremos como true por padrão.
    }

    @Override
    public boolean isEnabled() {
        // Indica se o usuário está habilitado.
        return true; // Deixaremos como true por padrão.
    }
    
    // --- FIM DOS MÉTODOS UserDetails ---


    // --- GETTERS E SETTERS (JÁ DEVEM ESTAR AÍ) ---

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // O método getPassword() já foi implementado acima, não precisa de outro.
    // getUsername() também já foi implementado.
    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public List<Address> getEnderecos() {
        return enderecos;
    }

    public void setEnderecos(List<Address> enderecos) {
        this.enderecos = enderecos;
    }
}