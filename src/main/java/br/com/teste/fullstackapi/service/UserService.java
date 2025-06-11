// src/main/java/br/com/teste/fullstackapi/service/UserService.java
package br.com.teste.fullstackapi.service;

// --- IMPORTAÇÕES ADICIONADAS ---
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import br.com.teste.fullstackapi.model.Role;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.repository.UserRepository;
// ---------------------------------

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository; 

    @Autowired
    private PasswordEncoder passwordEncoder;

    public User createUser(User user) {
        // Criptografa a senha antes de salvar
        user.setSenha(passwordEncoder.encode(user.getSenha()));
        
        // Define um papel padrão para novos usuários
        if (user.getRole() == null) {
            user.setRole(Role.ROLE_USER);
        }
        
        return userRepository.save(user);
    }
    
    public Optional<User> findUserById(Long id) {
        return userRepository.findById(id);
    }
}