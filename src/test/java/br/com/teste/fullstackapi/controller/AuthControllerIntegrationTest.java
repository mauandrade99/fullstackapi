package br.com.teste.fullstackapi.controller;

import static org.hamcrest.Matchers.notNullValue;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.teste.fullstackapi.repository.UserRepository;
import br.com.teste.fullstackapi.security.dto.RegisterRequest;

@SpringBootTest // Carrega o contexto completo da aplicação Spring
@AutoConfigureMockMvc // Configura o MockMvc para fazer requisições HTTP falsas
@Transactional // Garante que cada teste rode em uma transação que será revertida (rollback) no final
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc; // Objeto para simular as requisições HTTP

    @Autowired
    private ObjectMapper objectMapper; // Para converter objetos Java em JSON

    @Autowired
    private UserRepository userRepository;

    @SuppressWarnings("unused") 
    @BeforeEach
    void setUp() {
        // Limpa o repositório antes de cada teste para garantir isolamento
        userRepository.deleteAll();
    }

    @Test
    void whenRegister_withValidData_shouldReturnToken() throws Exception {
        // --- Arrange ---
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNome("Integration Test User");
        registerRequest.setEmail("integration.test@email.com");
        registerRequest.setSenha("password123");

        // --- Act & Assert ---
        mockMvc.perform(post("/api/auth/register") // Simula um POST para o endpoint
                        .contentType(MediaType.APPLICATION_JSON) // Define o tipo de conteúdo
                        .content(objectMapper.writeValueAsString(registerRequest))) // Converte o objeto para JSON e o coloca no corpo
                .andExpect(status().isOk()) // Verifica se o status da resposta é 200 OK
                .andExpect(jsonPath("$.token", notNullValue())); // Verifica se a resposta JSON tem um campo "token" que não é nulo
    }
}