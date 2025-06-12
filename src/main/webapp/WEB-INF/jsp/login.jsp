<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-6 col-lg-4">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title text-center mb-4">Login</h3>
                    <form id="login-form">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Senha</label>
                            <input type="password" class="form-control" id="password" required>
                        </div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
                                <span id="login-spinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                                Entrar
                            </button>
                        </div>
                        <div id="error-message" class="alert alert-danger mt-3 d-none" role="alert"></div>
                    </form>
                    <div class="text-center mt-3">
                        <p>Não tem uma conta? <a href="/register">Registre-se aqui</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS (opcional, mas recomendado) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('login-form').addEventListener('submit', function(event) {
        event.preventDefault(); // Impede o envio tradicional do formulário

        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const errorMessageDiv = document.getElementById('error-message');
        const spinner = document.getElementById('login-spinner');

        // Feedback visual: mostra o loader e esconde o erro
        spinner.classList.remove('d-none');
        errorMessageDiv.classList.add('d-none');

        // 4. Consumo da API REST com fetch
        fetch('/api/auth/authenticate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email: email, senha: password })
        })
        .then(response => {
            if (!response.ok) {
                // Se a resposta não for 2xx, lança um erro para ser pego pelo .catch
                throw new Error('Email ou senha inválidos.');
            }
            return response.json();
        })
        .then(data => {
            // Sucesso! Salva o token e redireciona para o dashboard
            localStorage.setItem('jwt_token', data.token);
            window.location.href = '/dashboard'; // Redireciona para a página do dashboard
        })
        .catch(error => {
            // 5. Feedback visual de erro
            errorMessageDiv.textContent = error.message;
            errorMessageDiv.classList.remove('d-none');
        })
        .finally(() => {
            // Esconde o loader, independentemente do resultado
            spinner.classList.add('d-none');
        });
    });
</script>
</body>
</html>