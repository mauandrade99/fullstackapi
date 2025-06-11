package br.com.teste.fullstackapi.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.teste.fullstackapi.model.Address;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {
}