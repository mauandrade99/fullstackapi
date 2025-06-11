package br.com.teste.fullstackapi.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.teste.fullstackapi.model.Address;
import br.com.teste.fullstackapi.service.AddressService;

@RestController
@RequestMapping("/api/users/{userId}/addresses") // Endpoints de endereço são aninhados sob usuários
public class AddressController {

    private final AddressService addressService;

    public AddressController(AddressService addressService) {
        this.addressService = addressService;
    }

    @PostMapping
    public ResponseEntity<Address> createAddress(@PathVariable Long userId, @RequestBody AddressCreateRequest request) {
        Address newAddress = addressService.createAddressForUser(
            userId,
            request.getCep(),
            request.getNumero(),
            request.getComplemento()
        );
        return ResponseEntity.ok(newAddress);
    }
}

// Classe DTO para a requisição de criação de endereço
class AddressCreateRequest {
    private String cep;
    private String numero;
    private String complemento;
    // Getters e Setters
    public String getCep() { return cep; }
    public void setCep(String cep) { this.cep = cep; }
    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }
    public String getComplemento() { return complemento; }
    public void setComplemento(String complemento) { this.complemento = complemento; }
}