package br.com.teste.fullstackapi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable; // Importante para validar o corpo da requisição
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.teste.fullstackapi.dto.UserMapper;
import br.com.teste.fullstackapi.dto.UserResponseDTO;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.service.UserService;
import jakarta.validation.Valid;

/**
 * Controller para gerenciar as requisições relacionadas a Usuários.
 * A anotação @RestController combina @Controller e @ResponseBody,
 * indicando que os retornos dos métodos serão o corpo da resposta HTTP.
 */
@RestController
@RequestMapping("/api/users") // Todas as requisições para este controller começarão com /api/users
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * Endpoint para criar um novo usuário.
     * Mapeado para requisições POST em /api/users.
     *
     * @param user O objeto User vindo do corpo da requisição (@RequestBody).
     *             A anotação @Valid ativa as validações definidas no modelo (se houver).
     * @return uma ResponseEntity contendo o usuário criado e o status HTTP 201 (Created).
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')") 
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User createdUser = userService.createUser(user);
        return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
    }
    
    @GetMapping("/{id}")
    // Um usuário só pode ver a si mesmo, a menos que seja um ADMIN.
    @PreAuthorize("hasRole('ADMIN') or #id == authentication.principal.id") 
    public ResponseEntity<UserResponseDTO> getUserById(@PathVariable Long id) {
        return userService.findUserById(id)
                .map(user -> ResponseEntity.ok(UserMapper.toDTO(user))) // Se encontrar, converte para DTO e retorna 200 OK
                .orElse(ResponseEntity.notFound().build()); // Se não encontrar, retorna 404 Not Found
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')") // Listar todos os usuários é uma ação de Admin
    public ResponseEntity<Page<UserResponseDTO>> getAllUsers(Pageable pageable) {
        // Busca a página de entidades User
        Page<User> userPage = userService.findAllUsers(pageable);
        
        // Converte a página de User para uma página de UserResponseDTO
        Page<UserResponseDTO> userDtoPage = userPage.map(UserMapper::toDTO);
        
        return ResponseEntity.ok(userDtoPage);
    }

}