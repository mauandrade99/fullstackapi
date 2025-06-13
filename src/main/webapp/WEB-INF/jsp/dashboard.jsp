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
                    <nav aria-label="Paginação de usuários" class="mt-4 d-none" id="pagination-controls">
                        <ul class="pagination justify-content-center">
                            <li class="page-item" id="prev-page-item">
                                <a class="page-link" href="#" id="prev-page-btn">Anterior</a>
                            </li>
                            <li class="page-item disabled">
                                <span class="page-link" id="page-info">Página 1 de 1</span>
                            </li>
                            <li class="page-item" id="next-page-item">
                                <a class="page-link" href="#" id="next-page-btn">Próxima</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
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


    let currentPage = 0;
    const pageSize = 8; 

    function fetchUsersForAdmin(token, page = 0) {
        console.log('Buscando usuários para a página: ' + page);
        currentPage = page; 

        const usersList = document.getElementById('users-list');
        const loader = document.getElementById('users-loader');
        const paginationControls = document.getElementById('pagination-controls');

        loader.style.display = 'block';
        usersList.innerHTML = '';
        paginationControls.classList.add('d-none'); 

        const url = '/api/users?page=' + page + '&size=' + pageSize + '&sort=nome,asc';

        fetch(url, { headers: { 'Authorization': 'Bearer ' + token } })
        .then(function(res) { return res.json(); })
        .then(function(pageData) {
            loader.style.display = 'none';
            
            pageData.content.forEach(function(user) {
                const listItem = document.createElement('div'); 
                listItem.className = 'list-group-item d-flex justify-content-between align-items-center';

                const userData = parseJwt(token);
                const loggedInUserId = userData.userId;


                let deleteButtonHtml = '';
               
                if (user.id !== loggedInUserId) {
                    deleteButtonHtml = '<button class="btn btn-sm btn-danger" onclick="confirmUserDelete(' + user.id + ')"><i class="fas fa-trash"></i></button>';
                }

                listItem.innerHTML = 
                    '<a href="#" class="text-decoration-none text-dark flex-grow-1 user-select-link">' + user.nome + ' (' + user.email + ')' + '</a>' +
                    deleteButtonHtml;

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

            updatePaginationControls(pageData);
        })
        .catch(function(err) {
            console.error("Erro no fetch de usuários:", err);
            loader.innerHTML = '<div class="alert alert-danger">Erro ao carregar usuários.</div>';
        });
    }

    function updatePaginationControls(pageData) {
        const paginationControls = document.getElementById('pagination-controls');
        const prevPageItem = document.getElementById('prev-page-item');
        const nextPageItem = document.getElementById('next-page-item');
        const pageInfo = document.getElementById('page-info');

        paginationControls.classList.remove('d-none');

        pageInfo.textContent = 'Página ' + (pageData.number + 1) + ' de ' + pageData.totalPages;

        if (pageData.first) {
            prevPageItem.classList.add('disabled');
        } else {
            prevPageItem.classList.remove('disabled');
        }

        if (pageData.last) {
            nextPageItem.classList.add('disabled');
        } else {
            nextPageItem.classList.remove('disabled');
        }
    }

    function editAddress(address) {
        document.getElementById('modal-title').textContent = 'Editar Endereço';
        document.getElementById('address-form').reset();
        document.getElementById('address-id').value = address.id;
        document.getElementById('cep').value = address.cep;
        document.getElementById('numero').value = address.numero;
        document.getElementById('complemento').value = address.complemento;
        addressModal.show();
    }

    function confirmUserDelete(userId) {
        const confirmBtn = document.getElementById('confirm-delete-btn');
        const modalBody = document.querySelector('#confirm-delete-modal .modal-body');
        
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
                    
                    return res.text().then(text => { throw new Error('Erro ao excluir usuário: ' + text) });
                }
                
                fetchUsersForAdmin(token);

                document.getElementById('addresses-content').innerHTML = '';
                document.getElementById('addresses-user-info').innerHTML = '';
                document.getElementById('add-address-btn').classList.add('d-none');
            })
            .catch(function(err) { 
                alert(err.message); 
            });
        }
    }


    function deleteAddress(addressId, userId) {
        const confirmBtn = document.getElementById('confirm-delete-btn');

        confirmDeleteModal.show();

        confirmBtn.onclick = function() {

            confirmDeleteModal.hide();
            
            const token = localStorage.getItem('jwt_token');
            fetch('/api/users/' + userId + '/addresses/' + addressId, {
                method: 'DELETE',
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(function(res) {
                if (!res.ok) throw new Error('Erro ao excluir endereço.');

                fetchAndDisplayAddresses(userId, token);
            })
            .catch(function(err) { 
                alert(err.message); 
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


    document.addEventListener('DOMContentLoaded', function() {
        if (!token) {
            window.location.href = '/login';
            return;
        }

        const userDataFromToken = parseJwt(token);
        if (!userDataFromToken || !userDataFromToken.userId) {

            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
            return;
        }

        const loggedInUserId = userDataFromToken.userId;
        const isAdmin = userDataFromToken.authorities && userDataFromToken.authorities.includes('ROLE_ADMIN');


        fetch('/api/users/' + loggedInUserId, {
            headers: { 'Authorization': 'Bearer ' + token }
        })
        .then(function(response) {
            if (!response.ok) {
                throw new Error('Sessão inválida.');
            }
            return response.json();
        })
        .then(function(userProfile) {

            document.getElementById('welcome-message').innerHTML = '<h2>Bem-vindo, ' + userProfile.nome + '!</h2>';
            

            if (!isAdmin) {
                
                document.getElementById('admin-section').style.display = 'none';
                document.getElementById('address-column').className = 'col-md-12';
                document.getElementById('addresses-placeholder').textContent = '';
                document.getElementById('addresses-user-info').innerHTML = '<strong>Seus Endereços:</strong>';
                fetchAndDisplayAddresses(loggedInUserId, token);
            }
        })
        .catch(function(error) {
            console.error('Erro ao buscar perfil do usuário:', error);
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
        });

        document.getElementById('logout-button').addEventListener('click', function() {
            localStorage.removeItem('jwt_token');
            window.location.href = '/login';
        });

        document.getElementById('prev-page-btn').addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 0) {
                fetchUsersForAdmin(token, currentPage - 1);
            }
        });

        document.getElementById('next-page-btn').addEventListener('click', function(e) {
            e.preventDefault();

            fetchUsersForAdmin(token, currentPage + 1);
        });

        document.getElementById('add-address-btn').addEventListener('click', function() {
            console.log("Botão 'Adicionar Endereço' clicado. Resetando o modal.");

            document.getElementById('modal-title').textContent = 'Adicionar Novo Endereço';
            document.getElementById('address-form').reset();
            document.getElementById('address-id').value = ''; 
            document.getElementById('cep').readOnly = false;
            document.getElementById('modal-error').classList.add('d-none');
        });
        
        if (isAdmin) {
            fetchUsersForAdmin(token, 0);
        }

    });
</script>
    
</body>
</html>