// src/main/java/br/com/teste/fullstackapi/dto/AddressCreateRequest.java
package br.com.teste.fullstackapi.dto; // <-- O pacote correto

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

// A classe agora é pública e independente
public class AddressCreateRequest {
    
    @NotEmpty(message = "O CEP não pode ser vazio.")
    @Size(min = 8, max = 8, message = "O CEP deve ter exatamente 8 caracteres.")
    private String cep;
    
    @NotEmpty(message = "O número não pode ser vazio.")
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

