<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome para ícones -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="/dashboard">home</a>
        <button id="logout-button" class="btn btn-outline-light">Sair <i class="fas fa-sign-out-alt"></i></button>
    </div>
</nav>

<main class="container mt-4">
    <div id="welcome-message"></div>
    <hr>
    
    <div class="row g-4">
        <%-- Card da Esquerda: Lista de Usuários (Apenas para Admin) --%>
        <div class="col-md-6" id="admin-section">
            <div class="card h-100">
                <div class="card-header">
                    <h3><i class="fas fa-users"></i> Gerenciamento de Usuários (Admin)</h3>
                </div>
                <div class="card-body">
                    <div id="users-loader" class="text-center">
                        <div class="spinner-border" role="status"><span class="visually-hidden">Carregando...</span></div>
                    </div>
                    <ul class="list-group" id="users-list">
                        <%-- Itens da lista serão inseridos aqui via JavaScript --%>
                    </ul>
                </div>
            </div>
        </div>

        <%-- Card da Direita: Detalhes e Endereços do Usuário Selecionado --%>
        <div class="col-md-6">
            <div class="card h-100">
                <div class="card-header">
                    <h3><i class="fas fa-map-marker-alt"></i> Endereços do Usuário</h3>
                </div>
                <div class="card-body" id="addresses-section">
                    <div id="addresses-placeholder">
                        <p class="text-muted">Selecione um usuário na lista à esquerda para ver seus endereços (função de admin).</p>
                    </div>
                    <div id="addresses-loader" class="text-center d-none">
                        <div class="spinner-border text-secondary" role="status"><span class="visually-hidden">Carregando endereços...</span></div>
                    </div>
                    <div id="addresses-content">
                        <%-- Conteúdo dos endereços será inserido aqui --%>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const token = localStorage.getItem('jwt_token');
        if (!token) {
            window.location.href = '/login';
            return;
        }

        const userData = parseJwt(token);
        if (userData) {
            document.getElementById('welcome-message').innerHTML = `<h2>Bem-vindo, \${userData.sub}!</h2>`;
        }
        
        const isAdmin = userData.authorities && userData.authorities.includes('ROLE_ADMIN');

        // Se não for admin, busca os endereços do próprio usuário logado
        if (!isAdmin) {
            document.getElementById('admin-section').classList.add('d-none'); // Esconde a lista de usuários
            document.querySelector('.col-md-6').classList.replace('col-md-6', 'col-md-12'); // Faz o card de endereço ocupar a tela toda
            document.getElementById('addresses-placeholder').textContent = 'Carregando seus endereços...';
            fetchAndDisplayAddresses(userData.userId, token); // Supondo que o ID do usuário está no token
        } else {
            // Se for admin, busca a lista de usuários
            fetchUsersForAdmin(token);
        }

        document.getElementById('logout-button').addEventListener('click', function() {
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
        });
    });

    function parseJwt(token) {
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            // Adicionei o userId ao payload para facilitar. Você precisará ajustar o JwtService no backend.
            return payload;
        } catch (e) {
            return null;
        }
    }

    // Função para admin buscar e listar usuários
    function fetchUsersForAdmin(token) {
        const usersList = document.getElementById('users-list');
        const loader = document.getElementById('users-loader');

        fetch('/api/users?sort=nome,asc', { headers: { 'Authorization': 'Bearer ' + token } })
        .then(res => res.json())
        .then(data => {
            loader.classList.add('d-none');
            usersList.innerHTML = '';
            data.content.forEach(user => {
                const listItem = document.createElement('a');
                listItem.href = '#';
                listItem.className = 'list-group-item list-group-item-action';
                listItem.textContent = `\${user.nome} (\${user.email})`;
                listItem.dataset.userId = user.id; // Guarda o ID do usuário no elemento

                listItem.innerHTML = `<td>\${user.id}&nbsp;&nbsp;</td><td>\${user.nome}</td>`;

                // Adiciona o evento de clique para buscar os endereços
                listItem.addEventListener('click', (e) => {
                    e.preventDefault();
                    document.querySelectorAll('#users-list .list-group-item-action').forEach(item => item.classList.remove('active'));
                    listItem.classList.add('active');
                    fetchAndDisplayAddresses(user.id, token);
                });
                usersList.appendChild(listItem);
            });
        }).catch(err => {
            loader.innerHTML = '<div class="alert alert-danger">Erro ao carregar usuários.</div>';
        });
    }

    // Função para buscar e exibir os endereços de um usuário específico
    function fetchAndDisplayAddresses(userId, token) {
        const addressesPlaceholder = document.getElementById('addresses-placeholder');
        const addressesLoader = document.getElementById('addresses-loader');
        const addressesContent = document.getElementById('addresses-content');

        addressesPlaceholder.classList.add('d-none');
        addressesLoader.classList.remove('d-none');
        addressesContent.innerHTML = '';

        fetch(`/api/users/\${userId}/addresses`, { headers: { 'Authorization': 'Bearer ' + token } })
        .then(res => res.json())
        .then(addresses => {
            addressesLoader.classList.add('d-none');
            if (addresses.length === 0) {
                addressesContent.innerHTML = '<p class="text-muted">Nenhum endereço cadastrado para este usuário.</p>';
            } else {
                const addressList = document.createElement('ul');
                addressList.className = 'list-group';
                addresses.forEach(addr => {
                    const item = document.createElement('li');
                    item.className = 'list-group-item';
                    item.innerHTML = `
                        <strong>\${addr.logradouro}, \${addr.numero}</strong><br>
                        \${addr.bairro} - \${addr.cidade}/\${addr.estado}<br>
                        CEP: \${addr.cep}
                    `;
                    addressList.appendChild(item);
                });
                addressesContent.appendChild(addressList);
            }
        }).catch(err => {
            addressesLoader.classList.add('d-none');
            addressesContent.innerHTML = '<div class="alert alert-danger">Erro ao carregar endereços.</div>';
        });
    }
</script>

</body>
</html>