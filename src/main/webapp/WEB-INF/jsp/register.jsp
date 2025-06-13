<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Registro de Usuário</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
                        <div class="mb-3">
                            <label for="password" class="form-label">Senha</label>
                            <input type="password" class="form-control" id="password" required>
                        </div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
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
    document.getElementById('register-form').addEventListener('submit', function(event) {
        event.preventDefault();

        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        
        const errorMessageDiv = document.getElementById('error-message');
        const successMessageDiv = document.getElementById('success-message');
        const spinner = document.getElementById('register-spinner');


        spinner.classList.remove('d-none');
        errorMessageDiv.classList.add('d-none');
        successMessageDiv.classList.add('d-none');


        fetch('/api/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nome: name, email: email, senha: password })
        })
        .then(response => {
            if (response.status === 400 || response.status === 500) { 
                return response.json().then(err => { throw new Error('Erro ao registrar: ' + (err.details ? err.details.join(', ') : 'Tente novamente.'))});
            }
            if (!response.ok) {
                throw new Error('Ocorreu um erro ao tentar registrar.');
            }
            return response.json();
        })
        .then(data => {

            successMessageDiv.textContent = 'Registro realizado com sucesso! Redirecionando para o login...';
            successMessageDiv.classList.remove('d-none');

            localStorage.setItem('jwt_token', data.token);

            setTimeout(() => {
                window.location.href = '/login'; 
            }, 2000); 
        })
        .catch(error => {
            errorMessageDiv.textContent = error.message;
            errorMessageDiv.classList.remove('d-none');
        })
        .finally(() => {
            spinner.classList.add('d-none');
        });
    });
</script>

</body>
</html>