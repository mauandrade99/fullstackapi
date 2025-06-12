package br.com.teste.fullstackapi.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.teste.fullstackapi.model.Address;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByUsuarioId(Long usuarioId); // Adicionar este método
}