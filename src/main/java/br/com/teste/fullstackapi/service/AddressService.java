package br.com.teste.fullstackapi.service;

import br.com.teste.fullstackapi.client.ViaCepClient;
import br.com.teste.fullstackapi.client.dto.ViaCepResponse;
import br.com.teste.fullstackapi.model.Address;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.repository.AddressRepository;
import br.com.teste.fullstackapi.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class AddressService {

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final ViaCepClient viaCepClient;

    public AddressService(AddressRepository addressRepository, UserRepository userRepository, ViaCepClient viaCepClient) {
        this.addressRepository = addressRepository;
        this.userRepository = userRepository;
        this.viaCepClient = viaCepClient;
    }

    public Address createAddressForUser(Long userId, String cep, String numero, String complemento) {
        // 1. Busca o usuário que será o dono do endereço
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado!")); // Trocaremos por uma exceção customizada depois

        // 2. Consulta o ViaCEP para obter os dados do endereço
        ViaCepResponse viaCepResponse = viaCepClient.getEnderecoByCep(cep);
        
        // 3. Valida a resposta do ViaCEP
        if (viaCepResponse == null || viaCepResponse.isErro()) {
            throw new RuntimeException("CEP inválido ou não encontrado!");
        }

        // 4. Cria e preenche a nossa entidade Address
        Address newAddress = new Address();
        newAddress.setCep(viaCepResponse.getCep().replaceAll("-", "")); // Remove o traço
        newAddress.setLogradouro(viaCepResponse.getLogradouro());
        newAddress.setBairro(viaCepResponse.getBairro());
        newAddress.setCidade(viaCepResponse.getLocalidade());
        newAddress.setEstado(viaCepResponse.getUf());
        newAddress.setNumero(numero); // Usa o número fornecido pelo usuário
        newAddress.setComplemento(complemento); // Usa o complemento fornecido pelo usuário
        newAddress.setUsuario(user); // Associa o endereço ao usuário

        // 5. Salva o novo endereço no banco
        return addressRepository.save(newAddress);
    }
}