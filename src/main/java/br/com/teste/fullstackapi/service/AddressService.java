package br.com.teste.fullstackapi.service;

import java.util.List;

import org.springframework.stereotype.Service;

import br.com.teste.fullstackapi.client.ViaCepClient;
import br.com.teste.fullstackapi.client.dto.ViaCepResponse;
import br.com.teste.fullstackapi.model.Address;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.repository.AddressRepository;
import br.com.teste.fullstackapi.repository.UserRepository;

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

    public Address updateAddress(Long addressId, Address addressDetails) {
        // Busca o endereço existente no banco
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Endereço não encontrado com o id: " + addressId));

        // Verifica se o CEP foi alterado
        String newCep = addressDetails.getCep().replaceAll("-", "");
        if (!newCep.equals(address.getCep())) {
            // Se o CEP mudou, consulta o ViaCEP novamente
            ViaCepResponse viaCepResponse = viaCepClient.getEnderecoByCep(newCep);
            if (viaCepResponse == null || viaCepResponse.isErro()) {
                throw new RuntimeException("O novo CEP informado é inválido ou não foi encontrado!");
            }
            // Atualiza todos os dados do endereço com base na resposta do ViaCEP
            address.setCep(newCep);
            address.setLogradouro(viaCepResponse.getLogradouro());
            address.setBairro(viaCepResponse.getBairro());
            address.setCidade(viaCepResponse.getLocalidade());
            address.setEstado(viaCepResponse.getUf());
        }

        // Sempre atualiza o número e o complemento, que são fornecidos pelo usuário
        address.setNumero(addressDetails.getNumero());
        address.setComplemento(addressDetails.getComplemento());

        // Salva o endereço atualizado (com dados do ViaCEP se o CEP mudou)
        return addressRepository.save(address);
    }

    public void deleteAddress(Long addressId) {
        if (!addressRepository.existsById(addressId)) {
            throw new RuntimeException("Endereço não encontrado com o id: " + addressId);
        }
        addressRepository.deleteById(addressId);
    }

    public List<Address> findAddressesByUserId(Long userId) {
    if (!userRepository.existsById(userId)) {
        throw new RuntimeException("Usuário não encontrado!");
    }
    return addressRepository.findByUsuarioId(userId);
}
}