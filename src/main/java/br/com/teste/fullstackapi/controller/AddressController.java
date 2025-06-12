package br.com.teste.fullstackapi.controller;
    
import org.springframework.http.ResponseEntity; // 1. IMPORTA O DTO CORRETO
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody; // 2. IMPORTA O @Valid
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.teste.fullstackapi.dto.AddressCreateRequest;
import br.com.teste.fullstackapi.model.Address;
import br.com.teste.fullstackapi.service.AddressService;
import jakarta.validation.Valid;
    
@RestController
@RequestMapping("/api/users/{userId}/addresses")
public class AddressController {
    
    private final AddressService addressService;

    public AddressController(AddressService addressService) {
        this.addressService = addressService;
    }

    @PostMapping
    public ResponseEntity<Address> createAddress(
            @PathVariable Long userId, 
            @Valid @RequestBody AddressCreateRequest request // 3. USA O DTO E ATIVA A VALIDAÇÃO
    ) {
        Address newAddress = addressService.createAddressForUser(
            userId,
            request.getCep(),
            request.getNumero(),
            request.getComplemento()
        );
        return ResponseEntity.ok(newAddress);
    }
}