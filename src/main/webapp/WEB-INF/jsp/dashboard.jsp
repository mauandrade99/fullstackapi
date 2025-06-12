<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome para ícones -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="/dashboard"><i class="fas fa-home"></i> Home</a>
        <button id="logout-button" class="btn btn-outline-light">Sair <i class="fas fa-sign-out-alt"></i></button>
    </div>
</nav>

<main class="container mt-4">
    <div id="welcome-message"></div>
    <hr>
    
    <div class="row g-4">
        <!-- Card da Esquerda: Lista de Usuários (Apenas para Admin) -->
        <div class="col-md-5" id="admin-section">
            <div class="card h-100">
                <div class="card-header">
                    <h3><i class="fas fa-users"></i> Usuários</h3>
                </div>
                <div class="card-body">
                    <div id="users-loader" class="text-center">
                        <div class="spinner-border" role="status"><span class="visually-hidden">Carregando...</span></div>
                    </div>
                    <ul class="list-group" id="users-list">
                        <!-- Itens da lista serão inseridos aqui -->
                    </ul>
                </div>
            </div>
        </div>

        <!-- Card da Direita: Detalhes e Endereços do Usuário -->
        <div class="col-md-7" id="address-column">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3 class="mb-0"><i class="fas fa-map-marker-alt"></i> Endereços</h3>
                    <button class="btn btn-primary d-none" data-bs-toggle="modal" data-bs-target="#address-modal" id="add-address-btn">
                        <i class="fas fa-plus"></i> 
                    </button>
                </div>
                <div class="card-body" id="addresses-section">
                    <div id="addresses-user-info"></div>
                    <div id="addresses-placeholder"><p class="text-muted">Selecione um usuário na lista (função de admin) ou veja seus próprios endereços.</p></div>
                    <div id="addresses-loader" class="text-center d-none">
                        <div class="spinner-border text-secondary" role="status"><span class="visually-hidden">Carregando...</span></div>
                    </div>
                    <div id="addresses-content" class="mt-3"></div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Modal de Confirmação de Exclusão -->
<div class="modal fade" id="confirm-delete-modal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header text-black">
                <h5 class="modal-title">Confirmar Exclusão</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Tem certeza que deseja excluir este endereço? Esta ação não pode ser desfeita.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="confirm-delete-btn">Sim, Excluir</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal para Adicionar/Editar Endereço -->
<div class="modal fade" id="address-modal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modal-title">Adicionar Novo Endereço</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="address-form">
                    <input type="hidden" id="address-id">
                    <div class="mb-3">
                        <label for="cep" class="form-label">CEP (apenas números)</label>
                        <input type="text" class="form-control" id="cep" required maxlength="8">
                    </div>
                    <div class="mb-3">
                        <label for="numero" class="form-label">Número</label>
                        <input type="text" class="form-control" id="numero" required>
                    </div>
                    <div class="mb-3">
                        <label for="complemento" class="form-label">Complemento</label>
                        <input type="text" class="form-control" id="complemento">
                    </div>
                    <div id="modal-error" class="alert alert-danger d-none"></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="save-address-btn">Salvar</button>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Variáveis globais para o script
    const token = localStorage.getItem('jwt_token');
    let currentUserIdForAddress = null; // Guarda o ID do usuário cujos endereços estamos vendo/editando
    const addressModal = new bootstrap.Modal(document.getElementById('address-modal'));
    const confirmDeleteModal = new bootstrap.Modal(document.getElementById('confirm-delete-modal'));

    // Função para decodificar o token JWT
    function parseJwt(token) {
        try {
            return JSON.parse(atob(token.split('.')[1]));
        } catch (e) {
            return null;
        }
    }

    // Função para buscar e exibir os endereços de um usuário
    function fetchAndDisplayAddresses(userId, token) {
        const addressesPlaceholder = document.getElementById('addresses-placeholder');
        const addressesLoader = document.getElementById('addresses-loader');
        const addressesContent = document.getElementById('addresses-content');
        const addAddressBtn = document.getElementById('add-address-btn');

        currentUserIdForAddress = userId;
        addressesPlaceholder.classList.add('d-none');
        addressesLoader.classList.remove('d-none');
        addressesContent.innerHTML = '';
        addAddressBtn.classList.remove('d-none');

        fetch('/api/users/' + userId + '/addresses', 
        { 
            headers: { 'Authorization': 'Bearer ' + token } 
        })
        .then(function(res) { return res.json(); })
        .then(function(addresses) {
            addressesLoader.classList.add('d-none');
            if (addresses.length === 0) {
                addressesContent.innerHTML = '<p class="text-muted">Nenhum endereço cadastrado.</p>';
            } else {
                const addressList = document.createElement('ul');
                addressList.className = 'list-group';
                addresses.forEach(function(addr) {
                    const item = document.createElement('li');
                    item.className = 'list-group-item d-flex justify-content-between align-items-center';
                    
                    // Usando concatenação de strings
                    item.innerHTML = 
                        '<div>' +
                            '<strong>' + addr.logradouro + ', ' + addr.numero + '</strong>' + (addr.complemento == ''?'':', '+addr.complemento) + '<br>' +
                            addr.bairro + ' - ' + addr.cidade + '/' + addr.estado + '<br>' +
                            'CEP: ' + addr.cep +
                        '</div>' +
                        '<div>' +
                            '<button class="btn btn-sm btn-primary me-2" onclick=\'editAddress(' + JSON.stringify(addr) + ')\'><i class="fas fa-edit"></i></button>' +
                            '<button class="btn btn-sm btn-danger" onclick="deleteAddress(' + addr.id + ', ' + userId + ')"><i class="fas fa-trash"></i></button>' +
                        '</div>';
                    addressList.appendChild(item);
                });
                addressesContent.appendChild(addressList);
            }
        }).catch(function(err) {
            addressesLoader.classList.add('d-none');
            addressesContent.innerHTML = '<div class="alert alert-danger">Erro ao carregar endereços.</div>';
        });
    }

    // Função para admin buscar e listar usuários
    function fetchUsersForAdmin(token) {
        const usersList = document.getElementById('users-list');
        const loader = document.getElementById('users-loader');
        fetch('/api/users?sort=nome,asc', { headers: { 'Authorization': 'Bearer ' + token } })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            loader.classList.add('d-none');
            usersList.innerHTML = '';
            data.content.forEach(function(user) {
                const listItem = document.createElement('div'); // Mudar para div para conter mais elementos
                listItem.className = 'list-group-item d-flex justify-content-between align-items-center';

                const userData = parseJwt(token);
                const loggedInUserId = userData.userId;

                // Usando concatenação de strings
                let deleteButtonHtml = '';
                // Regra de JS: não mostra o botão de excluir se o ID do usuário da lista for igual ao ID do admin logado
                if (user.id !== loggedInUserId) {
                    deleteButtonHtml = '<button class="btn btn-sm btn-danger" onclick="confirmUserDelete(' + user.id + ')"><i class="fas fa-trash"></i></button>';
                }

                listItem.innerHTML = 
                    '<a href="#" class="text-decoration-none text-dark flex-grow-1 user-select-link">' + user.nome + ' (' + user.email + ')' + '</a>' +
                    deleteButtonHtml;

                // Adiciona o listener para selecionar o usuário
                listItem.querySelector('.user-select-link').addEventListener('click', function(e) {
                    e.preventDefault();
                    document.querySelectorAll('#users-list .list-group-item').forEach(function(item) {
                        item.classList.remove('active');
                    });
                    listItem.classList.add('active');
                    document.getElementById('addresses-user-info').innerHTML = '<strong>Exibindo endereços de: ' + user.nome + '</strong>';
                    fetchAndDisplayAddresses(user.id, token);
                });
                
                usersList.appendChild(listItem);
            });
        }).catch(function(err) {
            loader.innerHTML = '<div class="alert alert-danger">Erro ao carregar usuários.</div>';
        });
    }

    // Funções para o modal
    function editAddress(address) {
        document.getElementById('modal-title').textContent = 'Editar Endereço';
        document.getElementById('address-form').reset();
        document.getElementById('address-id').value = address.id;
        document.getElementById('cep').value = address.cep;
        document.getElementById('numero').value = address.numero;
        document.getElementById('complemento').value = address.complemento;
        addressModal.show();
    }

    // Adicione esta nova função ao seu script
    function confirmUserDelete(userId) {
        const confirmBtn = document.getElementById('confirm-delete-btn');
        const modalBody = document.querySelector('#confirm-delete-modal .modal-body');
        
        // Customiza o modal para a exclusão de usuário
        modalBody.innerHTML = '<p>Tem certeza que deseja excluir este <strong>usuário</strong>? Todos os seus endereços também serão excluídos. Esta ação não pode ser desfeita.</p>';
        confirmDeleteModal.show();
        
        confirmBtn.onclick = function() {
            confirmDeleteModal.hide();
            
            const token = localStorage.getItem('jwt_token');
            fetch('/api/users/' + userId, {
                method: 'DELETE',
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(function(res) {
                if (!res.ok) {
                    // Se houver um corpo de erro, tente lê-lo
                    return res.text().then(text => { throw new Error('Erro ao excluir usuário: ' + text) });
                }
                // Se for bem-sucedido, não há corpo (204 No Content)
                // Atualiza a lista de usuários para refletir a exclusão
                fetchUsersForAdmin(token);
                // Limpa a seção de endereços, já que o usuário foi removido
                document.getElementById('addresses-content').innerHTML = '';
                document.getElementById('addresses-user-info').innerHTML = '';
                document.getElementById('add-address-btn').classList.add('d-none');
            })
            .catch(function(err) { 
                alert(err.message); 
            });
        }
    }

    // Substitua a função deleteAddress existente por esta
    function deleteAddress(addressId, userId) {
        const confirmBtn = document.getElementById('confirm-delete-btn');
        
        // Abre o modal de confirmação
        confirmDeleteModal.show();
        
        // Adiciona um listener de clique ao botão de confirmação do modal.
        // Usamos .onclick para substituir qualquer listener anterior e evitar múltiplos deletes.
        confirmBtn.onclick = function() {
            // Esconde o modal antes de fazer a chamada
            confirmDeleteModal.hide();
            
            const token = localStorage.getItem('jwt_token');
            fetch('/api/users/' + userId + '/addresses/' + addressId, {
                method: 'DELETE',
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(function(res) {
                if (!res.ok) throw new Error('Erro ao excluir endereço.');
                // Atualiza a lista de endereços após a exclusão bem-sucedida
                fetchAndDisplayAddresses(userId, token);
            })
            .catch(function(err) { 
                alert(err.message); // Mantém um alerta simples para o erro de exclusão
            });
        }
    }

    const saveBtn = document.getElementById('save-address-btn');
    if (saveBtn) {
        saveBtn.addEventListener('click', function() {
            console.log("Botão 'Salvar' do modal clicado.");
            const addressId = document.getElementById('address-id').value;
            const cep = document.getElementById('cep').value;
            const numero = document.getElementById('numero').value;
            const complemento = document.getElementById('complemento').value;
            const modalError = document.getElementById('modal-error');
            
            modalError.classList.add('d-none');
            
            let url = '/api/users/' + currentUserIdForAddress + '/addresses';
            let method = 'POST';
            let body = { cep: cep, numero: numero, complemento: complemento };

            if (addressId) {
                url += '/' + addressId;
                method = 'PUT';
                body = { cep: cep, numero: numero, complemento: complemento };
            }

            fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
                body: JSON.stringify(body)
            })
            .then(function(res) {
                if (!res.ok) {
                    return res.json().then(function(err) { 
                        throw new Error(err.details ? err.details.join(', ') : 'Erro ao salvar. Verifique os dados.'); 
                    });
                }
                // Para POST, a resposta pode ser 201 Created, para PUT 200 OK.
                // Não precisamos necessariamente do corpo da resposta aqui.
                const addressModal = bootstrap.Modal.getInstance(document.getElementById('address-modal'));
                addressModal.hide();
                fetchAndDisplayAddresses(currentUserIdForAddress, token);
            })
            .catch(function(err) {
                console.error("Erro ao salvar endereço:", err);
                modalError.textContent = err.message;
                modalError.classList.remove('d-none');
            });
        });
    } else {
        console.error("Botão 'save-address-btn' não encontrado!");
    }


    // Ponto de entrada do script que roda quando a página carrega
    // Substitua o seu listener 'DOMContentLoaded' por este código completo.
    document.addEventListener('DOMContentLoaded', function() {
        if (!token) {
            window.location.href = '/login';
            return;
        }

        const userDataFromToken = parseJwt(token);
        if (!userDataFromToken || !userDataFromToken.userId) {
            // Se o token for inválido ou não tiver o ID, desloga
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
            return;
        }

        const loggedInUserId = userDataFromToken.userId;
        const isAdmin = userDataFromToken.authorities && userDataFromToken.authorities.includes('ROLE_ADMIN');

        // --- NOVA LÓGICA PARA BUSCAR O NOME DO USUÁRIO ---
        // Faz uma chamada à API para obter os detalhes do usuário logado
        fetch('/api/users/' + loggedInUserId, {
            headers: { 'Authorization': 'Bearer ' + token }
        })
        .then(function(response) {
            if (!response.ok) {
                // Se não conseguir buscar o usuário, desloga por segurança
                throw new Error('Sessão inválida.');
            }
            return response.json();
        })
        .then(function(userProfile) {
            // Agora temos o objeto completo do usuário, incluindo o nome
            document.getElementById('welcome-message').innerHTML = '<h2>Bem-vindo, ' + userProfile.nome + '!</h2>';
            
            // Continua a lógica original após buscar o perfil com sucesso
            if (isAdmin) {
                fetchUsersForAdmin(token);
            } else {
                document.getElementById('admin-section').style.display = 'none';
                document.getElementById('address-column').className = 'col-md-12';
                document.getElementById('addresses-placeholder').textContent = '';
                document.getElementById('addresses-user-info').innerHTML = '<strong>Seus Endereços:</strong>';
                fetchAndDisplayAddresses(loggedInUserId, token);
            }
        })
        .catch(function(error) {
            console.error('Erro ao buscar perfil do usuário:', error);
            // Se houver qualquer erro (ex: token expirado), limpa e redireciona para o login
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
        });
        // ---------------------------------------------------

        // Listeners de eventos para os botões (permanecem os mesmos)
        document.getElementById('logout-button').addEventListener('click', function() {
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
        });
        // ... outros listeners para o modal de endereço ...
    });
</script>
    
</body>
</html>