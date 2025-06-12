package br.com.teste.fullstackapi.dto;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

@SuppressWarnings("unused")
public class AddressUpdateRequest {
    @NotEmpty @Size(min = 8, max = 8)
    private String cep;
    @NotEmpty
    private String numero;
    private String complemento;
    // Getters e Setters
}