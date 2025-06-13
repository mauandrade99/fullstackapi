package br.com.teste.fullstackapi.security;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import br.com.teste.fullstackapi.model.Address;
import br.com.teste.fullstackapi.model.User;
import br.com.teste.fullstackapi.repository.AddressRepository;

@Service("addressSecurityService")
public class AddressSecurityService {
    private final AddressRepository addressRepository;
    public AddressSecurityService(AddressRepository addressRepository) { this.addressRepository = addressRepository; }

    public boolean isOwner(Authentication authentication, Long addressId) {
        if (!(authentication.getPrincipal() instanceof User loggedInUser)) {
            return false;
        }
        Address address = addressRepository.findById(addressId).orElse(null);
        if (address == null || address.getUsuario() == null) {
            return false;
        }
        return loggedInUser.getId().equals(address.getUsuario().getId());
    }
}