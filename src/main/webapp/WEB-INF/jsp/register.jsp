<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Registro de Usuário</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css">
</head>
<body class="bg-light">

<div class="container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-6 col-lg-5">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title text-center mb-4">Criar Conta</h3>
                    <form id="register-form">
                        <div class="mb-3">
                            <label for="name" class="form-label">Nome Completo</label>
                            <input type="text" class="form-control" id="name" required>
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" required>
                        </div>

                        <!-- Campo de Senha com o ícone -->
                        <div class="mb-3">
                            <label for="password" class="form-label">Senha</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="password" required>
                                <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                    <i class="fas fa-eye" id="togglePasswordIcon"></i>
                                </button>
                            </div>
                        </div>

                        <!-- Campo de Confirmação de Senha -->
                        <div class="mb-3">
                            <label for="confirm-password" class="form-label">Confirmar Senha</label>
                            <input type="password" class="form-control" id="confirm-password" required>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary" id="register-btn">
                                <span id="register-spinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                                Registrar
                            </button>
                        </div>
                        <div id="error-message" class="alert alert-danger mt-3 d-none" role="alert"></div>
                        <div id="success-message" class="alert alert-success mt-3 d-none" role="alert"></div>
                    </form>
                    <div class="text-center mt-3">
                        <p>Já tem uma conta? <a href="/login">Faça login aqui</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript -->
<script>
    const registerForm = document.getElementById('register-form');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirm-password');
    const togglePasswordBtn = document.getElementById('togglePassword');
    const togglePasswordIcon = document.getElementById('togglePasswordIcon');
    const errorMessageDiv = document.getElementById('error-message');
    const successMessageDiv = document.getElementById('success-message');
    const spinner = document.getElementById('register-spinner');

    // --- Lógica para Mostrar/Ocultar Senha ---
    togglePasswordBtn.addEventListener('click', function () {
        // Alterna o tipo do input entre 'password' e 'text'
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        confirmPasswordInput.setAttribute('type', type); // Também alterna o campo de confirmação

        // Alterna o ícone do olho
        togglePasswordIcon.classList.toggle('fa-eye');
        togglePasswordIcon.classList.toggle('fa-eye-slash');
    });


    // --- Lógica do Formulário de Registro ---
    registerForm.addEventListener('submit', function(event) {
        event.preventDefault();

        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;
        const password = passwordInput.value;
        const confirmPassword = confirmPasswordInput.value;
        
        // Esconde mensagens antigas
        errorMessageDiv.classList.add('d-none');
        successMessageDiv.classList.add('d-none');

        // --- Validação de Confirmação de Senha (no lado do cliente) ---
        if (password !== confirmPassword) {
            errorMessageDiv.textContent = 'As senhas não coincidem. Por favor, tente novamente.';
            errorMessageDiv.classList.remove('d-none');
            return; // Interrompe o envio do formulário
        }

        // Feedback visual
        spinner.classList.remove('d-none');
        document.getElementById('register-btn').disabled = true;

        // Consumo da API REST para registro
        fetch('/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ nome: name, email: email, senha: password })
        })
        .then(function(response) {
            if (!response.ok) {
                return response.json().then(function(err) { 
                    throw new Error(err.details ? err.details.join(', ') : 'Erro ao registrar.');
                });
            }
            return response.json();
        })
        .then(function(data) {
            // Sucesso!
            successMessageDiv.textContent = 'Registro realizado com sucesso! Redirecionando para o login...';
            successMessageDiv.classList.remove('d-none');
            setTimeout(function() {
                window.location.href = '/login'; 
            }, 2000);
        })
        .catch(function(error) {
            errorMessageDiv.textContent = error.message;
            errorMessageDiv.classList.remove('d-none');
        })
        .finally(function() {
            spinner.classList.add('d-none');
            document.getElementById('register-btn').disabled = false;
        });
    });
</script>


</body>
</html>