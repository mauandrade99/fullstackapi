package br.com.teste.fullstackapi.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import br.com.teste.fullstackapi.model.Role;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.repository.UserRepository;

@ExtendWith(MockitoExtension.class) 
class UserServiceTest {

    @Mock // Cria um mock (objeto falso) para o UserRepository
    private UserRepository userRepository;

    @Mock // Cria um mock para o PasswordEncoder
    private PasswordEncoder passwordEncoder;

    @InjectMocks // Cria uma instância real de UserService e injeta os mocks acima nela
    private UserService userService;

    private User user;

    @SuppressWarnings("unused") 
    @BeforeEach 
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setNome("Test User");
        user.setEmail("test@email.com");
        user.setSenha("password");
        user.setRole(Role.ROLE_USER);
    }

    @Test
    void whenCreateUser_shouldReturnUser() {
        // --- 1. Arrange (Preparação) ---
        // Quando o método "save" do mock userRepository for chamado com qualquer objeto User,
        // ele deve retornar o nosso objeto user de teste.
        when(userRepository.save(any(User.class))).thenReturn(user);

        // Quando o método "encode" do mock passwordEncoder for chamado,
        // ele deve retornar uma string "encodedPassword".
        when(passwordEncoder.encode(any(String.class))).thenReturn("encodedPassword");

        // --- 2. Act (Ação) ---
        // Chama o método que queremos testar
        User createdUser = userService.createUser(user);

        // --- 3. Assert (Verificação) ---
        assertNotNull(createdUser); // Verifica se o usuário retornado não é nulo
        assertEquals("test@email.com", createdUser.getEmail()); // Verifica se o email está correto
        assertEquals("encodedPassword", createdUser.getSenha()); // Verifica se a senha foi criptografada

        // Verifica se o método save do userRepository foi chamado exatamente 1 vez
        verify(userRepository, times(1)).save(any(User.class));
        // Verifica se o método encode do passwordEncoder foi chamado exatamente 1 vez
        verify(passwordEncoder, times(1)).encode("password");
    }
}