package br.com.teste.fullstackapi.controller;
    
import java.util.List;

import org.springframework.http.ResponseEntity; // 1. IMPORTA O DTO CORRETO
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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
    @PreAuthorize("hasRole('ADMIN') or @addressSecurityService.isOwner(authentication, #addressId)")
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

    @PutMapping("/{addressId}")
    @PreAuthorize("hasRole('ADMIN') or @addressSecurityService.isOwner(authentication, #addressId)")
    public ResponseEntity<Address> updateAddress(@PathVariable Long userId, @PathVariable Long addressId, @RequestBody Address addressDetails) {
        Address updatedAddress = addressService.updateAddress(addressId, addressDetails);
        return ResponseEntity.ok(updatedAddress);
    }

    @DeleteMapping("/{addressId}")
    @PreAuthorize("hasRole('ADMIN') or @addressSecurityService.isOwner(authentication, #addressId)")
    public ResponseEntity<Void> deleteAddress(@PathVariable Long userId, @PathVariable Long addressId) {
        addressService.deleteAddress(addressId);
        return ResponseEntity.noContent().build(); // Retorna 204 No Content
    }

    @GetMapping
    // Regra de segurança: só o próprio usuário ou um admin pode ver os endereços.
    @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
    public ResponseEntity<List<Address>> getAddressesByUserId(@PathVariable Long userId) {
        List<Address> addresses = addressService.findAddressesByUserId(userId);
        return ResponseEntity.ok(addresses);
    }
}